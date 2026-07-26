#!/usr/bin/env python3
"""Market fiyatlarını çeker ve `lib/data/price_book.dart` dosyasını üretir.

Akış:

1. Katalogdaki her ürün tipi için marketin kendi aramasını çağırır.
2. Dönen ürünlerden marka + çeşit + gramaj birebir tutanları seçer.
3. Aynı satırda birden fazla ürün varsa stokta olan ve en ucuz olanı alır.
4. Kalan (tip, marka) satırları için markanın adıyla hedefli arama yapar.
5. Sonucu Dart fiyat defterine yazar.

Örnek::

    python3 tools/price_sync/sync.py                 # bütün marketler
    python3 tools/price_sync/sync.py --markets sok   # tek market
    python3 tools/price_sync/sync.py --offline       # yalnızca önbellek

Ağ erişimi olmayan marketler otomatik atlanır; önceki fiyat defteri korunur.
"""

from __future__ import annotations

import argparse
import json
import sys
import time
from concurrent.futures import ThreadPoolExecutor
from dataclasses import asdict
from pathlib import Path

if __package__ in (None, ''):  # doğrudan `python3 tools/price_sync/sync.py`
    sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
    from price_sync.catalog import (  # noqa: E402
        GENERIC_BRAND, REPO, load_catalog, product_id, slug,
    )
    from price_sync.emit import write_dart  # noqa: E402
    from price_sync.markets import ADAPTERS, FetchError  # noqa: E402
    from price_sync.matching import (  # noqa: E402
        Offer, brand_of, brand_position, choose_shared_variant, matches_rule,
        variant_tokens,
    )
    from price_sync.rules import RULES  # noqa: E402
else:
    from .catalog import GENERIC_BRAND, REPO, load_catalog, product_id, slug
    from .emit import write_dart
    from .markets import ADAPTERS, FetchError
    from .matching import (
        Offer, brand_of, brand_position, choose_shared_variant, matches_rule,
        variant_tokens,
    )
    from .rules import RULES

DEFAULT_OUT = REPO / 'lib' / 'data' / 'price_book.dart'
DEFAULT_CACHE = REPO / '.price_sync_cache'


class SearchCache:
    """Arama sonuçlarını diske yazar: eşleştirmeyi yeniden ağ olmadan denerken."""

    def __init__(self, directory: Path, offline: bool = False):
        self.directory = directory
        self.offline = offline
        directory.mkdir(parents=True, exist_ok=True)

    def _path(self, market: str, term: str, page: int) -> Path:
        return self.directory / f'{market}__{slug(term)}__{page}.json'

    def offers(self, market: str, term: str, page: int) -> list[Offer] | None:
        path = self._path(market, term, page)
        if not path.exists():
            return None
        raw = json.loads(path.read_text(encoding='utf-8'))
        return [Offer(**item) for item in raw]

    def store(self, market: str, term: str, page: int, offers: list[Offer]) -> None:
        self._path(market, term, page).write_text(
            json.dumps([asdict(o) for o in offers], ensure_ascii=False),
            encoding='utf-8',
        )


def fetch(cache: SearchCache, market: str, term: str, page: int,
          delay: float) -> list[Offer]:
    cached = cache.offers(market, term, page)
    if cached is not None:
        return cached
    if cache.offline:
        return []
    adapter = ADAPTERS[market]
    try:
        offers = adapter.search(term, page)
    except FetchError as exc:
        print(f'  ! {market} "{term}" sayfa {page}: {exc}', file=sys.stderr)
        return []
    cache.store(market, term, page, offers)
    if delay:
        time.sleep(delay)
    return offers


def gather(cache: SearchCache, market: str, terms: list[tuple[str, int]],
           jobs: int, delay: float) -> dict[tuple[str, int], list[Offer]]:
    with ThreadPoolExecutor(max_workers=jobs) as pool:
        results = pool.map(
            lambda item: (item, fetch(cache, market, item[0], item[1], delay)),
            terms,
        )
        return dict(results)


def brand_candidates(offers: list[Offer], brand: str,
                     brands: list[str]) -> list[Offer]:
    """Ürün adı bu markayı gösteren teklifler.

    Marka adı ürün adında geçmeli ve adda daha uzun bir marka adı bulunmamalı:
    "Nuh'un Ankara Makarna" satırı `Ankara` markasına yazılmaz.
    """
    return [
        o for o in offers
        if brand_position(o.name, brand) >= 0
        and (brand_of(o.name, brands) or brand) == brand
    ]


def build_market(market: str, catalog, cache: SearchCache, jobs: int,
                 delay: float, targeted: bool) -> dict[str, list[Offer]]:
    """Bir marketin katalog satırlarına uyan ürünlerini toplar."""
    adapter = ADAPTERS[market]
    pages = [(RULES[t.id]['term'], page)
             for t in catalog.types
             for page in range(1, adapter.page_limit + 1)]
    fetched = gather(cache, market, pages, jobs, delay)

    found: dict[str, list[Offer]] = {}
    misses: list[tuple[str, str]] = []

    for type_ in catalog.types:
        rule = RULES[type_.id]
        weight_based = type_.unit == 'kg'
        seen: set[str] = set()
        candidates: list[Offer] = []
        for page in range(1, adapter.page_limit + 1):
            for offer in fetched.get((rule['term'], page), []):
                if offer.url in seen:
                    continue
                seen.add(offer.url)
                candidates.append(offer)
        matched = [o for o in candidates if matches_rule(rule, o, weight_based)]

        brands = catalog.brands_for(type_)
        for brand in brands:
            if brand == GENERIC_BRAND:
                continue
            hits = brand_candidates(matched, brand, brands)
            if hits:
                found[product_id(type_.id, brand)] = hits
            else:
                misses.append((type_.id, brand))

        # Markasız satır ancak marketin kendi ürün adı da markasızsa fiyat
        # alır: "Domates Kg", "Ekmek" gibi. Aksi halde markette bulunan
        # rastgele bir marka satıra yazılır ve marketler farklı ürünleri
        # karşılaştırır — kullanıcı marka seçmeli.
        plain = [
            o for o in matched
            if len(variant_tokens(o.name, rule, None)) <= 1
        ]
        if plain:
            found[product_id(type_.id, None)] = plain
            if GENERIC_BRAND in brands:
                found[product_id(type_.id, GENERIC_BRAND)] = plain

    if targeted and misses:
        extra = [(f'{brand} {RULES[type_id]["term"]}', 1)
                 for type_id, brand in misses]
        fetched_extra = gather(cache, market, extra, jobs, delay)
        types_by_id = {t.id: t for t in catalog.types}
        for type_id, brand in misses:
            type_ = types_by_id[type_id]
            rule = RULES[type_id]
            offers = fetched_extra.get((f'{brand} {rule["term"]}', 1), [])
            hits = brand_candidates(
                [o for o in offers if matches_rule(rule, o, type_.unit == 'kg')],
                brand,
                catalog.brands_for(type_),
            )
            if hits:
                found[product_id(type_id, brand)] = hits

    return found


def resolve(candidates: dict[str, dict[str, list[Offer]]],
            catalog) -> dict[str, dict[str, Offer]]:
    """Her satır için marketlerde mümkün olduğunca aynı çeşidi seçer."""
    brand_names = {
        product_id(t.id, brand): brand
        for t in catalog.types
        for brand in [*catalog.brands_for(t), None]
    }
    book: dict[str, dict[str, Offer]] = {}
    for product, per_market in candidates.items():
        type_id = product.split('__')[0]
        brand = brand_names.get(product)
        chosen = choose_shared_variant(
            per_market,
            RULES[type_id],
            None if brand == GENERIC_BRAND else brand,
        )
        if chosen:
            book[product] = chosen
    return book


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--markets', default=','.join(ADAPTERS),
                        help='virgülle ayrılmış market listesi')
    parser.add_argument('--out', type=Path, default=DEFAULT_OUT)
    parser.add_argument('--cache-dir', type=Path, default=DEFAULT_CACHE)
    parser.add_argument('--offline', action='store_true',
                        help='ağa çıkmaz, yalnızca önbellekten eşleştirir')
    parser.add_argument('--fresh', action='store_true',
                        help='önbelleği yok sayıp yeniden çeker')
    parser.add_argument('--no-targeted', action='store_true',
                        help='eksik markalar için hedefli arama yapmaz')
    parser.add_argument('--jobs', type=int, default=6)
    parser.add_argument('--delay', type=float, default=0.0,
                        help='istekler arası bekleme (saniye)')
    parser.add_argument('--fetched-at', default=None,
                        help='dosyaya yazılacak çekim tarihi (YYYY-MM-DD)')
    args = parser.parse_args()

    markets = [m.strip() for m in args.markets.split(',') if m.strip()]
    unknown = [m for m in markets if m not in ADAPTERS]
    if unknown:
        parser.error(f'bilinmeyen market: {", ".join(unknown)}')

    if args.fresh and args.cache_dir.exists():
        for path in args.cache_dir.glob('*.json'):
            path.unlink()

    catalog = load_catalog()
    cache = SearchCache(args.cache_dir, offline=args.offline)
    print(f'{len(catalog.types)} ürün tipi · {len(markets)} market')

    candidates: dict[str, dict[str, list[Offer]]] = {}
    for market in markets:
        found = build_market(market, catalog, cache, args.jobs, args.delay,
                             targeted=not args.no_targeted)
        for product, offers in found.items():
            candidates.setdefault(product, {})[market] = offers
        print(f'  {ADAPTERS[market].label}: {len(found)} satır eşleşti')

    book = resolve(candidates, catalog)

    if not book:
        print('hiçbir markette fiyat bulunamadı; dosya değiştirilmedi',
              file=sys.stderr)
        return 1

    write_dart(
        args.out,
        book,
        markets=markets,
        labels={m: ADAPTERS[m].label for m in markets},
        fetched_at=args.fetched_at,
    )
    offers = sum(len(entry) for entry in book.values())
    print(f'{args.out}: {len(book)} satır, {offers} market fiyatı')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())

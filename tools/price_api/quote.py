"""Canlı teklif: defterdeki URL'den sayfa okuma veya arama + eşleştirme."""

from __future__ import annotations

import re
from concurrent.futures import ThreadPoolExecutor, as_completed
from dataclasses import replace
from datetime import datetime, timezone
from pathlib import Path

from price_sync.catalog import GENERIC_BRAND, load_catalog
from price_sync.markets import ADAPTERS, FetchError, price_on_page
from price_sync.matching import (
    Offer, matches_rule, pick, variant_tokens,
)
from price_sync.rules import RULES
from price_sync.sync import SearchCache, brand_candidates, brand_index, confirm, fetch, MarketHealth

from .book import load_book

# Market slug (URL) -> dahili kimlik
SLUG_TO_MARKET = {
    'migros': 'migros',
    'macrocenter': 'macrocenter',
    'sok': 'sok',
    'hakmar': 'hakmar',
    'happy-center': 'happyCenter',
}

MARKET_TO_SLUG = {v: k for k, v in SLUG_TO_MARKET.items()}

# Fiyatı kendi sitesinden okunamayan marketler — uygulamadaki noPriceReason ile aynı.
UNPRICED = {
    'a101': 'sitesi otomatik fiyat okumaya kapalı',
    'bim': 'online satış yapmıyor, raf fiyatı yayınlamıyor',
    'carrefour': 'sitesi otomatik fiyat okumaya kapalı',
    'file': 'sitesinde ürün fiyatı yayınlanmıyor',
    'tarim-kredi': 'online mağazası yayında değil',
    'onur': 'sitesinde ürün fiyatı yayınlanmıyor',
    'metro': 'sitesi otomatik fiyat okumaya kapalı',
    'getir': 'sitesi otomatik fiyat okumaya kapalı',
}

ALL_MARKET_SLUGS = list(SLUG_TO_MARKET) + list(UNPRICED)

_PRICE_JSON = re.compile(
    r'"(?:shownPrice|regularPrice|discountedPrice|salePrice|price)"'
    r'\s*:\s*([0-9]+(?:\.[0-9]{1,2})?)',
)
_VISIBLE_TRY = re.compile(
    r'(?<![0-9])([0-9]{1,3}(?:[.\s][0-9]{3})*(?:,\d{1,2})?|\d+(?:,\d{2})?)'
    r'(?!\d)\s*(?:TL|₺)?',
)


def _iso_now() -> str:
    return datetime.now(timezone.utc).replace(microsecond=0).isoformat()


def extract_price_from_page(text: str, hint: float | None = None) -> float | None:
    """Sayfadaki ana fiyatı bulur.

    Önce ipucu tutarı (defterdeki son fiyat) aranır; yoksa gömülü JSON ve
    görünür TL kalıpları denenir.
    """
    if hint is not None and price_on_page(text, hint):
        return round(hint, 2)
    candidates: list[float] = []
    for match in _PRICE_JSON.finditer(text):
        try:
            value = float(match.group(1))
        except ValueError:
            continue
        if 0.5 <= value <= 50_000:
            candidates.append(value)
    for match in _VISIBLE_TRY.finditer(text):
        raw = match.group(1).replace(' ', '').replace('.', '').replace(',', '.')
        try:
            value = float(raw)
        except ValueError:
            continue
        if 0.5 <= value <= 50_000:
            candidates.append(value)
    if not candidates:
        return None
    # Aynı tutar birkaç yerde geçiyorsa o ana fiyattır.
    from collections import Counter
    counts = Counter(round(c, 2) for c in candidates)
    price, freq = counts.most_common(1)[0]
    return price if freq >= 1 else None


def _brand_for_product(product_id_str: str, brands: dict[str, str | None]) -> str | None:
    brand = brands.get(product_id_str)
    if brand == GENERIC_BRAND:
        return None
    return brand


def quote_product(
    *,
    product_id_str: str,
    market: str,
    book: dict[str, dict[str, Offer]],
    catalog,
    brands: dict[str, str | None],
    cache: SearchCache,
    health: MarketHealth,
) -> dict | None:
    """Tek ürün için bir marketten doğrulanmış teklif döner."""
    type_id = product_id_str.split('__')[0]
    if type_id not in RULES:
        return None
    rule = RULES[type_id]
    type_ = next(t for t in catalog.types if t.id == type_id)
    brand = _brand_for_product(product_id_str, brands)
    weight_based = type_.unit == 'kg'
    adapter = ADAPTERS.get(market)
    if adapter is None:
        return None

    # Hızlı yol: defterde URL var → doğrudan ürün sayfasını aç.
    cached = book.get(product_id_str, {}).get(market)
    if cached and cached.url:
        try:
            title, text = adapter.page(cached.url)
        except FetchError:
            title, text = '', ''
        if title:
            price = extract_price_from_page(text, cached.price)
            if price is not None:
                offer = replace(cached, name=title, price=price)
                confirmed = confirm(
                    product_id_str, market, offer, rule, brand, weight_based,
                )
                if confirmed:
                    return _quote_json(product_id_str, confirmed)

    # Yavaş yol: market araması + eşleştirme + sayfa doğrulaması.
    term = rule['term']
    if brand:
        term = f'{brand} {term}'
    offers: list[Offer] = []
    for page in range(1, adapter.page_limit + 1):
        if health.gave_up:
            break
        offers.extend(fetch(cache, health, term, page, 0.0))
    matched = [o for o in offers if matches_rule(rule, o, weight_based)]
    if brand:
        hits = brand_candidates(matched, brand, catalog.brands_for(type_))
    else:
        limit = 1 if weight_based else 3
        hits = [
            o for o in matched
            if len(variant_tokens(o.name, rule, None)) <= limit
        ]
    chosen = pick(hits, rule, brand)
    if not chosen:
        return None
    confirmed = confirm(product_id_str, market, chosen, rule, brand, weight_based)
    if not confirmed:
        return None
    return _quote_json(product_id_str, confirmed)


def _quote_json(product_id_str: str, offer: Offer) -> dict:
    return {
        'productId': product_id_str,
        'unitPrice': offer.price,
        'available': offer.in_stock,
        'currency': 'TRY',
        'sourceUrl': offer.url,
        'marketProduct': offer.name,
    }


def quote_market(
    *,
    slug: str,
    items: list[dict],
    region: str | None,
    book_path: Path,
    cache_dir: Path,
) -> dict:
    """Bir marketin sepet teklifini üretir."""
    fetched_at = _iso_now()
    if slug in UNPRICED:
        return {
            'marketId': _market_id_from_slug(slug),
            'status': 'ok',
            'fetchedAt': fetched_at,
            'storeId': None,
            'quotes': [],
            'noPriceReason': UNPRICED[slug],
        }

    market = SLUG_TO_MARKET.get(slug)
    if market is None:
        return {
            'marketId': slug,
            'status': 'failed',
            'fetchedAt': fetched_at,
            'errorMessage': f'bilinmeyen market: {slug}',
            'quotes': [],
        }

    fetched_at_book, book = load_book(book_path)
    catalog = load_catalog()
    brands = brand_index(catalog)
    cache = SearchCache(cache_dir, offline=False)
    health = MarketHealth(market)

    quotes: list[dict] = []
    for item in items:
        pid = item['productId']
        quote = quote_product(
            product_id_str=pid,
            market=market,
            book=book,
            catalog=catalog,
            brands=brands,
            cache=cache,
            health=health,
        )
        if quote:
            quotes.append(quote)

    return {
        'marketId': _market_id_from_slug(slug),
        'status': 'ok',
        'fetchedAt': fetched_at,
        'storeId': region,
        'quotes': quotes,
    }


def _market_id_from_slug(slug: str) -> str:
    market = SLUG_TO_MARKET.get(slug)
    if market:
        return market
    return slug.replace('-', '')


def compare_stream(
    *,
    items: list[dict],
    region: str | None,
    book_path: Path,
    cache_dir: Path,
    markets: list[str] | None = None,
):
    """Market market tamamlanan sepet sonuçlarını sırayla üretir."""
    slugs = markets or ALL_MARKET_SLUGS
    fetched_at_book, _ = load_book(book_path)

    with ThreadPoolExecutor(max_workers=min(8, len(slugs))) as pool:
        futures = {
            pool.submit(
                quote_market,
                slug=slug,
                items=items,
                region=region,
                book_path=book_path,
                cache_dir=cache_dir,
            ): slug
            for slug in slugs
        }
        for future in as_completed(futures):
            slug = futures[future]
            try:
                batch = future.result()
            except Exception as exc:  # noqa: BLE001
                batch = {
                    'marketId': _market_id_from_slug(slug),
                    'status': 'failed',
                    'fetchedAt': _iso_now(),
                    'errorMessage': str(exc),
                    'quotes': [],
                }
            yield {
                'event': 'market',
                'market': batch,
                'pricesFetchedAt': fetched_at_book,
            }

    yield {'event': 'done', 'comparedAt': _iso_now()}


def compare_all(
    *,
    items: list[dict],
    region: str | None,
    book_path: Path,
    cache_dir: Path,
) -> dict:
    """Tüm marketleri bekleyip tek yanıt döner."""
    markets = []
    for chunk in compare_stream(
        items=items,
        region=region,
        book_path=book_path,
        cache_dir=cache_dir,
    ):
        if chunk.get('event') == 'market':
            markets.append(chunk['market'])
    return {
        'markets': markets,
        'comparedAt': _iso_now(),
    }

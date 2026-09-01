"""Canlı teklif: defter + SKU dizini + sayfa okuma + arama + eşleştirme."""

from __future__ import annotations

import os
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
from .cache import PageCache, SkuIndex
from .market_fiyati import MF_MARKETS, quote_for_item as mf_quote_for_item

# Market slug (URL) -> dahili kimlik
SLUG_TO_MARKET = {
    'migros': 'migros',
    'macrocenter': 'macrocenter',
    'sok': 'sok',
    'hakmar': 'hakmar',
    'happy-center': 'happyCenter',
    'carrefour': 'carrefour',
    'a101': 'a101',
    'bim': 'bim',
    'tarim-kredi': 'tarimKredi',
}

MARKET_TO_SLUG = {v: k for k, v in SLUG_TO_MARKET.items()}

# Fiyatı kendi sitesinden okunamayan marketler — uygulamadaki noPriceReason ile aynı.
UNPRICED = {
    'file': 'sitesinde ürün fiyatı yayınlanmıyor',
    'onur': 'sitesinde ürün fiyatı yayınlanmıyor',
    'metro': 'sitesi otomatik fiyat okumaya kapalı',
    'getir': 'sitesi otomatik fiyat okumaya kapalı',
}

PRICED_SLUGS = list(SLUG_TO_MARKET)
ALL_MARKET_SLUGS = PRICED_SLUGS + list(UNPRICED)

# Ortam değişkenleriyle ayarlanabilir eşzamanlılık.
MAX_MARKET_WORKERS = int(os.environ.get('PRICE_API_MARKET_WORKERS', '12'))
MAX_ITEM_WORKERS = int(os.environ.get('PRICE_API_ITEM_WORKERS', '6'))
PAGE_CACHE_TTL = float(os.environ.get('PRICE_API_PAGE_CACHE_TTL', '45'))

_PRICE_JSON = re.compile(
    r'"(?:shownPrice|regularPrice|discountedPrice|salePrice|price)"'
    r'\s*:\s*([0-9]+(?:\.[0-9]{1,2})?)',
)
_VISIBLE_TRY = re.compile(
    r'(?<![0-9])([0-9]{1,3}(?:[.\s][0-9]{3})*(?:,\d{1,2})?|\d+(?:,\d{2})?)'
    r'(?!\d)\s*(?:TL|₺)?',
)

# Modül düzeyinde paylaşılan önbellekler (ThreadingHTTPServer ile güvenli).
_PAGE_CACHE = PageCache(ttl_seconds=PAGE_CACHE_TTL)
_SKU_INDEX: SkuIndex | None = None


def _iso_now() -> str:
    return datetime.now(timezone.utc).replace(microsecond=0).isoformat()


def _sku_index(cache_dir: Path) -> SkuIndex:
    global _SKU_INDEX  # noqa: PLW0603
    if _SKU_INDEX is None:
        _SKU_INDEX = SkuIndex(cache_dir / 'sku_index.json')
    return _SKU_INDEX


def extract_price_from_page(text: str, hint: float | None = None) -> float | None:
    """Sayfadaki ana fiyatı bulur."""
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
    from collections import Counter
    counts = Counter(round(c, 2) for c in candidates)
    price, _freq = counts.most_common(1)[0]
    return price


def _brand_for_product(product_id_str: str, brands: dict[str, str | None]) -> str | None:
    brand = brands.get(product_id_str)
    if brand == GENERIC_BRAND:
        return None
    return brand


def _fetch_page(adapter, url: str) -> tuple[str, str]:
    cached = _PAGE_CACHE.get(url)
    if cached is not None:
        return cached
    title, text = adapter.page(url)
    _PAGE_CACHE.put(url, title, text)
    return title, text


def _quote_from_url(
    *,
    product_id_str: str,
    market: str,
    adapter,
    offer: Offer,
    rule,
    brand: str | None,
    weight_based: bool,
) -> dict | None:
    try:
        title, text = _fetch_page(adapter, offer.url)
    except FetchError:
        return None
    if not title:
        return None
    price = extract_price_from_page(text, offer.price)
    if price is None:
        return None
    confirmed_offer = replace(offer, name=title, price=price)
    confirmed = confirm(
        product_id_str, market, confirmed_offer, rule, brand, weight_based,
    )
    if not confirmed:
        return None
    return _quote_json(product_id_str, confirmed)


def quote_product(
    *,
    product_id_str: str,
    market: str,
    book: dict[str, dict[str, Offer]],
    catalog,
    brands: dict[str, str | None],
    cache: SearchCache,
    health: MarketHealth,
    sku_index: SkuIndex,
    region: str | None = None,
    display_name: str | None = None,
    item_brand: str | None = None,
    mf_cache: dict[str, object] | None = None,
) -> dict | None:
    """Tek ürün için bir marketten doğrulanmış teklif döner."""
    type_id = product_id_str.split('__')[0]
    brand = item_brand or _brand_for_product(product_id_str, brands)
    name = display_name or ''
    if not name and catalog is not None:
        type_ = next((t for t in catalog.types if t.id == type_id), None)
        if type_ is not None:
            name = type_.name

    # 0) Market Fiyatı resmi platformu — A101/BİM dahil anlık şube fiyatı.
    if market in MF_MARKETS:
        mf_cache = mf_cache if mf_cache is not None else {}
        if product_id_str not in mf_cache:
            try:
                mf_cache[product_id_str] = mf_quote_for_item(
                    product_id=product_id_str,
                    brand=brand,
                    name=name or brand or product_id_str,
                    region=region,
                )
            except Exception:  # noqa: BLE001
                mf_cache[product_id_str] = None
        mf_product = mf_cache.get(product_id_str)
        if mf_product is not None:
            depot = mf_product.cheapest_by_market().get(market)
            if depot is not None:
                sku_index.put(
                    product_id_str,
                    market,
                    Offer(
                        market=market,
                        name=depot.product_name,
                        url=mf_product.source_url(),
                        price=depot.price,
                        in_stock=True,
                    ),
                )
                return {
                    'productId': product_id_str,
                    'unitPrice': depot.price,
                    'available': True,
                    'currency': 'TRY',
                    'sourceUrl': mf_product.source_url(),
                    'marketProduct': depot.product_name,
                    'storeId': depot.depot_id,
                }

    if type_id not in RULES:
        return None
    rule = RULES[type_id]
    type_ = next((t for t in catalog.types if t.id == type_id), None)
    if type_ is None:
        return None
    weight_based = type_.unit == 'kg'
    adapter = ADAPTERS.get(market)
    if adapter is None:
        return None

    # 1) SKU dizini — önceki canlı çekimden kalıcı URL.
    indexed = sku_index.get(product_id_str, market)
    if indexed:
        quote = _quote_from_url(
            product_id_str=product_id_str,
            market=market,
            adapter=adapter,
            offer=indexed.to_offer(market),
            rule=rule,
            brand=brand,
            weight_based=weight_based,
        )
        if quote:
            return quote

    # 2) Fiyat defteri URL'si.
    cached = book.get(product_id_str, {}).get(market)
    if cached and cached.url:
        quote = _quote_from_url(
            product_id_str=product_id_str,
            market=market,
            adapter=adapter,
            offer=cached,
            rule=rule,
            brand=brand,
            weight_based=weight_based,
        )
        if quote:
            sku_index.put(product_id_str, market, cached)
            return quote

    # 3) Yavaş yol: market araması + eşleştirme + sayfa doğrulaması.
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
    sku_index.put(product_id_str, market, confirmed)
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
    mf_cache: dict[str, object] | None = None,
) -> dict:
    """Bir marketin sepet teklifini üretir — ürünler paralel çekilir."""
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

    _, book = load_book(book_path)
    catalog = load_catalog()
    brands = brand_index(catalog)
    cache = SearchCache(cache_dir, offline=False)
    health = MarketHealth(market)
    sku = _sku_index(cache_dir)
    shared_mf = mf_cache if mf_cache is not None else {}

    quotes: list[dict] = []
    workers = min(MAX_ITEM_WORKERS, max(1, len(items)))

    def _one(item: dict) -> dict | None:
        return quote_product(
            product_id_str=item['productId'],
            market=market,
            book=book,
            catalog=catalog,
            brands=brands,
            cache=cache,
            health=health,
            sku_index=sku,
            region=region,
            display_name=item.get('name'),
            item_brand=item.get('brand'),
            mf_cache=shared_mf,
        )

    if workers <= 1 or len(items) <= 1:
        for item in items:
            quote = _one(item)
            if quote:
                quotes.append(quote)
    else:
        with ThreadPoolExecutor(max_workers=workers) as pool:
            futures = {pool.submit(_one, item): item for item in items}
            for future in as_completed(futures):
                try:
                    quote = future.result()
                except Exception:  # noqa: BLE001
                    continue
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
    """Market market tamamlanan sepet sonuçlarını sırayla üretir.

    Önce fiyat okunabilen marketler, sonra diğerleri — kullanıcı fiyatları
    daha erken görür.
    """
    if markets is None:
        slugs = PRICED_SLUGS + [s for s in UNPRICED if s not in PRICED_SLUGS]
    else:
        slugs = markets

    fetched_at_book, _ = load_book(book_path)
    workers = min(MAX_MARKET_WORKERS, max(1, len(slugs)))
    mf_cache: dict[str, object] = {}

    with ThreadPoolExecutor(max_workers=workers) as pool:
        futures = {
            pool.submit(
                quote_market,
                slug=slug,
                items=items,
                region=region,
                book_path=book_path,
                cache_dir=cache_dir,
                mf_cache=mf_cache,
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
                'pricesFetchedAt': _iso_now(),
                'bookFetchedAt': fetched_at_book,
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

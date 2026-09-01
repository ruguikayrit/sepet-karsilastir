"""TÜBİTAK Market Fiyatı (marketfiyati.org.tr) resmi arama API'si.

Kaynak: https://api.marketfiyati.org.tr/api/v2
A101, BİM, Şok, Migros, CarrefourSA, Hakmar ve Tarım Kredi şube fiyatları
konuma göre tek yanıtta gelir. Tahmin üretilmez; yalnızca API'nin döndürdüğü
tutar ve market ürün adı kullanılır.
"""

from __future__ import annotations

import json
import time
import urllib.error
import urllib.request
from dataclasses import dataclass
from typing import Any

from price_sync.catalog import fold

BASE_URL = 'https://api.marketfiyati.org.tr/api/v2'
SOURCE_HOST = 'https://marketfiyati.org.tr'

#: marketAdi (API) -> uygulamadaki market kimliği
MARKET_ALIASES = {
    'a101': 'a101',
    'bim': 'bim',
    'sok': 'sok',
    'sokmarket': 'sok',
    'migros': 'migros',
    'carrefour': 'carrefour',
    'carrefoursa': 'carrefour',
    'hakmar': 'hakmar',
    'tarimkredi': 'tarimKredi',
    'tarim-kredi': 'tarimKredi',
    'tarim_kredi': 'tarimKredi',
    'tkk': 'tarimKredi',
}

MF_MARKETS = frozenset(MARKET_ALIASES.values())

REGIONS = {
    'istanbul': (41.0082, 28.9784),
    'ankara': (39.9334, 32.8597),
    'izmir': (38.4237, 27.1428),
}

HEADERS = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Origin': SOURCE_HOST,
    'Referer': f'{SOURCE_HOST}/',
    'User-Agent': (
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '
        '(KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36'
    ),
}


@dataclass(frozen=True)
class DepotPrice:
    market: str
    depot_id: str
    depot_name: str
    price: float
    product_name: str
    index_time: str | None


@dataclass(frozen=True)
class MfProduct:
    id: str
    title: str
    brand: str | None
    volume: str | None
    category: str
    image_url: str | None
    depots: tuple[DepotPrice, ...]

    def cheapest_by_market(self) -> dict[str, DepotPrice]:
        best: dict[str, DepotPrice] = {}
        for depot in self.depots:
            current = best.get(depot.market)
            if current is None or depot.price < current.price:
                best[depot.market] = depot
        return best

    def source_url(self) -> str:
        return f'{SOURCE_HOST}/?product={self.id}'


def coords_for(region: str | None) -> tuple[float, float]:
    key = (region or 'istanbul').strip().lower()
    return REGIONS.get(key, REGIONS['istanbul'])


def _post(path: str, payload: dict[str, Any], attempts: int = 4) -> dict:
    body = json.dumps(payload).encode('utf-8')
    last: Exception | None = None
    for attempt in range(attempts):
        req = urllib.request.Request(
            f'{BASE_URL}/{path}',
            data=body,
            headers=HEADERS,
            method='POST',
        )
        try:
            with urllib.request.urlopen(req, timeout=20) as response:
                raw = response.read().decode('utf-8')
                parsed = json.loads(raw) if raw else {}
                return parsed if isinstance(parsed, dict) else {}
        except urllib.error.HTTPError as exc:
            last = exc
            if exc.code in {418, 429, 500, 502, 503} and attempt < attempts - 1:
                time.sleep(0.6 * (attempt + 1))
                continue
            raise
        except Exception as exc:  # noqa: BLE001
            last = exc
            if attempt < attempts - 1:
                time.sleep(0.4 * (attempt + 1))
                continue
            raise
    raise last or RuntimeError(f'{path} başarısız')


def _market_id(raw: str | None) -> str | None:
    if not raw:
        return None
    key = fold(raw).replace(' ', '')
    return MARKET_ALIASES.get(key) or MARKET_ALIASES.get(raw.lower())


def _parse_product(raw: dict) -> MfProduct | None:
    pid = str(raw.get('id') or '').strip()
    title = (raw.get('title') or '').strip()
    if not pid or not title:
        return None
    depots: list[DepotPrice] = []
    for item in raw.get('productDepotInfoList') or []:
        if not isinstance(item, dict):
            continue
        market = _market_id(item.get('marketAdi'))
        try:
            price = float(item.get('price'))
        except (TypeError, ValueError):
            continue
        if market is None or price <= 0:
            continue
        depots.append(
            DepotPrice(
                market=market,
                depot_id=str(item.get('depotId') or ''),
                depot_name=str(item.get('depotName') or ''),
                price=round(price, 2),
                product_name=title,
                index_time=item.get('indexTime'),
            ),
        )
    return MfProduct(
        id=pid,
        title=title,
        brand=(raw.get('brand') or None),
        volume=(raw.get('refinedVolumeOrWeight') or None),
        category=(
            raw.get('menu_category')
            or raw.get('main_category')
            or 'Genel'
        ),
        image_url=raw.get('imageUrl'),
        depots=tuple(depots),
    )


def search(
    keywords: str,
    *,
    region: str | None = 'istanbul',
    size: int = 24,
    latitude: float | None = None,
    longitude: float | None = None,
    distance: int = 10,
) -> list[MfProduct]:
    lat, lng = coords_for(region)
    payload = {
        'keywords': keywords,
        'latitude': latitude if latitude is not None else lat,
        'longitude': longitude if longitude is not None else lng,
        'distance': distance,
        'size': size,
    }
    data = _post('search', payload)
    products: list[MfProduct] = []
    for raw in data.get('content') or []:
        if isinstance(raw, dict):
            parsed = _parse_product(raw)
            if parsed:
                products.append(parsed)
    return products


def search_by_id(
    product_id: str,
    *,
    region: str | None = 'istanbul',
    keywords: str | None = None,
) -> MfProduct | None:
    lat, lng = coords_for(region)
    payload: dict[str, Any] = {
        'identity': product_id,
        'identityType': 'id',
        'latitude': lat,
        'longitude': lng,
        'distance': 10,
    }
    if keywords:
        payload['keywords'] = keywords
    data = _post('searchByIdentity', payload)
    for raw in data.get('content') or []:
        if isinstance(raw, dict):
            parsed = _parse_product(raw)
            if parsed and parsed.id == product_id:
                return parsed
            if parsed:
                return parsed
    return None


def _score(product: MfProduct, *, brand: str | None, name: str) -> int:
    hay = fold(f'{product.brand or ""} {product.title} {product.volume or ""}')
    score = 0
    if brand:
        b = fold(brand)
        if b and b in hay:
            score += 8
        elif b:
            score -= 4
    for token in fold(name).split():
        if len(token) < 2:
            continue
        if token in hay:
            score += 2
    return score


def match_product(
    products: list[MfProduct],
    *,
    brand: str | None,
    name: str,
) -> MfProduct | None:
    if not products:
        return None
    ranked = sorted(
        products,
        key=lambda p: _score(p, brand=brand, name=name),
        reverse=True,
    )
    best = ranked[0]
    if _score(best, brand=brand, name=name) < 4:
        return None
    return best


def quote_for_item(
    *,
    product_id: str,
    brand: str | None,
    name: str,
    region: str | None,
) -> MfProduct | None:
    """Sepet satırını Market Fiyatı ürününe bağlar."""
    if product_id.startswith('mf:'):
        return search_by_id(product_id[3:], region=region, keywords=name)
    keywords = ' '.join(part for part in (brand, name) if part).strip()
    if not keywords:
        return None
    hits = search(keywords, region=region, size=24)
    return match_product(hits, brand=brand, name=name)

"""Market adapterları: her biri kendi zincirinin yayınından ürün + fiyat okur.

Bir zincir buraya ancak üç bilgiyi birlikte veriyorsa girer: ürün adı, raf
fiyatı ve **o ürünün kendi sayfasının adresi**. Adresi olmayan fiyat
uygulamada gösterilmez, çünkü kullanıcı fiyatı doğrulayamaz.

Kapsam dışı kalan zincirler ve nedeni [UNSUPPORTED] içinde.
"""

from __future__ import annotations

import gzip
import html as html_lib
import io
import json
import re
import time
import urllib.error
import urllib.parse
import urllib.request
from dataclasses import dataclass

from .matching import Offer

UA = (
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '
    '(KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36'
)


class FetchError(RuntimeError):
    pass


def http_get(url: str, headers: dict[str, str] | None = None,
             timeout: int = 30, attempts: int = 3) -> str:
    request_headers = {
        'User-Agent': UA,
        'Accept-Language': 'tr-TR,tr;q=0.9',
        'Accept-Encoding': 'gzip',
    }
    request_headers.update(headers or {})
    last: Exception | None = None
    for attempt in range(attempts):
        try:
            request = urllib.request.Request(url, headers=request_headers)
            with urllib.request.urlopen(request, timeout=timeout) as response:
                raw = response.read()
                if response.headers.get('Content-Encoding') == 'gzip':
                    raw = gzip.GzipFile(fileobj=io.BytesIO(raw)).read()
                return raw.decode('utf-8', 'replace')
        except Exception as exc:  # noqa: BLE001 - ağ hatası: yeniden dene
            last = exc
            if attempt < attempts - 1:
                time.sleep(1.5 * (attempt + 1))
    raise FetchError(f'{url}: {last}')


@dataclass(frozen=True)
class Unsupported:
    market: str
    name: str
    reason: str


# Fiyatı uygulamaya alınamayan zincirler. Metin karşılaştırma ekranında
# kullanıcıya gösterildiği için sebebi kısa ve doğru yazılır.
UNSUPPORTED = [
    Unsupported('bim', 'BİM', 'online satış yapmıyor, raf fiyatı yayınlamıyor'),
    Unsupported('a101', 'A101', 'site otomatik erişimi engelliyor'),
    Unsupported('file', 'File', 'sitesinde ürün fiyatı yayınlanmıyor'),
    Unsupported('tarimKredi', 'Tarım Kredi Market',
                'online mağazası yayında değil'),
    Unsupported('onur', 'Onur Market', 'sitesinde ürün fiyatı yayınlanmıyor'),
    Unsupported('metro', 'Metro Market', 'site otomatik erişimi engelliyor'),
    Unsupported('getir', 'Getir Büyük', 'site otomatik erişimi engelliyor'),
]


class MarketAdapter:
    """Bir zincirin arama yayınını [Offer] listesine çevirir."""

    market: str
    label: str
    host: str
    page_limit: int = 3

    #: Sayfa başlığının sonuna eklenen site adı.
    title_suffixes: tuple[str, ...] = ()

    def search(self, term: str, page: int) -> list[Offer]:
        raise NotImplementedError

    def page(self, url: str) -> tuple[str, str]:
        """Ürün sayfasının (başlık, aranabilir tüm içerik) hâli.

        Doğrulama buradan yürür: kullanıcı bağlantıya dokunduğunda göreceği
        ürün adı ve fiyat, sayfanın kendisinden okunur. İçerik etiketleriyle
        birlikte taranıyor: bazı marketler fiyatı sayfaya gömülü JSON'dan
        basıyor, görünür metinde durmuyor.
        """
        html = http_get(url, timeout=25, attempts=2)
        return self.page_title(html), _flat(html)

    def page_title(self, html: str) -> str:
        """Sayfadaki ürün adı."""
        return self._strip_suffix(_tag(html, 'h1') or _title_tag(html))

    def _strip_suffix(self, title: str) -> str:
        for suffix in self.title_suffixes:
            if title.lower().endswith(suffix.lower()):
                title = title[: -len(suffix)]
        return title.strip(' -|·')

    def _offer(self, name: str, path: str, price: float, in_stock: bool,
               sold_by_weight: bool = False) -> Offer | None:
        name = (name or '').strip()
        path = (path or '').strip().lstrip('/')
        if not name or not path or not price or price <= 0:
            return None
        return Offer(
            market=self.market,
            name=name,
            url=f'{self.host}/{path}',
            price=round(float(price), 2),
            in_stock=in_stock,
            sold_by_weight=sold_by_weight,
        )


class SokAdapter(MarketAdapter):
    """sokmarket.com.tr — arama sayfası sonucu HTML içinde JSON olarak gelir."""

    market = 'sok'
    label = 'Şok'
    host = 'https://www.sokmarket.com.tr'
    title_suffixes = (' - Cepte Şok',)
    page_limit = 5

    def search(self, term: str, page: int) -> list[Offer]:
        query = urllib.parse.quote(term)
        url = f'{self.host}/arama?q={query}'
        if page > 1:
            url += f'&page={page}'
        html = http_get(url)
        payload = self._search_payload(html)
        offers = []
        for item in payload.get('results', []):
            product = item.get('product') or {}
            price = ((item.get('prices') or {}).get('discounted') or {}).get('value')
            offer = self._offer(
                product.get('name'),
                product.get('path'),
                price,
                bool(item.get('hasStock')),
                sold_by_weight=(product.get('stockUnit') == 'KG'),
            )
            if offer:
                offers.append(offer)
        return offers

    @staticmethod
    def _search_payload(html: str) -> dict:
        chunks = re.findall(
            r'self\.__next_f\.push\(\[1,\s*("(?:[^"\\]|\\.)*")\]\)', html)
        text = ''.join(json.loads(chunk) for chunk in chunks)
        marker = '"initialSearchResult":'
        start = text.find(marker)
        if start < 0:
            return {}
        payload, _ = json.JSONDecoder().raw_decode(text[start + len(marker):])
        return payload or {}


class HappyCenterAdapter(MarketAdapter):
    """happycenter.com.tr — otomatik tamamlama + arama sayfası (çok sayfa)."""

    market = 'happyCenter'
    label = 'Happy Center'
    host = 'https://happycenter.com.tr'
    page_limit = 5

    # Katalogda kalan iptal/çıkma kayıtları: fiyatı güncel değil.
    JUNK = re.compile(r'(^|_|-|\b)(iptal|cikma|test)(_|-|\b|$)')

    _CARD = re.compile(
        r'href="/([^"]+)" class="desktop-product-image"',
        re.I,
    )
    _NAME = re.compile(
        r'class="desktop-product-name"[^>]*>\s*<a[^>]*>([^<]+)',
        re.S | re.I,
    )
    _PRICE = re.compile(
        r'class="price"[^>]*>\s*<a[^>]*>([^<]+)',
        re.S | re.I,
    )
    _MOBILE = re.compile(
        r'seourl="([^"]+)".*?>([0-9]+(?:[.,][0-9]+)?)</a>',
        re.S | re.I,
    )

    def search(self, term: str, page: int) -> list[Offer]:
        offers: list[Offer] = []
        seen: set[str] = set()
        if page == 1:
            for offer in self._autocomplete(term):
                if offer.url not in seen:
                    seen.add(offer.url)
                    offers.append(offer)
        for offer in self._html_search(term, page):
            if offer.url not in seen:
                seen.add(offer.url)
                offers.append(offer)
        return offers

    def _autocomplete(self, term: str) -> list[Offer]:
        query = urllib.parse.quote(term)
        raw = http_get(
            f'{self.host}/Product/SearchAutoComplete?term={query}',
            headers={'Accept': 'application/json'},
        )
        items = json.loads(raw)
        offers = []
        for item in items if isinstance(items, list) else []:
            name = (item.get('sto_isim') or '').strip()
            path = (item.get('seourl') or '').strip()
            if self.JUNK.search(path.lower()) or self.JUNK.search(name.lower()):
                continue
            offer = self._offer(name, path, _parse_try(item.get('priceText')), True)
            if offer:
                offers.append(offer)
        return offers

    def _html_search(self, term: str, page: int) -> list[Offer]:
        query = urllib.parse.quote(term)
        url = f'{self.host}/arama?q={query}'
        if page > 1:
            url += f'&sayfa={page}'
        html = http_get(url)
        offers: list[Offer] = []
        for match in self._CARD.finditer(html):
            path = match.group(1).strip()
            if self.JUNK.search(path.lower()):
                continue
            chunk = html[match.start(): match.start() + 1800]
            name_match = self._NAME.search(chunk)
            price_match = self._PRICE.search(chunk)
            name = html_lib.unescape(name_match.group(1).strip()) if name_match else path
            price = _parse_try(price_match.group(1)) if price_match else None
            offer = self._offer(name, path, price, True)
            if offer:
                offers.append(offer)
        if offers:
            return offers
        # Mobil düzen: seourl + fiyat bitişik.
        for path, price_text in self._MOBILE.findall(html):
            if self.JUNK.search(path.lower()):
                continue
            offer = self._offer(path.replace('_', ' '), path, _parse_try(price_text), True)
            if offer:
                offers.append(offer)
        return offers


class HakmarAdapter(MarketAdapter):
    """hakmarexpress.com.tr — mağaza API'si arama sonucunu ürün kartı verir."""

    market = 'hakmar'
    label = 'Hakmar Express'
    host = 'https://www.hakmarexpress.com.tr'
    api = 'https://api.hakmarexpress.com.tr/api'
    page_limit = 5

    def page_title(self, html: str) -> str:
        # Sayfadaki tek h1 "Tüm Kategoriler"; ürün adı og:title'da.
        return self._strip_suffix(_meta_title(html) or _title_tag(html))

    def search(self, term: str, page: int) -> list[Offer]:
        query = urllib.parse.quote(term)
        raw = http_get(
            f'{self.api}/home/slug/search?q={query}',
            headers={
                'Accept': 'application/json',
                'Origin': self.host,
                'Referer': f'{self.host}/',
                'x-page-number': str(page),
            },
        )
        offers = []
        for product in _walk_products(json.loads(raw)):
            offer = self._offer(
                product.get('name'),
                product.get('slug'),
                product.get('price'),
                not product.get('outOfStock'),
                sold_by_weight=(product.get('unitCode') or '').lower() == 'kg',
            )
            if offer:
                offers.append(offer)
        return offers


class MigrosPlatformAdapter(MarketAdapter):
    """Migros altyapısı (Migros ve Macrocenter) — /rest/products/search."""

    def search(self, term: str, page: int) -> list[Offer]:
        query = urllib.parse.quote(term)
        raw = http_get(
            f'{self.host}/rest/products/search?q={query}&sayfa={page}',
            headers={'Accept': 'application/json'},
        )
        data = (json.loads(raw) or {}).get('data') or {}
        offers = []
        for item in data.get('storeProductInfos') or []:
            price = item.get('shownPrice') or item.get('regularPrice')
            offer = self._offer(
                item.get('name'),
                item.get('prettyName'),
                None if price is None else price / 100,
                item.get('status') == 'IN_SALE',
                sold_by_weight=(item.get('unit') == 'KG'),
            )
            if offer:
                offers.append(offer)
        return offers


class MigrosAdapter(MigrosPlatformAdapter):
    market = 'migros'
    label = 'Migros'
    host = 'https://www.migros.com.tr'
    title_suffixes = (' | Migros', ' - Migros')


class MacrocenterAdapter(MigrosPlatformAdapter):
    market = 'macrocenter'
    label = 'Macrocenter'
    host = 'https://www.macrocenter.com.tr'
    title_suffixes = (' | Macroonline', ' | Macrocenter')


class CarrefourAdapter(MigrosPlatformAdapter):
    """carrefoursa.com — Migros altyapısı; bazı IP'lerde erişilebilir."""

    market = 'carrefour'
    label = 'CarrefourSA'
    host = 'https://www.carrefoursa.com'
    title_suffixes = (' | CarrefourSA', ' - CarrefourSA')


ADAPTERS: dict[str, MarketAdapter] = {
    adapter.market: adapter
    for adapter in (
        SokAdapter(),
        HappyCenterAdapter(),
        HakmarAdapter(),
        MigrosAdapter(),
        MacrocenterAdapter(),
        CarrefourAdapter(),
    )
}


def price_on_page(text: str, price: float) -> bool:
    """Bu tutar sayfada yazıyor mu?

    Marketler binlik ayırıcıyı ve kuruşu farklı yazıyor ("1.600,00", "1600,00",
    "554,9"); hepsini karşılayan bir kalıp kuruluyor.
    """
    lira, kurus = f'{price:.2f}'.split('.')
    grouped = f'{int(lira):,}'.replace(',', '[.]?')
    # Kuruş varsa sayfada da yazmalı; sıfırsa yazılıp yazılmaması serbest.
    kurus_part = rf'[,.]{kurus[0]}(?:{kurus[1]})?' if kurus != '00' \
        else r'(?:[,.]0{1,2})?'
    return re.search(rf'(?<![0-9]){grouped}{kurus_part}(?![0-9])',
                     text) is not None


def _flat(html: str) -> str:
    """Sayfanın tümü, tek satıra indirilmiş."""
    return re.sub(r'\s+', ' ', html_lib.unescape(html))


def _text(html: str) -> str:
    without_script = re.sub(r'<(script|style)\b.*?</\1>', ' ', html,
                            flags=re.S | re.I)
    stripped = re.sub(r'<[^>]+>', ' ', without_script)
    return re.sub(r'\s+', ' ', html_lib.unescape(stripped)).strip()


def _tag(html: str, name: str) -> str:
    match = re.search(rf'<{name}\b[^>]*>(.*?)</{name}>', html, re.S | re.I)
    return _text(match.group(1)) if match else ''


def _title_tag(html: str) -> str:
    return _tag(html, 'title')


def _meta_title(html: str) -> str:
    match = re.search(
        r'<meta[^>]+(?:property|name)=["\']og:title["\'][^>]+content=["\']'
        r'([^"\']+)', html, re.I)
    return html_lib.unescape(match.group(1)).strip() if match else ''


def _walk_products(node: object) -> list[dict]:
    """Hakmar sayfa şemasında ürün kartlarını toplar."""
    found: list[dict] = []
    if isinstance(node, dict):
        if 'slug' in node and 'price' in node and 'name' in node:
            found.append(node)
        for value in node.values():
            found += _walk_products(value)
    elif isinstance(node, list):
        for value in node:
            found += _walk_products(value)
    return found


def _parse_try(text: str | None) -> float | None:
    match = re.search(r'([0-9]+(?:\.[0-9]{3})*(?:,[0-9]+)?)', text or '')
    if not match:
        return None
    return float(match.group(1).replace('.', '').replace(',', '.'))

"""Eşleşen market ürünlerini uygulamanın okuduğu Dart dosyasına yazar."""

from __future__ import annotations

import re
from datetime import date
from pathlib import Path

from .matching import Offer

HEADER = '''/// Marketlerin kendi sayfalarından okunan ürün fiyatları.
///
/// Bu dosya elle düzenlenmez; `tools/price_sync/sync.py` üretir.
///
/// Bir kayıt yalnızca üç bilgi birlikte doğrulandığında oluşur: marketin
/// sitesindeki ürün adı, o ürünün kendi sayfasının adresi ve o sayfadaki raf
/// fiyatı. Marka, çeşit ve gramaj katalogdaki satırla birebir aynıdır. Kaydı
/// olmayan satır uygulamada fiyatsız görünür; tahmin üretilmez.
///
/// Kaynak: {sources}
/// Çekim: {fetched_at} · {offer_count} ürün fiyatı, {product_count} satır
library;

import '../models/market.dart';

/// Bir marketin yayınladığı tek bir ürün.
class MarketOffer {{
  const MarketOffer({{
    required this.product,
    required this.url,
    required this.price,
    this.inStock = true,
  }});

  /// Marketin sitesindeki tam ürün adı.
  final String product;

  /// Fiyatın okunduğu ürün sayfası — satıra dokununca bu adres açılır.
  final String url;

  /// Sayfadaki raf fiyatı (TRY).
  final double price;

  /// Çekim anında online satışta mıydı?
  final bool inStock;
}}

/// Fiyat defterinin çekildiği gün (ISO 8601).
const priceBookFetchedAt = '{fetched_at}';

/// Fiyatı kendi sitesinden okunabilen marketler.
const priceBookMarkets = <MarketId>[
{market_list}
];

/// `ürün tipi__marka` -> market -> o marketteki ürün ve fiyatı.
const priceBook = <String, Map<MarketId, MarketOffer>>{{
'''


_ENTRY = re.compile(r"^  '((?:[^'\\]|\\.)*)': \{$")
_OFFER = re.compile(
    r"^    MarketId\.(\w+): MarketOffer\($"
)
_FIELD = re.compile(r"^      (\w+): (.*),$")
_FETCHED_AT = re.compile(r"^const priceBookFetchedAt = '([^']*)';$", re.M)


def _unquote(value: str) -> str:
    if value.startswith("'") and value.endswith("'"):
        inner = value[1:-1]
        return re.sub(r'\\(.)', r'\1', inner)
    return value


def read_dart(path: Path) -> tuple[str, dict[str, dict[str, Offer]]]:
    """Üretilmiş fiyat defterini geri okur.

    Tek bir marketi yenilerken ötekilerin kayıtlarını korumak için gerekiyor
    (`--merge-from`). Dosya bu araç tarafından üretildiği için biçimi sabit.
    """
    source = path.read_text(encoding='utf-8')
    fetched_at_match = _FETCHED_AT.search(source)
    fetched_at = fetched_at_match.group(1) if fetched_at_match else ''

    book: dict[str, dict[str, Offer]] = {}
    product: str | None = None
    market: str | None = None
    fields: dict[str, str] = {}

    def flush() -> None:
        if product is None or market is None or not fields:
            return
        book.setdefault(product, {})[market] = Offer(
            market=market,
            name=_unquote(fields['product']),
            url=_unquote(fields['url']),
            price=float(fields['price']),
            in_stock=fields.get('inStock', 'true') == 'true',
        )

    for line in source.splitlines():
        entry = _ENTRY.match(line)
        if entry:
            flush()
            product, market, fields = _unquote(f"'{entry.group(1)}'"), None, {}
            continue
        offer = _OFFER.match(line)
        if offer:
            flush()
            market, fields = offer.group(1), {}
            continue
        field = _FIELD.match(line)
        if field and market:
            fields[field.group(1)] = field.group(2)
    flush()
    return fetched_at, book


def dart_string(value: str) -> str:
    escaped = value.replace('\\', r'\\').replace("'", r"\'").replace('$', r'\$')
    return f"'{escaped}'"


def write_dart(
    path: Path,
    book: dict[str, dict[str, Offer]],
    markets: list[str],
    labels: dict[str, str],
    fetched_at: str | None = None,
) -> None:
    fetched_at = fetched_at or date.today().isoformat()
    offer_count = sum(len(entry) for entry in book.values())
    sources = ', '.join(labels[market] for market in markets)

    lines = [
        HEADER.format(
            sources=sources,
            fetched_at=fetched_at,
            offer_count=offer_count,
            product_count=len(book),
            market_list='\n'.join(f'  MarketId.{market},' for market in markets),
        )
    ]
    for product_id in sorted(book):
        entry = book[product_id]
        lines.append(f'  {dart_string(product_id)}: {{')
        for market in markets:
            offer = entry.get(market)
            if offer is None:
                continue
            lines.append(f'    MarketId.{market}: MarketOffer(')
            lines.append(f'      product: {dart_string(offer.name)},')
            lines.append(f'      url: {dart_string(offer.url)},')
            lines.append(f'      price: {float(offer.price)},')
            if not offer.in_stock:
                lines.append('      inStock: false,')
            lines.append('    ),')
        lines.append('  },')
    lines.append('};')
    path.write_text('\n'.join(lines) + '\n', encoding='utf-8')

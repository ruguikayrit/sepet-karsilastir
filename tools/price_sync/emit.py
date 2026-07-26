"""Eşleşen market ürünlerini uygulamanın okuduğu Dart dosyasına yazar."""

from __future__ import annotations

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

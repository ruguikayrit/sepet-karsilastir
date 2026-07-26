import '../../models/market.dart';

/// Bizim ürün id ↔ market SKU eşlemesi.
///
/// Canlı sistemde bu tablo backend DB'den gelir; burada iskelet / offline fallback.
class ProductSkuMap {
  const ProductSkuMap(this._map);

  /// marketId -> (productId -> externalSku)
  final Map<MarketId, Map<String, String>> _map;

  /// Başlangıç eşlemeleri — backend hazır olunca kaldırılabilir.
  factory ProductSkuMap.seed() {
    return const ProductSkuMap({
      MarketId.migros: {
        'sut-1l': 'MIG-SUT-1L',
        'yumurta-30': 'MIG-YUM-30',
        'ekmek-250': 'MIG-EKM-250',
        'pirinc-1kg': 'MIG-PIR-1KG',
        'aycicek-1l': 'MIG-YAG-1L',
      },
      MarketId.a101: {
        'sut-1l': 'A101-SUT-1L',
        'yumurta-30': 'A101-YUM-30',
        'ekmek-250': 'A101-EKM-250',
        'pirinc-1kg': 'A101-PIR-1KG',
        'aycicek-1l': 'A101-YAG-1L',
      },
      MarketId.sok: {
        'sut-1l': 'SOK-SUT-1L',
        'yumurta-30': 'SOK-YUM-30',
        'ekmek-250': 'SOK-EKM-250',
        'pirinc-1kg': 'SOK-PIR-1KG',
        'aycicek-1l': 'SOK-YAG-1L',
      },
      MarketId.carrefour: {
        'sut-1l': 'CRF-SUT-1L',
        'yumurta-30': 'CRF-YUM-30',
        'ekmek-250': 'CRF-EKM-250',
        'pirinc-1kg': 'CRF-PIR-1KG',
        'aycicek-1l': 'CRF-YAG-1L',
      },
      MarketId.file: {
        'sut-1l': 'FILE-SUT-1L',
        'yumurta-30': 'FILE-YUM-30',
        'ekmek-250': 'FILE-EKM-250',
        'pirinc-1kg': 'FILE-PIR-1KG',
        'aycicek-1l': 'FILE-YAG-1L',
      },
    });
  }

  String? skuFor(MarketId marketId, String productId) {
    return _map[marketId]?[productId];
  }

  List<SkuLookup> lookupsFor(
    MarketId marketId,
    Iterable<String> productIds,
  ) {
    return productIds
        .map(
          (id) => SkuLookup(
            productId: id,
            externalSku: skuFor(marketId, id),
          ),
        )
        .toList();
  }
}

class SkuLookup {
  const SkuLookup({required this.productId, this.externalSku});

  final String productId;
  final String? externalSku;
}

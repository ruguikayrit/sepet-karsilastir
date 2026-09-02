import '../../data/mock_catalog.dart';
import '../../models/market.dart';

/// Bizim ürün tipi ↔ market SKU eşlemesi.
///
/// Canlı sistemde bu tablo backend DB'den gelir; burada iskelet / offline fallback.
class ProductSkuMap {
  const ProductSkuMap(this._map);

  /// marketId -> (typeId -> externalSku)
  final Map<MarketId, Map<String, String>> _map;

  static const _prefixes = <MarketId, String>{
    MarketId.migros: 'MIG',
    MarketId.macrocenter: 'MACRO',
    MarketId.a101: 'A101',
    MarketId.bim: 'BIM',
    MarketId.sok: 'SOK',
    MarketId.carrefour: 'CRF',
    MarketId.tarimKredi: 'TKM',
    MarketId.hakmar: 'HAK',
    MarketId.happyCenter: 'HAPPY',
  };

  /// Katalogdaki tüm ürün tipleri için placeholder SKU üretir.
  factory ProductSkuMap.seed() {
    final map = <MarketId, Map<String, String>>{};
    for (final market in Market.all) {
      final prefix = _prefixes[market.id] ?? market.id.name.toUpperCase();
      map[market.id] = {
        for (final type in productTypes)
          type.id: '$prefix-${type.id.toUpperCase()}',
      };
    }
    return ProductSkuMap(map);
  }

  String? skuFor(MarketId marketId, String typeId) {
    return _map[marketId]?[typeId];
  }

  List<SkuLookup> lookupsFor(
    MarketId marketId,
    Iterable<String> typeIds,
  ) {
    return typeIds
        .map(
          (id) => SkuLookup(
            typeId: id,
            externalSku: skuFor(marketId, id),
          ),
        )
        .toList();
  }
}

class SkuLookup {
  const SkuLookup({required this.typeId, this.externalSku});

  final String typeId;
  final String? externalSku;
}

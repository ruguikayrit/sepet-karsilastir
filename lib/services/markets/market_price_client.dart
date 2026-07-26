import '../../models/list_item.dart';
import '../../models/market.dart';
import '../../models/market_quote.dart';
import '../mapping/product_sku_map.dart';

/// Tek bir market zinciri için fiyat istemcisi sözleşmesi.
///
/// Uygulama → kendi backend → market kaynağı.
/// Doğrudan Migros/A101/… sitesine client’tan istek atılmaz.
abstract class MarketPriceClient {
  MarketId get marketId;

  /// Sepet kalemleri için anlık fiyatları döner.
  Future<MarketQuoteBatch> fetchBasketQuotes({
    required List<ListItem> items,
    required ProductSkuMap skuMap,
    String? region,
    String? storeId,
  });
}

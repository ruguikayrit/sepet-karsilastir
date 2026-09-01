import '../config/app_config.dart';
import '../data/mock_catalog.dart';
import '../models/comparison_result.dart';
import '../models/list_item.dart';
import '../models/product.dart';
import 'hybrid_price_service.dart';
import 'market_fiyati/market_fiyati_price_service.dart';

/// Market fiyat kaynağı sözleşmesi.
abstract class PriceService {
  Future<List<ProductType>> searchProductTypes(String query);
  Future<ComparisonResult> compareBasket(List<ListItem> items);
  Future<List<Product>> searchCatalogProducts(String query);
}

/// Varsayılan: defter anında, API yapılandırıldıysa canlı yenileme.
///
/// `USE_LIVE_PRICES=true` ve gerçek bir `API_BASE_URL` varsa marketler
/// kademeli güncellenir. Aksi halde yalnızca doğrulanmış fiyat defteri
/// kullanılır — tahmin üretilmez.
PriceService createPriceService({bool? useLive}) {
  if (AppConfig.useMarketFiyati) {
    return MarketFiyatiPriceService(
      fallback: HybridPriceService.create(),
    );
  }
  final live = useLive ?? AppConfig.useLivePrices;
  if (live && !AppConfig.apiBaseUrl.contains('example.com')) {
    return HybridPriceService.create();
  }
  return HybridPriceService(
    apiClient: null,
    liveFallback: null,
  );
}

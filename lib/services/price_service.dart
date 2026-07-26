import '../config/app_config.dart';
import '../models/comparison_result.dart';
import '../models/list_item.dart';
import '../models/product.dart';
import 'live_price_service.dart';
import 'mock_price_service.dart';

/// Market fiyat kaynağı sözleşmesi.
abstract class PriceService {
  Future<List<Product>> searchProducts(String query);
  Future<ComparisonResult> compareBasket(List<ListItem> items);
}

/// `USE_LIVE_PRICES` dart-define ile mock / canlı seçimi.
PriceService createPriceService({bool? useLive}) {
  final live = useLive ?? AppConfig.useLivePrices;
  if (live) {
    // Backend URL yoksa stub ile akış doğrulanabilir.
    // Gerçek backend: LivePriceService.backend()
    if (AppConfig.apiBaseUrl.contains('example.com')) {
      return LivePriceService.stubbed();
    }
    return LivePriceService.backend();
  }
  return MockPriceService();
}

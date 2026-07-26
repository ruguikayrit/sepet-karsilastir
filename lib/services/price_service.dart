import '../config/app_config.dart';
import '../data/mock_catalog.dart';
import '../models/comparison_result.dart';
import '../models/list_item.dart';
import 'live_price_service.dart';
import 'mock_price_service.dart';

/// Market fiyat kaynağı sözleşmesi.
abstract class PriceService {
  Future<List<ProductType>> searchProductTypes(String query);
  Future<ComparisonResult> compareBasket(List<ListItem> items);
}

/// `USE_LIVE_PRICES` dart-define ile mock / canlı seçimi.
PriceService createPriceService({bool? useLive}) {
  final live = useLive ?? AppConfig.useLivePrices;
  if (live) {
    if (AppConfig.apiBaseUrl.contains('example.com')) {
      return LivePriceService.stubbed();
    }
    return LivePriceService.backend();
  }
  return MockPriceService();
}

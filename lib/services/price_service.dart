import '../config/app_config.dart';
import '../data/mock_catalog.dart';
import '../models/comparison_result.dart';
import '../models/list_item.dart';
import 'live_price_service.dart';
import 'price_book_service.dart';

/// Market fiyat kaynağı sözleşmesi.
abstract class PriceService {
  Future<List<ProductType>> searchProductTypes(String query);
  Future<ComparisonResult> compareBasket(List<ListItem> items);
}

/// `USE_LIVE_PRICES` dart-define ile fiyat defteri / canlı backend seçimi.
///
/// Canlı kaynak istenip de gerçek bir backend adresi verilmediyse fiyat
/// defterine düşer: uydurma fiyat üreten bir taklit servis yoktur.
PriceService createPriceService({bool? useLive}) {
  final live = useLive ?? AppConfig.useLivePrices;
  if (live && !AppConfig.apiBaseUrl.contains('example.com')) {
    return LivePriceService.backend();
  }
  return const PriceBookService();
}

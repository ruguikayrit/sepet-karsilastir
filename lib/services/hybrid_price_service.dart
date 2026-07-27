import '../config/app_config.dart';
import '../data/mock_catalog.dart';
import '../models/comparison_result.dart';
import '../models/list_item.dart';
import '../models/market_quote.dart';
import '../services/http/api_client.dart';
import 'live_price_service.dart';
import 'price_book_service.dart';
import 'price_service.dart';

/// Önce fiyat defterini anında gösterir, API varsa market market canlı yeniler.
///
/// Kullanıcı boş ekran görmez: defter 0 ms'de gelir. Backend yanıt verince
/// satırlar tek tek güncellenir; her tutar yine ürün sayfasından okunmuş
/// olmak zorundadır.
class HybridPriceService implements PriceService {
  HybridPriceService({
    PriceBookService? book,
    ApiClient? apiClient,
    LivePriceService? liveFallback,
  })  : _book = book ?? const PriceBookService(),
        _api = apiClient,
        _liveFallback = liveFallback;

  factory HybridPriceService.create() {
    final hasApi =
        AppConfig.useLivePrices && !AppConfig.apiBaseUrl.contains('example.com');
    return HybridPriceService(
      apiClient: hasApi ? ApiClient() : null,
      liveFallback: hasApi ? LivePriceService.backend() : null,
    );
  }

  final PriceBookService _book;
  final ApiClient? _api;
  final LivePriceService? _liveFallback;

  bool get canStreamLive => _api != null;

  @override
  Future<List<ProductType>> searchProductTypes(String query) async {
    return _book.searchProductTypes(query);
  }

  @override
  Future<ComparisonResult> compareBasket(List<ListItem> items) async {
    if (!canStreamLive) {
      return _book.compareBasket(items);
    }
    ComparisonResult? last;
    await for (final snapshot in watchBasketComparison(items)) {
      last = snapshot;
    }
    return last ?? _book.compareBasket(items);
  }

  /// Defter anında, sonra market market canlı güncelleme.
  Stream<ComparisonResult> watchBasketComparison(List<ListItem> items) async* {
    final preview = await _book.compareBasket(items);

    if (_api == null) {
      yield preview;
      return;
    }

    yield preview.copyWith(refreshing: true);

    try {
      var merged = preview.copyWith(
        source: PriceSource.live,
        refreshing: true,
      );
      await for (final chunk in _api.postNdjsonStream(
        '/v1/compare/stream',
        _payload(items),
      )) {
        if (chunk['event'] == 'market') {
          final batchJson = chunk['market'] as Map<String, dynamic>;
          final batch = MarketQuoteBatch.fromJson(batchJson);
          merged = _mergeMarket(merged, batch, items);
          final fetchedAt = chunk['pricesFetchedAt'] as String?;
          yield merged.copyWith(
            pricesFetchedAt: fetchedAt ?? merged.pricesFetchedAt,
            refreshing: true,
          );
        } else if (chunk['event'] == 'done') {
          yield merged.copyWith(refreshing: false);
        }
      }
    } catch (_) {
      // Akış düşerse paralel market isteklerine düş.
      if (_liveFallback != null) {
        final live = await _liveFallback.compareBasket(items);
        yield live;
        return;
      }
      yield preview;
    }
  }

  Map<String, dynamic> _payload(List<ListItem> items) => {
        'region': AppConfig.defaultRegion,
        'items': [
          for (final item in items)
            {
              'productId': item.product.id,
              'typeId': item.product.typeId,
              'brand': item.product.brand,
              'quantity': item.quantity,
              'name': item.product.displayName,
            },
        ],
      };

  ComparisonResult _mergeMarket(
    ComparisonResult current,
    MarketQuoteBatch batch,
    List<ListItem> items,
  ) {
    final updated = LivePriceService.toBasketResult(batch, items);
    final baskets = [
      for (final basket in current.baskets)
        if (basket.market.id == batch.marketId) updated else basket,
    ];
    return ComparisonResult(
      baskets: baskets,
      comparedAt: DateTime.now(),
      source: PriceSource.live,
      pricesFetchedAt: current.pricesFetchedAt,
      refreshing: true,
    );
  }
}

import '../config/app_config.dart';
import '../data/mock_catalog.dart';
import '../models/comparison_result.dart';
import '../models/fetch_status.dart';
import '../models/list_item.dart';
import '../models/market_quote.dart';
import '../models/product.dart';
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
  Future<List<Product>> searchCatalogProducts(String query) async {
    return const [];
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
          final bookFetchedAt = chunk['bookFetchedAt'] as String?;
          yield merged.copyWith(
            pricesFetchedAt: fetchedAt ?? bookFetchedAt ?? merged.pricesFetchedAt,
            refreshing: true,
          );
        } else if (chunk['event'] == 'done') {
          yield merged.copyWith(refreshing: false);
        }
      }
    } catch (_) {
      // Akış düşerse defter fiyatlarını koru; boş canlı yanıt defteri silmesin.
      if (_liveFallback != null) {
        try {
          final live = await _liveFallback.compareBasket(items);
          yield _mergePreviewWithLive(preview, live);
          return;
        } catch (_) {}
      }
      yield preview.copyWith(refreshing: false);
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
    final liveBasket = LivePriceService.toBasketResult(batch, items);
    final bookBasket = current.baskets.firstWhere(
      (b) => b.market.id == batch.marketId,
    );
    final mergedBasket = _mergeBaskets(bookBasket, liveBasket);

    final baskets = [
      for (final basket in current.baskets)
        if (basket.market.id == batch.marketId) mergedBasket else basket,
    ];
    return ComparisonResult(
      baskets: baskets,
      comparedAt: DateTime.now(),
      source: PriceSource.live,
      pricesFetchedAt: current.pricesFetchedAt,
      refreshing: true,
    );
  }

  /// Canlı yanıt geçerliyse onu al; yoksa defter satırını koru.
  ComparisonResult _mergePreviewWithLive(
    ComparisonResult preview,
    ComparisonResult live,
  ) {
    final liveByMarket = {for (final b in live.baskets) b.market.id: b};
    final baskets = preview.baskets.map((bookBasket) {
      final liveBasket = liveByMarket[bookBasket.market.id];
      if (liveBasket == null) return bookBasket;
      return _mergeBaskets(bookBasket, liveBasket);
    }).toList();

    return ComparisonResult(
      baskets: baskets,
      comparedAt: DateTime.now(),
      source: PriceSource.live,
      pricesFetchedAt: live.pricesFetchedAt ?? preview.pricesFetchedAt,
      refreshing: false,
    );
  }

  MarketBasketResult _mergeBaskets(
    MarketBasketResult book,
    MarketBasketResult live,
  ) {
    final liveByProduct = {for (final l in live.lines) l.product.id: l};
    final mergedLines = [
      for (final bookLine in book.lines)
        _preferPricedLine(
          liveByProduct[bookLine.product.id],
          bookLine,
        ),
    ];

    final hasLivePrice = mergedLines.any((l) {
      final liveLine = liveByProduct[l.product.id];
      return liveLine?.available ?? false;
    });

    return MarketBasketResult(
      market: book.market,
      lines: mergedLines,
      fetchedAt: live.fetchedAt,
      status: live.status.isFailed && !hasLivePrice ? book.status : live.status,
      errorMessage:
          live.status.isFailed && !hasLivePrice ? book.errorMessage : live.errorMessage,
      storeId: live.storeId ?? book.storeId,
    );
  }

  LinePrice _preferPricedLine(LinePrice? live, LinePrice book) {
    if (live != null && live.available) return live;
    if (book.available) return book;
    return live ?? book;
  }
}

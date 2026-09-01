import '../../config/app_config.dart';
import '../../data/mock_catalog.dart';
import '../../models/comparison_result.dart';
import '../../models/fetch_status.dart';
import '../../models/list_item.dart';
import '../../models/product.dart';
import '../../models/product_link.dart';
import '../hybrid_price_service.dart';
import '../price_book_service.dart';
import '../price_service.dart';
import 'market_fiyati_client.dart';

/// Market Fiyatı uygulamasından canlı katalog ve anlık şube fiyatı.
///
/// Kullanıcı araması 50 bin+ ürüne gider. Karşılaştırma, seçilen ürünün
/// yakındaki A101 / BİM / Şok / Migros / CarrefourSA / Hakmar / Tarım Kredi
/// şube fiyatını resmi API'den okur.
class MarketFiyatiPriceService implements PriceService {
  MarketFiyatiPriceService({
    MarketFiyatiClient? client,
    PriceBookService? book,
    HybridPriceService? fallback,
  })  : _client = client ?? MarketFiyatiClient(),
        _book = book ?? const PriceBookService(),
        _fallback = fallback;

  final MarketFiyatiClient _client;
  final PriceBookService _book;
  final HybridPriceService? _fallback;

  bool get canStreamLive => true;

  @override
  Future<List<ProductType>> searchProductTypes(String query) {
    return _book.searchProductTypes(query);
  }

  @override
  Future<List<Product>> searchCatalogProducts(String query) async {
    final q = query.trim();
    if (q.isEmpty) return const [];
    try {
      final hits = await _client.search(q, region: AppConfig.defaultRegion);
      return [for (final hit in hits) hit.toProduct()];
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<ComparisonResult> compareBasket(List<ListItem> items) async {
    ComparisonResult? last;
    await for (final snapshot in watchBasketComparison(items)) {
      last = snapshot;
    }
    return last ?? _book.compareBasket(items);
  }

  Stream<ComparisonResult> watchBasketComparison(List<ListItem> items) async* {
    final preview = await _book.compareBasket(items);
    yield preview.copyWith(refreshing: true, source: PriceSource.live);

    try {
      var merged = preview.copyWith(source: PriceSource.live, refreshing: true);
      for (final item in items) {
        final product = await _resolve(item.product);
        if (product == null) continue;
        merged = _mergeProduct(merged, item, product);
        yield merged.copyWith(refreshing: true);
      }
      yield merged.copyWith(refreshing: false);
    } catch (_) {
      if (_fallback != null) {
        await for (final snapshot in _fallback.watchBasketComparison(items)) {
          yield snapshot;
        }
        return;
      }
      yield preview.copyWith(refreshing: false);
    }
  }

  Future<MfProduct?> _resolve(Product product) async {
    if (product.id.startsWith('mf:')) {
      return _client.byId(
        product.id.substring(3),
        region: AppConfig.defaultRegion,
        keywords: product.displayName,
      );
    }
    final hits = await _client.search(
      product.displayName,
      region: AppConfig.defaultRegion,
    );
    if (hits.isEmpty) return null;
    hits.sort(
      (a, b) => b
          .score(brand: product.brand, name: product.name)
          .compareTo(a.score(brand: product.brand, name: product.name)),
    );
    final best = hits.first;
    if (best.score(brand: product.brand, name: product.name) < 4) {
      return null;
    }
    return best;
  }

  ComparisonResult _mergeProduct(
    ComparisonResult current,
    ListItem item,
    MfProduct live,
  ) {
    final byMarket = live.cheapestByMarket();
    final baskets = [
      for (final basket in current.baskets)
        _mergeBasket(basket, item, live, byMarket[basket.market.id.name]),
    ];
    return ComparisonResult(
      baskets: baskets,
      comparedAt: DateTime.now(),
      source: PriceSource.live,
      pricesFetchedAt: DateTime.now().toUtc().toIso8601String(),
      refreshing: true,
    );
  }

  MarketBasketResult _mergeBasket(
    MarketBasketResult basket,
    ListItem item,
    MfProduct live,
    MfDepot? depot,
  ) {
    final lines = [
      for (final line in basket.lines)
        if (line.product.id == item.product.id && depot != null)
          LinePrice(
            product: item.product,
            quantity: item.quantity,
            unitPrice: depot.price,
            marketProduct: depot.productName,
            source: ProductLink(
              url: live.sourceUrl,
              kind: ProductLinkKind.product,
            ),
          )
        else
          line,
    ];
    return MarketBasketResult(
      market: basket.market,
      lines: lines,
      fetchedAt: DateTime.now(),
      status: FetchStatus.ok,
      storeId: depot?.depotId ?? basket.storeId,
    );
  }
}

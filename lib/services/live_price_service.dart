import '../config/app_config.dart';
import '../data/mock_catalog.dart';
import '../models/comparison_result.dart';
import '../models/fetch_status.dart';
import '../models/list_item.dart';
import '../models/market.dart';
import '../models/market_quote.dart';
import 'catalog/catalog_client.dart';
import 'http/api_client.dart';
import 'mapping/product_sku_map.dart';
import 'markets/backend_market_price_client.dart';
import 'markets/market_price_client.dart';
import 'price_service.dart';

/// Canlı fiyat orkestratörü.
///
/// 1. Market istemcilerine paralel istek atar
/// 2. Kısmi hataları tolere eder
/// 3. [ComparisonResult] üretir
///
/// Tercihen uygulama kendi backend’ine bağlanır; market sitelerine
/// doğrudan scraping/API çağrısı bu katmanda yapılmaz.
class LivePriceService implements PriceService {
  LivePriceService({
    required List<MarketPriceClient> marketClients,
    required CatalogClient catalogClient,
    ProductSkuMap? skuMap,
    this.region = AppConfig.defaultRegion,
    this.allowPartialFailures = AppConfig.allowPartialMarketFailures,
  })  : _clients = marketClients,
        _catalog = catalogClient,
        _skuMap = skuMap ?? ProductSkuMap.seed();

  /// Varsayılan üretim kurulumu: backend market + yerel katalog fallback.
  factory LivePriceService.backend({
    ApiClient? apiClient,
    CatalogClient? catalogClient,
    String region = AppConfig.defaultRegion,
  }) {
    final api = apiClient ?? ApiClient();
    return LivePriceService(
      marketClients: MarketClients.all(api),
      catalogClient: catalogClient ??
          _ResilientCatalogClient(
            primary: BackendCatalogClient(api),
            fallback: LocalCatalogClient(),
          ),
      region: region,
    );
  }

  /// Backend yokken entegrasyon akışını test etmek için.
  factory LivePriceService.stubbed() {
    const factors = <MarketId, double>{
      MarketId.tarimKredi: 0.89,
      MarketId.bim: 0.91,
      MarketId.hakmar: 0.92,
      MarketId.a101: 0.93,
      MarketId.sok: 0.94,
      MarketId.metro: 0.95,
      MarketId.onur: 0.98,
      MarketId.file: 0.99,
      MarketId.happyCenter: 1.00,
      MarketId.migros: 1.05,
      MarketId.carrefour: 1.06,
      MarketId.getir: 1.12,
      MarketId.macrocenter: 1.24,
    };

    return LivePriceService(
      marketClients: Market.all
          .map(
            (market) => StubMarketPriceClient(
              marketId: market.id,
              priceFactor: factors[market.id] ?? 1.0,
            ),
          )
          .toList(),
      catalogClient: LocalCatalogClient(),
    );
  }

  final List<MarketPriceClient> _clients;
  final CatalogClient _catalog;
  final ProductSkuMap _skuMap;
  final String region;
  final bool allowPartialFailures;

  @override
  Future<List<ProductType>> searchProductTypes(String query) =>
      _catalog.search(query);

  @override
  Future<ComparisonResult> compareBasket(List<ListItem> items) async {
    final futures = _clients.map((client) {
      return client.fetchBasketQuotes(
        items: items,
        skuMap: _skuMap,
        region: region,
      );
    });

    final batches = await Future.wait(futures);
    final okCount = batches.where((b) => b.status.isOk).length;

    if (okCount == 0) {
      throw StateError('Hiçbir marketten fiyat alınamadı.');
    }
    if (!allowPartialFailures && okCount < batches.length) {
      throw StateError('Bazı marketler yanıt vermedi.');
    }

    final baskets = batches.map((batch) {
      return _toBasketResult(batch, items);
    }).toList();

    return ComparisonResult(
      baskets: baskets,
      comparedAt: DateTime.now(),
      source: PriceSource.live,
    );
  }

  MarketBasketResult _toBasketResult(
    MarketQuoteBatch batch,
    List<ListItem> items,
  ) {
    final market = Market.byId(batch.marketId);
    final byProduct = {
      for (final q in batch.quotes) q.productId: q,
    };

    if (batch.status.isFailed) {
      return MarketBasketResult(
        market: market,
        lines: items
            .map(
              (item) => LinePrice(
                product: item.product,
                quantity: item.quantity,
                unitPrice: 0,
                available: false,
              ),
            )
            .toList(),
        fetchedAt: batch.fetchedAt,
        status: FetchStatus.failed,
        errorMessage: batch.errorMessage,
        storeId: batch.storeId,
      );
    }

    final lines = items.map((item) {
      final quote = byProduct[item.product.id];
      if (quote == null) {
        return LinePrice(
          product: item.product,
          quantity: item.quantity,
          unitPrice: 0,
          available: false,
        );
      }
      return LinePrice(
        product: item.product,
        quantity: item.quantity,
        unitPrice: quote.unitPrice,
        available: quote.available,
      );
    }).toList();

    return MarketBasketResult(
      market: market,
      lines: lines,
      fetchedAt: batch.fetchedAt,
      status: FetchStatus.ok,
      storeId: batch.storeId,
    );
  }
}

/// Katalog: önce backend, hata olursa yerel.
class _ResilientCatalogClient implements CatalogClient {
  _ResilientCatalogClient({
    required this.primary,
    required this.fallback,
  });

  final CatalogClient primary;
  final CatalogClient fallback;

  @override
  Future<List<ProductType>> search(String query) async {
    try {
      return await primary.search(query);
    } catch (_) {
      return fallback.search(query);
    }
  }
}

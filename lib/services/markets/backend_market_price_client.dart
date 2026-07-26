import '../../models/fetch_status.dart';
import '../../models/list_item.dart';
import '../../models/market.dart';
import '../../models/market_quote.dart';
import '../http/api_client.dart';
import '../mapping/product_sku_map.dart';
import 'market_price_client.dart';

/// Backend üzerinden tek market fiyatı.
///
/// Beklenen endpoint:
/// `POST /v1/markets/{slug}/quotes`
///
/// Body:
/// ```json
/// {
///   "region": "istanbul",
///   "storeId": null,
///   "items": [
///     { "productId": "sut-1l", "externalSku": "MIG-SUT-1L", "quantity": 2 }
///   ]
/// }
/// ```
///
/// Response:
/// ```json
/// {
///   "marketId": "migros",
///   "status": "ok",
///   "fetchedAt": "2026-07-26T08:00:00.000Z",
///   "storeId": "store-42",
///   "quotes": [
///     {
///       "productId": "sut-1l",
///       "externalSku": "MIG-SUT-1L",
///       "unitPrice": 41.5,
///       "available": true,
///       "currency": "TRY"
///     }
///   ]
/// }
/// ```
class BackendMarketPriceClient implements MarketPriceClient {
  BackendMarketPriceClient({
    required this.marketId,
    required ApiClient apiClient,
    String? slug,
  })  : _api = apiClient,
        slug = slug ?? marketId.name;

  @override
  final MarketId marketId;
  final ApiClient _api;
  final String slug;

  @override
  Future<MarketQuoteBatch> fetchBasketQuotes({
    required List<ListItem> items,
    required ProductSkuMap skuMap,
    String? region,
    String? storeId,
  }) async {
    try {
      final payload = <String, dynamic>{
        'region': region,
        'storeId': storeId,
        'items': items.map((item) {
          return {
            'productId': item.product.id,
            'externalSku': skuMap.skuFor(marketId, item.product.id),
            'quantity': item.quantity,
            'name': item.product.displayName,
          };
        }).toList(),
      };

      final json = await _api.postJson('/v1/markets/$slug/quotes', payload);
      final batch = MarketQuoteBatch.fromJson({
        ...json,
        'marketId': json['marketId'] ?? marketId.name,
      });
      return batch;
    } on ApiException catch (e) {
      return MarketQuoteBatch.failed(
        marketId: marketId,
        message: e.message,
      );
    } catch (e) {
      return MarketQuoteBatch.failed(
        marketId: marketId,
        message: e.toString(),
      );
    }
  }
}

/// Hazır market istemcileri — slug’lar backend route’larıyla uyumlu tutulmalı.
class MarketClients {
  const MarketClients._();

  static List<MarketPriceClient> all(ApiClient api) => [
        BackendMarketPriceClient(marketId: MarketId.migros, apiClient: api),
        BackendMarketPriceClient(marketId: MarketId.a101, apiClient: api),
        BackendMarketPriceClient(
          marketId: MarketId.sok,
          apiClient: api,
          slug: 'sok',
        ),
        BackendMarketPriceClient(
          marketId: MarketId.carrefour,
          apiClient: api,
        ),
        BackendMarketPriceClient(marketId: MarketId.file, apiClient: api),
      ];
}

/// Backend yokken iskeleti doğrulamak için sabit yanıt üreten istemci.
class StubMarketPriceClient implements MarketPriceClient {
  StubMarketPriceClient({
    required this.marketId,
    this.priceFactor = 1.0,
    this.shouldFail = false,
  });

  @override
  final MarketId marketId;
  final double priceFactor;
  final bool shouldFail;

  @override
  Future<MarketQuoteBatch> fetchBasketQuotes({
    required List<ListItem> items,
    required ProductSkuMap skuMap,
    String? region,
    String? storeId,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    if (shouldFail) {
      return MarketQuoteBatch.failed(
        marketId: marketId,
        message: '${marketId.name} stub failure',
      );
    }

    return MarketQuoteBatch(
      marketId: marketId,
      status: FetchStatus.ok,
      fetchedAt: DateTime.now(),
      storeId: storeId ?? 'stub-store',
      quotes: items.map((item) {
        final base = 50.0 + item.product.id.hashCode % 40;
        return ProductQuote(
          productId: item.product.id,
          externalSku: skuMap.skuFor(marketId, item.product.id),
          unitPrice: double.parse((base * priceFactor).toStringAsFixed(2)),
          available: true,
        );
      }).toList(),
    );
  }
}

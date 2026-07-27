import '../../config/app_config.dart';
import '../../models/list_item.dart';
import '../../models/market.dart';
import '../../models/market_quote.dart';
import '../http/api_client.dart';
import '../mapping/product_sku_map.dart';
import 'market_price_client.dart';
import 'quote_cache.dart';

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
///       "currency": "TRY",
///       "marketProduct": "İçim Süt Tam Yağlı 1 L",
///       "sourceUrl": "https://www.migros.com.tr/icim-sut-tam-yagli-1-l-p-1a2b3c"
///     }
///   ]
/// }
/// ```
///
/// `sourceUrl` zorunludur: fiyatın okunduğu ürün sayfası gelmezse uygulama o
/// satırı fiyatsız gösterir, çünkü kullanıcı tutarı tıklayıp doğrulayamaz.
class BackendMarketPriceClient implements MarketPriceClient {
  BackendMarketPriceClient({
    required this.marketId,
    required ApiClient apiClient,
    String? slug,
    QuoteCache? cache,
  })  : _api = apiClient,
        _cache = cache,
        slug = slug ?? marketId.name;

  @override
  final MarketId marketId;
  final ApiClient _api;
  final QuoteCache? _cache;
  final String slug;

  @override
  Future<MarketQuoteBatch> fetchBasketQuotes({
    required List<ListItem> items,
    required ProductSkuMap skuMap,
    String? region,
    String? storeId,
  }) async {
    final cacheKey = _cache?.keyFor(
      marketId: marketId,
      items: items,
      region: region,
      storeId: storeId,
    );
    if (cacheKey != null) {
      final cached = _cache!.read(cacheKey);
      if (cached != null) return cached;
    }

    try {
      final payload = <String, dynamic>{
        'region': region,
        'storeId': storeId,
        'items': items.map((item) {
          return {
            'productId': item.product.id,
            'typeId': item.product.typeId,
            'brand': item.product.brand,
            'externalSku': skuMap.skuFor(marketId, item.product.typeId),
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
      if (cacheKey != null) _cache!.write(cacheKey, batch);
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

  static const slugs = <MarketId, String>{
    MarketId.migros: 'migros',
    MarketId.macrocenter: 'macrocenter',
    MarketId.a101: 'a101',
    MarketId.bim: 'bim',
    MarketId.sok: 'sok',
    MarketId.carrefour: 'carrefour',
    MarketId.file: 'file',
    MarketId.tarimKredi: 'tarim-kredi',
    MarketId.hakmar: 'hakmar',
    MarketId.onur: 'onur',
    MarketId.happyCenter: 'happy-center',
    MarketId.metro: 'metro',
    MarketId.getir: 'getir',
  };

  static List<MarketPriceClient> all(ApiClient api, {QuoteCache? cache}) {
    final sharedCache = cache ?? QuoteCache(ttl: AppConfig.quoteCacheTtl);
    // Fiyatını kendi sitesinde yayınlamayan zincir için teklif istenmez.
    return Market.priced
        .map(
          (market) => BackendMarketPriceClient(
            marketId: market.id,
            apiClient: api,
            slug: slugs[market.id] ?? market.id.name,
            cache: sharedCache,
          ),
        )
        .toList();
  }
}
import 'package:flutter_test/flutter_test.dart';
import 'package:sepet_karsilastir/config/app_config.dart';
import 'package:sepet_karsilastir/data/mock_catalog.dart';
import 'package:sepet_karsilastir/models/fetch_status.dart';
import 'package:sepet_karsilastir/models/list_item.dart';
import 'package:sepet_karsilastir/models/market.dart';
import 'package:sepet_karsilastir/models/market_quote.dart';
import 'package:sepet_karsilastir/services/catalog/catalog_client.dart';
import 'package:sepet_karsilastir/services/live_price_service.dart';
import 'package:sepet_karsilastir/services/mapping/product_sku_map.dart';
import 'package:sepet_karsilastir/services/markets/backend_market_price_client.dart';
import 'package:sepet_karsilastir/services/markets/market_price_client.dart';
import 'package:sepet_karsilastir/services/markets/quote_cache.dart';

void main() {
  final milk = productTypes.firstWhere((t) => t.id == 'sut-1l').withBrand('İçim');
  final items = [ListItem(product: milk)];
  final skuMap = ProductSkuMap.seed();

  test('quote cache aynı anahtarı TTL içinde döner', () {
    final cache = QuoteCache(ttl: const Duration(seconds: 30));
    final key = cache.keyFor(marketId: MarketId.bim, items: items);
    final batch = MarketQuoteBatch(
      marketId: MarketId.bim,
      status: FetchStatus.ok,
      fetchedAt: DateTime.now(),
      quotes: [
        ProductQuote(
          productId: milk.id,
          unitPrice: 39.9,
          available: true,
        ),
      ],
    );

    expect(cache.read(key), isNull);
    cache.write(key, batch);
    expect(cache.read(key)?.quotes.first.unitPrice, 39.9);
  });

  test('başarısız batch önbelleğe yazılmaz', () {
    final cache = QuoteCache();
    final key = cache.keyFor(marketId: MarketId.a101, items: items);
    cache.write(
      key,
      MarketQuoteBatch.failed(marketId: MarketId.a101, message: 'timeout'),
    );
    expect(cache.read(key), isNull);
  });

  test('live stubbed servis 13 market sonucu üretir', () async {
    final service = LivePriceService.stubbed();
    final result = await service.compareBasket(items);
    expect(result.baskets, hasLength(Market.all.length));
    expect(result.source.name, 'live');
    expect(result.cheapestComplete, isNotNull);
  });

  test('kısmi market hatası tolere edilir', () async {
    final clients = <MarketPriceClient>[
      StubMarketPriceClient(marketId: MarketId.bim, priceFactor: 0.9),
      StubMarketPriceClient(marketId: MarketId.migros, shouldFail: true),
    ];
    final service = LivePriceService(
      marketClients: clients,
      catalogClient: LocalCatalogClient(),
      allowPartialFailures: AppConfig.allowPartialMarketFailures,
    );

    final result = await service.compareBasket(items);
    expect(result.failedMarketCount, 1);
    expect(result.cheapestComplete?.market.id, MarketId.bim);
  });

  test('tüm marketler düşerse hata fırlatır', () async {
    final service = LivePriceService(
      marketClients: [
        StubMarketPriceClient(marketId: MarketId.bim, shouldFail: true),
      ],
      catalogClient: LocalCatalogClient(),
    );

    expect(
      () => service.compareBasket(items),
      throwsA(isA<StateError>()),
    );
  });

  test('stub istemci SKU map kullanır', () async {
    final client = StubMarketPriceClient(marketId: MarketId.migros);
    final batch = await client.fetchBasketQuotes(
      items: items,
      skuMap: skuMap,
    );
    expect(batch.status.isOk, isTrue);
    expect(batch.quotes, hasLength(1));
    expect(batch.quotes.first.externalSku, isNotNull);
  });
}

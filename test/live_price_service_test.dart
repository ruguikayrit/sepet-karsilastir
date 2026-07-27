import 'package:flutter_test/flutter_test.dart';
import 'package:sepet_karsilastir/config/app_config.dart';
import 'package:sepet_karsilastir/data/mock_catalog.dart';
import 'package:sepet_karsilastir/models/fetch_status.dart';
import 'package:sepet_karsilastir/models/list_item.dart';
import 'package:sepet_karsilastir/models/market.dart';
import 'package:sepet_karsilastir/models/market_quote.dart';
import 'package:sepet_karsilastir/models/product_link.dart';
import 'package:sepet_karsilastir/services/catalog/catalog_client.dart';
import 'package:sepet_karsilastir/services/live_price_service.dart';
import 'package:sepet_karsilastir/services/mapping/product_sku_map.dart';
import 'package:sepet_karsilastir/services/markets/market_price_client.dart';
import 'package:sepet_karsilastir/services/markets/quote_cache.dart';
import 'package:sepet_karsilastir/services/price_book_service.dart';
import 'package:sepet_karsilastir/services/price_service.dart';

/// Backend yerine sabit teklif döndüren istemci.
class _FakeMarketClient implements MarketPriceClient {
  _FakeMarketClient({
    required this.marketId,
    this.quote,
    this.shouldFail = false,
  });

  @override
  final MarketId marketId;

  /// Bu marketin sepetteki tek ürün için verdiği teklif; `null` ise ürün yok.
  final ProductQuote? quote;
  final bool shouldFail;

  @override
  Future<MarketQuoteBatch> fetchBasketQuotes({
    required List<ListItem> items,
    required ProductSkuMap skuMap,
    String? region,
    String? storeId,
  }) async {
    if (shouldFail) {
      return MarketQuoteBatch.failed(
        marketId: marketId,
        message: '${marketId.name} yanıt vermedi',
      );
    }
    return MarketQuoteBatch(
      marketId: marketId,
      status: FetchStatus.ok,
      fetchedAt: DateTime(2026, 7, 26),
      storeId: storeId,
      quotes: [if (quote != null) quote!],
    );
  }
}

/// Canlı kaynakta da kural aynı: fiyat, ancak o fiyatın okunduğu ürün sayfası
/// birlikte geldiyse gösterilir. Backend sayfa adresi vermiyorsa satır
/// fiyatsız kalır — tahmini tutar üretilmez.
void main() {
  final milk =
      productTypes.firstWhere((t) => t.id == 'sut-1l').withBrand('İçim');
  final items = [ListItem(product: milk)];

  LivePriceService serviceOf(List<MarketPriceClient> clients) =>
      LivePriceService(
        marketClients: clients,
        catalogClient: LocalCatalogClient(),
        allowPartialFailures: AppConfig.allowPartialMarketFailures,
      );

  test('quote cache aynı anahtarı TTL içinde döner', () {
    final cache = QuoteCache(ttl: const Duration(seconds: 30));
    final key = cache.keyFor(marketId: MarketId.sok, items: items);
    final batch = MarketQuoteBatch(
      marketId: MarketId.sok,
      status: FetchStatus.ok,
      fetchedAt: DateTime.now(),
      quotes: [
        ProductQuote(productId: milk.id, unitPrice: 39.9, available: true),
      ],
    );

    expect(cache.read(key), isNull);
    cache.write(key, batch);
    expect(cache.read(key)?.quotes.first.unitPrice, 39.9);
  });

  test('başarısız batch önbelleğe yazılmaz', () {
    final cache = QuoteCache();
    final key = cache.keyFor(marketId: MarketId.migros, items: items);
    cache.write(
      key,
      MarketQuoteBatch.failed(marketId: MarketId.migros, message: 'timeout'),
    );
    expect(cache.read(key), isNull);
  });

  test('ürün sayfası gelen teklif fiyatlanır ve o sayfaya bağlanır', () async {
    const url = 'https://www.sokmarket.com.tr/icim-sut-tam-yagli-1-l-p-1234';
    final result = await serviceOf([
      _FakeMarketClient(
        marketId: MarketId.sok,
        quote: ProductQuote(
          productId: milk.id,
          unitPrice: 45.5,
          available: true,
          marketProduct: 'İçim Süt Tam Yağlı 1 L',
          sourceUrl: url,
        ),
      ),
    ]).compareBasket(items);

    expect(result.source.name, 'live');
    final line = result.baskets.single.lines.single;
    expect(line.unitPrice, 45.5);
    expect(line.marketProduct, 'İçim Süt Tam Yağlı 1 L');
    expect(line.sourceUrl, url);
    expect(line.source!.kind, ProductLinkKind.product);
    expect(line.opensPricedProduct, isTrue);
    expect(result.cheapestComplete?.market.id, MarketId.sok);
  });

  test('ürün sayfası gelmeyen teklif fiyat göstermez', () async {
    final result = await serviceOf([
      _FakeMarketClient(
        marketId: MarketId.sok,
        quote: ProductQuote(
          productId: milk.id,
          unitPrice: 45.5,
          available: true,
        ),
      ),
    ]).compareBasket(items);

    final line = result.baskets.single.lines.single;
    expect(line.unitPrice, isNull, reason: 'doğrulanamayan fiyat gösterilmez');
    expect(line.lineTotal, 0);
    expect(result.baskets.single.total, 0);
    expect(line.source!.kind, isNot(ProductLinkKind.product));
    expect(result.cheapestComplete, isNull);
  });

  test('stokta olmayan ürün fiyatsız kalır', () async {
    final result = await serviceOf([
      _FakeMarketClient(
        marketId: MarketId.sok,
        quote: ProductQuote(
          productId: milk.id,
          unitPrice: 45.5,
          available: false,
          sourceUrl: 'https://www.sokmarket.com.tr/icim-sut-1-l-p-1234',
        ),
      ),
    ]).compareBasket(items);

    expect(result.baskets.single.lines.single.available, isFalse);
  });

  test('kısmi market hatası tolere edilir', () async {
    final result = await serviceOf([
      _FakeMarketClient(
        marketId: MarketId.hakmar,
        quote: ProductQuote(
          productId: milk.id,
          unitPrice: 40,
          available: true,
          sourceUrl: 'https://www.hakmarexpress.com.tr/icim-sut-1-lt-1009-p',
        ),
      ),
      _FakeMarketClient(marketId: MarketId.migros, shouldFail: true),
    ]).compareBasket(items);

    expect(result.failedMarketCount, 1);
    expect(result.cheapestComplete?.market.id, MarketId.hakmar);
    // Yanıt vermeyen market satırında tutar yok.
    final migros =
        result.baskets.firstWhere((b) => b.market.id == MarketId.migros);
    expect(migros.lines.single.unitPrice, isNull);
    expect(migros.fetchFailed, isTrue);
  });

  test('tüm marketler düşerse hata fırlatır', () async {
    final service = serviceOf([
      _FakeMarketClient(marketId: MarketId.sok, shouldFail: true),
    ]);

    expect(
      () => service.compareBasket(items),
      throwsA(isA<StateError>()),
    );
  });

  test('backend adresi verilmediyse fiyat defteri kullanılır', () {
    // Uydurma fiyat üreten taklit servis yok: canlı kaynak yoksa defter.
    expect(createPriceService(useLive: true), isA<PriceBookService>());
  });
}

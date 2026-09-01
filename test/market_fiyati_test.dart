import 'package:flutter_test/flutter_test.dart';
import 'package:sepet_karsilastir/models/list_item.dart';
import 'package:sepet_karsilastir/models/market.dart';
import 'package:sepet_karsilastir/services/market_fiyati/market_fiyati_client.dart';
import 'package:sepet_karsilastir/services/market_fiyati/market_fiyati_price_service.dart';
import 'package:sepet_karsilastir/services/price_book_service.dart';

class _FakeClient extends MarketFiyatiClient {
  _FakeClient(this.product);

  final MfProduct product;

  @override
  Future<List<MfProduct>> search(
    String keywords, {
    String region = 'istanbul',
    int size = 24,
  }) async =>
      [product];

  @override
  Future<MfProduct?> byId(
    String id, {
    String region = 'istanbul',
    String? keywords,
  }) async =>
      product.id == id ? product : null;
}

void main() {
  final icim = MfProduct(
    id: '1T9S',
    title: 'İçim Süt 1 Lt',
    brand: 'İçim',
    volume: '1 LT',
    category: 'Süt Ürünleri ve Kahvaltılık',
    depots: const [
      MfDepot(
        marketId: 'a101',
        depotId: 'a101-1',
        depotName: 'A101 Kadıköy',
        price: 59.5,
        productName: 'İçim Süt 1 Lt',
      ),
      MfDepot(
        marketId: 'bim',
        depotId: 'bim-1',
        depotName: 'BİM Moda',
        price: 57.9,
        productName: 'İçim Süt 1 Lt',
      ),
      MfDepot(
        marketId: 'sok',
        depotId: 'sok-1',
        depotName: 'Şok Caferağa',
        price: 61.0,
        productName: 'İçim Süt 1 Lt',
      ),
    ],
  );

  test('Market Fiyatı ürünü A101 ve BİM fiyatını canlı yazar', () async {
    final service = MarketFiyatiPriceService(
      client: _FakeClient(icim),
      book: const PriceBookService(),
    );
    final product = icim.toProduct();
    final snapshots = await service
        .watchBasketComparison([ListItem(product: product)]).toList();

    final last = snapshots.last;
    expect(last.refreshing, isFalse);
    final a101 = last.baskets.firstWhere((b) => b.market.id == MarketId.a101);
    final bim = last.baskets.firstWhere((b) => b.market.id == MarketId.bim);
    expect(a101.lines.single.unitPrice, 59.5);
    expect(bim.lines.single.unitPrice, 57.9);
    expect(a101.lines.single.sourceUrl, contains('marketfiyati.org.tr'));
  });

  test('canlı katalog araması Market Fiyatı ürünlerini döner', () async {
    final service = MarketFiyatiPriceService(
      client: _FakeClient(icim),
      book: const PriceBookService(),
    );
    final results = await service.searchCatalogProducts('icim sut');
    expect(results.single.id, 'mf:1T9S');
    expect(results.single.brand, 'İçim');
    expect(results.single.name, 'Süt');
    expect(results.single.unit, '1 LT');
  });

  test('canlı ürün marka, ad ve ebatı ayırır', () {
    final product = icim.toProduct();
    expect(product.brandLabel, 'İçim');
    expect(product.name, 'Süt');
    expect(product.sizeLabel, '1 LT');
    expect(product.displayName, 'İçim Süt');
  });
}

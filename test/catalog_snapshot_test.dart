import 'package:flutter_test/flutter_test.dart';
import 'package:sepet_karsilastir/data/brands.dart';
import 'package:sepet_karsilastir/data/market_price_snapshot.dart';
import 'package:sepet_karsilastir/data/mock_catalog.dart';
import 'package:sepet_karsilastir/models/list_item.dart';
import 'package:sepet_karsilastir/models/market.dart';
import 'package:sepet_karsilastir/services/mapping/product_source_url.dart';
import 'package:sepet_karsilastir/services/mock_price_service.dart';

void main() {
  test('katalog resmi market fiyat snapshot’ı ile genişletildi', () {
    expect(productTypes.length, greaterThanOrEqualTo(70));
    expect(marketPriceSnapshot.length, productTypes.length);
    expect(marketPriceSnapshotSources, contains('https://www.sokmarket.com.tr'));
    expect(marketPriceSnapshotSources, contains('https://happycenter.com.tr'));

    for (final type in productTypes) {
      final ref = marketPriceSnapshot[type.id];
      expect(ref, isNotNull, reason: '${type.id} snapshot’ta yok');
      expect(ref!.unitPrice, greaterThan(0));
      expect(ref.sampleProduct, isNotEmpty);
      expect(
        ref.sokPath != null || ref.happyCenterPath != null,
        isTrue,
        reason: '${type.id} için market yolu yok',
      );
    }
  });

  test('yeni kategoriler için marka önerisi var', () {
    expect(brandsForCategory('Konserve'), isNotEmpty);
    expect(brandsForCategory('Dondurma').map((b) => b.name), contains('Algida'));
    expect(brandsForCategory('Bebek').map((b) => b.name), contains('Sleepy'));
  });

  test('mock servis snapshot fiyatını taban alır', () async {
    final milk = productTypes.firstWhere((t) => t.id == 'sut-1l');
    final service = MockPriceService();
    final result = await service.compareBasket([
      ListItem(product: milk.withBrand('İçim')),
    ]);

    final sok = result.baskets.firstWhere((b) => b.market.id == MarketId.sok);
    final line = sok.lines.single;
    expect(line.available, isTrue);
    final base = marketPriceSnapshot['sut-1l']!.unitPrice;
    expect(line.unitPrice, greaterThan(base * 0.8));
    expect(line.unitPrice, lessThan(base * 1.3));
  });

  test('Şok satırı her zaman sokmarket.com.tr linki açar', () async {
    final milk = productTypes.firstWhere((t) => t.id == 'sut-1l');
    final cheese = productTypes.firstWhere((t) => t.id == 'kasar-500');
    final service = MockPriceService();
    final result = await service.compareBasket([
      ListItem(product: milk.withBrand('Ülker')),
      ListItem(product: cheese.withBrand('Bahçıvan')),
    ]);

    final sok = result.baskets.firstWhere((b) => b.market.id == MarketId.sok);
    for (final line in sok.lines) {
      expect(line.sourceUrl, isNotNull);
      expect(line.sourceUrl!, contains('sokmarket.com.tr'));
      expect(line.sourceUrl!, isNot(contains('happycenter.com.tr')));
    }

    // Bahçıvan 500g Şok’ta yoksa arama; sorgu birimi korur.
    final kasar = sok.lines.firstWhere((l) => l.product.typeId == 'kasar-500');
    expect(kasar.sourceUrl!, contains('Bah'));
    expect(kasar.sourceUrl!.toLowerCase(), contains('500'));
  });

  test('bilinen Şok markası doğrudan ürün sayfasına gider', () {
    final cheese = productTypes
        .firstWhere((t) => t.id == 'kasar-500')
        .withBrand('Sütaş');
    final url = ProductSourceUrl.resolve(
      marketId: MarketId.sok,
      product: cheese,
    );
    expect(url, contains('sutas-kasar-peyniri-500-g-p-4684'));
  });

  test('ürün adındaki birim tüm satırlarda aynı kalır', () async {
    final cheese = productTypes.firstWhere((t) => t.id == 'kasar-500');
    final service = MockPriceService();
    final result = await service.compareBasket([
      ListItem(product: cheese.withBrand('Bahçıvan')),
    ]);

    for (final basket in result.baskets) {
      final line = basket.lines.single;
      expect(line.product.name, 'Kaşar Peynir 500g');
      expect(line.product.brand, 'Bahçıvan');
    }
  });
}

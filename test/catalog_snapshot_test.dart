import 'package:flutter_test/flutter_test.dart';
import 'package:sepet_karsilastir/data/brands.dart';
import 'package:sepet_karsilastir/data/market_price_snapshot.dart';
import 'package:sepet_karsilastir/data/mock_catalog.dart';
import 'package:sepet_karsilastir/models/list_item.dart';
import 'package:sepet_karsilastir/models/market.dart';
import 'package:sepet_karsilastir/services/mock_price_service.dart';

void main() {
  test('katalog resmi market fiyat snapshot’ı ile genişletildi', () {
    expect(productTypes.length, greaterThanOrEqualTo(80));
    expect(marketPriceSnapshot.length, productTypes.length);
    expect(marketPriceSnapshotSources, contains('https://www.sokmarket.com.tr'));
    expect(marketPriceSnapshotSources, contains('https://happycenter.com.tr'));

    for (final type in productTypes) {
      final ref = marketPriceSnapshot[type.id];
      expect(ref, isNotNull, reason: '${type.id} snapshot’ta yok');
      expect(ref!.unitPrice, greaterThan(0));
      expect(ref.sampleProduct, isNotEmpty);
      expect(ref.sourceUrl, startsWith('http'));
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
    // Şok index 1.0; jitter/brand ile %20 sapma bandı.
    final base = marketPriceSnapshot['sut-1l']!.unitPrice;
    expect(line.unitPrice, greaterThan(base * 0.8));
    expect(line.unitPrice, lessThan(base * 1.3));
  });
}

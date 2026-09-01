import 'package:flutter_test/flutter_test.dart';
import 'package:sepet_karsilastir/data/sample_basket.dart';
import 'package:sepet_karsilastir/models/list_item.dart';
import 'package:sepet_karsilastir/services/price_book_service.dart';

void main() {
  test('örnek sepetteki ürünlerin en az bir markette fiyatı var', () async {
    final items = [
      for (final product in sampleBasketProducts()) ListItem(product: product),
    ];

    for (final item in items) {
      expect(
        PriceBookService.pricedMarketCount(item.product.id),
        greaterThan(0),
        reason: '${item.product.displayName} defterde yok',
      );
    }

    final result = await const PriceBookService().compareBasket(items);
    final withPrices = result.baskets.where((b) => b.availableCount > 0);
    expect(withPrices.length, greaterThanOrEqualTo(3));
  });
}

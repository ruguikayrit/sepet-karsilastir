import 'package:flutter_test/flutter_test.dart';
import 'package:sepet_karsilastir/data/brands.dart';
import 'package:sepet_karsilastir/data/mock_catalog.dart';
import 'package:sepet_karsilastir/models/list_item.dart';
import 'package:sepet_karsilastir/models/market.dart';
import 'package:sepet_karsilastir/services/price_book_service.dart';
import 'package:sepet_karsilastir/state/basket_controller.dart';

void main() {
  final milkType = productTypes.firstWhere((t) => t.id == 'sut-1l');

  test('aynı ürün farklı markalarla ayrı satır olur', () {
    final controller = BasketController(const PriceBookService());

    controller.addProduct(milkType.withBrand('İçim'));
    controller.addProduct(milkType.withBrand('Pınar'));
    controller.addProduct(milkType.withBrand('İçim'));

    expect(controller.items, hasLength(2));
    expect(controller.totalQuantity, 3);
    expect(controller.uniqueBrandCount, 2);
  });

  test('kategoriye göre marka listesi döner', () {
    final dairy = brandsForCategory('Süt & Kahvaltı').map((b) => b.name);

    expect(dairy, contains('İçim'));
    expect(dairy, contains('Sütaş'));
    expect(dairy, isNot(contains('Ariel')));
  });

  test('karşılaştırma yalnızca fiyat yayınlayan marketleri kapsar', () async {
    final result = await const PriceBookService().compareBasket([
      ListItem(product: milkType.withBrand('İçim')),
      ListItem(product: milkType.withBrand('Sütaş')),
    ]);

    expect(
      result.baskets.map((b) => b.market.id),
      Market.priced.map((m) => m.id),
    );
    // Fiyatını kendi sitesinde yayınlamayan zincir hiç görünmez: uygulama o
    // market için tutar uyduramaz.
    for (final market in Market.unpriced) {
      expect(
        result.baskets.map((b) => b.market.id),
        isNot(contains(market.id)),
        reason: '${market.name}: ${market.noPriceReason}',
      );
    }
  });
}

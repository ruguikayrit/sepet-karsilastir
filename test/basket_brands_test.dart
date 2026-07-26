import 'package:flutter_test/flutter_test.dart';
import 'package:sepet_karsilastir/data/brands.dart';
import 'package:sepet_karsilastir/data/mock_catalog.dart';
import 'package:sepet_karsilastir/models/list_item.dart';
import 'package:sepet_karsilastir/models/market.dart';
import 'package:sepet_karsilastir/services/mock_price_service.dart';
import 'package:sepet_karsilastir/state/basket_controller.dart';

void main() {
  final milkType = productTypes.firstWhere((t) => t.id == 'sut-1l');

  test('aynı ürün farklı markalarla ayrı satır olur', () {
    final controller = BasketController(MockPriceService());

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

  test('mock servis genişletilmiş market listesini fiyatlar', () async {
    final service = MockPriceService();
    final result = await service.compareBasket([
      ListItem(product: milkType.withBrand('İçim')),
      ListItem(product: milkType.withBrand('Sütaş')),
    ]);

    expect(result.baskets, hasLength(Market.all.length));
    expect(
      result.baskets.map((b) => b.market.id),
      containsAll([MarketId.macrocenter, MarketId.bim, MarketId.tarimKredi]),
    );

    final macro =
        result.baskets.firstWhere((b) => b.market.id == MarketId.macrocenter);
    final bim = result.baskets.firstWhere((b) => b.market.id == MarketId.bim);
    expect(macro.total, greaterThan(bim.total));
  });
}

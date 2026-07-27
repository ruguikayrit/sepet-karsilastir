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

  test('karşılaştırma bütün marketleri listeler, fiyatı olmayan da', () async {
    final result = await const PriceBookService().compareBasket([
      ListItem(product: milkType.withBrand('İçim')),
      ListItem(product: milkType.withBrand('Sütaş')),
    ]);

    expect(result.baskets.map((b) => b.market.id), Market.all.map((m) => m.id));

    // Fiyatını kendi sitesinde yayınlamayan zincir listede kalır ama tutar
    // göstermez: kullanıcı marketin bakıldığını görür, uydurma fiyat görmez.
    for (final market in Market.unpriced) {
      final basket =
          result.baskets.firstWhere((b) => b.market.id == market.id);
      expect(basket.foundNothing, isTrue, reason: market.name);
      expect(basket.availableCount, 0, reason: market.name);
      expect(basket.total, 0, reason: market.name);
      expect(
        PriceBookService.noPriceReasonFor(market.id),
        market.noPriceReason,
        reason: market.name,
      );
    }

    // Sıfır toplamlı market sıralamada en ucuz gibi görünmez.
    expect(result.ranked.last.foundNothing, isTrue);
    expect(result.ranked.first.foundNothing, isFalse);
  });
}

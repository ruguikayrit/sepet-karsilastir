import 'package:flutter_test/flutter_test.dart';
import 'package:sepet_karsilastir/data/market_price_snapshot.dart';
import 'package:sepet_karsilastir/data/mock_catalog.dart';
import 'package:sepet_karsilastir/models/list_item.dart';
import 'package:sepet_karsilastir/services/mock_price_service.dart';
import 'package:sepet_karsilastir/services/storage/basket_repository.dart';
import 'package:sepet_karsilastir/services/storage/key_value_store.dart';
import 'package:sepet_karsilastir/state/basket_controller.dart';

void main() {
  final milkType = productTypes.firstWhere((t) => t.id == 'sut-1l');

  test('sepet kalıcı depoya yazılır ve yeniden yüklenir', () {
    final store = InMemoryStore();
    final repo = BasketRepository(store);

    final first = BasketController(MockPriceService(), repository: repo);
    first.addProduct(milkType.withBrand('İçim'));
    first.addProduct(milkType.withBrand('Pınar'));
    first.setQuantity(milkType.withBrand('İçim').id, 3);

    final second = BasketController(MockPriceService(), repository: repo);
    expect(second.items, hasLength(2));
    expect(second.totalQuantity, 4);
    expect(
      second.items.map((i) => i.product.brand),
      containsAll(['İçim', 'Pınar']),
    );
  });

  test('kayıtlı liste kaydedilir, yüklenir ve silinir', () {
    final store = InMemoryStore();
    final controller = BasketController(
      MockPriceService(),
      repository: BasketRepository(store),
    );

    controller.addProduct(milkType.withBrand('Sütaş'));
    final saved = controller.saveCurrentBasket('Haftalık');
    expect(saved, isNotNull);
    expect(controller.savedLists, hasLength(1));

    controller.clear();
    expect(controller.isEmpty, isTrue);

    controller.loadSavedList(saved!.id);
    expect(controller.totalQuantity, 1);
    expect(controller.items.first.product.brand, 'Sütaş');

    controller.deleteSavedList(saved.id);
    expect(controller.savedLists, isEmpty);
  });

  test('karşılaştırma geçmişe yazılır ve sepete geri yüklenir', () async {
    final store = InMemoryStore();
    final controller = BasketController(
      MockPriceService(),
      repository: BasketRepository(store),
    );

    controller.addProduct(milkType.withBrand('İçim'));
    final result = await controller.compare();
    expect(result, isNotNull);
    expect(controller.history, hasLength(1));
    expect(controller.history.first.winnerMarketId, isNotNull);

    controller.clear();
    expect(controller.isEmpty, isTrue);

    controller.restoreSnapshot(controller.history.first.id);
    expect(controller.totalQuantity, 1);

    // Yeniden açınca geçmiş hâlâ orada.
    final restored = BasketController(
      MockPriceService(),
      repository: BasketRepository(store),
    );
    expect(restored.history, hasLength(1));
    expect(restored.history.first.items, hasLength(1));
  });

  test('adı düzeltilen ürün tipi eski kayıttan taşınır', () {
    final store = InMemoryStore({
      'basket.items.v1': '['
          '{"product":{"id":"tuz-750__billur","typeId":"tuz-750",'
          '"name":"Sofra Tuzu 500g","category":"Temel Gıda","unit":"adet",'
          '"brand":"Billur"},"quantity":2}]',
    });

    final restored = BasketRepository(store).loadBasket();
    expect(restored, hasLength(1));

    final product = restored.single.product;
    expect(product.typeId, 'tuz-500');
    // Kimlik yeniden üretilmezse aynı ürün sepette iki satır olur.
    expect(
      product.id,
      productTypes.firstWhere((t) => t.id == 'tuz-500').withBrand('Billur').id,
    );
    expect(marketPriceSnapshot[product.typeId], isNotNull);
  });

  test('bozuk kayıtlar sessizce atlanır', () async {
    final store = InMemoryStore({
      'basket.items.v1': '[{"product":{"id":"x"},"quantity":1}, "broken"]',
    });
    final repo = BasketRepository(store);
    expect(repo.loadBasket(), isEmpty);

    final items = [
      ListItem(product: milkType.withBrand('İçim'), quantity: 2),
    ];
    await repo.saveBasket(items);
    expect(repo.loadBasket().first.quantity, 2);
  });
}

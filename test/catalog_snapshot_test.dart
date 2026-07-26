import 'package:flutter_test/flutter_test.dart';
import 'package:sepet_karsilastir/data/brands.dart';
import 'package:sepet_karsilastir/data/mock_catalog.dart';
import 'package:sepet_karsilastir/models/list_item.dart';
import 'package:sepet_karsilastir/services/price_book_service.dart';

void main() {
  test('katalog market taramasıyla genişletildi', () {
    expect(productTypes.length, greaterThanOrEqualTo(70));
    for (final type in productTypes) {
      expect(type.id, isNotEmpty);
      expect(type.name, isNotEmpty);
      expect(type.category, isNotEmpty);
      expect(type.unit, anyOf('adet', 'kg'));
    }
  });

  test('paketli ürün adı gramajı taşır', () {
    // Somun ekmek ve demet maydanoz tanesiyle satılır; gramaj yazılmaz.
    const soldPerPiece = {'ekmek-beyaz', 'ekmek-tam-bugday', 'maydanoz'};

    for (final type in productTypes) {
      // kg ile satılanlarda gramaj ürün adında değil, birimde yazar.
      if (type.unit != 'adet') continue;

      final hasQuantity = RegExp(r'\d').hasMatch(type.name);
      if (soldPerPiece.contains(type.id)) {
        expect(hasQuantity, isFalse,
            reason: '${type.id} artık gramajlı, listeden çıkarılmalı');
        continue;
      }
      expect(
        hasQuantity,
        isTrue,
        reason: '${type.id}: "${type.name}" gramaj söylemiyor, marketler '
            'farklı boyları karşılaştırabilir',
      );
    }
  });

  test('yeni kategoriler için marka önerisi var', () {
    expect(brandsForCategory('Konserve'), isNotEmpty);
    expect(brandsForCategory('Dondurma').map((b) => b.name), contains('Algida'));
    expect(brandsForCategory('Bebek').map((b) => b.name), contains('Sleepy'));
  });

  test('ürün adındaki birim tüm satırlarda aynı kalır', () async {
    final cheese = productTypes.firstWhere((t) => t.id == 'kasar-500');
    final result = await const PriceBookService().compareBasket([
      ListItem(product: cheese.withBrand('Bahçıvan')),
    ]);

    for (final basket in result.baskets) {
      final line = basket.lines.single;
      expect(line.product.name, 'Kaşar Peynir 500g');
      expect(line.product.brand, 'Bahçıvan');
    }
  });

  test('Türkçe karakter katlaması ile arama çalışır', () {
    expect(
      searchProductTypesLocal('sut').map((t) => t.id),
      contains('sut-1l'),
    );
    expect(
      searchProductTypesLocal('yogurt').map((t) => t.id),
      contains('yogurt-1kg'),
    );
    expect(
      searchProductTypesLocal('cay 500').map((t) => t.id),
      contains('cay-500'),
    );
    expect(
      searchProductTypesLocal('kasar peynir').map((t) => t.id),
      contains('kasar-500'),
    );
    expect(searchProductTypesLocal('zzzz'), isEmpty);
    expect(searchProductTypesLocal('  '), productTypes);
  });
}

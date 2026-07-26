import 'package:flutter_test/flutter_test.dart';
import 'package:sepet_karsilastir/data/brands.dart';
import 'package:sepet_karsilastir/data/market_price_snapshot.dart';
import 'package:sepet_karsilastir/data/market_product_snapshot.dart';
import 'package:sepet_karsilastir/data/mock_catalog.dart';
import 'package:sepet_karsilastir/models/list_item.dart';
import 'package:sepet_karsilastir/models/market.dart';
import 'package:sepet_karsilastir/models/product_link.dart';
import 'package:sepet_karsilastir/services/mapping/product_source_url.dart';
import 'package:sepet_karsilastir/services/mock_price_service.dart';

import 'support/quantity.dart';

void main() {
  test('katalog resmi market fiyat snapshot’ı ile genişletildi', () {
    expect(productTypes.length, greaterThanOrEqualTo(70));
    expect(marketPriceSnapshot.length, productTypes.length);
    expect(marketPriceSnapshotSources, contains('https://www.sokmarket.com.tr'));
    expect(marketPriceSnapshotSources, contains('https://happycenter.com.tr'));

    for (final type in productTypes) {
      final ref = marketPriceSnapshot[type.id];
      expect(ref, isNotNull, reason: '${type.id} snapshot’ta yok');
      expect(ref!.typeId, type.id);
      expect(ref.unitPrice, greaterThan(0));
      expect(ref.sampleProduct, isNotEmpty);
      expect(
        ref.sokPath != null || ref.happyCenterPath != null,
        isTrue,
        reason: '${type.id} için market yolu yok',
      );
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

  test('referans fiyat örnek ürünle aynı gramajdan gelir', () {
    for (final type in productTypes) {
      final ref = marketPriceSnapshot[type.id]!;
      final expected = normalizedQuantities(type.name);
      if (expected.isEmpty) continue;
      expect(
        normalizedQuantities(ref.sampleProduct),
        containsAll(expected),
        reason: '${type.id}: "${ref.sampleProduct}" (${ref.unitPrice} TL) '
            '${type.name} birimiyle uyuşmuyor',
      );
    }
  });

  test('referans kaynağı ile yolu tutarlı', () {
    for (final ref in marketPriceSnapshot.values) {
      expect(
        ref.source,
        anyOf('sokmarket.com.tr', 'happycenter.com.tr'),
        reason: ref.typeId,
      );
      if (ref.source == 'sokmarket.com.tr') {
        expect(ref.sokPath, isNotNull, reason: ref.typeId);
        expect(ref.sokUrl, startsWith('https://www.sokmarket.com.tr/'));
      } else {
        expect(ref.happyCenterPath, isNotNull, reason: ref.typeId);
        expect(ref.happyCenterUrl, startsWith('https://happycenter.com.tr/'));
      }
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
    expect(line.unitPrice, lessThan(base * 2));
  });

  test('doğrulanmış market satırı gerçek fiyatı gösterir', () async {
    final entry = marketProductSnapshot.entries
        .firstWhere((e) => e.value.sok != null && e.value.sok!.inStock);
    final type = productTypes
        .firstWhere((t) => t.id == entry.key.split('__').first);
    final brand = foodBrands
        .firstWhere((b) => type.withBrand(b.name).id == entry.key)
        .name;

    final result = await MockPriceService().compareBasket([
      ListItem(product: type.withBrand(brand)),
    ]);

    final sok = result.baskets.firstWhere((b) => b.market.id == MarketId.sok);
    expect(sok.lines.single.unitPrice, entry.value.sok!.price);
    expect(sok.lines.single.available, isTrue);
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

    // Bahçıvan 500g Şok’ta doğrulanmadı: arama açılır, sorgu birimi korur.
    final kasar = sok.lines.firstWhere((l) => l.product.typeId == 'kasar-500');
    expect(kasar.source!.kind, ProductLinkKind.search);
    expect(kasar.sourceUrl!, contains('Bah'));
    expect(kasar.sourceUrl!.toLowerCase(), contains('500'));
  });

  test('bilinen Şok markası doğrudan ürün sayfasına gider', () {
    final cheese = productTypes
        .firstWhere((t) => t.id == 'kasar-500')
        .withBrand('Sütaş');
    final link = ProductSourceUrl.resolve(
      marketId: MarketId.sok,
      product: cheese,
    );
    expect(link.kind, ProductLinkKind.product);
    expect(link.url, contains(marketProductSnapshot[cheese.id]!.sok!.path));
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

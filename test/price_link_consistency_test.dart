import 'package:flutter_test/flutter_test.dart';
import 'package:sepet_karsilastir/data/brands.dart';
import 'package:sepet_karsilastir/data/mock_catalog.dart';
import 'package:sepet_karsilastir/data/price_book.dart';
import 'package:sepet_karsilastir/models/list_item.dart';
import 'package:sepet_karsilastir/models/market.dart';
import 'package:sepet_karsilastir/models/product.dart';
import 'package:sepet_karsilastir/models/product_link.dart';
import 'package:sepet_karsilastir/services/mapping/product_source_url.dart';
import 'package:sepet_karsilastir/services/price_book_service.dart';

/// Ekranda yazan tutar ile satırın açtığı sayfa aynı ürünü göstermeli.
///
/// Kullanıcıya verilen söz bu: "fiyat doğru mu?" diye merak edince satıra
/// dokunur, marketin sayfası açılır ve aynı tutarı görür. Bu dosya bütün
/// katalogu sepete koyup her market satırını tek tek denetler; fiyatı olan
/// satır daima ürün sayfasına, fiyatı olmayan satır asla ürün sayfasına
/// bağlanmaz.
void main() {
  final typesById = {for (final type in productTypes) type.id: type};
  final brandNames = foodBrands.map((b) => b.name).toList();

  Product productOf(String productId) {
    final type = typesById[productId.split('__').first]!;
    final brandKey = productId.split('__').last;
    final brand = brandKey == 'markasiz'
        ? null
        : brandNames.firstWhere(
            (name) => Product.brandKeyOf(name) == brandKey,
            orElse: () => brandKey,
          );
    return type.withBrand(brand);
  }

  test('fiyat gösteren satır fiyatın okunduğu sayfayı açar', () async {
    final products = <Product>[
      for (final productId in priceBook.keys) productOf(productId),
      // Markasız satırlar da aynı kurala tabi: fiyat varsa ürün sayfası vardır.
      for (final type in productTypes) type.withBrand(null),
    ];

    final result = await const PriceBookService().compareBasket([
      for (final product in products) ListItem(product: product),
    ]);
    expect(result.baskets.map((b) => b.market.id), Market.all.map((m) => m.id));

    var priced = 0;
    for (final basket in result.baskets) {
      final marketId = basket.market.id;
      for (final line in basket.lines) {
        final label = '${line.product.id} · ${marketId.name}';
        final link = line.source!;
        final offer = priceBook[line.product.id]?[marketId];

        if (line.available) {
          priced++;
          expect(offer, isNotNull, reason: '$label: defterde kayıt yok');
          expect(line.unitPrice, offer!.price, reason: label);
          expect(offer.inStock, isTrue, reason: label);
          // Tutar, açılan sayfadaki üründen okundu: ikisi aynı kayıt.
          expect(line.marketProduct, offer.product, reason: label);
          expect(link.url, offer.url, reason: label);
          expect(link.kind, ProductLinkKind.product, reason: label);
          expect(line.opensPricedProduct, isTrue, reason: label);
          expect(link.host, isNotEmpty, reason: label);
          continue;
        }

        // Fiyat yok: tahmin de yok, ürün sayfası iddiası da yok.
        expect(line.unitPrice, isNull, reason: label);
        expect(line.lineTotal, 0, reason: label);
        expect(line.marketProduct, isNull, reason: label);
        expect(link.kind, isNot(ProductLinkKind.product), reason: label);
        expect(offer?.inStock ?? false, isFalse, reason: label);

        if (link.kind == ProductLinkKind.search) {
          final query = Uri.parse(link.url).queryParameters.values.single;
          expect(query, contains(line.product.name), reason: label);
          final brand = line.product.brand;
          if (brand != null && !ProductSourceUrl.isGenericBrand(brand)) {
            expect(query, contains(brand), reason: label);
          }
        }
      }
    }

    // Defterin gerçekten okunduğunu görmek için: aksi halde test yalnızca
    // fiyatsız satırları denetliyor olurdu.
    expect(priced, greaterThan(150));
  });

  test('marketin toplamı yalnızca fiyatı okunan satırlardan oluşur', () async {
    final result = await const PriceBookService().compareBasket([
      for (final productId in priceBook.keys.take(60))
        ListItem(product: productOf(productId), quantity: 2),
    ]);

    for (final basket in result.baskets) {
      final expected = basket.lines
          .where((line) => line.available)
          .fold<double>(0, (sum, line) => sum + line.unitPrice! * 2);
      expect(basket.total, closeTo(expected, 0.001),
          reason: basket.market.name);
      expect(basket.availableCount + basket.missingCount, basket.lines.length);
    }
  });
}

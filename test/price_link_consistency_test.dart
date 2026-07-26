import 'package:flutter_test/flutter_test.dart';
import 'package:sepet_karsilastir/data/brands.dart';
import 'package:sepet_karsilastir/data/market_price_index.dart';
import 'package:sepet_karsilastir/data/market_price_snapshot.dart';
import 'package:sepet_karsilastir/data/market_product_snapshot.dart';
import 'package:sepet_karsilastir/data/mock_catalog.dart';
import 'package:sepet_karsilastir/models/list_item.dart';
import 'package:sepet_karsilastir/models/market.dart';
import 'package:sepet_karsilastir/models/product.dart';
import 'package:sepet_karsilastir/models/product_link.dart';
import 'package:sepet_karsilastir/services/mock_price_service.dart';
import 'package:sepet_karsilastir/utils/text.dart';

/// Satırda yazan tutar ile satırın açtığı bağlantı aynı ürünü göstermeli.
///
/// Doğrulanmış bir fiyat gösterip başka bir ürünün sayfasına gitmek, "aynı
/// listeyi karşılaştırıyoruz" sözünün en kolay bozulduğu yer. Bu dosya bütün
/// veri kaynaklarını sepete koyup her market satırını tek tek denetler.
void main() {
  final typeById = {for (final type in productTypes) type.id: type};
  final brandKeyToName = {
    for (final brand in foodBrands) slugifyTurkish(brand.name): brand.name,
  };

  Product? productOf(String id) {
    final parts = id.split('__');
    final type = typeById[parts.first];
    final brand = brandKeyToName[parts.last];
    if (type == null || brand == null) return null;
    return type.withBrand(brand);
  }

  test('doğrulanmış fiyat ile bağlantı aynı ürünü gösterir', () async {
    final products = <Product>[
      for (final id in {
        ...marketProductSnapshot.keys,
        ...marketPriceIndex.keys,
      })
        if (productOf(id) case final product?) product,
      // Markasız satırlar tip seviyesindeki ürün sayfasına bağlanır.
      for (final type in productTypes) type.withBrand(null),
    ];
    expect(products, hasLength(greaterThan(150)));

    final result = await MockPriceService().compareBasket([
      for (final product in products) ListItem(product: product),
    ]);

    var verified = 0;
    for (final basket in result.baskets) {
      final marketId = basket.market.id;
      for (final line in basket.lines) {
        final id = line.product.id;
        final link = line.source!;
        final reason = '$id · ${marketId.name}';

        final brandRef = switch (marketId) {
          MarketId.sok => marketProductSnapshot[id]?.sok,
          MarketId.happyCenter => marketProductSnapshot[id]?.happyCenter,
          _ => null,
        };
        if (brandRef != null) {
          verified++;
          expect(line.unitPrice, brandRef.price, reason: reason);
          expect(line.verified, isTrue, reason: reason);
          expect(link.kind, ProductLinkKind.product, reason: reason);
          expect(link.url, endsWith(brandRef.path), reason: reason);
          continue;
        }

        final indexed = marketPriceIndex[id];
        if (indexed != null && indexed.prices.containsKey(marketId)) {
          verified++;
          expect(line.unitPrice, indexed.prices[marketId], reason: reason);
          expect(line.verified, isTrue, reason: reason);
          // Arama sunan marketlerde sorgu, fiyatı yazan ürünün adıdır.
          if (link.kind == ProductLinkKind.search) {
            expect(
              Uri.parse(link.url).queryParameters.values.single,
              indexed.product,
              reason: reason,
            );
          }
          continue;
        }

        final typeRef = marketPriceSnapshot[line.product.typeId]!;
        final generic = line.product.brand == null;
        final typePath = switch (marketId) {
          MarketId.sok => generic ? typeRef.sokPath : null,
          MarketId.happyCenter => generic ? typeRef.happyCenterPath : null,
          _ => null,
        };
        if (typePath != null) {
          verified++;
          final price = marketId == MarketId.sok
              ? typeRef.sokPrice
              : typeRef.happyCenterPrice;
          expect(line.unitPrice, price, reason: reason);
          expect(line.verified, isTrue, reason: reason);
          expect(link.kind, ProductLinkKind.product, reason: reason);
          expect(link.url, endsWith(typePath), reason: reason);
          continue;
        }

        // Kalan satırlar tahmini: tutar türetilir ama marka ve birim korunur.
        expect(line.verified, isFalse, reason: reason);
        expect(line.product.name, typeById[line.product.typeId]!.name,
            reason: reason);
        if (link.kind == ProductLinkKind.search) {
          final query = Uri.parse(link.url).queryParameters.values.single;
          expect(query, contains(line.product.name), reason: reason);
          if (line.product.brand != null) {
            expect(query, contains(line.product.brand!), reason: reason);
          }
        }
      }
    }

    // Kaynakların gerçekten kullanıldığını görmek için: aksi halde test
    // yalnızca tahmini satırları denetliyor olurdu.
    expect(verified, greaterThan(300));
  });
}

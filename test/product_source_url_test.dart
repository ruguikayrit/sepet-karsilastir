import 'package:flutter_test/flutter_test.dart';
import 'package:sepet_karsilastir/data/mock_catalog.dart';
import 'package:sepet_karsilastir/models/market.dart';
import 'package:sepet_karsilastir/models/product_link.dart';
import 'package:sepet_karsilastir/services/mapping/product_source_url.dart';

/// Fiyatsız satırın bağlantısı: her zaman o marketin kendi alan adı, hiçbir
/// zaman fiyat iddiası yok.
void main() {
  const expectedHost = <MarketId, String>{
    MarketId.migros: 'www.migros.com.tr',
    MarketId.macrocenter: 'www.macrocenter.com.tr',
    MarketId.a101: 'www.a101.com.tr',
    MarketId.bim: 'www.bim.com.tr',
    MarketId.sok: 'www.sokmarket.com.tr',
    MarketId.carrefour: 'www.carrefoursa.com',
    MarketId.tarimKredi: 'www.tkkoop.com.tr',
    MarketId.hakmar: 'www.hakmarexpress.com.tr',
    MarketId.happyCenter: 'happycenter.com.tr',
  };

  final kasar = productTypes.firstWhere((t) => t.id == 'kasar-500');

  test('her market için bağlantı kendi alan adına gider', () {
    expect(expectedHost.keys, hasLength(MarketId.values.length));

    for (final type in productTypes) {
      for (final market in Market.all) {
        final link = ProductSourceUrl.search(
          marketId: market.id,
          product: type.withBrand('Market markası'),
        );
        final uri = Uri.parse(link.url);
        expect(uri.scheme, 'https', reason: '${market.id} https değil');
        expect(
          uri.host,
          expectedHost[market.id],
          reason: '${market.id}/${type.id} yanlış alan adına gidiyor',
        );
      }
    }
  });

  test('bağlantı asla ürün sayfası olarak işaretlenmez', () {
    // Ürün sayfası bağlantısı yalnızca fiyat defterinden gelir; buradan gelen
    // bağlantının yanında tutar gösterilmediği için türü de arama/sitedir.
    for (final market in Market.all) {
      final link = ProductSourceUrl.search(
        marketId: market.id,
        product: kasar.withBrand('Bahçıvan'),
      );
      expect(link.kind, isNot(ProductLinkKind.product));
    }
  });

  test('arama bağlantısı marka ve birimi sorguda taşır', () {
    final link = ProductSourceUrl.search(
      marketId: MarketId.migros,
      product: kasar.withBrand('Bahçıvan'),
    );

    expect(link.kind, ProductLinkKind.search);
    final query = Uri.parse(link.url).queryParameters['q'];
    expect(query, 'Bahçıvan Kaşar Peynir 500g');
  });

  test('markasız satırda sorgu yalnızca ürün adını taşır', () {
    for (final brand in [null, '', 'Market markası', 'Markasız']) {
      final link = ProductSourceUrl.search(
        marketId: MarketId.sok,
        product: kasar.withBrand(brand),
      );
      expect(Uri.parse(link.url).queryParameters['q'], 'Kaşar Peynir 500g');
    }
  });

  test('arama sunmayan market kendi ana sayfasını açar', () {
    for (final marketId in [
      MarketId.bim,
      MarketId.tarimKredi,
    ]) {
      final link = ProductSourceUrl.search(
        marketId: marketId,
        product: kasar.withBrand('Sütaş'),
      );
      expect(link.kind, ProductLinkKind.site);
      expect(link.url, Market.byId(marketId).site);
    }
  });

  test('site içi arama sunan marketlerde sorgu parametresi doğru', () {
    final cases = {
      MarketId.sok: ('www.sokmarket.com.tr', 'q'),
      MarketId.happyCenter: ('happycenter.com.tr', 'ara'),
      MarketId.hakmar: ('www.hakmarexpress.com.tr', 'q'),
      MarketId.migros: ('www.migros.com.tr', 'q'),
      MarketId.macrocenter: ('www.macrocenter.com.tr', 'q'),
      MarketId.a101: ('www.a101.com.tr', 'k'),
      MarketId.carrefour: ('www.carrefoursa.com', 'text'),
    };

    for (final entry in cases.entries) {
      final link = ProductSourceUrl.search(
        marketId: entry.key,
        product: kasar.withBrand('Sütaş'),
      );
      final uri = Uri.parse(link.url);
      expect(link.kind, ProductLinkKind.search, reason: entry.key.name);
      expect(uri.host, entry.value.$1);
      expect(uri.queryParameters[entry.value.$2], contains('Kaşar'));
    }
  });
}

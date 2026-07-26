import 'package:flutter_test/flutter_test.dart';
import 'package:sepet_karsilastir/data/brands.dart';
import 'package:sepet_karsilastir/data/market_price_index.dart';
import 'package:sepet_karsilastir/data/market_price_snapshot.dart';
import 'package:sepet_karsilastir/data/market_product_snapshot.dart';
import 'package:sepet_karsilastir/data/mock_catalog.dart';
import 'package:sepet_karsilastir/models/market.dart';
import 'package:sepet_karsilastir/models/product_link.dart';
import 'package:sepet_karsilastir/services/mapping/product_source_url.dart';

/// Her market satırı kendi alan adına gitmeli ve marka + birim korunmalı.
void main() {
  /// Bağlantının gitmesi gereken alan adı (market bazında).
  const expectedHost = <MarketId, String>{
    MarketId.migros: 'www.migros.com.tr',
    MarketId.macrocenter: 'www.macrocenter.com.tr',
    MarketId.a101: 'www.a101.com.tr',
    MarketId.bim: 'www.bim.com.tr',
    MarketId.sok: 'www.sokmarket.com.tr',
    MarketId.carrefour: 'www.carrefoursa.com',
    MarketId.file: 'www.file.com.tr',
    MarketId.tarimKredi: 'www.tkkoop.com.tr',
    MarketId.hakmar: 'www.hakmarexpress.com.tr',
    MarketId.onur: 'www.onurmarket.com',
    MarketId.happyCenter: 'happycenter.com.tr',
    MarketId.metro: 'www.metro-tr.com',
    MarketId.getir: 'getir.com',
  };

  final kasar = productTypes.firstWhere((t) => t.id == 'kasar-500');

  test('her market için bağlantı kendi alan adına gider', () {
    expect(expectedHost.keys, hasLength(MarketId.values.length));

    for (final type in productTypes) {
      final product = type.withBrand('Market markası');
      for (final market in Market.all) {
        final link = ProductSourceUrl.resolve(
          marketId: market.id,
          product: product,
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

  test('arama bağlantısı marka ve birimi sorguda taşır', () {
    final product = kasar.withBrand('Bahçıvan');
    final link = ProductSourceUrl.resolve(
      marketId: MarketId.migros,
      product: product,
    );

    expect(link.kind, ProductLinkKind.search);
    final query = Uri.parse(link.url).queryParameters['q'];
    expect(query, 'Bahçıvan Kaşar Peynir 500g');
  });

  test('fiyat indeksten gelen aramada indeksin ürün adı kullanılır', () {
    // Migros araması, fiyatı yazan ürünün kendisine çıkmalı; sepetin genel
    // ürün adı ("Sofra Tuzu 500g") başka bir ürünü öne çıkarabilir.
    final entry = marketPriceIndex.entries.firstWhere(
      (e) =>
          e.value.prices.containsKey(MarketId.migros) &&
          !marketProductSnapshot.containsKey(e.key),
    );
    final type =
        productTypes.firstWhere((t) => t.id == entry.key.split('__').first);
    final brandName = foodBrands
        .firstWhere((b) => type.withBrand(b.name).id == entry.key)
        .name;

    final link = ProductSourceUrl.resolve(
      marketId: MarketId.migros,
      product: type.withBrand(brandName),
    );
    expect(link.kind, ProductLinkKind.search);
    expect(
      Uri.parse(link.url).queryParameters['q'],
      entry.value.product,
    );

    // İndeksin kapsamadığı markette sepetteki marka + birim aranır.
    final macro = ProductSourceUrl.resolve(
      marketId: MarketId.macrocenter,
      product: type.withBrand(brandName),
    );
    expect(
      Uri.parse(macro.url).queryParameters['q'],
      '$brandName ${type.name}',
    );
  });

  test('site bağlantısı sunan marketlerde sorgu parametresi olmaz', () {
    const siteOnly = [
      MarketId.bim,
      MarketId.file,
      MarketId.tarimKredi,
      MarketId.onur,
      MarketId.metro,
      MarketId.getir,
    ];

    for (final marketId in siteOnly) {
      final link = ProductSourceUrl.resolve(
        marketId: marketId,
        product: kasar.withBrand('Sütaş'),
      );
      expect(link.kind, ProductLinkKind.site, reason: '$marketId');
      expect(Uri.parse(link.url).queryParameters, isEmpty, reason: '$marketId');
    }
  });

  test('doğrulanmış marka kaydı doğrudan ürün sayfasına gider', () {
    final verified = marketProductSnapshot.entries
        .where((e) => e.value.sok != null)
        .toList();
    expect(verified, isNotEmpty);

    for (final entry in verified.take(20)) {
      final parts = entry.key.split('__');
      final type = productTypes.firstWhere((t) => t.id == parts.first);
      final brandName = foodBrands
          .firstWhere((b) => type.withBrand(b.name).id == entry.key)
          .name;

      final link = ProductSourceUrl.resolve(
        marketId: MarketId.sok,
        product: type.withBrand(brandName),
      );
      expect(link.kind, ProductLinkKind.product, reason: entry.key);
      expect(link.url, endsWith(entry.value.sok!.path), reason: entry.key);
    }
  });

  test('markasız satır tip seviyesindeki ürün sayfasına gider', () {
    for (final type in productTypes) {
      final ref = marketPriceSnapshot[type.id]!;
      final product = type.withBrand(null);

      final sok = ProductSourceUrl.resolve(
        marketId: MarketId.sok,
        product: product,
      );
      expect(
        sok.kind,
        ref.sokPath == null ? ProductLinkKind.search : ProductLinkKind.product,
        reason: type.id,
      );

      final happy = ProductSourceUrl.resolve(
        marketId: MarketId.happyCenter,
        product: product,
      );
      expect(
        happy.kind,
        ref.happyCenterPath == null
            ? ProductLinkKind.search
            : ProductLinkKind.product,
        reason: type.id,
      );
    }
  });

  test('doğrulanmamış marka aramaya düşer, tip sayfasına sapmaz', () {
    // Bahçıvan kaşar peyniri Şok kataloğunda doğrulanmadı: tip seviyesindeki
    // Sütaş ürününe gitmek yanlış marka gösterir, o yüzden arama açılmalı.
    final product = kasar.withBrand('Bahçıvan');
    expect(marketProductSnapshot[product.id]?.sok, isNull);

    final link = ProductSourceUrl.resolve(
      marketId: MarketId.sok,
      product: product,
    );
    expect(link.kind, ProductLinkKind.search);
    expect(link.url, isNot(contains(marketPriceSnapshot['kasar-500']!.sokPath!)));
    expect(Uri.parse(link.url).queryParameters['q'], contains('Bahçıvan'));
  });

  test('market markası ve markasız satırlar aynı tip sayfasını kullanır', () {
    final withoutBrand = ProductSourceUrl.resolve(
      marketId: MarketId.sok,
      product: kasar.withBrand(null),
    );
    final privateLabel = ProductSourceUrl.resolve(
      marketId: MarketId.sok,
      product: kasar.withBrand('Market markası'),
    );
    expect(privateLabel.url, withoutBrand.url);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:sepet_karsilastir/data/brands.dart';
import 'package:sepet_karsilastir/data/mock_catalog.dart';
import 'package:sepet_karsilastir/data/price_book.dart';
import 'package:sepet_karsilastir/models/list_item.dart';
import 'package:sepet_karsilastir/models/market.dart';
import 'package:sepet_karsilastir/models/product.dart';
import 'package:sepet_karsilastir/models/product_link.dart';
import 'package:sepet_karsilastir/services/price_book_service.dart';
import 'package:sepet_karsilastir/utils/text.dart';

import 'support/quantity.dart';

/// Fiyat defteri, uygulamadaki tek fiyat kaynağıdır.
///
/// Buradaki kurallar kullanıcıya verilen sözü korur: ekranda yazan tutar,
/// satıra dokununca açılan market sayfasındaki üründen okunmuştur.
void main() {
  final typesById = {for (final type in productTypes) type.id: type};
  final brandNames = foodBrands.map((b) => b.name).toList();

  test('defter boş değil ve tarih taşır', () {
    expect(priceBook, isNotEmpty);
    expect(priceBookMarkets, isNotEmpty);
    expect(DateTime.tryParse(priceBookFetchedAt), isNotNull);
    final offerCount =
        priceBook.values.fold<int>(0, (sum, entry) => sum + entry.length);
    expect(offerCount, greaterThan(200));
  });

  test('yalnızca fiyat yayınlayan marketler defterde', () {
    final priced = Market.priced.map((m) => m.id).toSet();
    for (final marketId in priceBookMarkets) {
      expect(
        priced,
        contains(marketId),
        reason: '${marketId.name} fiyat yayınlamıyor işaretli, ama defterde',
      );
    }
    for (final entry in priceBook.values) {
      for (final marketId in entry.keys) {
        expect(priceBookMarkets, contains(marketId));
      }
    }
  });

  test('her kayıt katalogdaki bir satıra bağlı', () {
    for (final productId in priceBook.keys) {
      final typeId = productId.split('__').first;
      final type = typesById[typeId];
      expect(type, isNotNull, reason: '$productId: katalogda tip yok');

      final brandKey = productId.split('__').last;
      final brand = brandKey == 'markasiz'
          ? null
          : brandNames.firstWhere(
              (name) => Product.brandKeyOf(name) == brandKey,
              orElse: () => '',
            );
      expect(brand, isNot(''), reason: '$productId: katalogda marka yok');
      expect(type!.withBrand(brand).id, productId);
    }
  });

  test('her fiyatın kendi ürün sayfası ve pozitif tutarı var', () {
    final hosts = {
      MarketId.sok: 'www.sokmarket.com.tr',
      MarketId.happyCenter: 'happycenter.com.tr',
      MarketId.hakmar: 'www.hakmarexpress.com.tr',
      MarketId.migros: 'www.migros.com.tr',
      MarketId.macrocenter: 'www.macrocenter.com.tr',
    };

    for (final entry in priceBook.entries) {
      for (final offer in entry.value.entries) {
        final label = '${entry.key} · ${offer.key.name}';
        expect(offer.value.price, greaterThan(0), reason: label);
        expect(offer.value.product.trim(), isNotEmpty, reason: label);
        final uri = Uri.parse(offer.value.url);
        expect(uri.scheme, 'https', reason: label);
        expect(uri.host, hosts[offer.key], reason: label);
        // Ürün sayfası: arama ya da kategori adresi olmamalı.
        expect(uri.path.length, greaterThan(1), reason: label);
        expect(uri.query, isEmpty, reason: label);
        expect(uri.path, isNot(contains('/arama')), reason: label);
      }
    }
  });

  test('markalı satırda marka market ürün adında geçer', () {
    for (final entry in priceBook.entries) {
      final brandKey = entry.key.split('__').last;
      if (brandKey == 'markasiz' || brandKey == 'market-markasi') continue;
      final brand = brandNames
          .firstWhere((name) => Product.brandKeyOf(name) == brandKey);

      for (final offer in entry.value.entries) {
        expect(
          _mentionsBrand(offer.value.product, brand),
          isTrue,
          reason: '${entry.key} · ${offer.key.name}: '
              '"${offer.value.product}" $brand markasını göstermiyor',
        );
      }
    }
  });

  test('market ürünü katalogdaki gramajla aynı', () {
    for (final entry in priceBook.entries) {
      final type = typesById[entry.key.split('__').first]!;
      final expected = normalizedQuantities(type.name);
      if (expected.isEmpty) continue;

      for (final offer in entry.value.entries) {
        expect(
          normalizedQuantities(offer.value.product),
          containsAll(expected),
          reason: '${entry.key} · ${offer.key.name}: '
              '"${offer.value.product}" ${type.name} gramajında değil',
        );
      }
    }
  });

  test('aynı satırın market fiyatları birbirine yakın', () {
    for (final entry in priceBook.entries) {
      final brandKey = entry.key.split('__').last;
      // Markasız satırda her market kendi ürününü gösterir; fark gerçektir.
      if (brandKey == 'markasiz' || brandKey == 'market-markasi') continue;
      if (entry.value.length < 3) continue;

      final prices = entry.value.values.map((o) => o.price).toList()..sort();
      expect(
        prices.last / prices.first,
        lessThan(4),
        reason: '${entry.key}: fiyatlar çok açık, biri başka çeşit olabilir '
            '(${entry.value.entries.map((e) => '${e.key.name}=${e.value.price}').join(', ')})',
      );
    }
  });

  test('fiyatlı satır defterdeki tutarı ve ürün linkini gösterir', () async {
    final productId = priceBook.keys.first;
    final type = typesById[productId.split('__').first]!;
    final brandKey = productId.split('__').last;
    final brand = brandKey == 'markasiz'
        ? null
        : brandNames.firstWhere((n) => Product.brandKeyOf(n) == brandKey);

    final result = await const PriceBookService().compareBasket([
      ListItem(product: type.withBrand(brand), quantity: 2),
    ]);

    for (final marketId in priceBook[productId]!.keys) {
      final offer = priceBook[productId]![marketId]!;
      final line = result.baskets
          .firstWhere((b) => b.market.id == marketId)
          .lines
          .single;
      expect(line.unitPrice, offer.price);
      expect(line.lineTotal, offer.price * 2);
      expect(line.marketProduct, offer.product);
      expect(line.sourceUrl, offer.url);
      expect(line.source!.kind, ProductLinkKind.product);
      expect(line.opensPricedProduct, isTrue);
    }
  });

  test('defterde olmayan satır fiyatsız kalır ve tahmin üretmez', () async {
    final type = productTypes.firstWhere((t) => t.id == 'kasar-500');
    // Katalogda olan ama hiçbir markette bu gramajla bulunmayan bir marka.
    final product = type.withBrand('Danone');
    expect(priceBook[product.id], isNull);

    final result = await const PriceBookService().compareBasket([
      ListItem(product: product),
    ]);

    for (final basket in result.baskets) {
      final line = basket.lines.single;
      expect(line.unitPrice, isNull);
      expect(line.available, isFalse);
      expect(line.lineTotal, 0);
      expect(basket.total, 0);
      // Fiyat yok: bağlantı ürün sayfası değil, marketin kendi araması.
      expect(line.source!.kind, isNot(ProductLinkKind.product));
    }
  });

  test('stokta olmayan kayıt fiyat göstermez', () async {
    final entry = priceBook.entries.firstWhere(
      (e) => e.value.values.any((offer) => !offer.inStock),
      orElse: () => const MapEntry('', {}),
    );
    if (entry.key.isEmpty) return;

    final type = typesById[entry.key.split('__').first]!;
    final brandKey = entry.key.split('__').last;
    final brand = brandKey == 'markasiz'
        ? null
        : brandNames.firstWhere((n) => Product.brandKeyOf(n) == brandKey);
    final result = await const PriceBookService().compareBasket([
      ListItem(product: type.withBrand(brand)),
    ]);

    for (final offer in entry.value.entries) {
      if (offer.value.inStock) continue;
      final line = result.baskets
          .firstWhere((b) => b.market.id == offer.key)
          .lines
          .single;
      expect(line.available, isFalse);
    }
  });

  test('sepetteki her fiyat ya defterden gelir ya da yoktur', () async {
    final items = [
      for (final productId in priceBook.keys.take(40))
        ListItem(
          product: _productFor(productId, typesById, brandNames),
        ),
    ];
    final result = await const PriceBookService().compareBasket(items);

    var priced = 0;
    for (final basket in result.baskets) {
      for (final line in basket.lines) {
        final offer = priceBook[line.product.id]?[basket.market.id];
        if (line.available) {
          priced++;
          expect(offer, isNotNull);
          expect(line.unitPrice, offer!.price);
          expect(line.sourceUrl, offer.url);
        } else {
          expect(offer?.inStock ?? false, isFalse);
        }
      }
    }
    expect(priced, greaterThan(40));
  });
}

Product _productFor(
  String productId,
  Map<String, ProductType> typesById,
  List<String> brandNames,
) {
  final type = typesById[productId.split('__').first]!;
  final brandKey = productId.split('__').last;
  final brand = brandKey == 'markasiz'
      ? null
      : brandNames.firstWhere((n) => Product.brandKeyOf(n) == brandKey);
  return type.withBrand(brand);
}

/// Marka adı ürün adında kelime olarak geçiyor mu?
bool _mentionsBrand(String product, String brand) {
  String normalize(String value) => foldTurkish(value)
      .replaceAll(RegExp(r"[^a-z0-9]+"), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  final haystack = ' ${normalize(product)} ';
  final needle = normalize(brand);
  if (haystack.contains(' $needle ')) return true;
  // Kesme işareti markete göre değişir: "Nuh'un Ankara" / "Nuhun Ankara".
  return haystack.replaceAll(' ', '').contains(needle.replaceAll(' ', ''));
}

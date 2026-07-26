import 'package:flutter_test/flutter_test.dart';
import 'package:sepet_karsilastir/data/brands.dart';
import 'package:sepet_karsilastir/data/market_price_index.dart';
import 'package:sepet_karsilastir/data/market_product_snapshot.dart';
import 'package:sepet_karsilastir/data/mock_catalog.dart';
import 'package:sepet_karsilastir/models/list_item.dart';
import 'package:sepet_karsilastir/models/market.dart';
import 'package:sepet_karsilastir/services/mock_price_service.dart';
import 'package:sepet_karsilastir/utils/text.dart';

import 'support/quantity.dart';

/// marketfiyati.org.tr indeksinin veri bütünlüğü.
///
/// İndeks yedi zincirin kasa fiyatını taşıyor. Bir kayıt tek bir ürünün
/// zincirlere göre fiyatıdır: sepetteki marka, gramaj ve çeşit hiçbir
/// markette değişmemeli, yoksa "aynı listeyi karşılaştırıyoruz" sözü bozulur.
void main() {
  final typeById = {for (final type in productTypes) type.id: type};

  /// İndeksin kapsadığı zincirler — başka bir market kaydı olmamalı.
  const indexedMarkets = {
    MarketId.bim,
    MarketId.a101,
    MarketId.sok,
    MarketId.migros,
    MarketId.carrefour,
    MarketId.hakmar,
    MarketId.tarimKredi,
  };

  final brandKeyToName = {
    for (final brand in foodBrands) slugifyTurkish(brand.name): brand.name,
  };

  test('her kayıt gerçek bir ürün tipi ve gerçek bir markaya bağlanır', () {
    expect(marketPriceIndex, isNotEmpty);

    for (final id in marketPriceIndex.keys) {
      final parts = id.split('__');
      expect(parts, hasLength(2), reason: '$id ürün kimliği biçiminde değil');

      final type = typeById[parts.first];
      expect(type, isNotNull, reason: '$id bilinmeyen ürün tipi');

      final brandName = brandKeyToName[parts.last];
      expect(brandName, isNotNull, reason: '$id bilinmeyen marka anahtarı');
      expect(
        brandsForCategory(type!.category).map((b) => b.name),
        contains(brandName),
        reason: '$id: $brandName markası ${type.category} altında önerilmiyor',
      );

      // Kimlik kataloğun ürettiği kimlikle birebir aynı olmalı, yoksa kayıt
      // sepetteki üründe hiç kullanılmaz.
      expect(type.withBrand(brandName).id, id);
    }
  });

  test('yalnızca indeksin yayınladığı yedi zincir yer alır', () {
    for (final entry in marketPriceIndex.entries) {
      expect(entry.value.prices, isNotEmpty,
          reason: '${entry.key} fiyatsız kayıt');
      for (final marketId in entry.value.prices.keys) {
        expect(
          indexedMarkets,
          contains(marketId),
          reason: '${entry.key}: ${marketId.name} indekste yayınlanmıyor',
        );
      }
    }
  });

  test('her fiyat pozitif ve ürün adı dolu', () {
    for (final entry in marketPriceIndex.entries) {
      expect(entry.value.product, isNotEmpty,
          reason: '${entry.key} ürün adı boş');
      for (final price in entry.value.prices.values) {
        expect(price, greaterThan(0), reason: '${entry.key} fiyatı yok');
      }
    }
  });

  test('indekste listelenen ürün sepetteki markayı taşır', () {
    for (final entry in marketPriceIndex.entries) {
      final brandKey = entry.key.split('__').last;
      final brandTokens = brandKey.split('-');
      final nameTokens = RegExp(r'[a-z0-9]+')
          .allMatches(foldTurkish(entry.value.product))
          .map((m) => m.group(0)!)
          .toList();

      final carriesBrand = [
        for (var i = 0; i + brandTokens.length <= nameTokens.length; i++)
          nameTokens.sublist(i, i + brandTokens.length),
      ].any((window) => window.join('-') == brandKey);

      expect(
        carriesBrand,
        isTrue,
        reason: '${entry.key}: "${entry.value.product}" $brandKey markasını '
            'taşımıyor',
      );
    }
  });

  test('indeksteki gramaj katalogdaki birimle aynı', () {
    for (final entry in marketPriceIndex.entries) {
      final type = typeById[entry.key.split('__').first]!;
      final expected = normalizedQuantities(type.name);
      if (expected.isEmpty) continue; // kg ile satılanlar, somun ekmek

      final published = <String>{
        ...normalizedQuantities(entry.value.product),
        ...normalizedQuantities(entry.value.unit ?? ''),
      };
      expect(
        published,
        containsAll(expected),
        reason: '${entry.key}: "${entry.value.product}" '
            '(${entry.value.unit}) ${type.name} birimiyle aynı gramajda değil',
      );
    }
  });

  test('paket adedi katalogdaki adetle aynı', () {
    final count = RegExp(r"(\d+)\s*'?(lu|lü|li|lı)\b");
    final listed = RegExp(r"(\d+)\s*'?(adet|lu|lü|li|lı|rulo)");

    for (final entry in marketPriceIndex.entries) {
      final type = typeById[entry.key.split('__').first]!;
      final expected = count.firstMatch(foldTurkish(type.name))?.group(1);
      if (expected == null) continue; // gramajla satılan tipler

      final counts = listed
          .allMatches(foldTurkish('${entry.value.product} ${entry.value.unit}'))
          .map((m) => m.group(1))
          .toSet();
      expect(
        counts,
        contains(expected),
        reason: '${entry.key}: "${entry.value.product}" ${type.name} '
            'adediyle aynı değil',
      );
    }
  });

  test('aynı ürünün market fiyatları birbirinden makul uzaklıkta', () {
    for (final entry in marketPriceIndex.entries) {
      final prices = entry.value.prices.values.toList()..sort();
      if (prices.length < 2) continue;
      expect(
        prices.last / prices.first,
        lessThan(3),
        reason: '${entry.key}: fiyatlar ${prices.first}–${prices.last} TL '
            'arasında, muhtemelen farklı ürünler eşleşti',
      );
    }
  });

  test('indeksli market satırı indeks fiyatını doğrulanmış gösterir', () async {
    // Şok/Happy Center kaydı olmayan bir Migros fiyatı seç: satırın fiyatı
    // yalnızca indeksten gelebilir.
    final entry = marketPriceIndex.entries.firstWhere((e) =>
        e.value.prices.containsKey(MarketId.migros) &&
        !marketProductSnapshot.containsKey(e.key));
    final type = typeById[entry.key.split('__').first]!;
    final brand = brandKeyToName[entry.key.split('__').last]!;

    final result = await MockPriceService().compareBasket([
      ListItem(product: type.withBrand(brand)),
    ]);

    final migros =
        result.baskets.firstWhere((b) => b.market.id == MarketId.migros);
    final line = migros.lines.single;
    expect(line.unitPrice, entry.value.prices[MarketId.migros]);
    expect(line.available, isTrue);
    expect(line.verified, isTrue);
    expect(line.isEstimate, isFalse);

    // İndeksin kapsamadığı market aynı marka + birimi tahminle gösterir.
    final macro =
        result.baskets.firstWhere((b) => b.market.id == MarketId.macrocenter);
    expect(macro.lines.single.verified, isFalse);
    expect(macro.lines.single.product.name, type.name);
    expect(macro.lines.single.product.brand, brand);
  });

  test('indeks fiyatı doğrulanmayan marketlerin tahminini besler', () async {
    // Aynı tipte pahalı ve ucuz marka: indeksten gelen fiyat farkı, indeksin
    // kapsamadığı marketlerde de korunmalı.
    final cheese = productTypes.firstWhere((t) => t.id == 'kasar-500');
    final service = MockPriceService();

    final premium = await service.compareBasket([
      ListItem(product: cheese.withBrand('Muratbey')),
    ]);
    final budget = await service.compareBasket([
      ListItem(product: cheese.withBrand('İçim')),
    ]);

    double at(dynamic result, MarketId id) => result.baskets
        .firstWhere((b) => b.market.id == id)
        .lines
        .single
        .unitPrice as double;

    expect(at(premium, MarketId.file), greaterThan(at(budget, MarketId.file)));
  });
}

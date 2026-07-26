import 'package:flutter_test/flutter_test.dart';
import 'package:sepet_karsilastir/data/brands.dart';
import 'package:sepet_karsilastir/data/market_product_snapshot.dart';
import 'package:sepet_karsilastir/data/mock_catalog.dart';
import 'package:sepet_karsilastir/utils/text.dart';

import 'support/quantity.dart';

/// Doğrulanmış market kayıtlarının veri bütünlüğü.
///
/// Bu dosya uygulamanın çekirdek sözünü koruyor: sepete "Bahçıvan Kaşar
/// Peyniri 500g" eklendiyse hiçbir market satırı başka bir markaya ya da
/// başka bir gramaja gitmez.
void main() {
  final typeById = {for (final type in productTypes) type.id: type};

  /// Ürün kimliği `<tipId>__<markaAnahtarı>` biçiminde üretilir; anahtarı
  /// [ProductType.withBrand] ile birebir aynı yoldan çözüyoruz.
  final brandKeyToName = {
    for (final brand in foodBrands) slugifyTurkish(brand.name): brand.name,
  };

  test('her kayıt gerçek bir ürün tipi ve gerçek bir markaya bağlanır', () {
    expect(marketProductSnapshot, isNotEmpty);

    for (final id in marketProductSnapshot.keys) {
      final parts = id.split('__');
      expect(parts, hasLength(2), reason: '$id ürün kimliği biçiminde değil');

      final type = typeById[parts.first];
      expect(type, isNotNull, reason: '$id bilinmeyen ürün tipi');

      final brandName = brandKeyToName[parts.last];
      expect(brandName, isNotNull, reason: '$id bilinmeyen marka anahtarı');

      // Kayıt yalnızca marka o kategoride önerilebiliyorsa erişilebilir.
      expect(
        brandsForCategory(type!.category).map((b) => b.name),
        contains(brandName),
        reason: '$id: $brandName markası ${type.category} altında önerilmiyor',
      );

      // Kimlik gerçekten kataloğun ürettiği kimlikle aynı mı?
      expect(type.withBrand(brandName).id, id);
    }
  });

  test('market ürün adı sepetteki markayı taşır', () {
    for (final entry in marketProductSnapshot.entries) {
      final brandKey = entry.key.split('__').last;
      final brandTokens = brandKey.split('-');

      for (final ref in entry.value.all) {
        final nameTokens = RegExp(r'[a-z0-9]+')
            .allMatches(foldTurkish(ref.name))
            .map((m) => m.group(0)!)
            .toList();

        final carriesBrand = [
          for (var i = 0; i + brandTokens.length <= nameTokens.length; i++)
            nameTokens.sublist(i, i + brandTokens.length),
        ].any((window) => window.join('-') == brandKey);

        expect(
          carriesBrand,
          isTrue,
          reason: '${entry.key}: "${ref.name}" $brandKey markasını taşımıyor',
        );
      }
    }
  });

  test('market ürününün gramajı katalogdaki birimle aynı', () {
    for (final entry in marketProductSnapshot.entries) {
      final type = typeById[entry.key.split('__').first]!;
      final expected = normalizedQuantities(type.name);
      if (expected.isEmpty) continue; // kg ile satılan sebze/meyve

      for (final ref in entry.value.all) {
        expect(
          normalizedQuantities(ref.name),
          containsAll(expected),
          reason: '${entry.key}: "${ref.name}" ${type.name} birimiyle '
              'aynı gramajda değil',
        );
      }
    }
  });

  test('her kayıtta yol ve pozitif fiyat var', () {
    for (final entry in marketProductSnapshot.entries) {
      for (final ref in entry.value.all) {
        expect(ref.path, isNotEmpty, reason: '${entry.key} yolu boş');
        expect(ref.path, isNot(startsWith('/')),
            reason: '${entry.key} yolu alan adına göreli olmalı');
        expect(ref.path, isNot(contains('http')),
            reason: '${entry.key} yolu tam URL içeriyor');
        expect(ref.price, greaterThan(0), reason: '${entry.key} fiyatı yok');
        expect(ref.name, isNotEmpty);
      }
    }
  });

  test('Şok yolları ürün kimliğini içerir', () {
    for (final entry in marketProductSnapshot.entries) {
      final sok = entry.value.sok;
      if (sok == null) continue;
      expect(
        sok.path,
        matches(RegExp(r'-p-\d+$')),
        reason: '${entry.key}: ${sok.path} Şok ürün yolu biçiminde değil',
      );
    }
  });
}

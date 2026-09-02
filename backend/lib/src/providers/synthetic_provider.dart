import '../catalog.dart';
import 'official_provider.dart';

/// Geliştirme / demo: deterministik fiyat motoru.
///
/// Resmi market uygulaması fiyatı değildir. Yalnızca `PRICE_MODE=synthetic`
/// iken kullanılır; production’da resmi adaptörler bağlanmalıdır.
class SyntheticPriceProvider implements OfficialMarketProvider {
  SyntheticPriceProvider({
    required this.slug,
    required this.displayName,
    required this.priceIndex,
    this.unavailableTypes = const {},
  });

  @override
  final String slug;

  @override
  final String displayName;

  final double priceIndex;
  final Set<String> unavailableTypes;

  static const _basePrices = <String, double>{
    'sut-1l': 42.90,
    'yumurta-30': 149.90,
    'ekmek-250': 28.50,
    'pirinc-1kg': 89.90,
    'makarna-500': 32.50,
    'aycicek-1l': 89.90,
    'seker-1kg': 54.90,
    'cay-500': 178.00,
    'su-6x': 79.90,
    'domates-1kg': 39.90,
    'patates-1kg': 24.90,
    'muz-1kg': 69.90,
    'tavuk-1kg': 189.90,
    'kofte-400': 129.90,
    'peynir-500': 159.90,
    'yogurt-1kg': 69.90,
    'deterjan-3kg': 289.90,
    'sampuan-400': 94.90,
    'tuvalet-8': 119.90,
    'cips-107': 45.90,
  };

  static const _premiumOnlyBrands = <String>{
    'Barilla',
    'Danone',
    'Head & Shoulders',
    'Dove',
    'Doritos',
  };

  static const _limitedSlugs = <String>{
    'bim',
    'a101',
    'sok',
    'hakmar',
    'tarim-kredi',
  };

  @override
  bool get isConfigured => true;

  @override
  String get configurationHint =>
      'Sentetik demo motoru (resmi uygulama fiyatı değil)';

  @override
  Future<MarketQuoteResult> fetchQuotes({
    required List<QuoteItem> items,
    String? region,
    String? storeId,
  }) async {
    final quotes = items.map((item) {
      final base = _basePrices[item.typeId] ?? 49.90;
      final brand = item.brand;
      final available = !unavailableTypes.contains(item.typeId) &&
          !_brandMissing(brand);

      final price = _round(
        base *
            priceIndex *
            _jitter(item.typeId) *
            _brandFactor(brand),
      );

      return LineQuote(
        productId: item.productId,
        externalSku: item.externalSku,
        unitPrice: price,
        available: available,
        matchedTitle: item.name ?? item.catalogType?.name,
        depotName: '$displayName demo',
      );
    }).toList();

    return MarketQuoteResult(
      marketId: _marketId,
      status: 'ok',
      fetchedAt: DateTime.now(),
      storeId: storeId ?? 'synthetic-$slug',
      quotes: quotes,
      source: 'synthetic',
    );
  }

  bool _brandMissing(String? brand) {
    if (brand == null || brand.isEmpty) return false;
    return _limitedSlugs.contains(slug) && _premiumOnlyBrands.contains(brand);
  }

  double _jitter(String typeId) {
    final seed = '$slug:$typeId'.hashCode.abs();
    return 0.96 + (seed % 9) * 0.01;
  }

  double _brandFactor(String? brand) {
    if (brand == null || brand.isEmpty) return 0.97;
    if (brand == 'Market markası') return 0.88;
    if (_premiumOnlyBrands.contains(brand)) return 1.12;
    final h = brand.hashCode.abs() % 9;
    return 0.96 + (h * 0.01);
  }

  double _round(double value) => (value * 100).roundToDouble() / 100;

  String get _marketId {
    const map = {
      'tarim-kredi': 'tarimKredi',
      'happy-center': 'happyCenter',
    };
    return map[slug] ?? slug;
  }
}

List<OfficialMarketProvider> buildSyntheticProviders() {
  return [
    SyntheticPriceProvider(
      slug: 'migros',
      displayName: 'Migros',
      priceIndex: 1.05,
    ),
    SyntheticPriceProvider(
      slug: 'macrocenter',
      displayName: 'Macrocenter',
      priceIndex: 1.24,
    ),
    SyntheticPriceProvider(
      slug: 'a101',
      displayName: 'A101',
      priceIndex: 0.93,
    ),
    SyntheticPriceProvider(
      slug: 'bim',
      displayName: 'BİM',
      priceIndex: 0.91,
      unavailableTypes: {'domates-1kg', 'patates-1kg', 'tavuk-1kg'},
    ),
    SyntheticPriceProvider(
      slug: 'sok',
      displayName: 'Şok',
      priceIndex: 0.94,
    ),
    SyntheticPriceProvider(
      slug: 'carrefour',
      displayName: 'CarrefourSA',
      priceIndex: 1.06,
    ),
    SyntheticPriceProvider(
      slug: 'tarim-kredi',
      displayName: 'Tarım Kredi Market',
      priceIndex: 0.89,
      unavailableTypes: {'cips-107', 'sampuan-400'},
    ),
    SyntheticPriceProvider(
      slug: 'hakmar',
      displayName: 'Hakmar Express',
      priceIndex: 0.92,
      unavailableTypes: {'tavuk-1kg', 'muz-1kg'},
    ),
    SyntheticPriceProvider(
      slug: 'happy-center',
      displayName: 'Happy Center',
      priceIndex: 1.00,
    ),
  ];
}

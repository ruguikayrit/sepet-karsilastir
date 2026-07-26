import '../data/mock_catalog.dart';
import '../models/comparison_result.dart';
import '../models/fetch_status.dart';
import '../models/list_item.dart';
import '../models/market.dart';
import 'price_service.dart';

/// Demo / geliştirme: marketlere göre değişen güncel-benzer fiyatlar.
///
/// Her market için tek bir fiyat seviyesi (index) tutulur; ürün bazlı küçük
/// sapma deterministik hash ile üretilir. Böylece market sayısı arttıkça
/// tablo büyümez ve farklı marketler farklı üründe öne çıkar.
class MockPriceService implements PriceService {
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

  /// Marketin genel fiyat seviyesi.
  static const _marketIndex = <MarketId, double>{
    MarketId.bim: 0.91,
    MarketId.a101: 0.93,
    MarketId.sok: 0.94,
    MarketId.hakmar: 0.92,
    MarketId.tarimKredi: 0.89,
    MarketId.metro: 0.95,
    MarketId.file: 0.99,
    MarketId.onur: 0.98,
    MarketId.happyCenter: 1.00,
    MarketId.migros: 1.05,
    MarketId.carrefour: 1.06,
    MarketId.getir: 1.12,
    MarketId.macrocenter: 1.24,
  };

  /// Marketin taşımadığı ürün tipleri.
  static const _unavailableTypes = <MarketId, Set<String>>{
    MarketId.bim: {'domates-1kg', 'patates-1kg', 'tavuk-1kg'},
    MarketId.hakmar: {'tavuk-1kg', 'muz-1kg'},
    MarketId.tarimKredi: {'cips-107', 'sampuan-400'},
    MarketId.metro: {'ekmek-250'},
    MarketId.getir: {'kofte-400'},
    MarketId.file: {'kofte-400'},
  };

  /// İndirim marketlerinde bulunmayan ulusal markalar.
  static const _limitedAssortment = <MarketId>{
    MarketId.bim,
    MarketId.a101,
    MarketId.sok,
    MarketId.hakmar,
    MarketId.tarimKredi,
  };

  static const _premiumOnlyBrands = <String>{
    'Barilla',
    'Danone',
    'Head & Shoulders',
    'Dove',
    'Doritos',
  };

  @override
  Future<List<ProductType>> searchProductTypes(String query) async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    return searchProductTypesLocal(query);
  }

  @override
  Future<ComparisonResult> compareBasket(List<ListItem> items) async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
    final now = DateTime.now();

    final baskets = Market.all.map((market) {
      final index = _marketIndex[market.id] ?? 1.0;
      final missingTypes = _unavailableTypes[market.id] ?? const <String>{};

      final lines = items.map((item) {
        final typeId = item.product.typeId;
        final brand = item.product.brand;
        final base = _basePrices[typeId] ?? 49.90;

        final available = !missingTypes.contains(typeId) &&
            !_brandMissing(market.id, brand);

        final price = _roundMoney(
          base * index * _productJitter(market.id, typeId) * _brandFactor(brand),
        );

        return LinePrice(
          product: item.product,
          quantity: item.quantity,
          unitPrice: price,
          available: available,
        );
      }).toList();

      return MarketBasketResult(
        market: market,
        lines: lines,
        fetchedAt: now,
        status: FetchStatus.ok,
      );
    }).toList();

    return ComparisonResult(
      baskets: baskets,
      comparedAt: now,
      source: PriceSource.mock,
    );
  }

  bool _brandMissing(MarketId marketId, String? brand) {
    if (brand == null || brand.isEmpty) return false;
    return _limitedAssortment.contains(marketId) &&
        _premiumOnlyBrands.contains(brand);
  }

  /// Ürün bazlı ±4% deterministik sapma — her market farklı üründe öne çıkar.
  double _productJitter(MarketId marketId, String typeId) {
    final seed = '${marketId.name}:$typeId'.hashCode.abs();
    return 0.96 + (seed % 9) * 0.01;
  }

  /// Markaya göre fiyat farkı (demo).
  double _brandFactor(String? brand) {
    if (brand == null || brand.isEmpty) return 0.97;
    if (brand == 'Market markası') return 0.88;
    if (_premiumOnlyBrands.contains(brand)) return 1.12;
    final h = brand.hashCode.abs() % 9;
    return 0.96 + (h * 0.01);
  }

  double _roundMoney(double value) => (value * 100).roundToDouble() / 100;
}

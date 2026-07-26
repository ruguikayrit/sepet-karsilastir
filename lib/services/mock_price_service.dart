import '../data/market_price_snapshot.dart';
import '../data/mock_catalog.dart';
import '../models/comparison_result.dart';
import '../models/fetch_status.dart';
import '../models/list_item.dart';
import '../models/market.dart';
import 'mapping/product_source_url.dart';
import 'price_service.dart';

/// Demo / geliştirme: market sitelerinden derlenen referans fiyatlara göre
/// market bazlı karşılaştırma üretir.
///
/// Taban fiyatlar [marketPriceSnapshot] içindeki resmi site verileridir
/// (Şok Market + Happy Center, 2026-07-26). Her market için tek bir fiyat
/// seviyesi (index) tutulur; ürün bazlı küçük sapma deterministik hash ile
/// üretilir. Satır linkleri [ProductSourceUrl] ile o marketin sitesine gider.
class MockPriceService implements PriceService {
  /// Snapshot’taki Şok/Happy Center birim fiyatları — diğer marketler index ile sapar.
  static final Map<String, double> _basePrices = {
    for (final entry in marketPriceSnapshot.entries)
      entry.key: entry.value.unitPrice,
  };

  /// Marketin genel fiyat seviyesi (1.0 ≈ snapshot kaynak marketleri).
  static const _marketIndex = <MarketId, double>{
    MarketId.bim: 0.97,
    MarketId.a101: 0.99,
    MarketId.sok: 1.00,
    MarketId.hakmar: 0.98,
    MarketId.tarimKredi: 0.95,
    MarketId.metro: 1.01,
    MarketId.file: 1.05,
    MarketId.onur: 1.04,
    MarketId.happyCenter: 1.00,
    MarketId.migros: 1.12,
    MarketId.carrefour: 1.13,
    MarketId.getir: 1.19,
    MarketId.macrocenter: 1.32,
  };

  /// Marketin taşımadığı ürün tipleri.
  static const _unavailableTypes = <MarketId, Set<String>>{
    MarketId.bim: {
      'domates-1kg',
      'patates-1kg',
      'tavuk-1kg',
      'pilic-butun',
      'biber-1kg',
      'fasulye-1kg',
    },
    MarketId.hakmar: {
      'tavuk-1kg',
      'muz-1kg',
      'pilic-but',
      'filtre-kahve',
    },
    MarketId.tarimKredi: {
      'cips-150',
      'sampuan-400',
      'dondurma-500',
      'bebek-bezi',
      'dus-jeli',
    },
    MarketId.metro: {'ekmek-250', 'ekmek-beyaz', 'maydanoz'},
    MarketId.getir: {'kofte-500', 'kiyma-400', 'un-5kg'},
    MarketId.file: {'kofte-500', 'sucuk-250'},
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
    "Kellogg's",
    'Mehmet Efendi',
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
          sourceUrl: ProductSourceUrl.resolve(
            marketId: market.id,
            product: item.product,
          ),
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

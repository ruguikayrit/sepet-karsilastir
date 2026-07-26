import '../data/mock_catalog.dart';
import '../models/comparison_result.dart';
import '../models/fetch_status.dart';
import '../models/list_item.dart';
import '../models/market.dart';
import 'price_service.dart';

/// Demo / geliştirme: marketlere göre değişen güncel-benzer fiyatlar.
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

  static const _marketBias = <MarketId, Map<String, double>>{
    MarketId.migros: {
      'sut-1l': 1.05,
      'yumurta-30': 1.02,
      'ekmek-250': 1.08,
      'pirinc-1kg': 0.98,
      'makarna-500': 1.00,
      'aycicek-1l': 1.03,
      'seker-1kg': 1.01,
      'cay-500': 0.97,
      'su-6x': 1.04,
      'domates-1kg': 1.06,
      'patates-1kg': 1.02,
      'muz-1kg': 1.05,
      'tavuk-1kg': 1.01,
      'kofte-400': 1.04,
      'peynir-500': 1.00,
      'yogurt-1kg': 0.99,
      'deterjan-3kg': 0.96,
      'sampuan-400': 1.02,
      'tuvalet-8': 1.03,
      'cips-107': 1.01,
    },
    MarketId.a101: {
      'sut-1l': 0.94,
      'yumurta-30': 0.93,
      'ekmek-250': 0.90,
      'pirinc-1kg': 0.95,
      'makarna-500': 0.92,
      'aycicek-1l': 0.94,
      'seker-1kg': 0.93,
      'cay-500': 0.98,
      'su-6x': 0.96,
      'domates-1kg': 0.97,
      'patates-1kg': 0.94,
      'muz-1kg': 0.98,
      'tavuk-1kg': 0.97,
      'kofte-400': 0.96,
      'peynir-500': 0.95,
      'yogurt-1kg': 0.94,
      'deterjan-3kg': 0.99,
      'sampuan-400': 0.97,
      'tuvalet-8': 0.95,
      'cips-107': 0.96,
    },
    MarketId.sok: {
      'sut-1l': 0.96,
      'yumurta-30': 0.95,
      'ekmek-250': 0.92,
      'pirinc-1kg': 0.97,
      'makarna-500': 0.94,
      'aycicek-1l': 0.95,
      'seker-1kg': 0.94,
      'cay-500': 0.99,
      'su-6x': 0.97,
      'domates-1kg': 0.95,
      'patates-1kg': 0.93,
      'muz-1kg': 0.97,
      'tavuk-1kg': 0.98,
      'kofte-400': 0.97,
      'peynir-500': 0.96,
      'yogurt-1kg': 0.95,
      'deterjan-3kg': 1.01,
      'sampuan-400': 0.98,
      'tuvalet-8': 0.96,
      'cips-107': 0.94,
    },
    MarketId.carrefour: {
      'sut-1l': 1.06,
      'yumurta-30': 1.04,
      'ekmek-250': 1.10,
      'pirinc-1kg': 1.02,
      'makarna-500': 1.03,
      'aycicek-1l': 1.05,
      'seker-1kg': 1.04,
      'cay-500': 1.01,
      'su-6x': 1.06,
      'domates-1kg': 1.08,
      'patates-1kg': 1.05,
      'muz-1kg': 1.07,
      'tavuk-1kg': 1.03,
      'kofte-400': 1.05,
      'peynir-500': 1.04,
      'yogurt-1kg': 1.02,
      'deterjan-3kg': 0.98,
      'sampuan-400': 1.04,
      'tuvalet-8': 1.05,
      'cips-107': 1.03,
    },
    MarketId.file: {
      'sut-1l': 0.98,
      'yumurta-30': 0.97,
      'ekmek-250': 0.95,
      'pirinc-1kg': 0.96,
      'makarna-500': 0.97,
      'aycicek-1l': 0.98,
      'seker-1kg': 0.97,
      'cay-500': 0.96,
      'su-6x': 0.99,
      'domates-1kg': 0.99,
      'patates-1kg': 0.96,
      'muz-1kg': 1.00,
      'tavuk-1kg': 0.99,
      'kofte-400': 0.98,
      'peynir-500': 0.97,
      'yogurt-1kg': 0.96,
      'deterjan-3kg': 0.97,
      'sampuan-400': 0.99,
      'tuvalet-8': 0.98,
      'cips-107': 0.97,
    },
  };

  static const _unavailable = <MarketId, Set<String>>{
    MarketId.file: {'kofte-400'},
    MarketId.carrefour: {},
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
      final bias = _marketBias[market.id]!;
      final missing = _unavailable[market.id] ?? {};

      final lines = items.map((item) {
        final typeId = item.product.typeId;
        final base = _basePrices[typeId] ?? 49.90;
        final factor = bias[typeId] ?? 1.0;
        final brandFactor = _brandFactor(item.product.brand);
        final available = !missing.contains(typeId);
        final price = _roundMoney(base * factor * brandFactor);
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

  /// Markaya göre küçük fiyat farkı (demo).
  double _brandFactor(String? brand) {
    if (brand == null || brand.isEmpty) return 0.97;
    if (brand == 'Market markası') return 0.92;
    final h = brand.hashCode.abs() % 9;
    return 0.96 + (h * 0.01);
  }

  double _roundMoney(double value) => (value * 100).roundToDouble() / 100;
}

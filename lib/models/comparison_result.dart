import 'fetch_status.dart';
import 'market.dart';
import 'product.dart';

enum PriceSource { mock, live }

class LinePrice {
  const LinePrice({
    required this.product,
    required this.quantity,
    required this.unitPrice,
    required this.available,
    this.sourceUrl,
  });

  final Product product;
  final int quantity;
  final double unitPrice;
  final bool available;

  /// Fiyatın alındığı orijinal market ürün sayfası (varsa).
  final String? sourceUrl;

  double get lineTotal => available ? unitPrice * quantity : 0;
}

class MarketBasketResult {
  const MarketBasketResult({
    required this.market,
    required this.lines,
    required this.fetchedAt,
    this.status = FetchStatus.ok,
    this.errorMessage,
    this.storeId,
  });

  final Market market;
  final List<LinePrice> lines;
  final DateTime fetchedAt;
  final FetchStatus status;
  final String? errorMessage;
  final String? storeId;

  double get total =>
      lines.fold<double>(0, (sum, line) => sum + line.lineTotal);

  int get missingCount => lines.where((l) => !l.available).length;

  bool get isComplete => status.isOk && missingCount == 0;

  int get availableCount => lines.where((l) => l.available).length;

  bool get fetchFailed => status.isFailed;
}

class ComparisonResult {
  const ComparisonResult({
    required this.baskets,
    required this.comparedAt,
    this.source = PriceSource.mock,
  });

  final List<MarketBasketResult> baskets;
  final DateTime comparedAt;
  final PriceSource source;

  /// En düşük toplam; fetch hatası ve eksik ürünler sonda.
  List<MarketBasketResult> get ranked {
    final sorted = [...baskets];
    sorted.sort((a, b) {
      if (a.fetchFailed != b.fetchFailed) {
        return a.fetchFailed ? 1 : -1;
      }
      if (a.isComplete != b.isComplete) {
        return a.isComplete ? -1 : 1;
      }
      return a.total.compareTo(b.total);
    });
    return sorted;
  }

  MarketBasketResult? get cheapestComplete {
    for (final b in ranked) {
      if (b.isComplete) return b;
    }
    return null;
  }

  double? get savingsVsMostExpensive {
    final complete = baskets.where((b) => b.isComplete).toList();
    if (complete.length < 2) return null;
    complete.sort((a, b) => a.total.compareTo(b.total));
    return complete.last.total - complete.first.total;
  }

  int get failedMarketCount =>
      baskets.where((b) => b.fetchFailed).length;
}

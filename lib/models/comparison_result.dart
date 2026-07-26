import 'fetch_status.dart';
import 'market.dart';
import 'product.dart';
import 'product_link.dart';

enum PriceSource { priceBook, live }

/// Bir marketin bir sepet satırı için verdiği fiyat.
///
/// Fiyat yalnızca marketin kendi ürün sayfasından okunduysa vardır: bu yüzden
/// [unitPrice] boş olabilir. Tahmin üretilmez — fiyat yoksa satır o markette
/// fiyatsızdır. Fiyat varsa [source] mutlaka o fiyatın okunduğu ürün
/// sayfasıdır, yani kullanıcı tutarı tıklayıp doğrulayabilir.
class LinePrice {
  const LinePrice({
    required this.product,
    required this.quantity,
    this.unitPrice,
    this.marketProduct,
    this.source,
  });

  final Product product;
  final int quantity;

  /// Marketin sayfasındaki raf fiyatı; fiyat yayınlanmıyorsa `null`.
  final double? unitPrice;

  /// Fiyatın okunduğu ürünün marketteki adı ("Mis Kaşar Peyniri 500 g").
  final String? marketProduct;

  /// Fiyatın okunduğu sayfa; fiyat varsa doğrudan ürün bağlantısıdır.
  final ProductLink? source;

  String? get sourceUrl => source?.url;

  /// Bu market bu satırı fiyatlıyor mu?
  bool get available => unitPrice != null;

  /// Fiyat, satıra dokununca açılan ürün sayfasından mı okundu?
  bool get opensPricedProduct =>
      available && source?.kind == ProductLinkKind.product;

  double get lineTotal => (unitPrice ?? 0) * quantity;
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

  /// Fiyat geldi ama liste tamamlanmıyor: toplam kısmi, market "en ucuz" sayılamaz.
  bool get isPartial => status.isOk && missingCount > 0;

  List<Product> get missingProducts =>
      lines.where((l) => !l.available).map((l) => l.product).toList();
}

class ComparisonResult {
  const ComparisonResult({
    required this.baskets,
    required this.comparedAt,
    this.source = PriceSource.priceBook,
    this.pricesFetchedAt,
  });

  /// Fiyatların market sitelerinden çekildiği gün (ISO 8601).
  final String? pricesFetchedAt;

  final List<MarketBasketResult> baskets;
  final DateTime comparedAt;
  final PriceSource source;

  /// Önce listeyi tamamlayanlar (en düşük toplam), sonra eksiği az olanlar,
  /// en sonda fiyat alınamayan marketler.
  List<MarketBasketResult> get ranked {
    final sorted = [...baskets];
    sorted.sort((a, b) {
      if (a.fetchFailed != b.fetchFailed) {
        return a.fetchFailed ? 1 : -1;
      }
      if (a.isComplete != b.isComplete) {
        return a.isComplete ? -1 : 1;
      }
      if (!a.isComplete && a.missingCount != b.missingCount) {
        return a.missingCount.compareTo(b.missingCount);
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

  int get completeCount => baskets.where((b) => b.isComplete).length;

  /// Tam sepet yoksa listeye en çok yaklaşan market.
  MarketBasketResult? get closestToComplete {
    final candidates = baskets.where((b) => !b.fetchFailed).toList();
    if (candidates.isEmpty) return null;
    candidates.sort((a, b) {
      if (a.missingCount != b.missingCount) {
        return a.missingCount.compareTo(b.missingCount);
      }
      return a.total.compareTo(b.total);
    });
    return candidates.first;
  }

  /// Hiçbir markette bulunamayan ürünler — liste bu haliyle tek markette tamamlanamaz.
  List<Product> get productsMissingEverywhere {
    final answered = baskets.where((b) => !b.fetchFailed).toList();
    if (answered.isEmpty) return const [];
    final available = <String>{};
    for (final basket in answered) {
      for (final line in basket.lines) {
        if (line.available) available.add(line.product.id);
      }
    }
    final seen = <String>{};
    final missing = <Product>[];
    for (final line in answered.first.lines) {
      final product = line.product;
      if (!available.contains(product.id) && seen.add(product.id)) {
        missing.add(product);
      }
    }
    return missing;
  }

  double? get savingsVsMostExpensive {
    final complete = baskets.where((b) => b.isComplete).toList();
    if (complete.length < 2) return null;
    complete.sort((a, b) => a.total.compareTo(b.total));
    return complete.last.total - complete.first.total;
  }

  int get failedMarketCount => baskets.where((b) => b.fetchFailed).length;
}

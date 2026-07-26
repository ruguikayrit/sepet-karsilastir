import 'package:flutter_test/flutter_test.dart';
import 'package:sepet_karsilastir/data/mock_catalog.dart';
// flutter_test da ComparisonResult adını dışa açtığı için önek kullanılıyor.
import 'package:sepet_karsilastir/models/comparison_result.dart' as model;
import 'package:sepet_karsilastir/models/fetch_status.dart';
import 'package:sepet_karsilastir/models/market.dart';
import 'package:sepet_karsilastir/models/product.dart';

/// Karşılaştırmanın kuralı: listeyi eksiksiz karşılamayan market "en ucuz"
/// olamaz, toplamı da tam bir sepetin toplamıyla kıyaslanamaz.
void main() {
  final milk =
      productTypes.firstWhere((t) => t.id == 'sut-1l').withBrand('İçim');
  final cheese =
      productTypes.firstWhere((t) => t.id == 'kasar-500').withBrand('Sütaş');

  model.MarketBasketResult basket(
    MarketId marketId, {
    required Map<Product, double?> prices,
    FetchStatus status = FetchStatus.ok,
    String? errorMessage,
  }) {
    return model.MarketBasketResult(
      market: Market.byId(marketId),
      lines: [
        for (final entry in prices.entries)
          model.LinePrice(
            product: entry.key,
            quantity: 1,
            unitPrice: entry.value ?? 0,
            available: entry.value != null,
          ),
      ],
      fetchedAt: DateTime(2026, 7, 26),
      status: status,
      errorMessage: errorMessage,
    );
  }

  model.ComparisonResult resultOf(List<model.MarketBasketResult> baskets) =>
      model.ComparisonResult(
        baskets: baskets,
        comparedAt: DateTime(2026, 7, 26),
      );

  test('eksik ürünü olan market daha düşük toplamla bile kazanmaz', () {
    final result = resultOf([
      // Ucuz görünüyor ama kaşar yok: kısmi toplam.
      basket(MarketId.bim, prices: {milk: 40, cheese: null}),
      basket(MarketId.sok, prices: {milk: 45, cheese: 300}),
      basket(MarketId.migros, prices: {milk: 55, cheese: 340}),
    ]);

    expect(result.cheapestComplete!.market.id, MarketId.sok);
    expect(result.ranked.first.market.id, MarketId.sok);
    expect(result.ranked.last.market.id, MarketId.bim);

    final bim = result.baskets.first;
    expect(bim.isComplete, isFalse);
    expect(bim.isPartial, isTrue);
    expect(bim.missingProducts.single.id, cheese.id);
    expect(bim.total, 40, reason: 'eksik satır toplama eklenmez');
  });

  test('tasarruf yalnızca tam sepetler arasında hesaplanır', () {
    final result = resultOf([
      basket(MarketId.bim, prices: {milk: 10, cheese: null}),
      basket(MarketId.sok, prices: {milk: 45, cheese: 300}),
      basket(MarketId.migros, prices: {milk: 55, cheese: 345}),
    ]);

    expect(result.savingsVsMostExpensive, 55);
    expect(result.completeCount, 2);
  });

  test('yanıt vermeyen market en sona düşer ve sıralamayı bozmaz', () {
    final result = resultOf([
      basket(
        MarketId.a101,
        prices: {milk: null, cheese: null},
        status: FetchStatus.failed,
        errorMessage: 'zaman aşımı',
      ),
      basket(MarketId.sok, prices: {milk: 45, cheese: 300}),
      basket(MarketId.file, prices: {milk: 50, cheese: null}),
    ]);

    expect(result.ranked.map((b) => b.market.id),
        [MarketId.sok, MarketId.file, MarketId.a101]);
    expect(result.failedMarketCount, 1);
    expect(result.productsMissingEverywhere, isEmpty);
  });

  test('tam sepet yoksa listeye en yakın market gösterilir', () {
    final bread =
        productTypes.firstWhere((t) => t.id == 'ekmek-beyaz').withBrand(null);

    final result = resultOf([
      basket(MarketId.bim, prices: {milk: 40, cheese: null, bread: null}),
      basket(MarketId.sok, prices: {milk: 45, cheese: 300, bread: null}),
      basket(MarketId.migros, prices: {milk: 55, cheese: 340, bread: null}),
    ]);

    expect(result.cheapestComplete, isNull);
    expect(result.completeCount, 0);
    expect(result.closestToComplete!.market.id, MarketId.sok);
    expect(result.productsMissingEverywhere.map((p) => p.id), [bread.id]);
    expect(result.savingsVsMostExpensive, isNull);
  });

  test('eksik sayısı eşitse ucuz olan öne geçer', () {
    final result = resultOf([
      basket(MarketId.migros, prices: {milk: 60, cheese: null}),
      basket(MarketId.bim, prices: {milk: 40, cheese: null}),
    ]);

    expect(result.ranked.first.market.id, MarketId.bim);
  });

  test('hiç ürün eklenmemişse her market tam sayılır', () {
    final result = resultOf([
      basket(MarketId.bim, prices: const {}),
      basket(MarketId.sok, prices: const {}),
    ]);

    expect(result.completeCount, 2);
    expect(result.cheapestComplete, isNotNull);
    expect(result.productsMissingEverywhere, isEmpty);
  });
}

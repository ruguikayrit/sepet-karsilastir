import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sepet_karsilastir/data/mock_catalog.dart';
import 'package:sepet_karsilastir/models/comparison_result.dart' as model;
import 'package:sepet_karsilastir/models/fetch_status.dart';
import 'package:sepet_karsilastir/models/list_item.dart';
import 'package:sepet_karsilastir/models/market.dart';
import 'package:sepet_karsilastir/models/product.dart';
import 'package:sepet_karsilastir/screens/compare_screen.dart';
import 'package:sepet_karsilastir/services/mapping/product_source_url.dart';
import 'package:sepet_karsilastir/services/price_service.dart';
import 'package:sepet_karsilastir/state/basket_controller.dart';
import 'package:sepet_karsilastir/theme/app_theme.dart';

/// Verilen fiyat tablosunu aynen döndüren servis: ekran davranışını
/// deterministik olarak sınamak için.
class _ScriptedPriceService implements PriceService {
  _ScriptedPriceService(this.prices);

  /// marketId -> (ürün kimliği -> birim fiyat; `null` ise o markette yok)
  final Map<MarketId, Map<String, double?>> prices;

  /// Fiyatı market sayfasından doğrulanmış sayılan marketler.
  final Set<MarketId> verifiedMarkets = {};

  @override
  Future<List<ProductType>> searchProductTypes(String query) async =>
      productTypes;

  @override
  Future<model.ComparisonResult> compareBasket(List<ListItem> items) async {
    final baskets = <model.MarketBasketResult>[];
    for (final entry in prices.entries) {
      baskets.add(
        model.MarketBasketResult(
          market: Market.byId(entry.key),
          lines: [
            for (final item in items)
              model.LinePrice(
                product: item.product,
                quantity: item.quantity,
                unitPrice: entry.value[item.product.id] ?? 0,
                available: entry.value[item.product.id] != null,
                verified: verifiedMarkets.contains(entry.key),
                source: ProductSourceUrl.resolve(
                  marketId: entry.key,
                  product: item.product,
                ),
              ),
          ],
          fetchedAt: DateTime(2026, 7, 26),
          status: FetchStatus.ok,
        ),
      );
    }
    return model.ComparisonResult(
      baskets: baskets,
      comparedAt: DateTime(2026, 7, 26),
    );
  }
}

Future<void> _pumpCompare(
  WidgetTester tester,
  BasketController controller,
) async {
  await tester.pumpWidget(
    ChangeNotifierProvider<BasketController>.value(
      value: controller,
      child: MaterialApp(
        theme: AppTheme.light(),
        home: const CompareScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// Sonuç listesi uzun; aranan metni görünür alana getirir.
Future<void> _scrollTo(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(
    finder,
    240,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
}

void main() {
  final milk = productTypes.firstWhere((t) => t.id == 'sut-1l');
  final cheese = productTypes.firstWhere((t) => t.id == 'kasar-500');

  Product milkOf(String brand) => milk.withBrand(brand);
  Product cheeseOf(String brand) => cheese.withBrand(brand);

  testWidgets('eksik ürünü olan market kısmi toplam olarak işaretlenir',
      (tester) async {
    final icim = milkOf('İçim');
    final sutas = cheeseOf('Sütaş');

    final controller = BasketController(
      _ScriptedPriceService({
        MarketId.bim: {icim.id: 40, sutas.id: null},
        MarketId.sok: {icim.id: 45, sutas.id: 300},
      }),
    );
    controller.addProduct(icim);
    controller.addProduct(sutas);
    await controller.compare();

    await _pumpCompare(tester, controller);

    expect(find.text('EN KARLI'), findsOneWidget);
    expect(find.text('Şok'), findsWidgets);
    expect(find.text('kısmi toplam'), findsOneWidget);
    expect(
        find.textContaining('1/2 market listeyi tamamlıyor'), findsOneWidget);

    // Fiyat dökümünde eksik ürün sayısı da yazar.
    await _scrollTo(tester, find.text('1 ürün eksik'));
    expect(find.text('1 ürün eksik'), findsOneWidget);
  });

  testWidgets('hiçbir market listeyi tamamlamıyorsa uyarı gösterilir',
      (tester) async {
    final icim = milkOf('İçim');
    final sutas = cheeseOf('Sütaş');

    final controller = BasketController(
      _ScriptedPriceService({
        MarketId.bim: {icim.id: 40, sutas.id: null},
        MarketId.sok: {icim.id: 45, sutas.id: null},
      }),
    );
    controller.addProduct(icim);
    controller.addProduct(sutas);
    await controller.compare();

    await _pumpCompare(tester, controller);

    expect(find.text('EN KARLI'), findsNothing);
    expect(
        find.text('Listeyi tek başına tamamlayan market yok'), findsOneWidget);
    expect(
      find.textContaining('Hiçbir markette bulunamadı: Sütaş Kaşar Peynir'),
      findsOneWidget,
    );
    expect(find.textContaining('Listeye en yakın: BİM'), findsOneWidget);
  });

  testWidgets('ürün satırı marketin ürün sayfasına bağlanır', (tester) async {
    final sutas = cheeseOf('Sütaş');

    final controller = BasketController(
      _ScriptedPriceService({
        MarketId.sok: {sutas.id: 299},
      }),
    );
    controller.addProduct(sutas);
    await controller.compare();

    await _pumpCompare(tester, controller);

    await _scrollTo(tester, find.byType(ExpansionTile).first);
    await tester.tap(find.byType(ExpansionTile).first);
    await tester.pumpAndSettle();

    expect(find.text('Sütaş Kaşar Peynir 500g ×1'), findsOneWidget);
    expect(
        find.byTooltip('Ürün sayfası · www.sokmarket.com.tr · tahmini fiyat'),
        findsOneWidget);
  });

  testWidgets('tahmini fiyatlı toplam “~” ile gösterilir', (tester) async {
    final sutas = cheeseOf('Sütaş');
    final service = _ScriptedPriceService({
      MarketId.sok: {sutas.id: 299},
      MarketId.migros: {sutas.id: 340},
    });
    // Şok fiyatı doğrulandı, Migros satırı tahmin.
    service.verifiedMarkets.add(MarketId.sok);

    final controller = BasketController(service);
    controller.addProduct(sutas);
    await controller.compare();

    await _pumpCompare(tester, controller);

    expect(find.textContaining('Tüm satırlar market sayfasından doğrulandı'),
        findsOneWidget);
    expect(find.textContaining('“~” işaretli fiyatlar'), findsOneWidget);
    // Migros toplamı tahmini olduğu için tilde ile yazılır.
    expect(find.textContaining('~'), findsWidgets);

    await _scrollTo(tester, find.text('1/1 fiyat doğrulandı'));
    expect(find.text('1/1 fiyat doğrulandı'), findsOneWidget);
  });
}

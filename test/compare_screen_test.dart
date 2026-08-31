import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sepet_karsilastir/data/mock_catalog.dart';
import 'package:sepet_karsilastir/models/comparison_result.dart' as model;
import 'package:sepet_karsilastir/models/fetch_status.dart';
import 'package:sepet_karsilastir/models/list_item.dart';
import 'package:sepet_karsilastir/models/market.dart';
import 'package:sepet_karsilastir/models/product.dart';
import 'package:sepet_karsilastir/models/product_link.dart';
import 'package:sepet_karsilastir/screens/compare_screen.dart';
import 'package:sepet_karsilastir/services/price_book_service.dart';
import 'package:sepet_karsilastir/services/mapping/product_source_url.dart';
import 'package:sepet_karsilastir/services/price_service.dart';
import 'package:sepet_karsilastir/state/basket_controller.dart';
import 'package:sepet_karsilastir/theme/app_theme.dart';

/// Marketin sayfasında bulunan ürün: fiyat ve o fiyatın okunduğu adres.
class _Found {
  const _Found(this.price, this.product, this.url);

  final double price;
  final String product;
  final String url;
}

/// Verilen fiyat tablosunu aynen döndüren servis: ekran davranışını
/// deterministik olarak sınamak için.
///
/// Fiyat defterinin kuralını taklit eder: fiyat varsa bağlantı o fiyatın
/// okunduğu ürün sayfasıdır, fiyat yoksa satır fiyatsız kalır ve bağlantı
/// yalnızca marketin aramasına gider.
class _ScriptedPriceService implements PriceService {
  _ScriptedPriceService(this.found, {this.pricesFetchedAt = '2026-07-26'});

  /// marketId -> (ürün kimliği -> markette bulunan ürün; `null` ise fiyat yok)
  final Map<MarketId, Map<String, _Found?>> found;

  /// Fiyatların çekildiği gün (ISO 8601).
  final String pricesFetchedAt;

  @override
  Future<List<ProductType>> searchProductTypes(String query) async =>
      productTypes;

  @override
  Future<model.ComparisonResult> compareBasket(List<ListItem> items) async {
    final baskets = <model.MarketBasketResult>[];
    for (final entry in found.entries) {
      baskets.add(
        model.MarketBasketResult(
          market: Market.byId(entry.key),
          lines: [
            for (final item in items)
              _line(entry.key, item, entry.value[item.product.id]),
          ],
          fetchedAt: DateTime(2026, 7, 26),
          status: FetchStatus.ok,
        ),
      );
    }
    return model.ComparisonResult(
      baskets: baskets,
      comparedAt: DateTime(2026, 7, 26),
      pricesFetchedAt: pricesFetchedAt,
    );
  }

  model.LinePrice _line(MarketId marketId, ListItem item, _Found? offer) {
    if (offer == null) {
      return model.LinePrice(
        product: item.product,
        quantity: item.quantity,
        source: ProductSourceUrl.search(
          marketId: marketId,
          product: item.product,
        ),
      );
    }
    return model.LinePrice(
      product: item.product,
      quantity: item.quantity,
      unitPrice: offer.price,
      marketProduct: offer.product,
      source: ProductLink(url: offer.url, kind: ProductLinkKind.product),
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
///
/// ListView çocukları tembel üretildiği için hedef henüz ağaçta olmayabilir;
/// önce sürükleyerek build ettiririz.
Future<void> _scrollTo(WidgetTester tester, Finder finder) async {
  final scrollable = find.byType(Scrollable).first;
  for (var i = 0; i < 24; i++) {
    final matches = finder.evaluate();
    if (matches.isNotEmpty) {
      await tester.ensureVisible(find.byWidget(matches.first.widget));
      await tester.pumpAndSettle();
      return;
    }
    await tester.drag(scrollable, const Offset(0, -320));
    await tester.pumpAndSettle();
  }
  await tester.scrollUntilVisible(
    finder,
    240,
    scrollable: scrollable,
  );
  await tester.pumpAndSettle();
}

void main() {
  final milk = productTypes.firstWhere((t) => t.id == 'sut-1l');
  final cheese = productTypes.firstWhere((t) => t.id == 'kasar-500');

  Product milkOf(String brand) => milk.withBrand(brand);
  Product cheeseOf(String brand) => cheese.withBrand(brand);

  const sokCheese = _Found(
    299,
    'Sütaş Kaşar Peyniri 500 g',
    'https://www.sokmarket.com.tr/sutas-kasar-peyniri-500-g-p-4684',
  );
  const sokMilk = _Found(
    45,
    'İçim Süt Tam Yağlı 1 L',
    'https://www.sokmarket.com.tr/icim-sut-tam-yagli-1-l-p-1234',
  );
  const hakmarMilk = _Found(
    40,
    'İçim Süt Tam Yağlı 1 Lt',
    'https://www.hakmarexpress.com.tr/icim-sut-tam-yagli-1-lt-1009421-p',
  );

  testWidgets('fiyatı olmayan market kısmi toplam olarak işaretlenir',
      (tester) async {
    final icim = milkOf('İçim');
    final sutas = cheeseOf('Sütaş');

    final controller = BasketController(
      _ScriptedPriceService({
        MarketId.hakmar: {icim.id: hakmarMilk, sutas.id: null},
        MarketId.sok: {icim.id: sokMilk, sutas.id: sokCheese},
      }),
    );
    controller.addProduct(icim);
    controller.addProduct(sutas);
    await controller.compare();

    await _pumpCompare(tester, controller);

    expect(find.text('BUGÜN BURAYA GİT'), findsOneWidget);
    expect(find.text('Şok'), findsWidgets);
    expect(find.text('kısmi toplam'), findsOneWidget);
    expect(find.textContaining('1/2 market listeyi tamamlıyor'),
        findsOneWidget);
    // Fiyatın hangi gün marketin sayfasından okunduğu yazar.
    expect(find.textContaining('Fiyatlar 26 Tem 2026'), findsOneWidget);

    await _scrollTo(tester, find.text('1 ürün bulunamadı'));
    expect(find.text('1 ürün bulunamadı'), findsOneWidget);
  });

  testWidgets('hiçbir market listeyi tamamlamıyorsa uyarı gösterilir',
      (tester) async {
    final icim = milkOf('İçim');
    final sutas = cheeseOf('Sütaş');

    final controller = BasketController(
      _ScriptedPriceService({
        MarketId.hakmar: {icim.id: hakmarMilk, sutas.id: null},
        MarketId.sok: {icim.id: sokMilk, sutas.id: null},
      }),
    );
    controller.addProduct(icim);
    controller.addProduct(sutas);
    await controller.compare();

    await _pumpCompare(tester, controller);

    expect(find.text('BUGÜN BURAYA GİT'), findsNothing);
    expect(find.text('Listeyi tek başına tamamlayan market yok'),
        findsOneWidget);
    expect(
      find.textContaining('Hiçbir markette bulunamadı: Sütaş Kaşar Peynir'),
      findsOneWidget,
    );
    expect(find.textContaining('Listeye en yakın: Hakmar Express'),
        findsOneWidget);
  });

  testWidgets('fiyatlı satır fiyatın okunduğu ürün sayfasını açar',
      (tester) async {
    final sutas = cheeseOf('Sütaş');

    final controller = BasketController(
      _ScriptedPriceService({
        MarketId.sok: {sutas.id: sokCheese},
      }),
    );
    controller.addProduct(sutas);
    await controller.compare();

    await _pumpCompare(tester, controller);

    await _scrollTo(tester, find.byType(ExpansionTile));
    await tester.tap(find.byType(ExpansionTile).first);
    await tester.pumpAndSettle();

    expect(find.text('Sütaş Kaşar Peynir 500g ×1'), findsOneWidget);
    // Tutarın yanında, fiyatın okunduğu marketteki ürünün adı yazar.
    expect(find.text(sokCheese.product), findsOneWidget);
    expect(find.textContaining('299,00'), findsWidgets);
    expect(
      find.byTooltip('Ürün sayfası · www.sokmarket.com.tr'),
      findsOneWidget,
    );
  });

  testWidgets('fiyatı olmayan satırda tutar yerine “Ürün bulunamadı” yazar',
      (tester) async {
    final sutas = cheeseOf('Sütaş');

    final controller = BasketController(
      _ScriptedPriceService({
        MarketId.sok: {sutas.id: null},
      }),
    );
    controller.addProduct(sutas);
    await controller.compare();

    await _pumpCompare(tester, controller);

    await _scrollTo(tester, find.byType(ExpansionTile));
    await tester.tap(find.byType(ExpansionTile).first);
    await tester.pumpAndSettle();

    expect(find.text('Ürün bulunamadı'), findsWidgets);
    // Tahmini tutar üretilmez: ne satırda ne toplamda sayı çıkar.
    expect(find.textContaining('~'), findsNothing);
    // Bağlantı ürün sayfası değil, marketin kendi araması.
    expect(
      find.byTooltip('Site içi arama · www.sokmarket.com.tr'),
      findsOneWidget,
    );
  });

  testWidgets('hiçbir ürünü bulunamayan market tutar yerine sebebini yazar',
      (tester) async {
    final sutas = cheeseOf('Sütaş');

    final controller = BasketController(
      _ScriptedPriceService({
        MarketId.sok: {sutas.id: sokCheese},
        // Fiyatını kendi sitesinde yayınlamayan zincir: listede kalır.
        MarketId.bim: {sutas.id: null},
      }),
    );
    controller.addProduct(sutas);
    await controller.compare();

    await _pumpCompare(tester, controller);

    final bim = Market.byId(MarketId.bim);
    final subtitle = find.text('Ürün bulunamadı — ${bim.noPriceReason}');
    await _scrollTo(tester, subtitle);
    expect(subtitle, findsOneWidget);
    // Sıfır lira yazılmaz: "bedava" diye okunacak bir tutar göstermiyoruz.
    expect(find.textContaining('0,00'), findsNothing);
    expect(find.text('—'), findsWidgets);
  });

  testWidgets('fiyatlar eskimişse uyarı çıkar', (tester) async {
    final sutas = cheeseOf('Sütaş');
    final old = DateTime.now().subtract(const Duration(days: 5));

    final controller = BasketController(
      _ScriptedPriceService(
        {
          MarketId.sok: {sutas.id: sokCheese},
        },
        pricesFetchedAt: '${old.year}-${old.month.toString().padLeft(2, '0')}'
            '-${old.day.toString().padLeft(2, '0')}',
      ),
    );
    controller.addProduct(sutas);
    await controller.compare();

    await _pumpCompare(tester, controller);

    expect(
      find.textContaining('Fiyatlar 5 gündür yenilenmedi'),
      findsOneWidget,
    );
  });

  testWidgets('fiyat yayınlamayan marketler sebebiyle listelenir',
      (tester) async {
    final sutas = cheeseOf('Sütaş');

    final controller = BasketController(
      _ScriptedPriceService({
        MarketId.sok: {sutas.id: sokCheese},
      }),
    );
    controller.addProduct(sutas);
    await controller.compare();

    await _pumpCompare(tester, controller);

    final bim = Market.byId(MarketId.bim);
    final card = find.text('BİM — ${bim.noPriceReason}');
    await _scrollTo(tester, card);
    expect(card, findsOneWidget);
    // Kart iki grubu birlikte anlatır: hiç fiyat yayınlamayanlar ve son
    // çekimde sitesinden fiyat okunamayanlar.
    expect(
      find.text(
        'Fiyat gösterilemeyen ${PriceBookService.withoutPrices.length} market',
      ),
      findsOneWidget,
    );
  });
}

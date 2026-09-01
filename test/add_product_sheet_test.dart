import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sepet_karsilastir/data/mock_catalog.dart';
import 'package:sepet_karsilastir/models/comparison_result.dart' as model;
import 'package:sepet_karsilastir/models/list_item.dart';
import 'package:sepet_karsilastir/models/product.dart';
import 'package:sepet_karsilastir/screens/add_product_sheet.dart';
import 'package:sepet_karsilastir/services/price_service.dart';
import 'package:sepet_karsilastir/state/basket_controller.dart';
import 'package:sepet_karsilastir/theme/app_theme.dart';

class _SearchService implements PriceService {
  _SearchService(this.hits);

  final List<Product> hits;

  @override
  Future<List<Product>> searchCatalogProducts(String query) async => hits;

  @override
  Future<List<ProductType>> searchProductTypes(String query) async => const [];

  @override
  Future<model.ComparisonResult> compareBasket(List<ListItem> items) {
    throw UnimplementedError();
  }
}

Future<void> _pumpSheet(
  WidgetTester tester, {
  required List<Product> hits,
}) async {
  final controller = BasketController(_SearchService(hits));
  await tester.pumpWidget(
    ChangeNotifierProvider<BasketController>.value(
      value: controller,
      child: MaterialApp(
        theme: AppTheme.light(),
        home: const Scaffold(body: AddProductSheet()),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  const icim1l = Product(
    id: 'mf:1',
    typeId: 'mf:1',
    name: 'Süt',
    category: 'Süt & Kahvaltı',
    unit: '1 LT',
    brand: 'İçim',
  );
  const icim200 = Product(
    id: 'mf:2',
    typeId: 'mf:2',
    name: 'Süt',
    category: 'Süt & Kahvaltı',
    unit: '200 ML',
    brand: 'İçim',
  );
  const pinar1l = Product(
    id: 'mf:3',
    typeId: 'mf:3',
    name: 'Süt',
    category: 'Süt & Kahvaltı',
    unit: '1 LT',
    brand: 'Pınar',
  );

  testWidgets('açılışta kayıtlı katalog ve marka filtresi yok', (tester) async {
    await _pumpSheet(tester, hits: const [icim1l]);

    expect(find.text('Marka filtresi'), findsNothing);
    expect(find.text('Katalog'), findsNothing);
    expect(find.text('Ürün adı yazın'), findsOneWidget);
    expect(find.text('İçim'), findsNothing);
  });

  testWidgets('arama marka, ad ve ebatı listeler; kullanıcı ebat seçer',
      (tester) async {
    await _pumpSheet(tester, hits: const [icim1l, icim200, pinar1l]);

    await tester.enterText(find.byType(TextField), 'süt');
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();

    expect(find.text('Marka filtresi'), findsNothing);
    expect(find.text('Katalog'), findsNothing);
    expect(find.text('İçim'), findsNWidgets(2));
    expect(find.text('Pınar'), findsOneWidget);
    expect(find.text('Süt'), findsNWidgets(3));
    expect(find.text('1 LT'), findsNWidgets(2));
    expect(find.text('200 ML'), findsOneWidget);

    await tester.tap(find.text('Ekle').at(1));
    await tester.pumpAndSettle();
    expect(find.textContaining('İçim · Süt · 200 ML eklendi'), findsOneWidget);
  });
}

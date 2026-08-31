import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sepet_karsilastir/main.dart';
import 'package:sepet_karsilastir/services/storage/key_value_store.dart';
import 'package:sepet_karsilastir/state/settings_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Nav bar sekmeleri görünür', (tester) async {
    await tester.pumpWidget(const SepetApp());
    await tester.pumpAndSettle();

    expect(find.text('Anasayfa'), findsWidgets);
    expect(find.text('Sepet'), findsWidgets);
    expect(find.text('Sonuç'), findsWidgets);
    expect(find.text('Listeler'), findsWidgets);
    expect(find.text('Ayarlar'), findsWidgets);
  });

  testWidgets('Sepet sekmesi boş listeyi gösterir', (tester) async {
    await tester.pumpWidget(const SepetApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Sepet').last);
    await tester.pumpAndSettle();

    expect(find.text('Listen boş'), findsOneWidget);
    expect(find.text('Ürün ekle'), findsOneWidget);
  });

  testWidgets('Listeler sekmesi boş durum gösterir', (tester) async {
    await tester.pumpWidget(const SepetApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Listeler'));
    await tester.pumpAndSettle();

    expect(find.text('Henüz kayıtlı liste yok'), findsOneWidget);
  });

  testWidgets('Ayarlardan koyu tema seçilir', (tester) async {
    final store = InMemoryStore();
    await tester.pumpWidget(SepetApp(store: store));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Ayarlar'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Koyu'));
    await tester.pumpAndSettle();

    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.themeMode, ThemeMode.dark);
    expect(SettingsController(store).themeMode, ThemeMode.dark);
  });
}

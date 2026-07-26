import 'package:flutter_test/flutter_test.dart';
import 'package:sepet_karsilastir/main.dart';

void main() {
  testWidgets('Nav bar sekmeleri görünür', (tester) async {
    await tester.pumpWidget(const SepetApp());

    expect(find.text('Anasayfa'), findsWidgets);
    expect(find.text('Sepet'), findsWidgets);
    expect(find.text('Karşılaştır'), findsWidgets);
    expect(find.text('Ayarlar'), findsWidgets);
  });

  testWidgets('Sepet sekmesi boş listeyi gösterir', (tester) async {
    await tester.pumpWidget(const SepetApp());

    await tester.tap(find.text('Sepet').last);
    await tester.pumpAndSettle();

    expect(find.text('Listen boş'), findsOneWidget);
    expect(find.text('Ürün ekle'), findsOneWidget);
  });
}

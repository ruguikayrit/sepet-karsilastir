import 'package:flutter_test/flutter_test.dart';
import 'package:sepet_karsilastir/main.dart';

void main() {
  testWidgets('Ana ekran liste boş durumunu gösterir', (tester) async {
    await tester.pumpWidget(const SepetApp());

    expect(find.text('Listen boş'), findsOneWidget);
    expect(find.text('Ürün ekle'), findsOneWidget);
  });
}

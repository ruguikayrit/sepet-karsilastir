import 'package:sepet_karsilastir/utils/text.dart';

/// Ürün adındaki miktarları ölçü sınıfına indirger: `1 kg` ile `1000 g`,
/// `1 L` ile `1000 ml` aynı miktar sayılır. Böylece katalogdaki birim ile
/// marketin ürün adındaki birim karşılaştırılabilir.
Set<String> normalizedQuantities(String text) {
  final folded = foldTurkish(text);
  final found = <String>{};

  // Süt/ayran raflarında "1/1" bir litreyi anlatır.
  if (RegExp(r'(^|\s)1/1(\s|$|\.)').hasMatch(folded)) {
    found.add('ml:1000');
  }

  // `3x200 g` çoklu paketi 600 g sayılır: katalog da toplam gramajı yazar.
  final matches =
      RegExp(r'(?:(\d+)\s*[x*]\s*)?(\d+(?:[.,]\d+)?)\s*(kg|gr|g|lt|l|ml|cc)\b')
          .allMatches(folded);
  for (final match in matches) {
    final pack = int.tryParse(match.group(1) ?? '') ?? 1;
    final amount =
        double.parse(match.group(2)!.replaceAll(',', '.')) * pack;
    final unit = match.group(3)!;
    final (base, factor) = switch (unit) {
      'kg' => ('g', 1000),
      'gr' || 'g' => ('g', 1),
      'lt' || 'l' => ('ml', 1000),
      _ => ('ml', 1),
    };
    final value = amount * factor;
    found.add('$base:${value == value.roundToDouble() ? value.round() : value}');
  }
  return found;
}

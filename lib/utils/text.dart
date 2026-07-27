/// Türkçe metinleri ASCII'ye katlar: arama ve anahtar üretiminde
/// "sut" ile "Süt", "yogurt" ile "Yoğurt" eşleşsin diye.
String foldTurkish(String value) {
  final lower = value.toLowerCase();
  final buffer = StringBuffer();
  for (final rune in lower.runes) {
    final char = String.fromCharCode(rune);
    buffer.write(_folded[char] ?? char);
  }
  return buffer.toString();
}

/// Katlanmış metinden kararlı bir anahtar üretir: `Nuh'un Ankara` → `nuh-un-ankara`.
String slugifyTurkish(String value) {
  final folded = foldTurkish(value.trim());
  return folded
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'-+'), '-')
      .replaceAll(RegExp(r'^-|-$'), '');
}

const _folded = <String, String>{
  'ı': 'i',
  'ğ': 'g',
  'ü': 'u',
  'ş': 's',
  'ö': 'o',
  'ç': 'c',
  'â': 'a',
  'î': 'i',
  'û': 'u',
  'é': 'e',
  // Dart'ta 'İ'.toLowerCase() → 'i' + birleşen nokta (U+0307)
  '\u0307': '',
};

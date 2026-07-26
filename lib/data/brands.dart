/// Türkiye'de market raflarında sık görülen gıda ve FMCG markaları.
class FoodBrand {
  const FoodBrand({
    required this.id,
    required this.name,
    required this.categories,
  });

  final String id;
  final String name;

  /// Bu markanın ürün eklerken önerileceği kategoriler.
  final List<String> categories;
}

const foodBrands = <FoodBrand>[
  // Süt & Kahvaltı
  FoodBrand(id: 'icim', name: 'İçim', categories: ['Süt & Kahvaltı']),
  FoodBrand(id: 'pinar', name: 'Pınar', categories: ['Süt & Kahvaltı', 'Et & Tavuk']),
  FoodBrand(id: 'sutas', name: 'Sütaş', categories: ['Süt & Kahvaltı']),
  FoodBrand(id: 'sek', name: 'Sek', categories: ['Süt & Kahvaltı']),
  FoodBrand(id: 'eker', name: 'Eker', categories: ['Süt & Kahvaltı']),
  FoodBrand(id: 'danone', name: 'Danone', categories: ['Süt & Kahvaltı']),
  FoodBrand(id: 'dost', name: 'Dost', categories: ['Süt & Kahvaltı']),
  FoodBrand(id: 'bahcivan', name: 'Bahçıvan', categories: ['Süt & Kahvaltı']),
  FoodBrand(id: 'tahsildaroglu', name: 'Tahsildaroğlu', categories: ['Süt & Kahvaltı']),
  FoodBrand(id: 'muratbey', name: 'Muratbey', categories: ['Süt & Kahvaltı']),
  FoodBrand(id: 'pak', name: 'Pak', categories: ['Süt & Kahvaltı']),
  FoodBrand(id: 'yumurta-cp', name: 'CP', categories: ['Süt & Kahvaltı']),

  // Temel gıda
  FoodBrand(id: 'yayla', name: 'Yayla', categories: ['Temel Gıda']),
  FoodBrand(id: 'reis', name: 'Reis', categories: ['Temel Gıda']),
  FoodBrand(id: 'ankara', name: 'Ankara', categories: ['Temel Gıda']),
  FoodBrand(id: 'barilla', name: 'Barilla', categories: ['Temel Gıda']),
  FoodBrand(id: 'filiz', name: 'Filiz', categories: ['Temel Gıda']),
  FoodBrand(id: 'nuhun-ankara', name: "Nuh'un Ankara", categories: ['Temel Gıda']),
  FoodBrand(id: 'pastavilla', name: 'Pastavilla', categories: ['Temel Gıda']),
  FoodBrand(id: 'yudum', name: 'Yudum', categories: ['Temel Gıda']),
  FoodBrand(id: 'komili', name: 'Komili', categories: ['Temel Gıda']),
  FoodBrand(id: 'orucoglu', name: 'Oruçoğlu', categories: ['Temel Gıda']),
  FoodBrand(id: 'bizim', name: 'Bizim', categories: ['Temel Gıda']),
  FoodBrand(id: 'turk-seker', name: 'Türk Şeker', categories: ['Temel Gıda']),
  FoodBrand(id: 'billur', name: 'Billur', categories: ['Temel Gıda']),

  // İçecek
  FoodBrand(id: 'caykur', name: 'Çaykur', categories: ['İçecek']),
  FoodBrand(id: 'dogus', name: 'Doğuş', categories: ['İçecek']),
  FoodBrand(id: 'lipton', name: 'Lipton', categories: ['İçecek']),
  FoodBrand(id: 'ofcay', name: 'Ofçay', categories: ['İçecek']),
  FoodBrand(id: 'erikli', name: 'Erikli', categories: ['İçecek']),
  FoodBrand(id: 'hayat', name: 'Hayat', categories: ['İçecek']),
  FoodBrand(id: 'saka', name: 'Saka', categories: ['İçecek']),
  FoodBrand(id: 'nestle-water', name: 'Nestlé Pure Life', categories: ['İçecek']),
  FoodBrand(id: 'coca-cola', name: 'Coca-Cola', categories: ['İçecek']),
  FoodBrand(id: 'fanta', name: 'Fanta', categories: ['İçecek']),
  FoodBrand(id: 'uludag', name: 'Uludağ', categories: ['İçecek']),

  // Et & Tavuk
  FoodBrand(id: 'namet', name: 'Namet', categories: ['Et & Tavuk']),
  FoodBrand(id: 'banvit', name: 'Banvit', categories: ['Et & Tavuk']),
  FoodBrand(id: 'erpilic', name: 'Erpiliç', categories: ['Et & Tavuk']),
  FoodBrand(id: 'senpilic', name: 'Şenpiliç', categories: ['Et & Tavuk']),
  FoodBrand(id: 'maret', name: 'Maret', categories: ['Et & Tavuk']),
  FoodBrand(id: 'sosero', name: 'Sosero', categories: ['Et & Tavuk']),

  // Atıştırmalık
  FoodBrand(id: 'lays', name: 'Lays', categories: ['Atıştırmalık']),
  FoodBrand(id: 'doritos', name: 'Doritos', categories: ['Atıştırmalık']),
  FoodBrand(id: 'ruffles', name: 'Ruffles', categories: ['Atıştırmalık']),
  FoodBrand(id: 'eti', name: 'Eti', categories: ['Atıştırmalık']),
  FoodBrand(id: 'ulker', name: 'Ülker', categories: ['Atıştırmalık', 'Süt & Kahvaltı']),
  FoodBrand(id: 'torku', name: 'Torku', categories: ['Atıştırmalık', 'Temel Gıda']),

  // Temizlik / bakım
  FoodBrand(id: 'ariel', name: 'Ariel', categories: ['Temizlik']),
  FoodBrand(id: 'persil', name: 'Persil', categories: ['Temizlik']),
  FoodBrand(id: 'bingo', name: 'Bingo', categories: ['Temizlik']),
  FoodBrand(id: 'alo', name: 'Alo', categories: ['Temizlik']),
  FoodBrand(id: 'solo', name: 'Solo', categories: ['Temizlik']),
  FoodBrand(id: 'selpak', name: 'Selpak', categories: ['Temizlik']),
  FoodBrand(id: 'elidor', name: 'Elidor', categories: ['Kişisel Bakım']),
  FoodBrand(id: 'clear', name: 'Clear', categories: ['Kişisel Bakım']),
  FoodBrand(id: 'headshoulders', name: "Head & Shoulders", categories: ['Kişisel Bakım']),
  FoodBrand(id: 'dove', name: 'Dove', categories: ['Kişisel Bakım']),

  // Fırın / genel
  FoodBrand(id: 'uno', name: 'Uno', categories: ['Fırın']),
  FoodBrand(id: 'market', name: 'Market markası', categories: [
    'Süt & Kahvaltı',
    'Temel Gıda',
    'İçecek',
    'Meyve & Sebze',
    'Et & Tavuk',
    'Fırın',
    'Temizlik',
    'Kişisel Bakım',
    'Atıştırmalık',
  ]),
];

List<FoodBrand> brandsForCategory(String category) {
  final matched = foodBrands
      .where((b) => b.categories.contains(category))
      .toList()
    ..sort((a, b) => a.name.compareTo(b.name));
  return matched;
}

FoodBrand? brandByName(String name) {
  final q = name.toLowerCase();
  for (final b in foodBrands) {
    if (b.name.toLowerCase() == q) return b;
  }
  return null;
}

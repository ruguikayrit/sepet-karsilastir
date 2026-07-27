/// Türkiye'de market raflarında sık görülen gıda ve FMCG markaları.
///
/// Liste, Şok Market (sokmarket.com.tr) katalog taramasındaki sık markalar
/// ve yaygın ulusal markalarla genişletilmiştir.
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

/// Marka belirtmeyen satır.
///
/// Kullanıcı marka seçmediğinde her market o gramajdaki kendi en uygun
/// ürününü gösterir; satırın altında hangi ürün olduğu yazar. Zincirin kendi
/// markası diye bir seçenek yok: hangi ürünün "market markası" olduğunu
/// marketler tutarlı yayınlamıyor, uydurmak da karşılaştırmayı bozar.
const genericBrand = 'Markasız';

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
  FoodBrand(id: 'mis', name: 'Mis', categories: ['Süt & Kahvaltı', 'İçecek']),
  FoodBrand(id: 'yumurta-cp', name: 'CP', categories: ['Süt & Kahvaltı']),
  FoodBrand(
    id: 'anadolu-ciftligi',
    name: 'Anadolu Çiftliği',
    categories: ['Süt & Kahvaltı'],
  ),
  FoodBrand(
    id: 'kelloggs',
    name: "Kellogg's",
    categories: ['Süt & Kahvaltı'],
  ),

  // Temel gıda / konserve
  FoodBrand(id: 'yayla', name: 'Yayla', categories: ['Temel Gıda']),
  FoodBrand(id: 'reis', name: 'Reis', categories: ['Temel Gıda']),
  FoodBrand(id: 'ankara', name: 'Ankara', categories: ['Temel Gıda']),
  FoodBrand(id: 'barilla', name: 'Barilla', categories: ['Temel Gıda']),
  FoodBrand(id: 'filiz', name: 'Filiz', categories: ['Temel Gıda']),
  FoodBrand(id: 'nuhun-ankara', name: "Nuh'un Ankara", categories: ['Temel Gıda']),
  FoodBrand(id: 'pastavilla', name: 'Pastavilla', categories: ['Temel Gıda']),
  FoodBrand(
    id: 'anadolu-mutfagi',
    name: 'Anadolu Mutfağı',
    categories: ['Temel Gıda'],
  ),
  FoodBrand(id: 'yudum', name: 'Yudum', categories: ['Temel Gıda']),
  FoodBrand(id: 'komili', name: 'Komili', categories: ['Temel Gıda']),
  FoodBrand(id: 'orucoglu', name: 'Oruçoğlu', categories: ['Temel Gıda']),
  FoodBrand(id: 'bizim', name: 'Bizim', categories: ['Temel Gıda']),
  FoodBrand(id: 'evin', name: 'Evin', categories: ['Temel Gıda']),
  FoodBrand(
    id: 'lio',
    name: 'Lio',
    categories: ['Temel Gıda', 'Süt & Kahvaltı'],
  ),
  FoodBrand(id: 'piyale', name: 'Piyale', categories: ['Temel Gıda']),
  FoodBrand(id: 'altinkup', name: 'Altınküp', categories: ['Temel Gıda']),
  FoodBrand(id: 'turk-seker', name: 'Türk Şeker', categories: ['Temel Gıda']),
  FoodBrand(id: 'billur', name: 'Billur', categories: ['Temel Gıda']),
  FoodBrand(
    id: 'bizim-vatan',
    name: 'Bizim Vatan',
    categories: ['Temel Gıda', 'Konserve'],
  ),
  FoodBrand(
    id: 'superfresh',
    name: 'Superfresh',
    categories: ['Konserve', 'Dondurma'],
  ),

  // İçecek
  FoodBrand(id: 'caykur', name: 'Çaykur', categories: ['İçecek']),
  FoodBrand(id: 'dogus', name: 'Doğuş', categories: ['İçecek']),
  FoodBrand(id: 'lipton', name: 'Lipton', categories: ['İçecek']),
  FoodBrand(id: 'ofcay', name: 'Ofçay', categories: ['İçecek']),
  FoodBrand(id: 'erikli', name: 'Erikli', categories: ['İçecek']),
  FoodBrand(id: 'hayat', name: 'Hayat', categories: ['İçecek']),
  FoodBrand(id: 'saka', name: 'Saka', categories: ['İçecek']),
  FoodBrand(id: 'kardelen', name: 'Kardelen', categories: ['İçecek']),
  FoodBrand(id: 'nestle-water', name: 'Nestlé Pure Life', categories: ['İçecek']),
  FoodBrand(id: 'coca-cola', name: 'Coca-Cola', categories: ['İçecek']),
  FoodBrand(id: 'fanta', name: 'Fanta', categories: ['İçecek']),
  FoodBrand(id: 'uludag', name: 'Uludağ', categories: ['İçecek']),
  FoodBrand(id: 'cola-turka', name: 'Cola Turka', categories: ['İçecek']),
  FoodBrand(id: 'beypazari', name: 'Beypazarı', categories: ['İçecek']),
  FoodBrand(id: 'meysu', name: 'Meysu', categories: ['İçecek']),
  FoodBrand(id: 'mehmet-efendi', name: 'Mehmet Efendi', categories: ['İçecek']),

  // Et & Tavuk
  FoodBrand(id: 'namet', name: 'Namet', categories: ['Et & Tavuk']),
  FoodBrand(id: 'banvit', name: 'Banvit', categories: ['Et & Tavuk']),
  FoodBrand(id: 'erpilic', name: 'Erpiliç', categories: ['Et & Tavuk']),
  FoodBrand(id: 'senpilic', name: 'Şenpiliç', categories: ['Et & Tavuk']),
  FoodBrand(id: 'gedik', name: 'Gedik', categories: ['Et & Tavuk']),
  FoodBrand(id: 'aytac', name: 'Aytaç', categories: ['Et & Tavuk']),
  FoodBrand(id: 'keskinoglu', name: 'Keskinoğlu', categories: ['Et & Tavuk']),
  FoodBrand(id: 'sultan', name: 'Sultan', categories: ['Et & Tavuk']),
  FoodBrand(id: 'maret', name: 'Maret', categories: ['Et & Tavuk']),
  FoodBrand(id: 'lezzetlim', name: 'Lezzetlim', categories: ['Et & Tavuk']),
  FoodBrand(id: 'sosero', name: 'Sosero', categories: ['Et & Tavuk']),

  // Atıştırmalık / dondurma
  FoodBrand(id: 'lays', name: 'Lays', categories: ['Atıştırmalık']),
  FoodBrand(id: 'doritos', name: 'Doritos', categories: ['Atıştırmalık']),
  FoodBrand(id: 'ruffles', name: 'Ruffles', categories: ['Atıştırmalık']),
  FoodBrand(
    id: 'amigo',
    name: 'Amigo',
    categories: ['Atıştırmalık', 'Meyve & Sebze'],
  ),
  FoodBrand(id: 'eti', name: 'Eti', categories: ['Atıştırmalık']),
  FoodBrand(
    id: 'ulker',
    name: 'Ülker',
    categories: ['Atıştırmalık', 'Süt & Kahvaltı'],
  ),
  FoodBrand(
    id: 'torku',
    name: 'Torku',
    categories: ['Atıştırmalık', 'Temel Gıda'],
  ),
  FoodBrand(id: 'solen', name: 'Şölen', categories: ['Atıştırmalık']),
  FoodBrand(id: 'algida', name: 'Algida', categories: ['Dondurma']),

  // Temizlik / bakım / bebek
  FoodBrand(id: 'ariel', name: 'Ariel', categories: ['Temizlik']),
  FoodBrand(id: 'persil', name: 'Persil', categories: ['Temizlik']),
  FoodBrand(id: 'bingo', name: 'Bingo', categories: ['Temizlik']),
  FoodBrand(id: 'alo', name: 'Alo', categories: ['Temizlik']),
  FoodBrand(id: 'omo', name: 'Omo', categories: ['Temizlik']),
  FoodBrand(id: 'peros', name: 'Peros', categories: ['Temizlik']),
  FoodBrand(id: 'solo', name: 'Solo', categories: ['Temizlik']),
  FoodBrand(id: 'selpak', name: 'Selpak', categories: ['Temizlik']),
  FoodBrand(id: 'elidor', name: 'Elidor', categories: ['Kişisel Bakım']),
  FoodBrand(id: 'clear', name: 'Clear', categories: ['Kişisel Bakım']),
  FoodBrand(
    id: 'headshoulders',
    name: 'Head & Shoulders',
    categories: ['Kişisel Bakım'],
  ),
  FoodBrand(id: 'dove', name: 'Dove', categories: ['Kişisel Bakım']),
  FoodBrand(id: 'colgate', name: 'Colgate', categories: ['Kişisel Bakım']),
  FoodBrand(id: 'duru', name: 'Duru', categories: ['Kişisel Bakım']),
  FoodBrand(id: 'sleepy', name: 'Sleepy', categories: ['Bebek', 'Temizlik']),
  FoodBrand(id: 'bebeland', name: 'Bebeland', categories: ['Bebek']),

  // Fırın / genel
  FoodBrand(id: 'uno', name: 'Uno', categories: ['Fırın']),
  FoodBrand(id: 'markasiz', name: genericBrand, categories: [
    'Süt & Kahvaltı',
    'Temel Gıda',
    'İçecek',
    'Meyve & Sebze',
    'Et & Tavuk',
    'Fırın',
    'Temizlik',
    'Kişisel Bakım',
    'Atıştırmalık',
    'Konserve',
    'Dondurma',
    'Bebek',
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

import '../models/product.dart';

/// Markasız ürün tipi — kullanıcı eklerken marka seçer.
///
/// Çeşit ve referans fiyatlar resmi market sitelerinden derlenmiştir.
/// Ürün adındaki birim (500g, 1L vb.) tüm market karşılaştırmalarında
/// sabittir; farklı gramajlar ayrı ürün tipidir.
class ProductType {
  const ProductType({
    required this.id,
    required this.name,
    required this.category,
    required this.unit,
  });

  final String id;
  final String name;
  final String category;
  final String unit;

  Product withBrand(String? brand) {
    final brandKey = _brandKey(brand);
    return Product(
      id: '${id}__$brandKey',
      typeId: id,
      name: name,
      category: category,
      unit: unit,
      brand: brand,
    );
  }

  /// Türkçe karakterleri koruyarak kararlı marka anahtarı üretir.
  static String _brandKey(String? brand) {
    if (brand == null || brand.trim().isEmpty) return 'markasiz';
    final lower = brand
        .trim()
        .toLowerCase()
        .replaceAll('\u0307', '')
        .replaceAll('ı', 'i')
        .replaceAll('ğ', 'g')
        .replaceAll('ü', 'u')
        .replaceAll('ş', 's')
        .replaceAll('ö', 'o')
        .replaceAll('ç', 'c');
    return lower
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
  }
}

const productTypes = <ProductType>[
  ProductType(
    id: 'sut-1l',
    name: 'Tam Yağlı Süt 1L',
    category: 'Süt & Kahvaltı',
    unit: 'adet',
  ),
  ProductType(
    id: 'sut-yarim-1l',
    name: 'Yarım Yağlı Süt 1L',
    category: 'Süt & Kahvaltı',
    unit: 'adet',
  ),
  ProductType(
    id: 'yumurta-30',
    name: 'Yumurta 30\'lu',
    category: 'Süt & Kahvaltı',
    unit: 'adet',
  ),
  ProductType(
    id: 'yumurta-15',
    name: 'Yumurta 15\'li',
    category: 'Süt & Kahvaltı',
    unit: 'adet',
  ),
  ProductType(
    id: 'peynir-500',
    name: 'Beyaz Peynir 500g',
    category: 'Süt & Kahvaltı',
    unit: 'adet',
  ),
  ProductType(
    id: 'kasar-500',
    name: 'Kaşar Peynir 500g',
    category: 'Süt & Kahvaltı',
    unit: 'adet',
  ),
  ProductType(
    id: 'labne-400',
    name: 'Labne 400g',
    category: 'Süt & Kahvaltı',
    unit: 'adet',
  ),
  ProductType(
    id: 'yogurt-1kg',
    name: 'Yoğurt 1kg',
    category: 'Süt & Kahvaltı',
    unit: 'adet',
  ),
  ProductType(
    id: 'tereyag-500',
    name: 'Tereyağı 500g',
    category: 'Süt & Kahvaltı',
    unit: 'adet',
  ),
  ProductType(
    id: 'zeytin-500',
    name: 'Siyah Zeytin 500g',
    category: 'Süt & Kahvaltı',
    unit: 'adet',
  ),
  ProductType(
    id: 'recel-380',
    name: 'Reçel 380g',
    category: 'Süt & Kahvaltı',
    unit: 'adet',
  ),
  ProductType(
    id: 'misir-gevregi',
    name: 'Mısır Gevreği 450g',
    category: 'Süt & Kahvaltı',
    unit: 'adet',
  ),
  ProductType(
    id: 'ekmek-250',
    name: 'Tam Buğday Ekmek',
    category: 'Fırın',
    unit: 'adet',
  ),
  ProductType(
    id: 'ekmek-beyaz',
    name: 'Beyaz Ekmek',
    category: 'Fırın',
    unit: 'adet',
  ),
  ProductType(
    id: 'pirinc-1kg',
    name: 'Pirinç 1kg',
    category: 'Temel Gıda',
    unit: 'adet',
  ),
  ProductType(
    id: 'makarna-500',
    name: 'Spagetti 500g',
    category: 'Temel Gıda',
    unit: 'adet',
  ),
  ProductType(
    id: 'makarna-penne',
    name: 'Penne Makarna 500g',
    category: 'Temel Gıda',
    unit: 'adet',
  ),
  ProductType(
    id: 'aycicek-1l',
    name: 'Ayçiçek Yağı 1L',
    category: 'Temel Gıda',
    unit: 'adet',
  ),
  ProductType(
    id: 'aycicek-5l',
    name: 'Ayçiçek Yağı 5L',
    category: 'Temel Gıda',
    unit: 'adet',
  ),
  ProductType(
    id: 'zeytinyagi-1l',
    name: 'Zeytinyağı 1L',
    category: 'Temel Gıda',
    unit: 'adet',
  ),
  ProductType(
    id: 'seker-2kg',
    name: 'Toz Şeker 2kg',
    category: 'Temel Gıda',
    unit: 'adet',
  ),
  ProductType(
    id: 'seker-1kg',
    name: 'Toz Şeker 1kg',
    category: 'Temel Gıda',
    unit: 'adet',
  ),
  ProductType(
    id: 'un-5kg',
    name: 'Un 5kg',
    category: 'Temel Gıda',
    unit: 'adet',
  ),
  ProductType(
    id: 'tuz-750',
    name: 'Sofra Tuzu 500g',
    category: 'Temel Gıda',
    unit: 'adet',
  ),
  ProductType(
    id: 'mercimek-1kg',
    name: 'Kırmızı Mercimek 1kg',
    category: 'Temel Gıda',
    unit: 'adet',
  ),
  ProductType(
    id: 'nohut-1kg',
    name: 'Nohut 1kg',
    category: 'Temel Gıda',
    unit: 'adet',
  ),
  ProductType(
    id: 'bulgur-1kg',
    name: 'Köftelik Bulgur 1kg',
    category: 'Temel Gıda',
    unit: 'adet',
  ),
  ProductType(
    id: 'salca-650',
    name: 'Biber Salçası 650g',
    category: 'Temel Gıda',
    unit: 'adet',
  ),
  ProductType(
    id: 'ketcap-500',
    name: 'Ketçap 500g',
    category: 'Temel Gıda',
    unit: 'adet',
  ),
  ProductType(
    id: 'mayonez-430',
    name: 'Mayonez 430g',
    category: 'Temel Gıda',
    unit: 'adet',
  ),
  ProductType(
    id: 'ton-2x160',
    name: 'Ton Balığı 2x160g',
    category: 'Konserve',
    unit: 'adet',
  ),
  ProductType(
    id: 'konserve-fasulye',
    name: 'Haşlanmış Fasulye 800g',
    category: 'Konserve',
    unit: 'adet',
  ),
  ProductType(
    id: 'konserve-misir',
    name: 'Mısır Konservesi 3x200g',
    category: 'Konserve',
    unit: 'adet',
  ),
  ProductType(
    id: 'cay-500',
    name: 'Dökme Çay 500g',
    category: 'İçecek',
    unit: 'adet',
  ),
  ProductType(
    id: 'cay-1000',
    name: 'Dökme Çay 1kg',
    category: 'İçecek',
    unit: 'adet',
  ),
  ProductType(
    id: 'su-5l',
    name: 'Su 5L',
    category: 'İçecek',
    unit: 'adet',
  ),
  ProductType(
    id: 'su-1-5l',
    name: 'Su 1.5L',
    category: 'İçecek',
    unit: 'adet',
  ),
  ProductType(
    id: 'kola-1l',
    name: 'Kola 1L',
    category: 'İçecek',
    unit: 'adet',
  ),
  ProductType(
    id: 'kola-2-5l',
    name: 'Kola 2.5L',
    category: 'İçecek',
    unit: 'adet',
  ),
  ProductType(
    id: 'ayran-285',
    name: 'Ayran 285ml',
    category: 'İçecek',
    unit: 'adet',
  ),
  ProductType(
    id: 'kahve-100',
    name: 'Türk Kahvesi 100g',
    category: 'İçecek',
    unit: 'adet',
  ),
  ProductType(
    id: 'filtre-kahve',
    name: 'Filtre Kahve 250g',
    category: 'İçecek',
    unit: 'adet',
  ),
  ProductType(
    id: 'meyvesuyu-1l',
    name: 'Meyve Suyu 1L',
    category: 'İçecek',
    unit: 'adet',
  ),
  ProductType(
    id: 'maden-6x',
    name: 'Maden Suyu 6x200ml',
    category: 'İçecek',
    unit: 'adet',
  ),
  ProductType(
    id: 'domates-1kg',
    name: 'Domates',
    category: 'Meyve & Sebze',
    unit: 'kg',
  ),
  ProductType(
    id: 'patates-1kg',
    name: 'Patates',
    category: 'Meyve & Sebze',
    unit: 'kg',
  ),
  ProductType(
    id: 'muz-1kg',
    name: 'Muz',
    category: 'Meyve & Sebze',
    unit: 'kg',
  ),
  ProductType(
    id: 'sogan-1kg',
    name: 'Kuru Soğan',
    category: 'Meyve & Sebze',
    unit: 'kg',
  ),
  ProductType(
    id: 'salatalik-1kg',
    name: 'Salatalık',
    category: 'Meyve & Sebze',
    unit: 'kg',
  ),
  ProductType(
    id: 'havuc-1kg',
    name: 'Havuç',
    category: 'Meyve & Sebze',
    unit: 'kg',
  ),
  ProductType(
    id: 'biber-1kg',
    name: 'Çarliston Biber',
    category: 'Meyve & Sebze',
    unit: 'kg',
  ),
  ProductType(
    id: 'patlican-1kg',
    name: 'Patlıcan',
    category: 'Meyve & Sebze',
    unit: 'kg',
  ),
  ProductType(
    id: 'kabak-1kg',
    name: 'Kabak',
    category: 'Meyve & Sebze',
    unit: 'kg',
  ),
  ProductType(
    id: 'fasulye-1kg',
    name: 'Taze Fasulye',
    category: 'Meyve & Sebze',
    unit: 'kg',
  ),
  ProductType(
    id: 'sarimsak-250',
    name: 'Sarımsak 250g',
    category: 'Meyve & Sebze',
    unit: 'adet',
  ),
  ProductType(
    id: 'maydanoz',
    name: 'Maydanoz',
    category: 'Meyve & Sebze',
    unit: 'adet',
  ),
  ProductType(
    id: 'pilic-butun',
    name: 'Piliç Bütün',
    category: 'Et & Tavuk',
    unit: 'kg',
  ),
  ProductType(
    id: 'pilic-but',
    name: 'Piliç Kalçalı But',
    category: 'Et & Tavuk',
    unit: 'kg',
  ),
  ProductType(
    id: 'tavuk-1kg',
    name: 'Piliç But Pirzola',
    category: 'Et & Tavuk',
    unit: 'kg',
  ),
  ProductType(
    id: 'kofte-500',
    name: 'Köfte 500g',
    category: 'Et & Tavuk',
    unit: 'adet',
  ),
  ProductType(
    id: 'sucuk-250',
    name: 'Sucuk 250g',
    category: 'Et & Tavuk',
    unit: 'adet',
  ),
  ProductType(
    id: 'salam-60',
    name: 'Salam 60g',
    category: 'Et & Tavuk',
    unit: 'adet',
  ),
  ProductType(
    id: 'sosis-190',
    name: 'Sosis 190g',
    category: 'Et & Tavuk',
    unit: 'adet',
  ),
  ProductType(
    id: 'kiyma-400',
    name: 'Dana Kıyma 400g',
    category: 'Et & Tavuk',
    unit: 'adet',
  ),
  ProductType(
    id: 'deterjan-1-5kg',
    name: 'Çamaşır Deterjanı 1.5kg',
    category: 'Temizlik',
    unit: 'adet',
  ),
  ProductType(
    id: 'bulasik-1500',
    name: 'Bulaşık Deterjanı 1500ml',
    category: 'Temizlik',
    unit: 'adet',
  ),
  ProductType(
    id: 'yumusatici-1440',
    name: 'Yumuşatıcı 1440ml',
    category: 'Temizlik',
    unit: 'adet',
  ),
  ProductType(
    id: 'tuvalet-16',
    name: 'Tuvalet Kağıdı 16\'lı',
    category: 'Temizlik',
    unit: 'adet',
  ),
  ProductType(
    id: 'cop-torbasi',
    name: 'Çöp Torbası 15\'li',
    category: 'Temizlik',
    unit: 'adet',
  ),
  ProductType(
    id: 'sampuan-400',
    name: 'Şampuan 400ml',
    category: 'Kişisel Bakım',
    unit: 'adet',
  ),
  ProductType(
    id: 'dis-macunu',
    name: 'Diş Macunu 75ml',
    category: 'Kişisel Bakım',
    unit: 'adet',
  ),
  ProductType(
    id: 'sabun-4',
    name: 'Kalıp Sabun 4\'lü',
    category: 'Kişisel Bakım',
    unit: 'adet',
  ),
  ProductType(
    id: 'dus-jeli',
    name: 'Duş Jeli',
    category: 'Kişisel Bakım',
    unit: 'adet',
  ),
  ProductType(
    id: 'cips-150',
    name: 'Patates Cipsi 150g',
    category: 'Atıştırmalık',
    unit: 'adet',
  ),
  ProductType(
    id: 'biskuvi-102',
    name: 'Bisküvi 102g',
    category: 'Atıştırmalık',
    unit: 'adet',
  ),
  ProductType(
    id: 'cikolata-100',
    name: 'Sütlü Çikolata 100g',
    category: 'Atıştırmalık',
    unit: 'adet',
  ),
  ProductType(
    id: 'gofret-350',
    name: 'Gofret 350g',
    category: 'Atıştırmalık',
    unit: 'adet',
  ),
  ProductType(
    id: 'kek-162',
    name: 'Kek 162g',
    category: 'Atıştırmalık',
    unit: 'adet',
  ),
  ProductType(
    id: 'kraker-82',
    name: 'Kraker 82g',
    category: 'Atıştırmalık',
    unit: 'adet',
  ),
  ProductType(
    id: 'findik-ici',
    name: 'Fındık İçi 150g',
    category: 'Atıştırmalık',
    unit: 'adet',
  ),
  ProductType(
    id: 'dondurma-500',
    name: 'Dondurma 500ml',
    category: 'Dondurma',
    unit: 'adet',
  ),
  ProductType(
    id: 'bebek-bezi',
    name: 'Bebek Bezi 40\'lı',
    category: 'Bebek',
    unit: 'adet',
  ),
];

List<ProductType> searchProductTypesLocal(String query) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return productTypes;
  return productTypes.where((p) {
    return p.name.toLowerCase().contains(q) ||
        p.category.toLowerCase().contains(q);
  }).toList();
}

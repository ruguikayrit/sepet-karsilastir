import '../models/product.dart';

/// Markasız ürün tipi — kullanıcı eklerken marka seçer.
///
/// Çeşit ve referans fiyatlar resmi market sitelerinden derlenmiştir:
/// Şok Market (sokmarket.com.tr) ve Happy Center (happycenter.com.tr),
/// çekim tarihi: 2026-07-26. Ayrıntılar için [marketPriceSnapshot].
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
    final brandKey = (brand ?? 'markasiz')
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-');
    return Product(
      id: '${id}__$brandKey',
      typeId: id,
      name: name,
      category: category,
      unit: unit,
      brand: brand,
    );
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
    name: 'Sofra Tuzu 750g',
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
    id: 'salca-700',
    name: 'Biber Salçası 650g',
    category: 'Temel Gıda',
    unit: 'adet',
  ),
  ProductType(
    id: 'ketcap-600',
    name: 'Ketçap 600g',
    category: 'Temel Gıda',
    unit: 'adet',
  ),
  ProductType(
    id: 'mayonez-550',
    name: 'Mayonez 550g',
    category: 'Temel Gıda',
    unit: 'adet',
  ),
  ProductType(
    id: 'ton-160',
    name: 'Ton Balığı 160g',
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
    name: 'Mısır Konservesi',
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
    id: 'su-6x',
    name: 'Su 6x1.5L',
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
    name: 'Maden Suyu 6\'lı',
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
    name: 'Tavuk Göğüs',
    category: 'Et & Tavuk',
    unit: 'kg',
  ),
  ProductType(
    id: 'kofte-400',
    name: 'Köfte 400g',
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
    id: 'salam-200',
    name: 'Salam 200g',
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
    id: 'deterjan-3kg',
    name: 'Çamaşır Deterjanı',
    category: 'Temizlik',
    unit: 'adet',
  ),
  ProductType(
    id: 'bulasik-750',
    name: 'Bulaşık Deterjanı',
    category: 'Temizlik',
    unit: 'adet',
  ),
  ProductType(
    id: 'yumusatici-2l',
    name: 'Yumuşatıcı',
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
    id: 'tuvalet-8',
    name: 'Tuvalet Kağıdı 8\'li',
    category: 'Temizlik',
    unit: 'adet',
  ),
  ProductType(
    id: 'cop-torbasi',
    name: 'Çöp Torbası',
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
    name: 'Duş Jeli 500ml',
    category: 'Kişisel Bakım',
    unit: 'adet',
  ),
  ProductType(
    id: 'cips-107',
    name: 'Patates Cipsi',
    category: 'Atıştırmalık',
    unit: 'adet',
  ),
  ProductType(
    id: 'biskuvi',
    name: 'Bisküvi',
    category: 'Atıştırmalık',
    unit: 'adet',
  ),
  ProductType(
    id: 'cikolata',
    name: 'Sütlü Çikolata',
    category: 'Atıştırmalık',
    unit: 'adet',
  ),
  ProductType(
    id: 'gofret',
    name: 'Gofret',
    category: 'Atıştırmalık',
    unit: 'adet',
  ),
  ProductType(
    id: 'kek',
    name: 'Kek',
    category: 'Atıştırmalık',
    unit: 'adet',
  ),
  ProductType(
    id: 'kraker',
    name: 'Kraker',
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
    name: 'Bebek Bezi',
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

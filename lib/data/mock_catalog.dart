import '../models/product.dart';

/// Markasız ürün tipi — kullanıcı eklerken marka seçer.
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
    id: 'yumurta-30',
    name: "Yumurta 30'lu",
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
    id: 'yogurt-1kg',
    name: 'Yoğurt 1kg',
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
    id: 'pirinc-1kg',
    name: 'Baldo Pirinç 1kg',
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
    id: 'aycicek-1l',
    name: 'Ayçiçek Yağı 1L',
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
    id: 'cay-500',
    name: 'Dökme Çay 500g',
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
    id: 'deterjan-3kg',
    name: 'Çamaşır Deterjanı 3kg',
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
    id: 'tuvalet-8',
    name: "Tuvalet Kağıdı 8'li",
    category: 'Temizlik',
    unit: 'adet',
  ),
  ProductType(
    id: 'cips-107',
    name: 'Patates Cipsi 107g',
    category: 'Atıştırmalık',
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

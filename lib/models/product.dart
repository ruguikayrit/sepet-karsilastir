import '../utils/text.dart';

class Product {
  const Product({
    required this.id,
    required this.typeId,
    required this.name,
    required this.category,
    required this.unit,
    this.brand,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final storedType = json['typeId'] as String;
    final typeId = _renamedTypeIds[storedType] ?? storedType;
    final brand = json['brand'] as String?;

    return Product(
      // Tip kimliği değiştiyse ürün kimliğini yeniden üret; aksi halde eski
      // sepet satırı yeni eklenen aynı ürünle birleşmez.
      id: typeId == storedType
          ? json['id'] as String
          : '${typeId}__${brandKeyOf(brand)}',
      typeId: typeId,
      name: json['name'] as String,
      category: json['category'] as String? ?? '',
      unit: json['unit'] as String? ?? 'adet',
      brand: brand,
    );
  }

  /// Katalogda adı düzeltilen ürün tiplerinin eski kimlikleri.
  ///
  /// Kalıcı sepet ve kayıtlı listeler eski kimliği taşıdığı için fiyat
  /// snapshot’ına ulaşabilmek üzere burada eşlenir.
  static const _renamedTypeIds = <String, String>{
    'tuz-750': 'tuz-500',
    'ekmek-250': 'ekmek-tam-bugday',
  };

  /// Marka adından kararlı anahtar üretir (ürün kimliğinin ikinci parçası).
  static String brandKeyOf(String? brand) {
    if (brand == null || brand.trim().isEmpty) return 'markasiz';
    final key = slugifyTurkish(brand);
    return key.isEmpty ? 'markasiz' : key;
  }

  /// Sepette benzersiz kimlik (ürün tipi + marka).
  final String id;

  /// Fiyat motorunda kullanılan ürün tipi kimliği.
  final String typeId;

  final String name;
  final String category;
  final String unit;
  final String? brand;

  String get displayName =>
      brand == null || brand!.isEmpty ? name : '$brand $name';

  Map<String, dynamic> toJson() => {
        'id': id,
        'typeId': typeId,
        'name': name,
        'category': category,
        'unit': unit,
        if (brand != null) 'brand': brand,
      };
}

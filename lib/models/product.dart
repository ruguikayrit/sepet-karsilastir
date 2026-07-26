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
    return Product(
      id: json['id'] as String,
      typeId: json['typeId'] as String,
      name: json['name'] as String,
      category: json['category'] as String? ?? '',
      unit: json['unit'] as String? ?? 'adet',
      brand: json['brand'] as String?,
    );
  }

  /// Sepette benzersiz kimlik (ürün tipi + marka).
  final String id;

  /// Fiyat motorunda kullanılan ürün tipi kimliği.
  final String typeId;

  final String name;
  final String category;
  final String unit;
  final String? brand;

  String get displayName => brand == null || brand!.isEmpty
      ? name
      : '$brand $name';

  Map<String, dynamic> toJson() => {
        'id': id,
        'typeId': typeId,
        'name': name,
        'category': category,
        'unit': unit,
        if (brand != null) 'brand': brand,
      };
}

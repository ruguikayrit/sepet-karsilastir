class Product {
  const Product({
    required this.id,
    required this.typeId,
    required this.name,
    required this.category,
    required this.unit,
    this.brand,
  });

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
}

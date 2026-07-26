class Product {
  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.unit,
    this.brand,
  });

  final String id;
  final String name;
  final String category;
  final String unit;
  final String? brand;

  String get displayName => brand == null ? name : '$brand $name';
}

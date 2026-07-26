import 'product.dart';

class ListItem {
  const ListItem({
    required this.product,
    this.quantity = 1,
  });

  factory ListItem.fromJson(Map<String, dynamic> json) {
    return ListItem(
      product: Product.fromJson(json['product'] as Map<String, dynamic>),
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
    );
  }

  final Product product;
  final int quantity;

  ListItem copyWith({Product? product, int? quantity}) {
    return ListItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }

  Map<String, dynamic> toJson() => {
        'product': product.toJson(),
        'quantity': quantity,
      };
}

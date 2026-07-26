import 'product.dart';

class ListItem {
  const ListItem({
    required this.product,
    this.quantity = 1,
  });

  final Product product;
  final int quantity;

  ListItem copyWith({Product? product, int? quantity}) {
    return ListItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }
}

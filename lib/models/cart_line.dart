import 'package:urban_threads/models/product.dart';

class CartLine {
  const CartLine({
    required this.product,
    required this.size,
    required this.quantity,
  });

  final Product product;
  final String size;
  final int quantity;

  CartLine copyWith({int? quantity}) => CartLine(
        product: product,
        size: size,
        quantity: quantity ?? this.quantity,
      );
}

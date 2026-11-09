import 'package:flutter/foundation.dart';
import 'package:urban_threads/models/cart_line.dart';
import 'package:urban_threads/models/product.dart';

class CartModel extends ChangeNotifier {
  final List<CartLine> _lines = [];

  List<CartLine> get lines => List.unmodifiable(_lines);
  int get count => _lines.fold(0, (total, line) => total + line.quantity);
  int get subtotal => _lines.fold(
      0, (total, line) => total + line.product.price * line.quantity);
  bool get isEmpty => _lines.isEmpty;

  void add(Product product, String size) {
    final index = _lines.indexWhere(
      (line) => line.product.id == product.id && line.size == size,
    );
    if (index == -1) {
      _lines.add(CartLine(product: product, size: size, quantity: 1));
    } else {
      _lines[index] = _lines[index].copyWith(
        quantity: _lines[index].quantity + 1,
      );
    }
    notifyListeners();
  }

  void changeQuantity(Product product, String size, int change) {
    final index = _lines.indexWhere(
      (line) => line.product.id == product.id && line.size == size,
    );
    if (index == -1) return;

    final quantity = _lines[index].quantity + change;
    if (quantity < 1) {
      _lines.removeAt(index);
    } else {
      _lines[index] = _lines[index].copyWith(quantity: quantity);
    }
    notifyListeners();
  }

  void remove(Product product, String size) {
    _lines.removeWhere(
      (line) => line.product.id == product.id && line.size == size,
    );
    notifyListeners();
  }

  void clear() {
    _lines.clear();
    notifyListeners();
  }
}

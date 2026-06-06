import 'product.dart';

/// Satu baris di keranjang belanja: sebuah produk beserta jumlahnya.
class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get subtotal => product.price * quantity;
}

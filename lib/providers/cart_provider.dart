import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/sample_data.dart';
import '../models/cart_item.dart';
import '../models/product.dart';

/// Mengelola isi keranjang belanja. Item disimpan dalam map dengan
/// kunci id produk agar penambahan/pengurangan jumlah efisien.
///
/// Isi keranjang dipertahankan antar sesi (persisten) lewat
/// [SharedPreferences]: yang disimpan hanya id produk + jumlahnya, lalu saat
/// aplikasi dibuka kembali objek produknya direkonstruksi dari [productById].
class CartProvider extends ChangeNotifier {
  static const _storageKey = 'cart_items';

  final Map<String, CartItem> _items = {};
  SharedPreferences? _prefs;

  CartProvider() {
    _load();
  }

  List<CartItem> get items => _items.values.toList();

  bool get isEmpty => _items.isEmpty;

  /// Total jumlah barang (menjumlahkan kuantitas tiap item).
  int get totalQuantity =>
      _items.values.fold(0, (sum, item) => sum + item.quantity);

  /// Total harga seluruh item di keranjang.
  double get totalPrice =>
      _items.values.fold(0.0, (sum, item) => sum + item.subtotal);

  int quantityOf(String productId) => _items[productId]?.quantity ?? 0;

  void add(Product product, {int qty = 1}) {
    final existing = _items[product.id];
    if (existing != null) {
      existing.quantity += qty;
    } else {
      _items[product.id] = CartItem(product: product, quantity: qty);
    }
    notifyListeners();
    _save();
  }

  void increase(String productId) {
    final item = _items[productId];
    if (item == null) return;
    item.quantity++;
    notifyListeners();
    _save();
  }

  /// Kurangi kuantitas; bila mencapai 0 item dihapus dari keranjang.
  void decrease(String productId) {
    final item = _items[productId];
    if (item == null) return;
    if (item.quantity > 1) {
      item.quantity--;
    } else {
      _items.remove(productId);
    }
    notifyListeners();
    _save();
  }

  void remove(String productId) {
    _items.remove(productId);
    notifyListeners();
    _save();
  }

  void clear() {
    _items.clear();
    notifyListeners();
    _save();
  }

  /// Memuat isi keranjang dari penyimpanan saat provider dibuat.
  Future<void> _load() async {
    _prefs = await SharedPreferences.getInstance();
    final raw = _prefs!.getString(_storageKey);
    if (raw == null) return;

    final decoded = jsonDecode(raw) as List<dynamic>;
    for (final entry in decoded) {
      final map = entry as Map<String, dynamic>;
      final id = map['id'] as String;
      final qty = map['qty'] as int;
      final product = productById(id);
      // Lewati id yang sudah tidak ada di katalog atau jumlah tidak valid.
      if (product != null && qty > 0) {
        _items[id] = CartItem(product: product, quantity: qty);
      }
    }
    notifyListeners();
  }

  /// Menyimpan isi keranjang (id + jumlah) ke penyimpanan.
  Future<void> _save() async {
    final prefs = _prefs ??= await SharedPreferences.getInstance();
    final encoded = jsonEncode(
      _items.values
          .map((item) => {'id': item.product.id, 'qty': item.quantity})
          .toList(),
    );
    await prefs.setString(_storageKey, encoded);
  }
}

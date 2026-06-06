import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/order.dart';

/// Menyimpan riwayat pesanan pengguna.
///
/// Pesanan dipertahankan antar sesi (persisten) lewat [SharedPreferences],
/// konsisten dengan keranjang dan favorit. Pesanan terbaru berada di urutan
/// pertama.
class OrdersProvider extends ChangeNotifier {
  static const _storageKey = 'orders';

  final List<Order> _orders = [];
  SharedPreferences? _prefs;

  OrdersProvider() {
    _load();
  }

  /// Daftar pesanan, terbaru lebih dulu.
  List<Order> get orders => List.unmodifiable(_orders);

  bool get isEmpty => _orders.isEmpty;

  int get count => _orders.length;

  /// Menambahkan pesanan baru ke urutan paling atas dan menyimpannya.
  void addOrder(Order order) {
    _orders.insert(0, order);
    notifyListeners();
    _save();
  }

  /// Memuat riwayat pesanan dari penyimpanan saat provider dibuat.
  Future<void> _load() async {
    _prefs = await SharedPreferences.getInstance();
    final raw = _prefs!.getString(_storageKey);
    if (raw == null) return;

    final decoded = jsonDecode(raw) as List<dynamic>;
    _orders
      ..clear()
      ..addAll(
        decoded.map((e) => Order.fromJson(e as Map<String, dynamic>)),
      );
    notifyListeners();
  }

  /// Menyimpan seluruh riwayat pesanan ke penyimpanan.
  Future<void> _save() async {
    final prefs = _prefs ??= await SharedPreferences.getInstance();
    final encoded = jsonEncode(_orders.map((o) => o.toJson()).toList());
    await prefs.setString(_storageKey, encoded);
  }
}

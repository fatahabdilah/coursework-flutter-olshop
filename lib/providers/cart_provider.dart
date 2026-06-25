import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/cart_item.dart';
import '../models/product.dart';
import 'products_provider.dart';

/// Mengelola isi keranjang belanja pengguna yang sedang login.
///
/// Yang disimpan (baik lokal maupun di tabel `cart_items` Supabase) hanya
/// id produk + jumlah. Objek produknya di-resolve secara *lazy* dari
/// [ProductsProvider] saat dibutuhkan, sehingga urutan pemuatan katalog vs
/// keranjang tidak jadi masalah. Keranjang tersinkron antar perangkat.
class CartProvider extends ChangeNotifier {
  final SupabaseClient _client = Supabase.instance.client;
  ProductsProvider _products;
  late final StreamSubscription<AuthState> _authSub;

  /// id produk -> jumlah.
  final Map<String, int> _qty = {};

  CartProvider(this._products) {
    _authSub = _client.auth.onAuthStateChange.listen((state) {
      if (state.session != null) {
        load();
      } else {
        _qty.clear();
        notifyListeners();
      }
    });
  }

  String? get _userId => _client.auth.currentUser?.id;

  /// Dipanggil oleh ChangeNotifierProxyProvider saat katalog produk berubah
  /// (mis. baru selesai dimuat), agar tampilan keranjang ikut menyegarkan
  /// resolusi produknya.
  void updateProducts(ProductsProvider products) {
    _products = products;
    WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
  }

  /// Item keranjang yang produknya berhasil di-resolve dari katalog.
  List<CartItem> get items {
    final result = <CartItem>[];
    _qty.forEach((id, qty) {
      final product = _products.byId(id);
      if (product != null) {
        result.add(CartItem(product: product, quantity: qty));
      }
    });
    return result;
  }

  bool get isEmpty => _qty.isEmpty;

  int get totalQuantity => _qty.values.fold(0, (sum, q) => sum + q);

  double get totalPrice => items.fold(0.0, (sum, item) => sum + item.subtotal);

  int quantityOf(String productId) => _qty[productId] ?? 0;

  /// Memuat isi keranjang dari Supabase.
  Future<void> load() async {
    final uid = _userId;
    if (uid == null) return;
    try {
      final rows = await _client
          .from('cart_items')
          .select('product_id, quantity')
          .eq('user_id', uid);
      _qty.clear();
      for (final row in rows as List) {
        final id = row['product_id'] as String;
        final qty = (row['quantity'] as num).toInt();
        if (qty > 0) _qty[id] = qty;
      }
      notifyListeners();
    } catch (_) {
      // Abaikan kegagalan muat; keranjang tetap kosong.
    }
  }

  void add(Product product, {int qty = 1}) {
    final newQty = (_qty[product.id] ?? 0) + qty;
    _qty[product.id] = newQty;
    notifyListeners();
    _upsert(product.id, newQty);
  }

  void increase(String productId) {
    final current = _qty[productId];
    if (current == null) return;
    final newQty = current + 1;
    _qty[productId] = newQty;
    notifyListeners();
    _upsert(productId, newQty);
  }

  void decrease(String productId) {
    final current = _qty[productId];
    if (current == null) return;
    if (current > 1) {
      final newQty = current - 1;
      _qty[productId] = newQty;
      notifyListeners();
      _upsert(productId, newQty);
    } else {
      remove(productId);
    }
  }

  void remove(String productId) {
    _qty.remove(productId);
    notifyListeners();
    _deleteRow(productId);
  }

  void clear() {
    _qty.clear();
    notifyListeners();
    final uid = _userId;
    if (uid != null) {
      _client.from('cart_items').delete().eq('user_id', uid);
    }
  }

  Future<void> _upsert(String productId, int qty) async {
    final uid = _userId;
    if (uid == null) return;
    await _client.from('cart_items').upsert({
      'user_id': uid,
      'product_id': productId,
      'quantity': qty,
    });
  }

  Future<void> _deleteRow(String productId) async {
    final uid = _userId;
    if (uid == null) return;
    await _client
        .from('cart_items')
        .delete()
        .eq('user_id', uid)
        .eq('product_id', productId);
  }

  @override
  void dispose() {
    _authSub.cancel();
    super.dispose();
  }
}

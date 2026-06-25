import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/product.dart';

/// Memuat & mengelola katalog produk dari tabel `products` di Supabase.
///
/// Untuk pelanggan biasa hanya menyediakan daftar produk (baca). Untuk
/// admin, menyediakan operasi tambah/ubah/hapus.
class ProductsProvider extends ChangeNotifier {
  final SupabaseClient _client = Supabase.instance.client;

  List<Product> _products = [];
  bool _loading = false;
  bool _loaded = false;
  String? _error;

  List<Product> get products => List.unmodifiable(_products);
  bool get loading => _loading;
  bool get loaded => _loaded;
  String? get error => _error;
  bool get isEmpty => _products.isEmpty;

  /// Cari produk berdasarkan id; `null` bila tidak ada di katalog.
  Product? byId(String id) {
    for (final p in _products) {
      if (p.id == id) return p;
    }
    return null;
  }

  /// Memuat (atau memuat ulang) seluruh produk dari Supabase.
  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final rows = await _client
          .from('products')
          .select()
          .order('created_at', ascending: true);
      _products = (rows as List)
          .map((e) => Product.fromMap(e as Map<String, dynamic>))
          .toList();
      _loaded = true;
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Tambah produk baru (khusus admin). Mengembalikan produk hasil insert.
  Future<void> addProduct(Product product) async {
    final inserted = await _client
        .from('products')
        .insert(product.toMap())
        .select()
        .single();
    _products.add(Product.fromMap(inserted));
    notifyListeners();
  }

  /// Ubah produk yang sudah ada (khusus admin).
  Future<void> updateProduct(String id, Product product) async {
    final updated = await _client
        .from('products')
        .update(product.toMap())
        .eq('id', id)
        .select()
        .single();
    final index = _products.indexWhere((p) => p.id == id);
    if (index != -1) {
      _products[index] = Product.fromMap(updated);
      notifyListeners();
    }
  }

  /// Hapus produk (khusus admin).
  Future<void> deleteProduct(String id) async {
    await _client.from('products').delete().eq('id', id);
    _products.removeWhere((p) => p.id == id);
    notifyListeners();
  }
}

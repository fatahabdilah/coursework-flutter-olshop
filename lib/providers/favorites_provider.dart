import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Menyimpan kumpulan id produk yang ditandai favorit/wishlist.
///
/// Daftar favorit dipertahankan antar sesi (persisten) lewat
/// [SharedPreferences].
class FavoritesProvider extends ChangeNotifier {
  static const _storageKey = 'favorite_ids';

  final Set<String> _ids = {};
  SharedPreferences? _prefs;

  FavoritesProvider() {
    _load();
  }

  Set<String> get ids => Set.unmodifiable(_ids);

  int get count => _ids.length;

  bool isFavorite(String productId) => _ids.contains(productId);

  void toggle(String productId) {
    if (!_ids.add(productId)) {
      _ids.remove(productId);
    }
    notifyListeners();
    _save();
  }

  /// Memuat daftar favorit dari penyimpanan saat provider dibuat.
  Future<void> _load() async {
    _prefs = await SharedPreferences.getInstance();
    final stored = _prefs!.getStringList(_storageKey);
    if (stored == null) return;
    _ids.addAll(stored);
    notifyListeners();
  }

  /// Menyimpan daftar favorit ke penyimpanan.
  Future<void> _save() async {
    final prefs = _prefs ??= await SharedPreferences.getInstance();
    await prefs.setStringList(_storageKey, _ids.toList());
  }
}

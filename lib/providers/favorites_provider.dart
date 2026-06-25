import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Menyimpan kumpulan id produk favorit (wishlist) pengguna yang login.
///
/// Disimpan di tabel `favorites` Supabase dan tersinkron antar perangkat.
class FavoritesProvider extends ChangeNotifier {
  final SupabaseClient _client = Supabase.instance.client;
  late final StreamSubscription<AuthState> _authSub;

  final Set<String> _ids = {};

  FavoritesProvider() {
    _authSub = _client.auth.onAuthStateChange.listen((state) {
      if (state.session != null) {
        load();
      } else {
        _ids.clear();
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _authSub.cancel();
    super.dispose();
  }

  String? get _userId => _client.auth.currentUser?.id;

  Set<String> get ids => Set.unmodifiable(_ids);

  int get count => _ids.length;

  bool isFavorite(String productId) => _ids.contains(productId);

  Future<void> load() async {
    final uid = _userId;
    if (uid == null) return;
    try {
      final rows =
          await _client.from('favorites').select('product_id').eq('user_id', uid);
      _ids
        ..clear()
        ..addAll((rows as List).map((e) => e['product_id'] as String));
      notifyListeners();
    } catch (_) {
      // Abaikan kegagalan muat.
    }
  }

  void toggle(String productId) {
    final uid = _userId;
    if (uid == null) return;
    if (_ids.add(productId)) {
      _client
          .from('favorites')
          .upsert({'user_id': uid, 'product_id': productId});
    } else {
      _ids.remove(productId);
      _client
          .from('favorites')
          .delete()
          .eq('user_id', uid)
          .eq('product_id', productId);
    }
    notifyListeners();
  }
}

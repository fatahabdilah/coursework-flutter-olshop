import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/address.dart';

/// Mengelola daftar alamat pengiriman pengguna yang login (tabel `addresses`).
///
/// Selalu ada tepat satu alamat utama selama daftar tidak kosong.
class AddressProvider extends ChangeNotifier {
  final SupabaseClient _client = Supabase.instance.client;
  late final StreamSubscription<AuthState> _authSub;

  final List<Address> _addresses = [];

  AddressProvider() {
    _authSub = _client.auth.onAuthStateChange.listen((state) {
      if (state.session != null) {
        load();
      } else {
        _addresses.clear();
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

  List<Address> get addresses => List.unmodifiable(_addresses);

  bool get isEmpty => _addresses.isEmpty;

  int get count => _addresses.length;

  Address? get defaultAddress {
    if (_addresses.isEmpty) return null;
    return _addresses.firstWhere(
      (a) => a.isDefault,
      orElse: () => _addresses.first,
    );
  }

  Future<void> load() async {
    final uid = _userId;
    if (uid == null) return;
    try {
      final rows = await _client
          .from('addresses')
          .select()
          .eq('user_id', uid)
          .order('created_at', ascending: true);
      _addresses
        ..clear()
        ..addAll((rows as List).map((e) => _fromMap(e as Map<String, dynamic>)));
      notifyListeners();
    } catch (_) {
      // Abaikan kegagalan muat.
    }
  }

  Future<void> add(Address address) async {
    final uid = _userId;
    if (uid == null) return;
    final makeDefault = address.isDefault || _addresses.isEmpty;
    if (makeDefault) await _unsetAllDefault(uid);
    await _client.from('addresses').insert({
      'user_id': uid,
      'label': address.label,
      'recipient': address.recipient,
      'phone': address.phone,
      'detail': address.detail,
      'is_default': makeDefault,
    });
    await load();
  }

  Future<void> update(Address address) async {
    final uid = _userId;
    if (uid == null) return;
    if (address.isDefault) await _unsetAllDefault(uid);
    await _client.from('addresses').update({
      'label': address.label,
      'recipient': address.recipient,
      'phone': address.phone,
      'detail': address.detail,
      'is_default': address.isDefault,
    }).eq('id', address.id);
    await load();
    await _ensureDefault();
  }

  Future<void> remove(String id) async {
    final uid = _userId;
    if (uid == null) return;
    await _client.from('addresses').delete().eq('id', id);
    await load();
    await _ensureDefault();
  }

  Future<void> setDefault(String id) async {
    final uid = _userId;
    if (uid == null) return;
    await _unsetAllDefault(uid);
    await _client.from('addresses').update({'is_default': true}).eq('id', id);
    await load();
  }

  Future<void> _unsetAllDefault(String uid) async {
    await _client
        .from('addresses')
        .update({'is_default': false})
        .eq('user_id', uid);
  }

  /// Pastikan ada satu alamat utama bila daftar tidak kosong.
  Future<void> _ensureDefault() async {
    if (_addresses.isEmpty) return;
    if (_addresses.any((a) => a.isDefault)) return;
    await setDefault(_addresses.first.id);
  }

  Address _fromMap(Map<String, dynamic> map) => Address(
        id: map['id'] as String,
        label: map['label'] as String,
        recipient: map['recipient'] as String,
        phone: map['phone'] as String,
        detail: map['detail'] as String,
        isDefault: (map['is_default'] as bool?) ?? false,
      );
}

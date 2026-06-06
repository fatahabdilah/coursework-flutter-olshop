import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/address.dart';

/// Mengelola daftar alamat pengiriman pengguna.
///
/// Dipertahankan antar sesi (persisten) lewat [SharedPreferences]. Selalu ada
/// tepat satu alamat utama selama daftar tidak kosong.
class AddressProvider extends ChangeNotifier {
  static const _storageKey = 'addresses';

  final List<Address> _addresses = [];
  SharedPreferences? _prefs;

  AddressProvider() {
    _load();
  }

  List<Address> get addresses => List.unmodifiable(_addresses);

  bool get isEmpty => _addresses.isEmpty;

  int get count => _addresses.length;

  /// Alamat utama; `null` bila belum ada alamat sama sekali.
  Address? get defaultAddress {
    if (_addresses.isEmpty) return null;
    return _addresses.firstWhere(
      (a) => a.isDefault,
      orElse: () => _addresses.first,
    );
  }

  void add(Address address) {
    // Alamat pertama otomatis menjadi utama.
    var toAdd = address;
    if (_addresses.isEmpty) {
      toAdd = toAdd.copyWith(isDefault: true);
    }
    if (toAdd.isDefault) _unsetDefault();
    _addresses.add(toAdd);
    _ensureDefault();
    _persist();
  }

  void update(Address address) {
    final index = _addresses.indexWhere((a) => a.id == address.id);
    if (index == -1) return;
    if (address.isDefault) _unsetDefault();
    _addresses[index] = address;
    _ensureDefault();
    _persist();
  }

  void remove(String id) {
    _addresses.removeWhere((a) => a.id == id);
    _ensureDefault();
    _persist();
  }

  void setDefault(String id) {
    for (var i = 0; i < _addresses.length; i++) {
      _addresses[i] =
          _addresses[i].copyWith(isDefault: _addresses[i].id == id);
    }
    _persist();
  }

  /// Menghapus tanda utama dari semua alamat.
  void _unsetDefault() {
    for (var i = 0; i < _addresses.length; i++) {
      if (_addresses[i].isDefault) {
        _addresses[i] = _addresses[i].copyWith(isDefault: false);
      }
    }
  }

  /// Memastikan ada satu alamat utama bila daftar tidak kosong.
  void _ensureDefault() {
    if (_addresses.isEmpty) return;
    if (_addresses.any((a) => a.isDefault)) return;
    _addresses[0] = _addresses[0].copyWith(isDefault: true);
  }

  void _persist() {
    notifyListeners();
    _save();
  }

  Future<void> _load() async {
    _prefs = await SharedPreferences.getInstance();
    final raw = _prefs!.getString(_storageKey);

    if (raw == null) {
      // Sediakan satu alamat contoh saat pertama kali dipakai.
      _addresses.add(const Address(
        id: 'seed-rumah',
        label: 'Rumah',
        recipient: 'Fatah',
        phone: '0812-3456-7890',
        detail: 'Jl. Merdeka No. 123, Jakarta Selatan, DKI Jakarta, 12345',
        isDefault: true,
      ));
      await _save();
      notifyListeners();
      return;
    }

    final decoded = jsonDecode(raw) as List<dynamic>;
    _addresses
      ..clear()
      ..addAll(
        decoded.map((e) => Address.fromJson(e as Map<String, dynamic>)),
      );
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = _prefs ??= await SharedPreferences.getInstance();
    final encoded = jsonEncode(_addresses.map((a) => a.toJson()).toList());
    await prefs.setString(_storageKey, encoded);
  }
}

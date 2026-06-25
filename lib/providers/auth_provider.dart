import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Mengelola sesi autentikasi pengguna lewat Supabase Auth.
///
/// Selain status login, provider ini juga memuat *profil* pengguna
/// (nama lengkap & role) dari tabel `profiles` untuk membedakan admin
/// dari pelanggan biasa.
class AuthProvider extends ChangeNotifier {
  final SupabaseClient _client = Supabase.instance.client;
  late final StreamSubscription<AuthState> _authSub;

  String _fullName = '';
  String _role = 'customer';
  bool _profileLoading = false;

  AuthProvider() {
    // Muat profil bila sudah ada sesi tersimpan saat aplikasi dibuka.
    if (_client.auth.currentUser != null) {
      _loadProfile();
    }
    _authSub = _client.auth.onAuthStateChange.listen((state) {
      if (state.session != null) {
        _loadProfile();
      } else {
        _fullName = '';
        _role = 'customer';
      }
      notifyListeners();
    });
  }

  User? get user => _client.auth.currentUser;
  bool get isAuthenticated => user != null;
  String get email => user?.email ?? '';
  String get fullName => _fullName;
  String get role => _role;
  bool get isAdmin => _role == 'admin';
  bool get profileLoading => _profileLoading;

  /// Inisial untuk avatar (huruf pertama nama, fallback email).
  String get initial {
    final source = _fullName.isNotEmpty ? _fullName : email;
    return source.isNotEmpty ? source[0].toUpperCase() : '?';
  }

  Future<void> _loadProfile() async {
    final id = user?.id;
    if (id == null) return;
    _profileLoading = true;
    notifyListeners();
    try {
      final data = await _client
          .from('profiles')
          .select('full_name, role')
          .eq('id', id)
          .maybeSingle();
      if (data != null) {
        _fullName = (data['full_name'] as String?) ?? '';
        _role = (data['role'] as String?) ?? 'customer';
      }
    } catch (_) {
      // Biarkan nilai default bila profil gagal dimuat.
    } finally {
      _profileLoading = false;
      notifyListeners();
    }
  }

  /// Masuk dengan email & kata sandi. Melempar [AuthException] bila gagal.
  Future<void> signIn(String email, String password) async {
    await _client.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Mendaftar akun baru. Nama lengkap disimpan di metadata user agar
  /// trigger `handle_new_user` mengisinya ke tabel profiles.
  Future<void> signUp(String email, String password, String fullName) async {
    await _client.auth.signUp(
      email: email.trim(),
      password: password,
      data: {'full_name': fullName.trim()},
    );
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  @override
  void dispose() {
    _authSub.cancel();
    super.dispose();
  }
}

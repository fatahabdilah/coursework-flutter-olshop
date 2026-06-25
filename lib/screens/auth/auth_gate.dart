import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/products_provider.dart';
import '../main_screen.dart';
import 'login_screen.dart';

/// Penjaga rute: menampilkan layar login bila belum masuk, atau aplikasi
/// utama bila sudah. Saat pengguna login, katalog produk dimuat dulu sebelum
/// aplikasi utama ditampilkan. Provider data per-pengguna (keranjang, favorit,
/// pesanan, alamat) hidup di root dan menyesuaikan dirinya sendiri terhadap
/// status login.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (!auth.isAuthenticated) {
      return const LoginScreen();
    }

    return _AuthenticatedApp(key: ValueKey(auth.user!.id));
  }
}

class _AuthenticatedApp extends StatefulWidget {
  const _AuthenticatedApp({super.key});

  @override
  State<_AuthenticatedApp> createState() => _AuthenticatedAppState();
}

class _AuthenticatedAppState extends State<_AuthenticatedApp> {
  @override
  void initState() {
    super.initState();
    // Muat katalog untuk sesi pengguna ini.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductsProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final products = context.watch<ProductsProvider>();

    if (!products.loaded) {
      return Scaffold(
        body: Center(
          child: products.error != null
              ? _LoadError(message: products.error!)
              : const CircularProgressIndicator(),
        ),
      );
    }

    return const MainScreen();
  }
}

class _LoadError extends StatelessWidget {
  final String message;

  const _LoadError({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 56, color: Colors.redAccent),
          const SizedBox(height: 12),
          const Text(
            'Gagal memuat produk',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => context.read<ProductsProvider>().load(),
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }
}

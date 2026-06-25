import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'providers/address_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/favorites_provider.dart';
import 'providers/orders_provider.dart';
import 'providers/products_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/auth/auth_gate.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Muat kredensial Supabase dari file .env.
  await dotenv.load(fileName: '.env');
  final url = dotenv.env['SUPABASE_URL'];
  final anonKey = dotenv.env['SUPABASE_ANON_KEY'];

  if (url == null || url.isEmpty || anonKey == null || anonKey.isEmpty) {
    runApp(const _ConfigErrorApp());
    return;
  }

  // anonKey klasik (format JWT) masih didukung; abaikan peringatan deprecation.
  // ignore: deprecated_member_use
  await Supabase.initialize(url: url, anonKey: anonKey);

  runApp(const OlshopApp());
}

class OlshopApp extends StatelessWidget {
  const OlshopApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Semua provider berada di atas MaterialApp agar bisa diakses dari
    // halaman yang di-push lewat Navigator (Checkout, Detail, dll). Provider
    // data per-pengguna memuat/mengosongkan dirinya sendiri saat login/logout
    // melalui listener auth.
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductsProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
        ChangeNotifierProvider(create: (_) => OrdersProvider()),
        ChangeNotifierProvider(create: (_) => AddressProvider()),
        ChangeNotifierProxyProvider<ProductsProvider, CartProvider>(
          create: (ctx) => CartProvider(ctx.read<ProductsProvider>()),
          update: (_, products, cart) => cart!..updateProducts(products),
        ),
      ],
      child: MaterialApp(
        title: 'Olshop',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: const AuthGate(),
      ),
    );
  }
}

/// Layar fallback bila kredensial Supabase belum diisi di file `.env`.
class _ConfigErrorApp extends StatelessWidget {
  const _ConfigErrorApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.cloud_off, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'Kredensial Supabase belum diisi',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Text(
                  'Isi SUPABASE_URL dan SUPABASE_ANON_KEY di file .env, '
                  'lalu jalankan ulang aplikasi.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

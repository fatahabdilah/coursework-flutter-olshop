import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Halaman informasi tentang aplikasi.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tentang Aplikasi')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
        children: [
          Center(
            child: Column(
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6C4DF6), Color(0xFFB89BFF)],
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(
                    Icons.shopping_bag,
                    color: Colors.white,
                    size: 44,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Olshop',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.ink,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Versi 1.0.0',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(
              'Olshop adalah aplikasi toko online sederhana yang dibuat dengan '
              'Flutter sebagai contoh. Jelajahi produk, simpan favorit, kelola '
              'keranjang, dan selesaikan pesananmu dengan mudah.',
              style: TextStyle(
                color: Colors.grey.shade700,
                height: 1.6,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Column(
              children: [
                _InfoTile(
                  icon: Icons.code,
                  label: 'Dibuat dengan',
                  value: 'Flutter',
                ),
                Divider(height: 1, indent: 56, endIndent: 16),
                _InfoTile(
                  icon: Icons.business_outlined,
                  label: 'Pengembang',
                  value: 'Orova Group',
                ),
                Divider(height: 1, indent: 56, endIndent: 16),
                _InfoTile(
                  icon: Icons.update,
                  label: 'Terakhir diperbarui',
                  value: 'Juni 2026',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              '© 2026 Olshop. Semua hak dilindungi.',
              style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.seed),
      title: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: AppTheme.ink,
          fontSize: 14,
        ),
      ),
      trailing: Text(
        value,
        style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
      ),
    );
  }
}

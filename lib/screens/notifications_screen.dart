import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';

/// Halaman pengaturan notifikasi. Tiap toggle disimpan persisten.
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Notifikasi')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          _Group(
            title: 'Notifikasi',
            children: [
              _Toggle(
                icon: Icons.local_offer_outlined,
                title: 'Promo & Diskon',
                subtitle: 'Info penawaran dan voucher terbaru',
                value: settings.notifPromo,
                onChanged: context.read<SettingsProvider>().setNotifPromo,
              ),
              _Toggle(
                icon: Icons.receipt_long_outlined,
                title: 'Status Pesanan',
                subtitle: 'Pembaruan saat pesanan diproses & dikirim',
                value: settings.notifOrder,
                onChanged: context.read<SettingsProvider>().setNotifOrder,
              ),
              _Toggle(
                icon: Icons.new_releases_outlined,
                title: 'Produk Baru',
                subtitle: 'Pemberitahuan saat ada produk baru',
                value: settings.notifNewProduct,
                onChanged:
                    context.read<SettingsProvider>().setNotifNewProduct,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _Group(
            title: 'Preferensi',
            children: [
              _Toggle(
                icon: Icons.volume_up_outlined,
                title: 'Suara',
                subtitle: 'Bunyikan suara saat notifikasi masuk',
                value: settings.notifSound,
                onChanged: context.read<SettingsProvider>().setNotifSound,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Group extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _Group({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade600,
              fontSize: 13,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                children[i],
                if (i != children.length - 1)
                  const Divider(height: 1, indent: 60, endIndent: 16),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _Toggle extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _Toggle({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      activeThumbColor: AppTheme.seed,
      secondary: Icon(icon, color: AppTheme.seed),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: AppTheme.ink,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
      ),
    );
  }
}

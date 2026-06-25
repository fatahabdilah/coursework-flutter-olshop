import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import 'about_screen.dart';
import 'address_screen.dart';
import 'admin/admin_orders_screen.dart';
import 'admin/admin_products_screen.dart';
import 'help_center_screen.dart';
import 'notifications_screen.dart';
import 'orders_screen.dart';
import 'payment_methods_screen.dart';

/// Layar profil berisi info pengguna dan menu akun.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _open(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  void _confirmLogout(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Keluar'),
        content: const Text('Apakah kamu yakin ingin keluar dari akun?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Batal'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFFF4D67),
            ),
            onPressed: () {
              Navigator.of(dialogContext).pop();
              // AuthGate otomatis kembali ke layar login setelah keluar.
              context.read<AuthProvider>().signOut();
            },
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final displayName = auth.fullName.isNotEmpty ? auth.fullName : 'Pengguna';

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: AppTheme.seed,
                  child: Text(
                    auth.initial,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              displayName,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.ink,
                              ),
                            ),
                          ),
                          if (auth.isAdmin) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.seed.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'Admin',
                                style: TextStyle(
                                  color: AppTheme.seed,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        auth.email,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (auth.isAdmin) ...[
            _MenuGroup(
              items: [
                _MenuData(
                  Icons.inventory_2_outlined,
                  'Kelola Produk',
                  () => _open(context, const AdminProductsScreen()),
                ),
                _MenuData(
                  Icons.receipt_long_outlined,
                  'Pesanan Masuk',
                  () => _open(context, const AdminOrdersScreen()),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          _MenuGroup(
            items: [
              _MenuData(
                Icons.receipt_long_outlined,
                'Pesanan Saya',
                () => _open(context, const OrdersScreen()),
              ),
              _MenuData(
                Icons.location_on_outlined,
                'Alamat Tersimpan',
                () => _open(context, const AddressScreen()),
              ),
              _MenuData(
                Icons.account_balance_wallet_outlined,
                'Metode Pembayaran',
                () => _open(context, const PaymentMethodsScreen()),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _MenuGroup(
            items: [
              _MenuData(
                Icons.notifications_none_rounded,
                'Notifikasi',
                () => _open(context, const NotificationsScreen()),
              ),
              _MenuData(
                Icons.help_outline,
                'Pusat Bantuan',
                () => _open(context, const HelpCenterScreen()),
              ),
              _MenuData(
                Icons.info_outline,
                'Tentang Aplikasi',
                () => _open(context, const AboutScreen()),
              ),
            ],
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => _confirmLogout(context),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              foregroundColor: const Color(0xFFFF4D67),
              side: const BorderSide(color: Color(0xFFFFC2CC)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            icon: const Icon(Icons.logout),
            label: const Text('Keluar'),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'Olshop v1.0.0',
              style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuData {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _MenuData(this.icon, this.label, this.onTap);
}

class _MenuGroup extends StatelessWidget {
  final List<_MenuData> items;

  const _MenuGroup({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            ListTile(
              leading: Icon(items[i].icon, color: AppTheme.seed),
              title: Text(
                items[i].label,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.ink,
                ),
              ),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: items[i].onTap,
            ),
            if (i != items.length - 1)
              const Divider(height: 1, indent: 56, endIndent: 16),
          ],
        ],
      ),
    );
  }
}

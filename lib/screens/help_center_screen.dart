import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class _Faq {
  final String question;
  final String answer;
  const _Faq(this.question, this.answer);
}

const List<_Faq> _faqs = [
  _Faq(
    'Bagaimana cara memesan produk?',
    'Pilih produk yang diinginkan, tekan "Tambah ke Keranjang", lalu buka '
        'keranjang dan tekan "Checkout" untuk menyelesaikan pesanan.',
  ),
  _Faq(
    'Metode pembayaran apa saja yang tersedia?',
    'Kami mendukung Transfer Bank, E-Wallet, Kartu Kredit/Debit, dan COD '
        '(bayar di tempat). Atur metode utama di menu Metode Pembayaran.',
  ),
  _Faq(
    'Berapa lama pesanan saya dikirim?',
    'Pengiriman Reguler memakan waktu 2-3 hari, sedangkan Express 1 hari '
        'kerja, tergantung lokasi tujuan.',
  ),
  _Faq(
    'Bagaimana cara melacak pesanan?',
    'Buka menu Profil → Pesanan Saya untuk melihat status setiap pesananmu.',
  ),
  _Faq(
    'Apakah produk bisa dikembalikan?',
    'Produk dapat dikembalikan dalam 7 hari setelah diterima jika terdapat '
        'kerusakan atau ketidaksesuaian. Hubungi tim kami untuk bantuan.',
  ),
];

/// Halaman pusat bantuan: FAQ dan opsi kontak.
class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  void _contact(BuildContext context, String channel) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('Menghubungkan ke $channel...')),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pusat Bantuan')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          const Text(
            'Pertanyaan Umum',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: AppTheme.ink,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (var i = 0; i < _faqs.length; i++) ...[
                  Theme(
                    data: Theme.of(context)
                        .copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      title: Text(
                        _faqs[i].question,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.ink,
                          fontSize: 14,
                        ),
                      ),
                      iconColor: AppTheme.seed,
                      childrenPadding:
                          const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      expandedCrossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _faqs[i].answer,
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            height: 1.5,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (i != _faqs.length - 1)
                    const Divider(height: 1, indent: 16, endIndent: 16),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Masih butuh bantuan?',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: AppTheme.ink,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              children: [
                _ContactTile(
                  icon: Icons.chat_bubble_outline,
                  title: 'Live Chat',
                  subtitle: 'Balasan rata-rata dalam 5 menit',
                  onTap: () => _contact(context, 'Live Chat'),
                ),
                const Divider(height: 1, indent: 60, endIndent: 16),
                _ContactTile(
                  icon: Icons.email_outlined,
                  title: 'Email',
                  subtitle: 'cs@olshop.id',
                  onTap: () => _contact(context, 'Email'),
                ),
                const Divider(height: 1, indent: 60, endIndent: 16),
                _ContactTile(
                  icon: Icons.phone_outlined,
                  title: 'Telepon',
                  subtitle: '(021) 1500-123',
                  onTap: () => _contact(context, 'Telepon'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ContactTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.seed),
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
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/payment_methods.dart';
import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';

/// Halaman pilih metode pembayaran utama. Pilihan disimpan persisten.
class PaymentMethodsScreen extends StatelessWidget {
  const PaymentMethodsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Metode Pembayaran')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          Text(
            'Pilih metode pembayaran utama yang akan dipakai saat checkout.',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
          const SizedBox(height: 16),
          for (final option in kPaymentMethods) ...[
            _PaymentTile(
              option: option,
              selected: settings.paymentMethod == option.name,
              onTap: () {
                context.read<SettingsProvider>().setPaymentMethod(option.name);
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(content: Text('${option.name} dipilih')),
                  );
              },
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _PaymentTile extends StatelessWidget {
  final PaymentOption option;
  final bool selected;
  final VoidCallback onTap;

  const _PaymentTile({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: selected
                ? Border.all(color: AppTheme.seed, width: 1.5)
                : Border.all(color: Colors.transparent, width: 1.5),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppTheme.seed.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(option.icon, color: AppTheme.seed),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppTheme.ink,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      option.description,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
                color: selected ? AppTheme.seed : Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

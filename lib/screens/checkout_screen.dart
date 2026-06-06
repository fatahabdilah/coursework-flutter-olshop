import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/order.dart';
import '../providers/cart_provider.dart';
import '../providers/orders_provider.dart';
import '../theme/app_theme.dart';
import '../utils/formatter.dart';
import 'orders_screen.dart';

/// Layar checkout: alamat, metode pengiriman & pembayaran, ringkasan,
/// dan tombol buat pesanan.
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  static const Map<String, double> _shippingCosts = {
    'Reguler': 20000,
    'Express': 40000,
  };

  static const String _address =
      'Rumah • Fatah\n'
      'Jl. Merdeka No. 123, Jakarta Selatan, DKI Jakarta, 12345';

  String _shipping = 'Reguler';
  String _payment = 'Transfer Bank';

  double get _shippingCost => _shippingCosts[_shipping]!;

  void _placeOrder(double total) {
    final cart = context.read<CartProvider>();

    // Bangun pesanan dari isi keranjang sebelum keranjang dikosongkan.
    final now = DateTime.now();
    final order = Order(
      id: 'INV${now.millisecondsSinceEpoch}',
      date: now,
      lines: cart.items
          .map(
            (item) => OrderLine(
              productId: item.product.id,
              name: item.product.name,
              emoji: item.product.emoji,
              price: item.product.price,
              quantity: item.quantity,
            ),
          )
          .toList(),
      shippingCost: _shippingCost,
      shippingMethod: _shipping,
      paymentMethod: _payment,
      address: _address,
    );

    context.read<OrdersProvider>().addOrder(order);
    cart.clear();

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle,
                  color: Colors.green, size: 56),
            ),
            const SizedBox(height: 16),
            const Text(
              'Pesanan Berhasil!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              'Terima kasih telah berbelanja. Pesananmu senilai '
              '${formatRupiah(total)} sedang diproses.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
        actions: [
          Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    Navigator.of(context).popUntil((route) => route.isFirst);
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const OrdersScreen()),
                    );
                  },
                  child: const Text('Lihat Pesanan'),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  child: const Text('Kembali ke Beranda'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final subtotal = cart.totalPrice;
    final total = subtotal + (cart.isEmpty ? 0 : _shippingCost);

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          const _SectionCard(
            title: 'Alamat Pengiriman',
            icon: Icons.location_on_outlined,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rumah • Fatah',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 4),
                Text(
                  'Jl. Merdeka No. 123, Jakarta Selatan, DKI Jakarta, 12345',
                  style: TextStyle(height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _SectionCard(
            title: 'Metode Pengiriman',
            icon: Icons.local_shipping_outlined,
            child: Column(
              children: [
                _RadioRow(
                  label: 'Reguler (2-3 hari)',
                  value: 'Reguler',
                  groupValue: _shipping,
                  trailing: formatRupiah(_shippingCosts['Reguler']!),
                  onChanged: (v) => setState(() => _shipping = v),
                ),
                _RadioRow(
                  label: 'Express (1 hari)',
                  value: 'Express',
                  groupValue: _shipping,
                  trailing: formatRupiah(_shippingCosts['Express']!),
                  onChanged: (v) => setState(() => _shipping = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _SectionCard(
            title: 'Metode Pembayaran',
            icon: Icons.payment_outlined,
            child: Column(
              children: [
                _RadioRow(
                  label: 'Transfer Bank',
                  value: 'Transfer Bank',
                  groupValue: _payment,
                  onChanged: (v) => setState(() => _payment = v),
                ),
                _RadioRow(
                  label: 'E-Wallet',
                  value: 'E-Wallet',
                  groupValue: _payment,
                  onChanged: (v) => setState(() => _payment = v),
                ),
                _RadioRow(
                  label: 'COD (Bayar di Tempat)',
                  value: 'COD',
                  groupValue: _payment,
                  onChanged: (v) => setState(() => _payment = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _SectionCard(
            title: 'Ringkasan Belanja',
            icon: Icons.receipt_long_outlined,
            child: Column(
              children: [
                _SummaryRow(
                  label: 'Subtotal (${cart.totalQuantity} barang)',
                  value: formatRupiah(subtotal),
                ),
                const SizedBox(height: 8),
                _SummaryRow(
                  label: 'Ongkos kirim',
                  value: formatRupiah(cart.isEmpty ? 0 : _shippingCost),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1),
                ),
                _SummaryRow(
                  label: 'Total',
                  value: formatRupiah(total),
                  emphasize: true,
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: FilledButton(
            onPressed: cart.isEmpty ? null : () => _placeOrder(total),
            child: Text('Buat Pesanan • ${formatRupiah(total)}'),
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppTheme.seed),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: AppTheme.ink,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _RadioRow extends StatelessWidget {
  final String label;
  final String value;
  final String groupValue;
  final String? trailing;
  final ValueChanged<String> onChanged;

  const _RadioRow({
    required this.label,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final selected = value == groupValue;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => onChanged(value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_off,
              color: selected ? AppTheme.seed : Colors.grey.shade400,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
            if (trailing != null)
              Text(
                trailing!,
                style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
              ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool emphasize;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: emphasize ? AppTheme.ink : Colors.grey.shade600,
            fontWeight: emphasize ? FontWeight.w800 : FontWeight.w500,
            fontSize: emphasize ? 16 : 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: emphasize ? AppTheme.seed : AppTheme.ink,
            fontWeight: emphasize ? FontWeight.w900 : FontWeight.w600,
            fontSize: emphasize ? 18 : 14,
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

import '../models/order.dart';
import '../theme/app_theme.dart';
import '../utils/formatter.dart';
import 'order_status_style.dart';

/// Halaman rincian satu pesanan: status, info, daftar barang, dan ringkasan.
class OrderDetailScreen extends StatelessWidget {
  final Order order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Pesanan')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          _StatusBanner(status: order.status),
          const SizedBox(height: 12),
          _Card(
            title: 'Informasi Pesanan',
            icon: Icons.receipt_long_outlined,
            child: Column(
              children: [
                _InfoRow(label: 'No. Pesanan', value: order.id),
                _InfoRow(label: 'Tanggal', value: formatDateTime(order.date)),
                _InfoRow(label: 'Pengiriman', value: order.shippingMethod),
                _InfoRow(label: 'Pembayaran', value: order.paymentMethod),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _Card(
            title: 'Alamat Pengiriman',
            icon: Icons.location_on_outlined,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(order.address, style: const TextStyle(height: 1.4)),
            ),
          ),
          const SizedBox(height: 12),
          _Card(
            title: 'Barang (${order.itemCount})',
            icon: Icons.shopping_bag_outlined,
            child: Column(
              children: [
                for (final line in order.lines) _OrderLineRow(line: line),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _Card(
            title: 'Ringkasan Pembayaran',
            icon: Icons.payments_outlined,
            child: Column(
              children: [
                _SummaryRow(
                  label: 'Subtotal',
                  value: formatRupiah(order.subtotal),
                ),
                const SizedBox(height: 8),
                _SummaryRow(
                  label: 'Ongkos kirim',
                  value: formatRupiah(order.shippingCost),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1),
                ),
                _SummaryRow(
                  label: 'Total',
                  value: formatRupiah(order.total),
                  emphasize: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  final OrderStatus status;

  const _StatusBanner({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = orderStatusColor(status);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.30)),
      ),
      child: Row(
        children: [
          Icon(orderStatusIcon(status), color: color),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                status.label,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                orderStatusHint(status),
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OrderLineRow extends StatelessWidget {
  final OrderLine line;

  const _OrderLineRow({required this.line});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppTheme.scaffoldBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(line.emoji, style: const TextStyle(fontSize: 24)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  line.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${line.quantity} × ${formatRupiah(line.price)}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            formatRupiah(line.subtotal),
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: AppTheme.ink,
            ),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _Card({required this.title, required this.icon, required this.child});

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

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppTheme.ink,
                fontSize: 13,
              ),
            ),
          ),
        ],
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

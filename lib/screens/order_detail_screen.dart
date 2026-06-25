import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../data/bank_account.dart';
import '../models/order.dart';
import '../providers/orders_provider.dart';
import '../theme/app_theme.dart';
import '../utils/formatter.dart';
import 'order_status_style.dart';

/// Halaman rincian satu pesanan: status, info, daftar barang, ringkasan, dan
/// (untuk pembayaran transfer) info rekening + unggah/tampilan bukti transfer.
///
/// [adminView] = true saat dibuka admin; tombol unggah bukti disembunyikan
/// karena bukti diunggah oleh pembeli.
class OrderDetailScreen extends StatefulWidget {
  final Order order;
  final bool adminView;

  const OrderDetailScreen({
    super.key,
    required this.order,
    this.adminView = false,
  });

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  late Order _order = widget.order;
  bool _uploading = false;

  bool get _needsPayment =>
      _order.status == OrderStatus.menungguPembayaran;

  Future<void> _pickAndUpload() async {
    // Tangkap dependensi yang butuh context sebelum operasi async.
    final orders = context.read<OrdersProvider>();
    final messenger = ScaffoldMessenger.of(context);

    final picker = ImagePicker();
    final XFile? file =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (file == null) return;

    setState(() => _uploading = true);
    try {
      final bytes = await file.readAsBytes();
      final parts = file.name.split('.');
      final ext = parts.length > 1 ? parts.last.toLowerCase() : 'jpg';
      final url = await orders.uploadPaymentProof(_order.id, bytes, ext);
      if (!mounted) return;
      setState(() {
        _order = _order.copyWith(paymentProofUrl: url);
        _uploading = false;
      });
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Bukti transfer terunggah.')),
        );
    } catch (e) {
      if (!mounted) return;
      setState(() => _uploading = false);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text('Gagal mengunggah: $e')));
    }
  }

  void _viewProofFull(String url) {
    showDialog<void>(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: const EdgeInsets.all(12),
        child: InteractiveViewer(
          child: Image.network(url, fit: BoxFit.contain),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Pesanan')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          _StatusBanner(status: _order.status),
          const SizedBox(height: 12),
          if (_needsPayment || _order.paymentProofUrl != null) ...[
            _buildPaymentCard(),
            const SizedBox(height: 12),
          ],
          _Card(
            title: 'Informasi Pesanan',
            icon: Icons.receipt_long_outlined,
            child: Column(
              children: [
                _InfoRow(label: 'No. Pesanan', value: _order.id),
                _InfoRow(label: 'Tanggal', value: formatDateTime(_order.date)),
                _InfoRow(label: 'Pengiriman', value: _order.shippingMethod),
                _InfoRow(label: 'Pembayaran', value: _order.paymentMethod),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _Card(
            title: 'Alamat Pengiriman',
            icon: Icons.location_on_outlined,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(_order.address, style: const TextStyle(height: 1.4)),
            ),
          ),
          const SizedBox(height: 12),
          _Card(
            title: 'Barang (${_order.itemCount})',
            icon: Icons.shopping_bag_outlined,
            child: Column(
              children: [
                for (final line in _order.lines) _OrderLineRow(line: line),
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
                  value: formatRupiah(_order.subtotal),
                ),
                const SizedBox(height: 8),
                _SummaryRow(
                  label: 'Ongkos kirim',
                  value: formatRupiah(_order.shippingCost),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1),
                ),
                _SummaryRow(
                  label: 'Total',
                  value: formatRupiah(_order.total),
                  emphasize: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard() {
    final proof = _order.paymentProofUrl;
    return _Card(
      title: 'Pembayaran Transfer',
      icon: Icons.account_balance_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info rekening hanya relevan selagi menunggu pembayaran.
          if (_needsPayment) ...[
            _BankRow(label: 'Bank', value: BankAccount.bank),
            const SizedBox(height: 6),
            _BankRow(label: 'No. Rekening', value: BankAccount.number),
            const SizedBox(height: 6),
            _BankRow(label: 'Atas Nama', value: BankAccount.holder),
            const SizedBox(height: 6),
            _BankRow(label: 'Nominal', value: formatRupiah(_order.total)),
            const Divider(height: 24),
          ],

          // Bukti transfer (jika sudah diunggah).
          if (proof != null) ...[
            const Text(
              'Bukti Transfer',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => _viewProofFull(proof),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  proof,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) =>
                      progress == null
                          ? child
                          : const SizedBox(
                              height: 200,
                              child: Center(child: CircularProgressIndicator()),
                            ),
                  errorBuilder: (_, _, _) => Container(
                    height: 120,
                    alignment: Alignment.center,
                    color: AppTheme.scaffoldBg,
                    child: const Text('Gagal memuat gambar'),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],

          // Pesan status verifikasi.
          if (_needsPayment)
            Text(
              proof == null
                  ? (widget.adminView
                      ? 'Pembeli belum mengunggah bukti transfer.'
                      : 'Silakan transfer sesuai nominal lalu unggah bukti '
                          'pembayaran di bawah.')
                  : (widget.adminView
                      ? 'Periksa bukti, lalu ubah status pesanan jika valid.'
                      : 'Bukti terunggah. Menunggu verifikasi admin.'),
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
                height: 1.4,
              ),
            ),

          // Tombol unggah / ganti bukti — hanya untuk pembeli saat menunggu.
          if (_needsPayment && !widget.adminView) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _uploading ? null : _pickAndUpload,
                icon: _uploading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.upload_file),
                label: Text(
                  proof == null ? 'Unggah Bukti Transfer' : 'Ganti Bukti',
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BankRow extends StatelessWidget {
  final String label;
  final String value;

  const _BankRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            color: AppTheme.ink,
            fontSize: 14,
          ),
        ),
      ],
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
          Expanded(
            child: Column(
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

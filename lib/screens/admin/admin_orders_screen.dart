import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/order.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatter.dart';
import '../../widgets/empty_state.dart';
import '../order_detail_screen.dart';
import '../order_status_style.dart';

/// Pesanan beserta nama pembeli (untuk tampilan admin).
class _AdminOrder {
  final Order order;
  final String buyerName;

  const _AdminOrder(this.order, this.buyerName);
}

/// Layar admin: melihat seluruh pesanan dari semua pengguna dan mengubah
/// status pesanan. Dilindungi RLS (hanya role admin yang boleh baca semua &
/// mengubah status).
class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  final SupabaseClient _client = Supabase.instance.client;

  List<_AdminOrder> _orders = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final rows = await _client
          .from('orders')
          .select('*, order_items(*)')
          .order('date', ascending: false);

      // Peta id pengguna -> nama, untuk menampilkan pembeli tiap pesanan.
      final profiles = await _client.from('profiles').select('id, full_name');
      final names = <String, String>{
        for (final p in profiles as List)
          p['id'] as String: (p['full_name'] as String?) ?? '',
      };

      final list = (rows as List).map((e) {
        final map = e as Map<String, dynamic>;
        final order = Order.fromSupabaseMap(map);
        final uid = map['user_id'] as String?;
        final name = (uid != null && (names[uid] ?? '').isNotEmpty)
            ? names[uid]!
            : 'Pengguna';
        return _AdminOrder(order, name);
      }).toList();

      setState(() {
        _orders = list;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _updateStatus(_AdminOrder item, OrderStatus status) async {
    try {
      await _client
          .from('orders')
          .update({'status': status.dbValue}).eq('id', item.order.id);
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text('Gagal ubah status: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pesanan Masuk'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Gagal memuat pesanan:\n$_error',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ),
                )
              : _orders.isEmpty
                  ? const EmptyState(
                      icon: Icons.receipt_long_outlined,
                      title: 'Belum ada pesanan',
                      message: 'Pesanan dari pengguna akan muncul di sini.',
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      itemCount: _orders.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) => _AdminOrderCard(
                        item: _orders[index],
                        onChangeStatus: (s) =>
                            _updateStatus(_orders[index], s),
                      ),
                    ),
    );
  }
}

class _AdminOrderCard extends StatelessWidget {
  final _AdminOrder item;
  final ValueChanged<OrderStatus> onChangeStatus;

  const _AdminOrderCard({required this.item, required this.onChangeStatus});

  @override
  Widget build(BuildContext context) {
    final order = item.order;
    final color = orderStatusColor(order.status);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => OrderDetailScreen(order: order, adminView: true),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.id,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: AppTheme.ink,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(Icons.person_outline,
                                size: 13, color: Colors.grey.shade500),
                            const SizedBox(width: 3),
                            Text(
                              item.buyerName,
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          formatDateTime(order.date),
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(orderStatusIcon(order.status),
                            size: 14, color: color),
                        const SizedBox(width: 4),
                        Text(
                          order.status.label,
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(height: 1),
              ),
              if (order.status == OrderStatus.menungguPembayaran) ...[
                _ProofIndicator(hasProof: order.paymentProofUrl != null),
                const SizedBox(height: 10),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${order.itemCount} barang',
                    style:
                        TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                  Text(
                    formatRupiah(order.total),
                    style: const TextStyle(
                      color: AppTheme.seed,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showStatusSheet(context),
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Ubah Status'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.seed,
                    side: BorderSide(color: AppTheme.seed.withValues(alpha: 0.4)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showStatusSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Text(
                'Ubah Status Pesanan',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              ),
            ),
            for (final status in OrderStatus.values)
              ListTile(
                leading: Icon(orderStatusIcon(status),
                    color: orderStatusColor(status)),
                title: Text(status.label),
                trailing: status == item.order.status
                    ? const Icon(Icons.check, color: AppTheme.seed)
                    : null,
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  if (status != item.order.status) onChangeStatus(status);
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

/// Penanda apakah pembeli sudah mengunggah bukti transfer.
class _ProofIndicator extends StatelessWidget {
  final bool hasProof;

  const _ProofIndicator({required this.hasProof});

  @override
  Widget build(BuildContext context) {
    final color = hasProof ? const Color(0xFF10B981) : const Color(0xFFFF9F43);
    return Row(
      children: [
        Icon(
          hasProof ? Icons.verified_outlined : Icons.pending_outlined,
          size: 16,
          color: color,
        ),
        const SizedBox(width: 6),
        Text(
          hasProof ? 'Bukti transfer terunggah' : 'Belum ada bukti transfer',
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

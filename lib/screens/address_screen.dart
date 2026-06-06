import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/address.dart';
import '../providers/address_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/empty_state.dart';
import 'address_form_screen.dart';

/// Halaman daftar alamat tersimpan dengan aksi tambah, ubah, hapus,
/// dan jadikan utama.
class AddressScreen extends StatelessWidget {
  const AddressScreen({super.key});

  void _openForm(BuildContext context, {Address? existing}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddressFormScreen(existing: existing),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Address address) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Alamat'),
        content: Text('Hapus alamat "${address.label}"?'),
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
              context.read<AddressProvider>().remove(address.id);
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AddressProvider>();
    final addresses = provider.addresses;

    return Scaffold(
      appBar: AppBar(title: const Text('Alamat Tersimpan')),
      body: addresses.isEmpty
          ? const EmptyState(
              icon: Icons.location_off_outlined,
              title: 'Belum ada alamat',
              message: 'Tambahkan alamat pengiriman untuk mempercepat checkout.',
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
              itemCount: addresses.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) => _AddressCard(
                address: addresses[index],
                onEdit: () => _openForm(context, existing: addresses[index]),
                onDelete: () => _confirmDelete(context, addresses[index]),
                onSetDefault: () =>
                    context.read<AddressProvider>().setDefault(
                          addresses[index].id,
                        ),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(context),
        backgroundColor: AppTheme.seed,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Alamat'),
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  final Address address;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onSetDefault;

  const _AddressCard({
    required this.address,
    required this.onEdit,
    required this.onDelete,
    required this.onSetDefault,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: address.isDefault
            ? Border.all(color: AppTheme.seed, width: 1.5)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.seed.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  address.label,
                  style: const TextStyle(
                    color: AppTheme.seed,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (address.isDefault)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Utama',
                    style: TextStyle(
                      color: Color(0xFF10B981),
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              const Spacer(),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.grey),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      onEdit();
                    case 'default':
                      onSetDefault();
                    case 'delete':
                      onDelete();
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Text('Ubah')),
                  if (!address.isDefault)
                    const PopupMenuItem(
                      value: 'default',
                      child: Text('Jadikan Utama'),
                    ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('Hapus'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            address.recipient,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: AppTheme.ink,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            address.phone,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
          const SizedBox(height: 6),
          Text(
            address.detail,
            style: const TextStyle(height: 1.4, color: AppTheme.ink),
          ),
        ],
      ),
    );
  }
}

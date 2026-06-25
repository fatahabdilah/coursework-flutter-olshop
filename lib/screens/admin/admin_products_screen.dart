import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/product.dart';
import '../../providers/products_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatter.dart';
import '../../widgets/empty_state.dart';
import 'product_form_screen.dart';

/// Layar admin untuk mengelola katalog produk (tambah, ubah, hapus).
class AdminProductsScreen extends StatelessWidget {
  const AdminProductsScreen({super.key});

  void _openForm(BuildContext context, {Product? existing}) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ProductFormScreen(existing: existing)),
    );
  }

  void _confirmDelete(BuildContext context, Product product) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Produk'),
        content: Text('Hapus "${product.name}" dari katalog?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Batal'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFFF4D67),
            ),
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              try {
                await context.read<ProductsProvider>().deleteProduct(product.id);
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(SnackBar(content: Text('Gagal menghapus: $e')));
              }
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductsProvider>();
    final products = provider.products;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Produk'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => provider.load(),
          ),
        ],
      ),
      body: products.isEmpty
          ? const EmptyState(
              icon: Icons.inventory_2_outlined,
              title: 'Belum ada produk',
              message: 'Tambahkan produk pertama lewat tombol di bawah.',
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
              itemCount: products.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final p = products[index];
                return _ProductRow(
                  product: p,
                  onEdit: () => _openForm(context, existing: p),
                  onDelete: () => _confirmDelete(context, p),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(context),
        backgroundColor: AppTheme.seed,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Produk'),
      ),
    );
  }
}

class _ProductRow extends StatelessWidget {
  final Product product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ProductRow({
    required this.product,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Text(product.emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${product.category}  •  Stok ${product.stock}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 2),
                Text(
                  formatRupiah(product.price),
                  style: const TextStyle(
                    color: AppTheme.seed,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppTheme.seed),
            onPressed: onEdit,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Color(0xFFFF4D67)),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

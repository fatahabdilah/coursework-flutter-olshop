import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/favorites_provider.dart';
import '../providers/products_provider.dart';
import '../widgets/empty_state.dart';
import '../widgets/product_card.dart';

/// Layar daftar produk favorit (wishlist).
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoritesProvider>();
    final allProducts = context.watch<ProductsProvider>().products;
    final products =
        allProducts.where((p) => favorites.isFavorite(p.id)).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Favorit')),
      body: products.isEmpty
          ? const EmptyState(
              icon: Icons.favorite_border,
              title: 'Belum ada favorit',
              message:
                  'Tekan ikon hati pada produk untuk menyimpannya di sini.',
            )
          : GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 0.62,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) =>
                  ProductCard(product: products[index]),
            ),
    );
  }
}

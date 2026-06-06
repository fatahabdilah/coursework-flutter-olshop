import 'package:flutter/material.dart';

import '../data/categories.dart';
import '../models/product.dart';

/// Placeholder gambar produk: latar gradasi sesuai kategori dengan
/// emoji produk di tengah. Selalu tampil walau tanpa koneksi internet.
class ProductImage extends StatelessWidget {
  final Product product;
  final double emojiSize;
  final BorderRadius? borderRadius;

  const ProductImage({
    super.key,
    required this.product,
    this.emojiSize = 56,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final info = categoryInfo(product.category);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        gradient: LinearGradient(
          colors: info.gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          product.emoji,
          style: TextStyle(fontSize: emojiSize),
        ),
      ),
    );
  }
}

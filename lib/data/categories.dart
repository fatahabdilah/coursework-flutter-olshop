import 'package:flutter/material.dart';

/// Metadata sebuah kategori produk: nama, ikon, dan warna gradasi
/// yang dipakai sebagai latar placeholder gambar.
class CategoryInfo {
  final String name;
  final IconData icon;
  final List<Color> gradient;

  const CategoryInfo(this.name, this.icon, this.gradient);
}

const List<CategoryInfo> kCategories = [
  CategoryInfo('Elektronik', Icons.devices_other, [
    Color(0xFF6C4DF6),
    Color(0xFF9D7BFF),
  ]),
  CategoryInfo('Fashion', Icons.checkroom, [
    Color(0xFFFF6B9D),
    Color(0xFFFFA6C4),
  ]),
  CategoryInfo('Makanan', Icons.restaurant, [
    Color(0xFFFF9F43),
    Color(0xFFFFC97A),
  ]),
  CategoryInfo('Rumah', Icons.chair_alt, [
    Color(0xFF26C6DA),
    Color(0xFF6FE3F0),
  ]),
  CategoryInfo('Kecantikan', Icons.spa, [
    Color(0xFFEC4899),
    Color(0xFFF9A8D4),
  ]),
  CategoryInfo('Olahraga', Icons.fitness_center, [
    Color(0xFF10B981),
    Color(0xFF6EE7B7),
  ]),
];

/// Cari metadata kategori berdasarkan nama, fallback ke kategori pertama.
CategoryInfo categoryInfo(String name) => kCategories.firstWhere(
      (c) => c.name == name,
      orElse: () => kCategories.first,
    );

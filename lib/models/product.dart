/// Model produk yang dijual di toko.
class Product {
  final String id;
  final String name;
  final String description;
  final double price;

  /// Harga sebelum diskon. `null` jika produk tidak sedang diskon.
  final double? oldPrice;
  final String category;

  /// Emoji yang dipakai sebagai placeholder gambar produk.
  final String emoji;
  final double rating;
  final int sold;
  final int stock;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.emoji,
    this.oldPrice,
    this.rating = 4.5,
    this.sold = 0,
    this.stock = 50,
  });

  bool get isDiscounted => oldPrice != null && oldPrice! > price;

  /// Persentase diskon (0-100).
  int get discountPercent =>
      isDiscounted ? (((oldPrice! - price) / oldPrice!) * 100).round() : 0;
}

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

  /// Membuat objek [Product] dari satu baris tabel `products` di Supabase.
  factory Product.fromMap(Map<String, dynamic> map) => Product(
        id: map['id'] as String,
        name: map['name'] as String,
        description: (map['description'] as String?) ?? '',
        price: (map['price'] as num).toDouble(),
        oldPrice: (map['old_price'] as num?)?.toDouble(),
        category: map['category'] as String,
        emoji: (map['emoji'] as String?) ?? '📦',
        rating: (map['rating'] as num?)?.toDouble() ?? 4.5,
        sold: (map['sold'] as num?)?.toInt() ?? 0,
        stock: (map['stock'] as num?)?.toInt() ?? 0,
      );

  /// Mengubah produk menjadi map kolom untuk insert/update ke Supabase.
  /// `id` tidak disertakan agar dibuat otomatis saat insert produk baru.
  Map<String, dynamic> toMap() => {
        'name': name,
        'description': description,
        'price': price,
        'old_price': oldPrice,
        'category': category,
        'emoji': emoji,
        'rating': rating,
        'sold': sold,
        'stock': stock,
      };
}

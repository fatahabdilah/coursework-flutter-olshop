/// Status sebuah pesanan beserta label tampilannya.
enum OrderStatus {
  menungguPembayaran('Menunggu Pembayaran'),
  diproses('Diproses'),
  dikirim('Dikirim'),
  selesai('Selesai'),
  dibatalkan('Dibatalkan');

  final String label;
  const OrderStatus(this.label);

  /// Nama kolom di database (snake_case), mis. `menunggu_pembayaran`.
  String get dbValue => switch (this) {
        OrderStatus.menungguPembayaran => 'menunggu_pembayaran',
        OrderStatus.diproses => 'diproses',
        OrderStatus.dikirim => 'dikirim',
        OrderStatus.selesai => 'selesai',
        OrderStatus.dibatalkan => 'dibatalkan',
      };

  /// Memetakan nilai kolom database ke enum.
  static OrderStatus fromDb(String value) => switch (value) {
        'menunggu_pembayaran' => OrderStatus.menungguPembayaran,
        'diproses' => OrderStatus.diproses,
        'dikirim' => OrderStatus.dikirim,
        'selesai' => OrderStatus.selesai,
        'dibatalkan' => OrderStatus.dibatalkan,
        _ => OrderStatus.diproses,
      };
}

/// Satu baris item di dalam pesanan.
///
/// Menyimpan *snapshot* produk saat pembelian (nama, harga, emoji) agar
/// riwayat pesanan tetap akurat meski katalog produk berubah di kemudian hari.
class OrderLine {
  final String productId;
  final String name;
  final String emoji;
  final double price;
  final int quantity;

  const OrderLine({
    required this.productId,
    required this.name,
    required this.emoji,
    required this.price,
    required this.quantity,
  });

  double get subtotal => price * quantity;

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'name': name,
        'emoji': emoji,
        'price': price,
        'quantity': quantity,
      };

  factory OrderLine.fromJson(Map<String, dynamic> json) => OrderLine(
        productId: json['productId'] as String,
        name: json['name'] as String,
        emoji: json['emoji'] as String,
        price: (json['price'] as num).toDouble(),
        quantity: json['quantity'] as int,
      );
}

/// Sebuah pesanan yang dibuat dari proses checkout.
class Order {
  final String id;
  final DateTime date;
  final List<OrderLine> lines;
  final double shippingCost;
  final String shippingMethod;
  final String paymentMethod;
  final String address;
  final OrderStatus status;

  /// URL gambar bukti transfer; `null` bila belum diunggah.
  final String? paymentProofUrl;

  const Order({
    required this.id,
    required this.date,
    required this.lines,
    required this.shippingCost,
    required this.shippingMethod,
    required this.paymentMethod,
    required this.address,
    this.status = OrderStatus.diproses,
    this.paymentProofUrl,
  });

  Order copyWith({OrderStatus? status, String? paymentProofUrl}) => Order(
        id: id,
        date: date,
        lines: lines,
        shippingCost: shippingCost,
        shippingMethod: shippingMethod,
        paymentMethod: paymentMethod,
        address: address,
        status: status ?? this.status,
        paymentProofUrl: paymentProofUrl ?? this.paymentProofUrl,
      );

  /// Total harga barang sebelum ongkir.
  double get subtotal => lines.fold(0.0, (sum, l) => sum + l.subtotal);

  /// Total yang dibayar (barang + ongkir).
  double get total => subtotal + shippingCost;

  /// Jumlah seluruh barang dalam pesanan.
  int get itemCount => lines.fold(0, (sum, l) => sum + l.quantity);

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.millisecondsSinceEpoch,
        'lines': lines.map((l) => l.toJson()).toList(),
        'shippingCost': shippingCost,
        'shippingMethod': shippingMethod,
        'paymentMethod': paymentMethod,
        'address': address,
        'status': status.dbValue,
      };

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        id: json['id'] as String,
        date: DateTime.fromMillisecondsSinceEpoch(json['date'] as int),
        lines: (json['lines'] as List<dynamic>)
            .map((e) => OrderLine.fromJson(e as Map<String, dynamic>))
            .toList(),
        shippingCost: (json['shippingCost'] as num).toDouble(),
        shippingMethod: json['shippingMethod'] as String,
        paymentMethod: json['paymentMethod'] as String,
        address: json['address'] as String,
        status: OrderStatus.fromDb(json['status'] as String),
      );

  /// Membangun [Order] dari baris tabel `orders` Supabase (kolom snake_case)
  /// yang sudah meng-embed `order_items(*)`.
  factory Order.fromSupabaseMap(Map<String, dynamic> map) {
    final lines = (map['order_items'] as List? ?? [])
        .map((e) => OrderLine(
              productId: e['product_id'] as String,
              name: e['name'] as String,
              emoji: e['emoji'] as String,
              price: (e['price'] as num).toDouble(),
              quantity: (e['quantity'] as num).toInt(),
            ))
        .toList();

    return Order(
      id: map['id'] as String,
      date: DateTime.parse(map['date'] as String),
      lines: lines,
      shippingCost: (map['shipping_cost'] as num).toDouble(),
      shippingMethod: map['shipping_method'] as String,
      paymentMethod: map['payment_method'] as String,
      address: map['address'] as String,
      status: OrderStatus.fromDb(map['status'] as String),
      paymentProofUrl: map['payment_proof_url'] as String?,
    );
  }
}

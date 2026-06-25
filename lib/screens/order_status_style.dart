import 'package:flutter/material.dart';

import '../models/order.dart';

/// Warna penanda untuk tiap status pesanan.
Color orderStatusColor(OrderStatus status) => switch (status) {
      OrderStatus.menungguPembayaran => const Color(0xFF8B5CF6),
      OrderStatus.diproses => const Color(0xFFFF9F43),
      OrderStatus.dikirim => const Color(0xFF3B82F6),
      OrderStatus.selesai => const Color(0xFF10B981),
      OrderStatus.dibatalkan => const Color(0xFFFF4D67),
    };

/// Ikon untuk tiap status pesanan.
IconData orderStatusIcon(OrderStatus status) => switch (status) {
      OrderStatus.menungguPembayaran => Icons.account_balance_wallet_outlined,
      OrderStatus.diproses => Icons.hourglass_top_rounded,
      OrderStatus.dikirim => Icons.local_shipping_outlined,
      OrderStatus.selesai => Icons.check_circle_outline,
      OrderStatus.dibatalkan => Icons.cancel_outlined,
    };

/// Keterangan singkat di bawah label status.
String orderStatusHint(OrderStatus status) => switch (status) {
      OrderStatus.menungguPembayaran =>
        'Selesaikan transfer & unggah bukti pembayaran.',
      OrderStatus.diproses => 'Pesanan sedang kami siapkan.',
      OrderStatus.dikirim => 'Pesanan dalam perjalanan ke alamatmu.',
      OrderStatus.selesai => 'Pesanan telah selesai. Terima kasih!',
      OrderStatus.dibatalkan => 'Pesanan ini dibatalkan.',
    };

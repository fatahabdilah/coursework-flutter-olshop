import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/order.dart';

/// Menyimpan riwayat pesanan pengguna yang login di Supabase
/// (tabel `orders` + `order_items`). Pesanan terbaru berada di urutan pertama.
class OrdersProvider extends ChangeNotifier {
  final SupabaseClient _client = Supabase.instance.client;
  late final StreamSubscription<AuthState> _authSub;

  final List<Order> _orders = [];

  OrdersProvider() {
    _authSub = _client.auth.onAuthStateChange.listen((state) {
      if (state.session != null) {
        load();
      } else {
        _orders.clear();
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _authSub.cancel();
    super.dispose();
  }

  String? get _userId => _client.auth.currentUser?.id;

  List<Order> get orders => List.unmodifiable(_orders);

  bool get isEmpty => _orders.isEmpty;

  int get count => _orders.length;

  Future<void> load() async {
    final uid = _userId;
    if (uid == null) return;
    try {
      final rows = await _client
          .from('orders')
          .select('*, order_items(*)')
          .eq('user_id', uid)
          .order('date', ascending: false);
      _orders
        ..clear()
        ..addAll((rows as List)
            .map((e) => Order.fromSupabaseMap(e as Map<String, dynamic>)));
      notifyListeners();
    } catch (_) {
      // Abaikan kegagalan muat.
    }
  }

  /// Menyimpan pesanan baru beserta item-itemnya ke Supabase.
  Future<void> addOrder(Order order) async {
    final uid = _userId;
    if (uid == null) return;

    await _client.from('orders').insert({
      'id': order.id,
      'user_id': uid,
      'date': order.date.toIso8601String(),
      'shipping_cost': order.shippingCost,
      'shipping_method': order.shippingMethod,
      'payment_method': order.paymentMethod,
      'address': order.address,
      'status': order.status.dbValue,
    });

    await _client.from('order_items').insert(
          order.lines
              .map((l) => {
                    'order_id': order.id,
                    'product_id': l.productId,
                    'name': l.name,
                    'emoji': l.emoji,
                    'price': l.price,
                    'quantity': l.quantity,
                  })
              .toList(),
        );

    _orders.insert(0, order);
    notifyListeners();
  }

  /// Mengunggah gambar bukti transfer ke Supabase Storage lalu menyimpan
  /// URL-nya di pesanan. Mengembalikan URL publik gambar.
  Future<String> uploadPaymentProof(
    String orderId,
    Uint8List bytes,
    String fileExt,
  ) async {
    final uid = _userId;
    if (uid == null) throw StateError('Belum login');

    final ext = fileExt.isEmpty ? 'jpg' : fileExt;
    final path = '$uid/$orderId.$ext';
    final storage = _client.storage.from('payment-proofs');

    await storage.uploadBinary(
      path,
      bytes,
      fileOptions: FileOptions(upsert: true, contentType: 'image/$ext'),
    );
    // Tambah query agar URL berubah saat gambar di-upload ulang (hindari cache).
    final url =
        '${storage.getPublicUrl(path)}?t=${DateTime.now().millisecondsSinceEpoch}';

    await _client
        .from('orders')
        .update({'payment_proof_url': url}).eq('id', orderId);

    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      _orders[index] = _orders[index].copyWith(paymentProofUrl: url);
      notifyListeners();
    }
    return url;
  }
}

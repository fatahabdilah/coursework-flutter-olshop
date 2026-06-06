// Memastikan riwayat pesanan tersimpan & dimuat kembali antar sesi.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:olshop/models/order.dart';
import 'package:olshop/providers/orders_provider.dart';

Order _sampleOrder() => Order(
      id: 'INV123',
      date: DateTime.fromMillisecondsSinceEpoch(1700000000000),
      lines: const [
        OrderLine(
          productId: 'e1',
          name: 'Wireless Headphone Pro',
          emoji: '🎧',
          price: 850000,
          quantity: 2,
        ),
      ],
      shippingCost: 20000,
      shippingMethod: 'Reguler',
      paymentMethod: 'Transfer Bank',
      address: 'Rumah • Fatah',
    );

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('Pesanan dimuat kembali setelah aplikasi dibuka ulang', () async {
    final orders1 = OrdersProvider();
    await Future<void>.delayed(Duration.zero); // tunggu _load() awal
    orders1.addOrder(_sampleOrder());
    await Future<void>.delayed(Duration.zero); // tunggu _save()

    final orders2 = OrdersProvider();
    await Future<void>.delayed(Duration.zero);

    expect(orders2.count, 1);
    final loaded = orders2.orders.first;
    expect(loaded.id, 'INV123');
    expect(loaded.itemCount, 2);
    expect(loaded.subtotal, 1700000);
    expect(loaded.total, 1720000);
    expect(loaded.status, OrderStatus.diproses);
    expect(loaded.lines.first.name, 'Wireless Headphone Pro');
  });

  test('Pesanan terbaru berada di urutan pertama', () async {
    final orders = OrdersProvider();
    await Future<void>.delayed(Duration.zero);

    orders.addOrder(_sampleOrder());
    orders.addOrder(
      Order(
        id: 'INV999',
        date: DateTime.fromMillisecondsSinceEpoch(1700000100000),
        lines: const [
          OrderLine(
            productId: 'f1',
            name: 'Kaos Premium Cotton',
            emoji: '👕',
            price: 120000,
            quantity: 1,
          ),
        ],
        shippingCost: 40000,
        shippingMethod: 'Express',
        paymentMethod: 'COD',
        address: 'Rumah • Fatah',
      ),
    );
    await Future<void>.delayed(Duration.zero);

    expect(orders.orders.first.id, 'INV999');
    expect(orders.orders.last.id, 'INV123');
  });
}

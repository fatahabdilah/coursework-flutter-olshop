// Test model murni (tanpa backend): pemetaan Product & perhitungan Order.

import 'package:flutter_test/flutter_test.dart';

import 'package:olshop/models/order.dart';
import 'package:olshop/models/product.dart';

void main() {
  group('Product', () {
    test('fromMap memetakan kolom Supabase (snake_case) dengan benar', () {
      final p = Product.fromMap({
        'id': 'e1',
        'name': 'Headphone',
        'description': 'Mantap',
        'price': 850000,
        'old_price': 1100000,
        'category': 'Elektronik',
        'emoji': '🎧',
        'rating': 4.8,
        'sold': 1243,
        'stock': 80,
      });

      expect(p.id, 'e1');
      expect(p.price, 850000);
      expect(p.oldPrice, 1100000);
      expect(p.isDiscounted, isTrue);
      expect(p.discountPercent, 23);
    });

    test('fromMap menangani old_price null & memberi nilai default', () {
      final p = Product.fromMap({
        'id': 'x1',
        'name': 'Tanpa diskon',
        'price': 1000,
        'category': 'Lain',
      });

      expect(p.oldPrice, isNull);
      expect(p.isDiscounted, isFalse);
      expect(p.discountPercent, 0);
      expect(p.emoji, '📦');
      expect(p.rating, 4.5);
      expect(p.stock, 0);
    });

    test('toMap tidak menyertakan id (dibuat otomatis saat insert)', () {
      const p = Product(
        id: 'abc',
        name: 'Produk',
        description: 'desc',
        price: 5000,
        category: 'Fashion',
        emoji: '👕',
      );

      final map = p.toMap();
      expect(map.containsKey('id'), isFalse);
      expect(map['name'], 'Produk');
      expect(map['old_price'], isNull);
      expect(map['category'], 'Fashion');
    });
  });

  group('Order', () {
    Order sample() => Order(
          id: 'INV1',
          date: DateTime.fromMillisecondsSinceEpoch(1700000000000),
          shippingCost: 20000,
          shippingMethod: 'Reguler',
          paymentMethod: 'Transfer Bank',
          address: 'Rumah',
          lines: const [
            OrderLine(
              productId: 'e1',
              name: 'Headphone',
              emoji: '🎧',
              price: 850000,
              quantity: 2,
            ),
            OrderLine(
              productId: 'm1',
              name: 'Kopi',
              emoji: '☕',
              price: 85000,
              quantity: 1,
            ),
          ],
        );

    test('subtotal, total, dan itemCount dihitung benar', () {
      final o = sample();
      expect(o.subtotal, 1785000);
      expect(o.total, 1805000);
      expect(o.itemCount, 3);
      expect(o.status, OrderStatus.diproses);
    });
  });
}

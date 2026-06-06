// Memastikan keranjang & favorit benar-benar tersimpan antar sesi.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:olshop/data/sample_data.dart';
import 'package:olshop/providers/cart_provider.dart';
import 'package:olshop/providers/favorites_provider.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('Keranjang dimuat kembali setelah aplikasi dibuka ulang', () async {
    final product = kProducts.first;

    // Sesi pertama: tambah item ke keranjang.
    final cart1 = CartProvider();
    await Future<void>.delayed(Duration.zero); // tunggu _load() awal
    cart1.add(product, qty: 3);
    await Future<void>.delayed(Duration.zero); // tunggu _save()

    // Sesi kedua: provider baru harus memuat data yang tersimpan.
    final cart2 = CartProvider();
    await Future<void>.delayed(Duration.zero);

    expect(cart2.items.length, 1);
    expect(cart2.quantityOf(product.id), 3);
    expect(cart2.totalQuantity, 3);
  });

  test('Favorit dimuat kembali setelah aplikasi dibuka ulang', () async {
    final product = kProducts.first;

    final fav1 = FavoritesProvider();
    await Future<void>.delayed(Duration.zero);
    fav1.toggle(product.id);
    await Future<void>.delayed(Duration.zero);

    final fav2 = FavoritesProvider();
    await Future<void>.delayed(Duration.zero);

    expect(fav2.isFavorite(product.id), isTrue);
    expect(fav2.count, 1);
  });
}

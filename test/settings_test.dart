// SettingsProvider tetap memakai SharedPreferences (preferensi lokal),
// jadi bisa diuji tanpa backend.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:olshop/providers/settings_provider.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('Preferensi pengaturan tersimpan & dimuat kembali', () async {
    final s1 = SettingsProvider();
    await Future<void>.delayed(Duration.zero);
    s1.setPaymentMethod('E-Wallet');
    s1.setNotifPromo(false);
    s1.setNotifNewProduct(true);
    await Future<void>.delayed(Duration.zero);

    final s2 = SettingsProvider();
    await Future<void>.delayed(Duration.zero);
    expect(s2.paymentMethod, 'E-Wallet');
    expect(s2.notifPromo, isFalse);
    expect(s2.notifNewProduct, isTrue);
    expect(s2.notifOrder, isTrue); // default tak berubah
  });
}

// Memastikan provider halaman profil (alamat & pengaturan) bekerja & persisten.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:olshop/models/address.dart';
import 'package:olshop/providers/address_provider.dart';
import 'package:olshop/providers/settings_provider.dart';

Address _addr(String id, {bool isDefault = false}) => Address(
      id: id,
      label: 'Kantor',
      recipient: 'Fatah',
      phone: '0812',
      detail: 'Jl. Contoh No. $id',
      isDefault: isDefault,
    );

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('Alamat contoh dibuat saat pertama kali & menjadi utama', () async {
    final provider = AddressProvider();
    await Future<void>.delayed(Duration.zero);

    expect(provider.count, 1);
    expect(provider.defaultAddress, isNotNull);
    expect(provider.defaultAddress!.isDefault, isTrue);
  });

  test('Hanya ada satu alamat utama setelah setDefault', () async {
    final provider = AddressProvider();
    await Future<void>.delayed(Duration.zero);

    provider.add(_addr('a'));
    provider.add(_addr('b'));
    provider.setDefault('b');

    final defaults = provider.addresses.where((a) => a.isDefault).toList();
    expect(defaults.length, 1);
    expect(defaults.first.id, 'b');
  });

  test('Menghapus alamat utama memindahkan status utama ke yang tersisa',
      () async {
    final provider = AddressProvider();
    await Future<void>.delayed(Duration.zero);

    // Hapus alamat seed agar daftar bersih.
    for (final a in provider.addresses.toList()) {
      provider.remove(a.id);
    }
    provider.add(_addr('a', isDefault: true));
    provider.add(_addr('b'));
    provider.remove('a');

    expect(provider.count, 1);
    expect(provider.addresses.first.isDefault, isTrue);
  });

  test('Alamat dimuat kembali antar sesi', () async {
    final p1 = AddressProvider();
    await Future<void>.delayed(Duration.zero);
    p1.add(_addr('persist'));
    await Future<void>.delayed(Duration.zero);

    final p2 = AddressProvider();
    await Future<void>.delayed(Duration.zero);
    expect(p2.addresses.any((a) => a.id == 'persist'), isTrue);
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

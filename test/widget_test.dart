// Smoke test dasar untuk aplikasi Olshop.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:olshop/main.dart';

void main() {
  setUp(() {
    // Provider memuat keranjang & favorit dari SharedPreferences; sediakan
    // penyimpanan kosong tiruan agar getInstance() berfungsi di lingkungan tes.
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Aplikasi tampil dengan navigasi utama',
      (WidgetTester tester) async {
    await tester.pumpWidget(const OlshopApp());
    await tester.pumpAndSettle();

    // Beranda menampilkan judul sapaan.
    expect(find.text('Mau belanja apa hari ini?'), findsOneWidget);

    // Navigasi bawah tersedia.
    expect(find.text('Beranda'), findsOneWidget);
    expect(find.text('Keranjang'), findsOneWidget);

    // Pindah ke tab Keranjang menampilkan kondisi kosong.
    await tester.tap(find.text('Keranjang'));
    await tester.pumpAndSettle();
    expect(find.text('Keranjang masih kosong'), findsOneWidget);
  });

  testWidgets('Profil membuka halaman Pesanan Saya',
      (WidgetTester tester) async {
    await tester.pumpWidget(const OlshopApp());
    await tester.pumpAndSettle();

    // Buka tab Profil lalu menu Pesanan Saya.
    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pesanan Saya'));
    await tester.pumpAndSettle();

    // Halaman pesanan tampil dengan kondisi kosong.
    expect(find.text('Belum ada pesanan'), findsOneWidget);
  });
}

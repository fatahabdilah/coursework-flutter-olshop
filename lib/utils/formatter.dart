import 'package:intl/intl.dart';

final NumberFormat _rupiah = NumberFormat.currency(
  locale: 'id_ID',
  symbol: 'Rp ',
  decimalDigits: 0,
);

/// Format angka menjadi string Rupiah, mis. `1500000` -> `Rp 1.500.000`.
String formatRupiah(num value) => _rupiah.format(value);

const List<String> _monthsId = [
  'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
  'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
];

/// Format tanggal & jam dalam Bahasa Indonesia, mis. `5 Jun 2026 • 14:30`.
String formatDateTime(DateTime dt) {
  final hour = dt.hour.toString().padLeft(2, '0');
  final minute = dt.minute.toString().padLeft(2, '0');
  return '${dt.day} ${_monthsId[dt.month - 1]} ${dt.year} • $hour:$minute';
}

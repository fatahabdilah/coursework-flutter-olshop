import 'package:flutter/material.dart';

/// Satu opsi metode pembayaran yang tersedia.
class PaymentOption {
  final String name;
  final String description;
  final IconData icon;

  const PaymentOption({
    required this.name,
    required this.description,
    required this.icon,
  });
}

/// Daftar metode pembayaran yang didukung toko.
const List<PaymentOption> kPaymentMethods = [
  PaymentOption(
    name: 'Transfer Bank',
    description: 'BCA, Mandiri, BNI, BRI',
    icon: Icons.account_balance_outlined,
  ),
  PaymentOption(
    name: 'E-Wallet',
    description: 'GoPay, OVO, DANA, ShopeePay',
    icon: Icons.account_balance_wallet_outlined,
  ),
  PaymentOption(
    name: 'Kartu Kredit/Debit',
    description: 'Visa, Mastercard, JCB',
    icon: Icons.credit_card_outlined,
  ),
  PaymentOption(
    name: 'COD',
    description: 'Bayar tunai saat barang tiba',
    icon: Icons.local_shipping_outlined,
  ),
];

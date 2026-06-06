import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Menyimpan preferensi akun: metode pembayaran utama dan pengaturan
/// notifikasi. Semuanya dipertahankan antar sesi (persisten).
class SettingsProvider extends ChangeNotifier {
  static const _kPayment = 'pref_payment_method';
  static const _kNotifPromo = 'pref_notif_promo';
  static const _kNotifOrder = 'pref_notif_order';
  static const _kNotifNewProduct = 'pref_notif_new_product';
  static const _kNotifSound = 'pref_notif_sound';

  SharedPreferences? _prefs;

  String _paymentMethod = 'Transfer Bank';
  bool _notifPromo = true;
  bool _notifOrder = true;
  bool _notifNewProduct = false;
  bool _notifSound = true;

  SettingsProvider() {
    _load();
  }

  String get paymentMethod => _paymentMethod;
  bool get notifPromo => _notifPromo;
  bool get notifOrder => _notifOrder;
  bool get notifNewProduct => _notifNewProduct;
  bool get notifSound => _notifSound;

  void setPaymentMethod(String value) {
    _paymentMethod = value;
    notifyListeners();
    _prefs?.setString(_kPayment, value);
  }

  void setNotifPromo(bool value) {
    _notifPromo = value;
    notifyListeners();
    _prefs?.setBool(_kNotifPromo, value);
  }

  void setNotifOrder(bool value) {
    _notifOrder = value;
    notifyListeners();
    _prefs?.setBool(_kNotifOrder, value);
  }

  void setNotifNewProduct(bool value) {
    _notifNewProduct = value;
    notifyListeners();
    _prefs?.setBool(_kNotifNewProduct, value);
  }

  void setNotifSound(bool value) {
    _notifSound = value;
    notifyListeners();
    _prefs?.setBool(_kNotifSound, value);
  }

  Future<void> _load() async {
    _prefs = await SharedPreferences.getInstance();
    _paymentMethod = _prefs!.getString(_kPayment) ?? _paymentMethod;
    _notifPromo = _prefs!.getBool(_kNotifPromo) ?? _notifPromo;
    _notifOrder = _prefs!.getBool(_kNotifOrder) ?? _notifOrder;
    _notifNewProduct = _prefs!.getBool(_kNotifNewProduct) ?? _notifNewProduct;
    _notifSound = _prefs!.getBool(_kNotifSound) ?? _notifSound;
    notifyListeners();
  }
}

/// Alamat pengiriman milik pengguna.
class Address {
  final String id;

  /// Label singkat, mis. "Rumah" atau "Kantor".
  final String label;
  final String recipient;
  final String phone;

  /// Alamat lengkap (jalan, kota, kode pos).
  final String detail;

  /// Apakah ini alamat utama yang dipakai secara default.
  final bool isDefault;

  const Address({
    required this.id,
    required this.label,
    required this.recipient,
    required this.phone,
    required this.detail,
    this.isDefault = false,
  });

  Address copyWith({
    String? label,
    String? recipient,
    String? phone,
    String? detail,
    bool? isDefault,
  }) {
    return Address(
      id: id,
      label: label ?? this.label,
      recipient: recipient ?? this.recipient,
      phone: phone ?? this.phone,
      detail: detail ?? this.detail,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'recipient': recipient,
        'phone': phone,
        'detail': detail,
        'isDefault': isDefault,
      };

  factory Address.fromJson(Map<String, dynamic> json) => Address(
        id: json['id'] as String,
        label: json['label'] as String,
        recipient: json['recipient'] as String,
        phone: json['phone'] as String,
        detail: json['detail'] as String,
        isDefault: json['isDefault'] as bool? ?? false,
      );
}

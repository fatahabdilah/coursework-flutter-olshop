import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/address.dart';
import '../providers/address_provider.dart';
import '../theme/app_theme.dart';

/// Form untuk menambah atau menyunting alamat.
///
/// Jika [existing] diberikan, form berperan sebagai edit; jika `null`, tambah.
class AddressFormScreen extends StatefulWidget {
  final Address? existing;

  const AddressFormScreen({super.key, this.existing});

  @override
  State<AddressFormScreen> createState() => _AddressFormScreenState();
}

class _AddressFormScreenState extends State<AddressFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _label;
  late final TextEditingController _recipient;
  late final TextEditingController _phone;
  late final TextEditingController _detail;
  late bool _isDefault;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final a = widget.existing;
    _label = TextEditingController(text: a?.label ?? '');
    _recipient = TextEditingController(text: a?.recipient ?? '');
    _phone = TextEditingController(text: a?.phone ?? '');
    _detail = TextEditingController(text: a?.detail ?? '');
    _isDefault = a?.isDefault ?? false;
  }

  @override
  void dispose() {
    _label.dispose();
    _recipient.dispose();
    _phone.dispose();
    _detail.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<AddressProvider>();
    if (_isEditing) {
      provider.update(
        widget.existing!.copyWith(
          label: _label.text.trim(),
          recipient: _recipient.text.trim(),
          phone: _phone.text.trim(),
          detail: _detail.text.trim(),
          isDefault: _isDefault,
        ),
      );
    } else {
      provider.add(
        Address(
          id: 'addr-${DateTime.now().millisecondsSinceEpoch}',
          label: _label.text.trim(),
          recipient: _recipient.text.trim(),
          phone: _phone.text.trim(),
          detail: _detail.text.trim(),
          isDefault: _isDefault,
        ),
      );
    }
    Navigator.of(context).pop();
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) return 'Wajib diisi';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Ubah Alamat' : 'Tambah Alamat'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            _Field(
              controller: _label,
              label: 'Label Alamat',
              hint: 'Rumah, Kantor, Kos...',
              validator: _required,
            ),
            _Field(
              controller: _recipient,
              label: 'Nama Penerima',
              hint: 'Nama lengkap penerima',
              validator: _required,
            ),
            _Field(
              controller: _phone,
              label: 'Nomor Telepon',
              hint: '08xxxxxxxxxx',
              keyboardType: TextInputType.phone,
              validator: _required,
            ),
            _Field(
              controller: _detail,
              label: 'Alamat Lengkap',
              hint: 'Jalan, nomor, kota, kode pos',
              maxLines: 3,
              validator: _required,
            ),
            const SizedBox(height: 4),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: SwitchListTile(
                value: _isDefault,
                onChanged: (v) => setState(() => _isDefault = v),
                activeThumbColor: AppTheme.seed,
                title: const Text(
                  'Jadikan alamat utama',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text('Dipakai sebagai default saat checkout'),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: FilledButton(
            onPressed: _save,
            child: Text(_isEditing ? 'Simpan Perubahan' : 'Simpan Alamat'),
          ),
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final int maxLines;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _Field({
    required this.controller,
    required this.label,
    required this.hint,
    this.maxLines = 1,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: AppTheme.ink,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            validator: validator,
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppTheme.seed, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

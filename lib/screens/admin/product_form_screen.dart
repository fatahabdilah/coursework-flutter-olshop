import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/categories.dart';
import '../../models/product.dart';
import '../../providers/products_provider.dart';
import '../../theme/app_theme.dart';

/// Form tambah / ubah produk untuk admin.
class ProductFormScreen extends StatefulWidget {
  final Product? existing;

  const ProductFormScreen({super.key, this.existing});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _name;
  late final TextEditingController _description;
  late final TextEditingController _price;
  late final TextEditingController _oldPrice;
  late final TextEditingController _emoji;
  late final TextEditingController _stock;
  late final TextEditingController _rating;
  late final TextEditingController _sold;
  late String _category;
  bool _saving = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final p = widget.existing;
    _name = TextEditingController(text: p?.name ?? '');
    _description = TextEditingController(text: p?.description ?? '');
    _price = TextEditingController(text: p?.price.toStringAsFixed(0) ?? '');
    _oldPrice =
        TextEditingController(text: p?.oldPrice?.toStringAsFixed(0) ?? '');
    _emoji = TextEditingController(text: p?.emoji ?? '📦');
    _stock = TextEditingController(text: p?.stock.toString() ?? '0');
    _rating = TextEditingController(text: p?.rating.toString() ?? '4.5');
    _sold = TextEditingController(text: p?.sold.toString() ?? '0');
    _category = p?.category ?? kCategories.first.name;
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _price.dispose();
    _oldPrice.dispose();
    _emoji.dispose();
    _stock.dispose();
    _rating.dispose();
    _sold.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final oldPriceText = _oldPrice.text.trim();
    final product = Product(
      id: widget.existing?.id ?? '',
      name: _name.text.trim(),
      description: _description.text.trim(),
      price: double.parse(_price.text.trim()),
      oldPrice: oldPriceText.isEmpty ? null : double.parse(oldPriceText),
      category: _category,
      emoji: _emoji.text.trim().isEmpty ? '📦' : _emoji.text.trim(),
      rating: double.tryParse(_rating.text.trim()) ?? 4.5,
      sold: int.tryParse(_sold.text.trim()) ?? 0,
      stock: int.tryParse(_stock.text.trim()) ?? 0,
    );

    final provider = context.read<ProductsProvider>();
    try {
      if (_isEditing) {
        await provider.updateProduct(widget.existing!.id, product);
      } else {
        await provider.addProduct(product);
      }
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text('Gagal menyimpan: $e')));
    }
  }

  String? _requiredNumber(String? v) {
    if (v == null || v.trim().isEmpty) return 'Wajib diisi';
    if (double.tryParse(v.trim()) == null) return 'Harus angka';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Ubah Produk' : 'Tambah Produk'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            _Field(
              controller: _name,
              label: 'Nama Produk',
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
            ),
            _DropdownField(
              label: 'Kategori',
              value: _category,
              items: kCategories.map((c) => c.name).toList(),
              onChanged: (v) => setState(() => _category = v),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _Field(
                    controller: _price,
                    label: 'Harga',
                    keyboardType: TextInputType.number,
                    validator: _requiredNumber,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _Field(
                    controller: _oldPrice,
                    label: 'Harga Coret (ops.)',
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 90,
                  child: _Field(
                    controller: _emoji,
                    label: 'Emoji',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _Field(
                    controller: _stock,
                    label: 'Stok',
                    keyboardType: TextInputType.number,
                    validator: _requiredNumber,
                  ),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _Field(
                    controller: _rating,
                    label: 'Rating',
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _Field(
                    controller: _sold,
                    label: 'Terjual',
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            _Field(
              controller: _description,
              label: 'Deskripsi',
              maxLines: 4,
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
            onPressed: _saving ? null : _save,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
            ),
            child: _saving
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : Text(_isEditing ? 'Simpan Perubahan' : 'Tambah Produk'),
          ),
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final int maxLines;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _Field({
    required this.controller,
    required this.label,
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

class _DropdownField extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;

  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
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
          DropdownButtonFormField<String>(
            initialValue: value,
            items: items
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (v) => onChanged(v ?? value),
            decoration: InputDecoration(
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
            ),
          ),
        ],
      ),
    );
  }
}

// Variant Form Card Widget
// Displays one product variant's editable fields inline within the product form.
// Used by AdminProductFormScreen to manage the list of variants.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../../features/catalog/domain/models/product_variant.dart';

class VariantFormCard extends StatefulWidget {
  /// The variant to display. May be a temporary (unsaved) object with id starting with "temp_".
  final ProductVariant variant;

  /// Called whenever any field is changed, passing the updated variant.
  final ValueChanged<ProductVariant> onChanged;

  /// Called when the user requests to remove this variant.
  final VoidCallback onRemove;

  const VariantFormCard({
    Key? key,
    required this.variant,
    required this.onChanged,
    required this.onRemove,
  }) : super(key: key);

  @override
  State<VariantFormCard> createState() => _VariantFormCardState();
}

class _VariantFormCardState extends State<VariantFormCard> {
  late final TextEditingController _skuCtrl;
  late final TextEditingController _sizeCtrl;
  late final TextEditingController _colorNameCtrl;
  late final TextEditingController _colorHexCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _compareAtCtrl;
  late final TextEditingController _stockCtrl;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    final v = widget.variant;
    _skuCtrl = TextEditingController(text: v.sku);
    _sizeCtrl = TextEditingController(text: v.size ?? '');
    _colorNameCtrl = TextEditingController(text: v.colorName ?? '');
    _colorHexCtrl = TextEditingController(text: v.colorHex ?? '');
    _priceCtrl = TextEditingController(text: v.price.toString());
    _compareAtCtrl = TextEditingController(
        text: v.compareAtPrice?.toString() ?? '');
    _stockCtrl = TextEditingController(text: v.stockQuantity.toString());
    _isActive = v.isActive;
  }

  @override
  void dispose() {
    _skuCtrl.dispose();
    _sizeCtrl.dispose();
    _colorNameCtrl.dispose();
    _colorHexCtrl.dispose();
    _priceCtrl.dispose();
    _compareAtCtrl.dispose();
    _stockCtrl.dispose();
    super.dispose();
  }

  ProductVariant get _current => widget.variant.copyWith(
        sku: _skuCtrl.text.trim(),
        size: _sizeCtrl.text.trim().isEmpty ? null : _sizeCtrl.text.trim(),
        colorName: _colorNameCtrl.text.trim().isEmpty
            ? null
            : _colorNameCtrl.text.trim(),
        colorHex: _colorHexCtrl.text.trim().isEmpty
            ? null
            : _colorHexCtrl.text.trim(),
        price: int.tryParse(_priceCtrl.text.replaceAll('.', '')) ?? 0,
        compareAtPrice: _compareAtCtrl.text.trim().isEmpty
            ? null
            : int.tryParse(_compareAtCtrl.text.replaceAll('.', '')),
        stockQuantity:
            int.tryParse(_stockCtrl.text) ?? widget.variant.stockQuantity,
        isActive: _isActive,
      );

  void _notify() => widget.onChanged(_current);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header row ─────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Biến thể: ${widget.variant.sku.isEmpty ? "(mới)" : widget.variant.sku}',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Switch(
                  value: _isActive,
                  onChanged: (val) {
                    setState(() => _isActive = val);
                    _notify();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  tooltip: 'Xóa biến thể',
                  onPressed: widget.onRemove,
                ),
              ],
            ),
            const Divider(),
            // ── Fields row 1: SKU, Size, Color ─────────────────────────
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _field(
                  ctrl: _skuCtrl,
                  label: 'SKU *',
                  width: 160,
                  onChanged: (_) => _notify(),
                ),
                _field(
                  ctrl: _sizeCtrl,
                  label: 'Kích thước',
                  width: 100,
                  onChanged: (_) => _notify(),
                ),
                _field(
                  ctrl: _colorNameCtrl,
                  label: 'Tên màu',
                  width: 120,
                  onChanged: (_) => _notify(),
                ),
                _field(
                  ctrl: _colorHexCtrl,
                  label: 'Mã màu hex',
                  width: 120,
                  hintText: '#ffffff',
                  onChanged: (_) => _notify(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // ── Fields row 2: Price, Compare, Stock ────────────────────
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _field(
                  ctrl: _priceCtrl,
                  label: 'Giá bán (₫) *',
                  width: 140,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (_) => _notify(),
                ),
                _field(
                  ctrl: _compareAtCtrl,
                  label: 'Giá gốc (₫)',
                  width: 140,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (_) => _notify(),
                ),
                _field(
                  ctrl: _stockCtrl,
                  label: 'Tồn kho',
                  width: 100,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (_) => _notify(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController ctrl,
    required String label,
    required double width,
    String? hintText,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    required ValueChanged<String> onChanged,
  }) {
    return SizedBox(
      width: width,
      child: TextField(
        controller: ctrl,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          border: const OutlineInputBorder(),
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        ),
      ),
    );
  }
}

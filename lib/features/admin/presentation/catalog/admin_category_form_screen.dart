// Admin Category Form Screen
// Used for both creating a new category and editing an existing one.
// If [categoryId] is null, it creates; otherwise it loads and edits.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../features/catalog/data/catalog_providers.dart';
import '../../../../features/catalog/data/catalog_repository.dart';
import '../../../../features/catalog/domain/models/category.dart';

class AdminCategoryFormScreen extends ConsumerStatefulWidget {
  /// Pass null to create a new category; pass an existing id to edit.
  final String? categoryId;

  const AdminCategoryFormScreen({Key? key, this.categoryId}) : super(key: key);

  @override
  ConsumerState<AdminCategoryFormScreen> createState() =>
      _AdminCategoryFormScreenState();
}

class _AdminCategoryFormScreenState
    extends ConsumerState<AdminCategoryFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _slugCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _sortCtrl = TextEditingController(text: '0');

  bool _isActive = true;
  bool _loading = false;
  bool _initialized = false;

  Category? _original;

  bool get _isEditing => widget.categoryId != null;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _slugCtrl.dispose();
    _descCtrl.dispose();
    _sortCtrl.dispose();
    super.dispose();
  }

  void _populateFromCategory(Category cat) {
    _nameCtrl.text = cat.name;
    _slugCtrl.text = cat.slug;
    _descCtrl.text = cat.description ?? '';
    _sortCtrl.text = cat.sortOrder.toString();
    _isActive = cat.isActive;
    _original = cat;
    _initialized = true;
  }

  /// Auto-generate slug from name (lowercase, replace spaces/special chars)
  void _generateSlug(String name) {
    if (_isEditing && _initialized) return; // Don't auto-override when editing
    final slug = name
        .toLowerCase()
        .replaceAll(RegExp(r'[àáạảãâầấậẩẫăằắặẳẵ]'), 'a')
        .replaceAll(RegExp(r'[èéẹẻẽêềếệểễ]'), 'e')
        .replaceAll(RegExp(r'[ìíịỉĩ]'), 'i')
        .replaceAll(RegExp(r'[òóọỏõôồốộổỗơờớợởỡ]'), 'o')
        .replaceAll(RegExp(r'[ùúụủũưừứựửữ]'), 'u')
        .replaceAll(RegExp(r'[ỳýỵỷỹ]'), 'y')
        .replaceAll('đ', 'd')
        .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
        .trim()
        .replaceAll(RegExp(r'\s+'), '-');
    _slugCtrl.text = slug;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      final repo = ref.read(catalogRepositoryProvider);

      if (_isEditing && _original != null) {
        final updated = _original!.copyWith(
          name: _nameCtrl.text.trim(),
          slug: _slugCtrl.text.trim(),
          description: _descCtrl.text.trim().isEmpty
              ? null
              : _descCtrl.text.trim(),
          sortOrder: int.tryParse(_sortCtrl.text) ?? 0,
          isActive: _isActive,
        );
        await repo.updateCategory(updated);
      } else {
        final now = DateTime.now();
        final cat = Category(
          id: '',
          name: _nameCtrl.text.trim(),
          slug: _slugCtrl.text.trim(),
          description:
              _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
          sortOrder: int.tryParse(_sortCtrl.text) ?? 0,
          isActive: _isActive,
          createdAt: now,
          updatedAt: now,
        );
        await repo.createCategory(cat);
      }

      // Invalidate cache so the list screen refreshes.
      ref.invalidate(adminCategoriesProvider);
      ref.invalidate(activeCategoriesProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing ? 'Đã cập nhật danh mục' : 'Đã tạo danh mục',
            ),
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // If editing, load the category data when not yet initialized.
    if (_isEditing && !_initialized) {
      final catAsync =
          ref.watch(adminCategoriesProvider);
      catAsync.whenData((cats) {
        final match = cats.where((c) => c.id == widget.categoryId).firstOrNull;
        if (match != null && !_initialized) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() => _populateFromCategory(match));
            }
          });
        }
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Chỉnh sửa danh mục' : 'Tạo danh mục mới'),
        actions: [
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            TextButton(
              onPressed: _save,
              child: const Text('Lưu'),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Name ─────────────────────────────────────────────────
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Tên danh mục *',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: _generateSlug,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Bắt buộc' : null,
                ),
                const SizedBox(height: 16),
                // ── Slug ─────────────────────────────────────────────────
                TextFormField(
                  controller: _slugCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Slug (URL) *',
                    hintText: 'vi-du-ao-thun',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Bắt buộc' : null,
                ),
                const SizedBox(height: 16),
                // ── Description ──────────────────────────────────────────
                TextFormField(
                  controller: _descCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Mô tả',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                // ── Sort order & active ───────────────────────────────────
                Row(
                  children: [
                    SizedBox(
                      width: 140,
                      child: TextFormField(
                        controller: _sortCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Thứ tự hiển thị',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: SwitchListTile(
                        title: const Text('Hiển thị công khai'),
                        value: _isActive,
                        onChanged: (v) => setState(() => _isActive = v),
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

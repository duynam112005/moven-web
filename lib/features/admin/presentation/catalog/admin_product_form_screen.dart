// Admin Product Form Screen
// Used for both creating a new product and editing an existing one.
// Manages product metadata, variants (via VariantFormCard), and images (via ImageUploadGrid).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../features/catalog/data/catalog_providers.dart';
import '../../../../features/catalog/data/catalog_repository.dart';
import '../../../../features/catalog/domain/models/product.dart';
import '../../../../features/catalog/domain/models/product_image.dart';
import '../../../../features/catalog/domain/models/product_variant.dart';
import 'widgets/image_upload_grid.dart';
import 'widgets/variant_form_card.dart';

class AdminProductFormScreen extends ConsumerStatefulWidget {
  /// Null when creating, non-null when editing.
  final String? productId;

  const AdminProductFormScreen({Key? key, this.productId}) : super(key: key);

  @override
  ConsumerState<AdminProductFormScreen> createState() =>
      _AdminProductFormScreenState();
}

class _AdminProductFormScreenState
    extends ConsumerState<AdminProductFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _slugCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _materialCtrl = TextEditingController();

  String _targetAudience = 'unisex';
  bool _isFeatured = false;
  bool _isActive = true;
  String? _categoryId;

  List<ProductVariant> _variants = [];
  List<ProductImage> _images = [];

  bool _loading = false;
  bool _initialized = false;
  Product? _original;

  bool get _isEditing => widget.productId != null;

  static const _audienceOptions = ['unisex', 'men', 'women'];
  static const _audienceLabels = {
    'unisex': 'Unisex',
    'men': 'Nam',
    'women': 'Nữ',
  };

  @override
  void dispose() {
    _nameCtrl.dispose();
    _slugCtrl.dispose();
    _descCtrl.dispose();
    _materialCtrl.dispose();
    super.dispose();
  }

  void _populateFromProduct(Product p) {
    _nameCtrl.text = p.name;
    _slugCtrl.text = p.slug;
    _descCtrl.text = p.description ?? '';
    _materialCtrl.text = p.material ?? '';
    _targetAudience = p.targetAudience;
    _isFeatured = p.isFeatured;
    _isActive = p.isActive;
    _categoryId = p.categoryId;
    _variants = List<ProductVariant>.from(p.variants);
    _images = List<ProductImage>.from(p.images);
    _original = p;
    _initialized = true;
  }

  void _generateSlug(String name) {
    if (_isEditing && _initialized) return;
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

  void _addVariant() {
    final now = DateTime.now();
    final tempId = 'temp_${now.millisecondsSinceEpoch}';
    setState(() {
      _variants.add(ProductVariant(
        id: tempId,
        productId: widget.productId ?? '',
        sku: '',
        price: 0,
        stockQuantity: 0,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ));
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_categoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn danh mục')),
      );
      return;
    }
    if (_variants.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sản phẩm cần ít nhất một biến thể')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final repo = ref.read(catalogRepositoryProvider);
      final now = DateTime.now();

      if (_isEditing && _original != null) {
        final updated = _original!.copyWith(
          categoryId: _categoryId!,
          name: _nameCtrl.text.trim(),
          slug: _slugCtrl.text.trim(),
          description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
          material: _materialCtrl.text.trim().isEmpty ? null : _materialCtrl.text.trim(),
          targetAudience: _targetAudience,
          isFeatured: _isFeatured,
          isActive: _isActive,
        );
        await repo.updateProduct(
          product: updated,
          variants: _variants,
          images: _images,
        );
      } else {
        final newProduct = Product(
          id: '',
          categoryId: _categoryId!,
          name: _nameCtrl.text.trim(),
          slug: _slugCtrl.text.trim(),
          description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
          material: _materialCtrl.text.trim().isEmpty ? null : _materialCtrl.text.trim(),
          targetAudience: _targetAudience,
          isFeatured: _isFeatured,
          isActive: _isActive,
          createdAt: now,
          updatedAt: now,
        );
        await repo.createProduct(
          product: newProduct,
          variants: _variants,
          images: _images,
        );
      }

      // Invalidate caches
      ref.invalidate(adminProductsProvider(const AdminProductQuery()));
      ref.invalidate(catalogProductsProvider);
      ref.invalidate(featuredProductsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? 'Đã cập nhật sản phẩm' : 'Đã tạo sản phẩm'),
          ),
        );
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('${RouteNames.adminCatalogPath}?tab=products');
        }
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

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xóa sản phẩm'),
        content: Text('Bạn có chắc chắn muốn xóa sản phẩm "${_nameCtrl.text}" không? Thao tác này không thể hoàn tác.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _loading = true);
    try {
      await ref.read(catalogRepositoryProvider).deleteProduct(widget.productId!);
      ref.invalidate(adminProductsProvider);
      ref.invalidate(catalogProductsProvider);
      ref.invalidate(featuredProductsProvider);
      ref.invalidate(activeCategoriesProvider);
      if (_original != null) {
        ref.invalidate(productDetailProvider(_original!.slug));
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã xóa sản phẩm thành công')),
        );
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('${RouteNames.adminCatalogPath}?tab=products');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Load existing product data when editing and not yet initialized.
    if (_isEditing && !_initialized) {
      final productAsync =
          ref.watch(adminProductDetailProvider(widget.productId!));
      productAsync.whenData((p) {
        if (p != null && !_initialized) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _populateFromProduct(p));
          });
        }
      });
    }

    final categoriesAsync = ref.watch(adminCategoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Chỉnh sửa sản phẩm' : 'Tạo sản phẩm mới'),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              tooltip: 'Xóa sản phẩm',
              onPressed: _loading ? null : _confirmDelete,
            ),
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
            TextButton(onPressed: _save, child: const Text('Lưu')),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 780),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Name & Slug ─────────────────────────────────────────
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Tên sản phẩm *',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: _generateSlug,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Bắt buộc' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _slugCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Slug *',
                    hintText: 'ao-thun-basic',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Bắt buộc' : null,
                ),
                const SizedBox(height: 16),
                // ── Category dropdown ────────────────────────────────────
                categoriesAsync.when(
                  loading: () => const LinearProgressIndicator(),
                  error: (e, _) =>
                      Text('Không thể tải danh mục: $e'),
                  data: (cats) => DropdownButtonFormField<String>(
                    value: _categoryId,
                    decoration: const InputDecoration(
                      labelText: 'Danh mục *',
                      border: OutlineInputBorder(),
                    ),
                    items: cats
                        .map((c) => DropdownMenuItem(
                              value: c.id,
                              child: Text(c.name),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => _categoryId = v),
                    validator: (v) => v == null ? 'Vui lòng chọn danh mục' : null,
                  ),
                ),
                const SizedBox(height: 16),
                // ── Description & Material ───────────────────────────────
                TextFormField(
                  controller: _descCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Mô tả',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 4,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _materialCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Chất liệu',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                // ── Target audience ──────────────────────────────────────
                DropdownButtonFormField<String>(
                  value: _targetAudience,
                  decoration: const InputDecoration(
                    labelText: 'Đối tượng',
                    border: OutlineInputBorder(),
                  ),
                  items: _audienceOptions
                      .map((a) => DropdownMenuItem(
                            value: a,
                            child: Text(_audienceLabels[a] ?? a),
                          ))
                      .toList(),
                  onChanged: (v) =>
                      setState(() => _targetAudience = v ?? 'unisex'),
                ),
                const SizedBox(height: 16),
                // ── Switches ─────────────────────────────────────────────
                SwitchListTile(
                  title: const Text('Sản phẩm nổi bật'),
                  value: _isFeatured,
                  onChanged: (v) => setState(() => _isFeatured = v),
                ),
                SwitchListTile(
                  title: const Text('Hiển thị công khai'),
                  value: _isActive,
                  onChanged: (v) => setState(() => _isActive = v),
                ),
                const Divider(height: 32),

                // ── Variants ─────────────────────────────────────────────
                Row(
                  children: [
                    Text(
                      'Biến thể sản phẩm',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Spacer(),
                    OutlinedButton.icon(
                      onPressed: _addVariant,
                      icon: const Icon(Icons.add),
                      label: const Text('Thêm biến thể'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (_variants.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      border: Border.all(color: Colors.orange.shade200),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.warning_amber_outlined, color: Colors.orange),
                        SizedBox(width: 8),
                        Text('Cần ít nhất một biến thể để lưu sản phẩm.'),
                      ],
                    ),
                  )
                else
                  ..._variants.asMap().entries.map((entry) {
                    final i = entry.key;
                    final v = entry.value;
                    return VariantFormCard(
                      key: ValueKey(v.id),
                      variant: v,
                      onChanged: (updated) {
                        setState(() => _variants[i] = updated);
                      },
                      onRemove: () {
                        setState(() => _variants.removeAt(i));
                      },
                    );
                  }),

                const Divider(height: 32),

                // ── Images ───────────────────────────────────────────────
                ImageUploadGrid(
                  images: _images,
                  productId: widget.productId ?? '',
                  onImagesChanged: (imgs) => setState(() => _images = imgs),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

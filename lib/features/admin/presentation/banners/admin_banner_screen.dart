// Admin Banner Screen
// CRUD interface for homepage banners.
// Shows a list of all banners (admin view, including inactive ones).
// Each item shows title, schedule window, active status, and actions (edit, delete).
// A FAB opens a dialog to create/edit a banner.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../features/catalog/data/catalog_providers.dart';
import '../../../../features/catalog/data/catalog_repository.dart';
import '../../../../features/catalog/data/storage_repository.dart';
import '../../../../features/catalog/domain/models/banner.dart';

// Conditional import: dart:html on web, stub on other platforms
import '../../../../core/utils/html_stub.dart'
    if (dart.library.html) 'dart:html' as html;

class AdminBannerScreen extends ConsumerWidget {
  const AdminBannerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bannersAsync = ref.watch(adminBannersProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(AppDimensions.space24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Quản trị Banner',
                        style: AppTypography.headlineMedium,
                      ),
                      const SizedBox(height: AppDimensions.space4),
                      Text(
                        'Cấu hình banner trình chiếu trang chủ, lịch hiển thị và liên kết đích',
                        style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppDimensions.space16),
                AppButton(
                  label: 'Tạo banner mới',
                  icon: const Icon(Icons.add, size: 18),
                  onPressed: () => _showBannerDialog(context, ref, null),
                ),
              ],
            ),

            const SizedBox(height: AppDimensions.space20),

            // 2. Banner List
            Expanded(
              child: bannersAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 8),
                      Text('Không tải được banner: $e'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => ref.refresh(adminBannersProvider),
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                ),
                data: (banners) {
                  if (banners.isEmpty) {
                    return const Center(child: Text('Chưa có banner nào'));
                  }
                  return RefreshIndicator(
                    onRefresh: () async => ref.refresh(adminBannersProvider),
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: banners.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, i) => _BannerCard(banner: banners[i]),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showBannerDialog(context, ref, null),
        icon: const Icon(Icons.add),
        label: const Text('Thêm banner'),
      ),
    );
  }

  static Future<void> _showBannerDialog(
    BuildContext context,
    WidgetRef ref,
    HomeBanner? existing,
  ) async {
    await showDialog(
      context: context,
      builder: (_) => _BannerDialog(existing: existing),
    );
    ref.invalidate(adminBannersProvider);
    ref.invalidate(activeBannersProvider);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BANNER CARD
// ─────────────────────────────────────────────────────────────────────────────

class _BannerCard extends ConsumerWidget {
  final HomeBanner banner;
  const _BannerCard({required this.banner});

  String _formatDate(DateTime? dt) {
    if (dt == null) return '—';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storageRepo = ref.read(storageRepositoryProvider);
    final imageUrl = storageRepo.getBannerImageUrl(banner.imagePath);

    return Card(
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: imageUrl.isNotEmpty
              ? Image.network(
                  imageUrl,
                  width: 64,
                  height: 48,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.broken_image_outlined),
                )
              : Container(
                  width: 64,
                  height: 48,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.image_outlined),
                ),
        ),
        title: Text(
          banner.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: banner.isActive ? null : Colors.grey,
          ),
        ),
        subtitle: Text(
          '${_formatDate(banner.startAt)} → ${_formatDate(banner.endAt)}'
          '  •  Thứ tự: ${banner.sortOrder}'
          '${banner.isActive ? '' : '  •  Đã ẩn'}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: banner.isActive,
              onChanged: (val) async {
                try {
                  final updated = banner.copyWith(isActive: val);
                  await ref.read(catalogRepositoryProvider).updateBanner(updated);
                  ref.invalidate(adminBannersProvider);
                  ref.invalidate(activeBannersProvider);
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Lỗi: $e')),
                    );
                  }
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Chỉnh sửa',
              onPressed: () {
                AdminBannerScreen._showBannerDialog(context, ref, banner);
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              tooltip: 'Xóa',
              onPressed: () => _confirmDelete(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xóa banner'),
        content: Text('Xóa banner "${banner.title}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Hủy')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Xóa', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      final repo = ref.read(catalogRepositoryProvider);
      final storageRepo = ref.read(storageRepositoryProvider);
      await repo.deleteBanner(banner.id);
      // Best-effort delete from Storage too.
      try {
        await storageRepo.deleteFile(
          bucket: StorageRepository.bannerBucket,
          path: banner.imagePath,
        );
      } catch (_) {}
      ref.invalidate(adminBannersProvider);
      ref.invalidate(activeBannersProvider);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Lỗi xóa: $e')));
      }
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BANNER DIALOG (Create / Edit)
// ─────────────────────────────────────────────────────────────────────────────

class _BannerDialog extends ConsumerStatefulWidget {
  final HomeBanner? existing;
  const _BannerDialog({this.existing});

  @override
  ConsumerState<_BannerDialog> createState() => _BannerDialogState();
}

class _BannerDialogState extends ConsumerState<_BannerDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _subtitleCtrl = TextEditingController();
  final _linkValueCtrl = TextEditingController();
  final _sortCtrl = TextEditingController(text: '0');

  String _linkType = 'none';
  bool _isActive = true;
  DateTime? _startAt;
  DateTime? _endAt;

  String? _existingImagePath;
  Uint8List? _pendingBytes;
  String? _pendingFileName;
  bool _saving = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final b = widget.existing;
    if (b != null) {
      _titleCtrl.text = b.title;
      _subtitleCtrl.text = b.subtitle ?? '';
      _linkValueCtrl.text = b.linkValue ?? '';
      _sortCtrl.text = b.sortOrder.toString();
      _linkType = b.linkType;
      _isActive = b.isActive;
      _startAt = b.startAt;
      _endAt = b.endAt;
      _existingImagePath = b.imagePath;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _subtitleCtrl.dispose();
    _linkValueCtrl.dispose();
    _sortCtrl.dispose();
    super.dispose();
  }

  void _pickImage() {
    final input = html.FileUploadInputElement()..accept = 'image/*';
    input.click();
    input.onChange.listen((_) async {
      final file = input.files?.first;
      if (file == null) return;
      final reader = html.FileReader();
      reader.readAsArrayBuffer(file);
      await reader.onLoad.first;
      setState(() {
        _pendingBytes = reader.result as Uint8List;
        _pendingFileName = file.name;
      });
    });
  }

  Future<DateTime?> _pickDate(DateTime? initial) async {
    return showDatePicker(
      context: context,
      initialDate: initial ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    // Must have an image (either existing or newly picked)
    if (_existingImagePath == null && _pendingBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ảnh banner')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final storageRepo = ref.read(storageRepositoryProvider);
      final catalogRepo = ref.read(catalogRepositoryProvider);

      String imagePath = _existingImagePath ?? '';

      // Upload new image if picked
      if (_pendingBytes != null && _pendingFileName != null) {
        imagePath = await storageRepo.uploadBannerImage(
          bytes: _pendingBytes!,
          fileName: _pendingFileName!,
        );
      }

      final now = DateTime.now();

      if (_isEditing && widget.existing != null) {
        final updated = widget.existing!.copyWith(
          title: _titleCtrl.text.trim(),
          subtitle: _subtitleCtrl.text.trim().isEmpty
              ? null
              : _subtitleCtrl.text.trim(),
          imagePath: imagePath,
          linkType: _linkType,
          linkValue: _linkValueCtrl.text.trim().isEmpty
              ? null
              : _linkValueCtrl.text.trim(),
          startAt: _startAt,
          endAt: _endAt,
          isActive: _isActive,
          sortOrder: int.tryParse(_sortCtrl.text) ?? 0,
        );
        await catalogRepo.updateBanner(updated);
      } else {
        final banner = HomeBanner(
          id: '',
          title: _titleCtrl.text.trim(),
          subtitle: _subtitleCtrl.text.trim().isEmpty
              ? null
              : _subtitleCtrl.text.trim(),
          imagePath: imagePath,
          linkType: _linkType,
          linkValue: _linkValueCtrl.text.trim().isEmpty
              ? null
              : _linkValueCtrl.text.trim(),
          startAt: _startAt,
          endAt: _endAt,
          isActive: _isActive,
          sortOrder: int.tryParse(_sortCtrl.text) ?? 0,
          createdAt: now,
          updatedAt: now,
        );
        await catalogRepo.createBanner(banner);
      }

      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final storageRepo = ref.read(storageRepositoryProvider);
    final existingUrl =
        _existingImagePath != null && _pendingBytes == null
            ? storageRepo.getBannerImageUrl(_existingImagePath!)
            : null;

    return AlertDialog(
      title: Text(_isEditing ? 'Chỉnh sửa banner' : 'Thêm banner mới'),
      content: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 480, maxWidth: 560),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image preview / picker
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 160,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(8),
                      image: _pendingBytes != null
                          ? DecorationImage(
                              image: MemoryImage(_pendingBytes!),
                              fit: BoxFit.cover,
                            )
                          : existingUrl != null && existingUrl.isNotEmpty
                              ? DecorationImage(
                                  image: NetworkImage(existingUrl),
                                  fit: BoxFit.cover,
                                )
                              : null,
                    ),
                    child: (_pendingBytes == null &&
                            (existingUrl == null || existingUrl.isEmpty))
                        ? const Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.add_photo_alternate_outlined,
                                    size: 40, color: Colors.grey),
                                SizedBox(height: 4),
                                Text('Chọn ảnh banner',
                                    style: TextStyle(color: Colors.grey)),
                              ],
                            ),
                          )
                        : null,
                  ),
                ),
                if (_pendingBytes != null)
                  TextButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Đổi ảnh'),
                  ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _titleCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Tiêu đề *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Bắt buộc' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _subtitleCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Phụ đề',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                // Link type
                DropdownButtonFormField<String>(
                  value: _linkType,
                  decoration: const InputDecoration(
                    labelText: 'Loại liên kết',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'none', child: Text('Không có')),
                    DropdownMenuItem(value: 'category', child: Text('Danh mục')),
                    DropdownMenuItem(value: 'product', child: Text('Sản phẩm')),
                    DropdownMenuItem(value: 'url', child: Text('URL tùy chỉnh')),
                  ],
                  onChanged: (v) => setState(() => _linkType = v ?? 'none'),
                ),
                if (_linkType != 'none') ...[
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _linkValueCtrl,
                    decoration: InputDecoration(
                      labelText: _linkType == 'url'
                          ? 'URL'
                          : _linkType == 'category'
                              ? 'Slug danh mục'
                              : 'Slug sản phẩm',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                // Date range
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final d = await _pickDate(_startAt);
                          if (d != null) setState(() => _startAt = d);
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Bắt đầu',
                            border: OutlineInputBorder(),
                          ),
                          child: Text(_startAt == null
                              ? 'Không giới hạn'
                              : '${_startAt!.day}/${_startAt!.month}/${_startAt!.year}'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final d = await _pickDate(_endAt);
                          if (d != null) setState(() => _endAt = d);
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Kết thúc',
                            border: OutlineInputBorder(),
                          ),
                          child: Text(_endAt == null
                              ? 'Không giới hạn'
                              : '${_endAt!.day}/${_endAt!.month}/${_endAt!.year}'),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    SizedBox(
                      width: 120,
                      child: TextFormField(
                        controller: _sortCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Thứ tự',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: SwitchListTile(
                        title: const Text('Hiển thị'),
                        value: _isActive,
                        onChanged: (v) => setState(() => _isActive = v),
                        dense: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Hủy'),
        ),
        if (_saving)
          const Padding(
            padding: EdgeInsets.all(8),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          )
        else
          ElevatedButton(
            onPressed: _save,
            child: const Text('Lưu'),
          ),
      ],
    );
  }
}

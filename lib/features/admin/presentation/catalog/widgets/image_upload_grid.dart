// Image Upload Grid Widget
// Displays a grid of product images with upload and delete capabilities.
// Each cell shows a thumbnail (or upload placeholder) and a delete button.
// Uses dart:html for file picking on Flutter Web — no extra package needed.

import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../features/catalog/data/catalog_repository.dart';
import '../../../../../../features/catalog/data/storage_repository.dart';
import '../../../../../../features/catalog/domain/models/product_image.dart';

// Conditional import: dart:html on web, stub on other platforms
import '../../../../../../core/utils/html_stub.dart'
    if (dart.library.html) 'dart:html' as html;

/// A pending upload entry (bytes + filename) not yet committed to Supabase.
class _PendingUpload {
  final Uint8List bytes;
  final String name;
  _PendingUpload(this.bytes, this.name);
}

/// Callback when the image list changes (after upload/delete).
typedef OnImagesChanged = void Function(List<ProductImage> images);

class ImageUploadGrid extends ConsumerStatefulWidget {
  /// Current saved images for the product.
  final List<ProductImage> images;

  /// The product ID (empty string if creating a new product).
  final String productId;

  /// Called after images are committed to Storage + DB, or a DB image is deleted.
  final OnImagesChanged onImagesChanged;

  const ImageUploadGrid({
    super.key,
    required this.images,
    required this.productId,
    required this.onImagesChanged,
  });

  @override
  ConsumerState<ImageUploadGrid> createState() => _ImageUploadGridState();
}

class _ImageUploadGridState extends ConsumerState<ImageUploadGrid> {
  final List<_PendingUpload> _pending = [];
  bool _uploading = false;

  Future<void> _pickFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          'jpg', 'jpeg', 'png', 'webp', 'gif', 'bmp', 'jfif', 'pjpeg', 'svg', 'heic', 'avif'
        ],
        allowMultiple: true,
        withData: true,
      );
      if (result != null && result.files.isNotEmpty) {
        final List<_PendingUpload> newlyPicked = [];
        for (final file in result.files) {
          final bytes = file.bytes;
          if (bytes != null && bytes.isNotEmpty) {
            newlyPicked.add(_PendingUpload(bytes, file.name));
          }
        }
        if (newlyPicked.isNotEmpty) {
          setState(() => _pending.addAll(newlyPicked));
          await _commitUploads();
        }
        return;
      }
    } catch (_) {
      // Fallback web nếu file_picker có vấn đề trên browser cũ
      _pickFilesFallbackWeb();
    }
  }

  void _pickFilesFallbackWeb() {
    if (!kIsWeb) return;
    final input = html.FileUploadInputElement()
      ..accept = 'image/*'
      ..multiple = true;
    input.click();
    input.onChange.listen((_) async {
      final files = input.files ?? [];
      final List<_PendingUpload> newlyPicked = [];
      for (final file in files) {
        final reader = html.FileReader();
        reader.readAsArrayBuffer(file);
        await reader.onLoad.first;
        final rawResult = reader.result;
        Uint8List bytes;
        if (rawResult is Uint8List) {
          bytes = rawResult;
        } else if (rawResult is ByteBuffer) {
          bytes = rawResult.asUint8List();
        } else if (rawResult is List<int>) {
          bytes = Uint8List.fromList(rawResult);
        } else {
          continue;
        }
        newlyPicked.add(_PendingUpload(bytes, file.name));
      }
      if (newlyPicked.isNotEmpty) {
        setState(() => _pending.addAll(newlyPicked));
        // Tự động tải lên ngay khi người dùng chọn ảnh
        await _commitUploads();
      }
    });
  }

  /// Uploads all pending files to Storage and inserts ProductImage rows.
  Future<void> _commitUploads() async {
    if (_pending.isEmpty) return;
    setState(() => _uploading = true);
    try {
      final storageRepo = ref.read(storageRepositoryProvider);
      final updatedImages = List<ProductImage>.from(widget.images);

      for (final pending in _pending) {
        final path = await storageRepo.uploadProductImage(
          bytes: pending.bytes,
          fileName: pending.name,
          folder: widget.productId.isEmpty ? 'temp' : widget.productId,
          contentType: StorageRepository.inferContentType(pending.name),
        );
        final now = DateTime.now();
        final img = ProductImage(
          id: 'temp_${now.millisecondsSinceEpoch}_${updatedImages.length}',
          productId: widget.productId,
          imagePath: path,
          sortOrder: updatedImages.length,
          isPrimary: updatedImages.isEmpty,
          createdAt: now,
        );
        updatedImages.add(img);
      }

      setState(() => _pending.clear());
      widget.onImagesChanged(updatedImages);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi upload ảnh: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _deleteImage(ProductImage img) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xóa ảnh'),
        content: const Text('Bạn có chắc muốn xóa ảnh này không?'),
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
      // Only delete from DB if image has a real (non-temp) id.
      if (img.id.isNotEmpty && !img.id.startsWith('temp_')) {
        await ref.read(catalogRepositoryProvider).deleteProductImage(img.id);
      }
      // Dọn dẹp file trên Storage nếu có đường dẫn
      if (img.imagePath.isNotEmpty) {
        try {
          await ref.read(storageRepositoryProvider).deleteFile(
                bucket: StorageRepository.productBucket,
                path: img.imagePath,
              );
        } catch (_) {}
      }
      final updated = widget.images.where((i) => i.id != img.id).toList();
      if (updated.isNotEmpty && !updated.any((i) => i.isPrimary)) {
        updated[0] = updated[0].copyWith(isPrimary: true);
      }
      widget.onImagesChanged(updated);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi xóa ảnh: $e')),
        );
      }
    }
  }

  void _setPrimary(ProductImage target) {
    final updated = widget.images.map((img) {
      return img.copyWith(isPrimary: img.id == target.id);
    }).toList();
    widget.onImagesChanged(updated);
  }

  Future<void> _showAddUrlDialog() async {
    final controller = TextEditingController();
    final url = await showDialog<String>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Thêm ảnh từ URL'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nhập đường dẫn trực tiếp của hình ảnh (hỗ trợ Unsplash, CDN hoặc website bất kỳ):',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'https://images.unsplash.com/...',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                Navigator.pop(dialogCtx, text);
              }
            },
            child: const Text('Thêm ảnh'),
          ),
        ],
      ),
    );

    if (url != null && url.isNotEmpty) {
      final now = DateTime.now();
      final newImg = ProductImage(
        id: 'temp_${now.millisecondsSinceEpoch}_${widget.images.length}',
        productId: widget.productId,
        imagePath: url,
        sortOrder: widget.images.length,
        isPrimary: widget.images.isEmpty,
        createdAt: now,
      );
      widget.onImagesChanged([...widget.images, newImg]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final storageRepo = ref.read(storageRepositoryProvider);
    final allImages = widget.images;
    const cellWidth = 120.0;
    const cellHeight = 160.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Ảnh sản phẩm', style: Theme.of(context).textTheme.titleSmall),
            TextButton.icon(
              onPressed: _showAddUrlDialog,
              icon: const Icon(Icons.link, size: 18),
              label: const Text('Thêm bằng link ảnh (URL)', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            // Saved images
            for (final img in allImages)
              _ImageCell(
                key: ValueKey(img.id),
                imageUrl: storageRepo.getProductImageUrl(img.imagePath),
                isPrimary: img.isPrimary,
                onDelete: () => _deleteImage(img),
                onSetPrimary: () => _setPrimary(img),
              ),
            // Pending (not uploaded yet) — shown as byte previews
            for (final p in _pending)
              _PendingImageCell(
                bytes: p.bytes,
                onRemove: () => setState(() => _pending.remove(p)),
              ),
            // "Add" button
            GestureDetector(
              onTap: _pickFiles,
              child: Container(
                width: cellWidth,
                height: cellHeight,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.add_photo_alternate_outlined, size: 36),
              ),
            ),
          ],
        ),
        if (_pending.isNotEmpty) ...[
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: _uploading ? null : _commitUploads,
            icon: _uploading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.cloud_upload_outlined),
            label: Text(_uploading
                ? 'Đang tải lên…'
                : 'Tải lên ${_pending.length} ảnh'),
          ),
        ],
      ],
    );
  }
}

class _ImageCell extends StatelessWidget {
  final String imageUrl;
  final bool isPrimary;
  final VoidCallback onDelete;
  final VoidCallback? onSetPrimary;
  const _ImageCell({
    super.key,
    required this.imageUrl,
    required this.isPrimary,
    required this.onDelete,
    this.onSetPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        InkWell(
          onTap: isPrimary ? null : onSetPrimary,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 120,
            height: 160,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: isPrimary
                  ? Border.all(
                      color: Theme.of(context).colorScheme.primary, width: 2)
                  : Border.all(color: Colors.grey.shade300, width: 1),
              color: Colors.grey.shade200,
            ),
            clipBehavior: Clip.antiAlias,
            child: imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.broken_image_outlined,
                      color: Colors.grey,
                    ),
                  )
                : const Icon(Icons.broken_image_outlined, color: Colors.grey),
          ),
        ),
        if (isPrimary)
          Positioned(
            top: 4,
            left: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'Ảnh chính',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          )
        else if (onSetPrimary != null)
          Positioned(
            bottom: 4,
            left: 4,
            right: 4,
            child: InkWell(
              onTap: onSetPrimary,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Center(
                  child: Text(
                    'Đặt làm ảnh chính',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: onDelete,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

class _PendingImageCell extends StatelessWidget {
  final Uint8List bytes;
  final VoidCallback onRemove;
  const _PendingImageCell({required this.bytes, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: 120,
          height: 160,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.orange, width: 1.5),
            image: DecorationImage(
              image: MemoryImage(bytes),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: 4,
          left: 4,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'Chờ upload',
              style: TextStyle(color: Colors.white, fontSize: 10),
            ),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

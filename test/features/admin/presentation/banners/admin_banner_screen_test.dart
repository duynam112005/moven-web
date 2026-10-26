import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moven/features/catalog/data/catalog_providers.dart';
import 'package:moven/features/catalog/data/storage_repository.dart';
import 'package:moven/features/catalog/domain/models/banner.dart';
import 'package:moven/features/admin/presentation/banners/admin_banner_screen.dart';

class FakeStorageRepository implements StorageRepository {
  @override
  String getPublicUrl({required String bucket, required String path}) => '';

  @override
  String getProductImageUrl(String? path) => '';

  @override
  String getBannerImageUrl(String? path) => '';

  @override
  Future<String> uploadProductImage({
    required Uint8List bytes,
    required String fileName,
    String? folder,
    String contentType = 'image/jpeg',
  }) async =>
      '';

  @override
  Future<String> uploadBannerImage({
    required Uint8List bytes,
    required String fileName,
    String contentType = 'image/jpeg',
  }) async =>
      '';

  @override
  Future<void> deleteFile({
    required String bucket,
    required String path,
  }) async {}
}

void main() {
  final testBanners = [
    HomeBanner(
      id: 'banner-1',
      title: 'Khuyến mãi Hè Rực Rỡ',
      subtitle: 'Giảm tới 50% toàn bộ áo polo',
      imagePath: 'banners/summer.webp',
      linkType: 'category',
      linkValue: 'ao-polo',
      isActive: true,
      sortOrder: 1,
      createdAt: DateTime(2025, 1, 1),
      updatedAt: DateTime(2025, 1, 1),
    ),
    HomeBanner(
      id: 'banner-2',
      title: 'Bộ Sưu Tập Mùa Thu',
      imagePath: 'banners/autumn.webp',
      linkType: 'none',
      isActive: false,
      sortOrder: 2,
      createdAt: DateTime(2025, 1, 1),
      updatedAt: DateTime(2025, 1, 1),
    ),
  ];

  Widget buildTestWidget() {
    return ProviderScope(
      overrides: [
        storageRepositoryProvider.overrideWithValue(FakeStorageRepository()),
        adminBannersProvider.overrideWith((ref) async => testBanners),
      ],
      child: const MaterialApp(
        home: AdminBannerScreen(),
      ),
    );
  }

  group('AdminBannerScreen Widget Tests', () {
    testWidgets('1. Hiển thị tiêu đề Quản trị Banner và nút Thêm banner',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Quản trị Banner'), findsOneWidget);
      expect(find.text('Thêm banner'), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('2. Hiển thị danh sách banner mẫu và trạng thái hiển thị',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Khuyến mãi Hè Rực Rỡ'), findsOneWidget);
      expect(find.text('Bộ Sưu Tập Mùa Thu'), findsOneWidget);
      expect(find.textContaining('Đã ẩn'), findsOneWidget); // banner-2 is inactive
    });

    testWidgets('3. Nhấn Thêm banner mở Dialog tạo banner mới',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Thêm banner'));
      await tester.pumpAndSettle();

      expect(find.text('Thêm banner mới'), findsOneWidget);
      expect(find.text('Tiêu đề *'), findsOneWidget);
      expect(find.text('Lưu'), findsOneWidget);
      expect(find.text('Hủy'), findsOneWidget);
    });
  });
}

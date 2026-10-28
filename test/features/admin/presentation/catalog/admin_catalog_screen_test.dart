import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moven/features/catalog/data/catalog_providers.dart';
import 'package:moven/features/catalog/data/catalog_repository.dart';
import 'package:moven/features/catalog/data/storage_repository.dart';
import 'package:moven/features/catalog/domain/models/category.dart';
import 'package:moven/features/catalog/domain/models/paginated_result.dart';
import 'package:moven/features/catalog/domain/models/product.dart';
import 'package:moven/features/catalog/domain/models/product_variant.dart';
import 'package:moven/features/admin/presentation/catalog/admin_catalog_screen.dart';

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

class FakeCatalogRepository implements CatalogRepository {
  String? lastDeletedProductId;

  @override
  Future<void> deleteProduct(String productId) async {
    lastDeletedProductId = productId;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  final testCategories = [
    Category(
      id: 'cat-1',
      name: 'Áo Thun Nam',
      slug: 'ao-thun-nam',
      isActive: true,
      sortOrder: 1,
      createdAt: DateTime(2025, 1, 1),
      updatedAt: DateTime(2025, 1, 1),
    ),
    Category(
      id: 'cat-2',
      name: 'Quần Jeans Nữ',
      slug: 'quan-jeans-nu',
      isActive: false,
      sortOrder: 2,
      createdAt: DateTime(2025, 1, 1),
      updatedAt: DateTime(2025, 1, 1),
    ),
  ];

  final testProducts = [
    Product(
      id: 'prod-1',
      categoryId: 'cat-1',
      name: 'Áo Thun MOVEN Basic',
      slug: 'ao-thun-moven-basic',
      targetAudience: 'men',
      isFeatured: true,
      isActive: true,
      createdAt: DateTime(2025, 1, 1),
      updatedAt: DateTime(2025, 1, 1),
      variants: [
        ProductVariant(
          id: 'var-1',
          productId: 'prod-1',
          sku: 'AT-01-M',
          size: 'M',
          colorName: 'Trắng',
          price: 250000,
          stockQuantity: 20,
          isActive: true,
          createdAt: DateTime(2025, 1, 1),
          updatedAt: DateTime(2025, 1, 1),
        ),
      ],
    ),
  ];

    late FakeCatalogRepository fakeCatalogRepo;

    setUp(() {
      fakeCatalogRepo = FakeCatalogRepository();
    });

    Widget buildTestWidget() {
      return ProviderScope(
        overrides: [
          catalogRepositoryProvider.overrideWithValue(fakeCatalogRepo),
          storageRepositoryProvider.overrideWithValue(FakeStorageRepository()),
          adminCategoriesProvider.overrideWith((ref) async => testCategories),
          adminProductsProvider.overrideWith((ref, query) async {
            return PaginatedResult<Product>(
              items: testProducts,
              totalCount: testProducts.length,
              page: 1,
              pageSize: 20,
            );
          }),
        ],
        child: const MaterialApp(
          home: AdminCatalogScreen(),
        ),
      );
    }

  group('AdminCatalogScreen Widget Tests', () {
    testWidgets('1. Hiển thị thanh tiêu đề AppBar và 2 tab Danh mục / Sản phẩm',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Quản trị Catalog'), findsOneWidget);
      expect(find.text('Danh mục'), findsOneWidget);
      expect(find.text('Sản phẩm'), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('2. Tab Danh mục hiển thị danh sách category mẫu',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Kiểm tra danh mục
      expect(find.text('Áo Thun Nam'), findsOneWidget);
      expect(find.text('Quần Jeans Nữ'), findsOneWidget);
      expect(find.textContaining('Đã ẩn'), findsOneWidget); // cat-2 is inactive
    });

    testWidgets('3. Chuyển sang Tab Sản phẩm hiển thị thanh tìm kiếm và sản phẩm mẫu',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Nhấn chuyển tab Sản phẩm
      await tester.tap(find.text('Sản phẩm'));
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Áo Thun MOVEN Basic'), findsOneWidget);
      expect(find.textContaining('250.000₫'), findsOneWidget);
    });

    testWidgets('4. Tab Sản phẩm hiển thị nút xóa, xác nhận xóa thành công và không bị trắng màn hình',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Chuyển sang Tab Sản phẩm
      await tester.tap(find.text('Sản phẩm'));
      await tester.pumpAndSettle();

      // Kiểm tra có nút xóa (Icons.delete_outline)
      final deleteBtn = find.byIcon(Icons.delete_outline);
      expect(deleteBtn, findsOneWidget);

      // Nhấn vào nút xóa
      await tester.tap(deleteBtn);
      await tester.pumpAndSettle();

      // Kiểm tra dialog xác nhận xuất hiện
      expect(find.text('Xóa sản phẩm'), findsOneWidget);
      expect(
        find.textContaining('Bạn có chắc chắn muốn xóa sản phẩm "Áo Thun MOVEN Basic" không?'),
        findsOneWidget,
      );
      expect(find.text('Hủy'), findsOneWidget);
      expect(find.text('Xóa'), findsOneWidget);

      // Nhấn nút Xóa trên dialog
      await tester.tap(find.text('Xóa'));
      await tester.pumpAndSettle();

      // Dialog đóng
      expect(find.text('Xóa sản phẩm'), findsNothing);

      // Màn hình KHÔNG bị trắng, giao diện Admin Catalog vẫn tồn tại nguyên vẹn
      expect(find.text('Quản trị Catalog'), findsOneWidget);
      expect(find.text('Sản phẩm'), findsOneWidget);

      // Repository đã nhận đúng lệnh xóa sản phẩm id 'prod-1'
      expect(fakeCatalogRepo.lastDeletedProductId, equals('prod-1'));
    });
  });
}

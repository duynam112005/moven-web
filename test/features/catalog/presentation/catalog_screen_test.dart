import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moven/core/utils/currency_formatter.dart';
import 'package:moven/features/catalog/data/catalog_providers.dart';
import 'package:moven/features/catalog/data/storage_repository.dart';
import 'package:moven/features/catalog/domain/models/category.dart';
import 'package:moven/features/catalog/domain/models/paginated_result.dart';
import 'package:moven/features/catalog/domain/models/product.dart';
import 'package:moven/features/catalog/domain/models/product_variant.dart';
import 'package:moven/features/catalog/presentation/catalog_screen.dart';
import 'package:moven/features/catalog/presentation/widgets/product_card.dart';

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
  final testCategories = [
    Category(
      id: 'cat-1',
      name: 'Áo Polo',
      slug: 'ao-polo',
      isActive: true,
      sortOrder: 1,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Category(
      id: 'cat-2',
      name: 'Quần Kaki',
      slug: 'quan-kaki',
      isActive: true,
      sortOrder: 2,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];

  final testProducts = [
    Product(
      id: 'prod-1',
      categoryId: 'cat-1',
      name: 'Áo Polo Pima Cotton',
      slug: 'ao-polo-pima-cotton',
      targetAudience: 'men',
      isFeatured: true,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      category: testCategories[0],
      variants: [
        ProductVariant(
          id: 'v1',
          productId: 'prod-1',
          sku: 'POLO-01',
          price: 299000,
          compareAtPrice: 350000,
          stockQuantity: 15,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ],
    ),
  ];

  testWidgets('CatalogScreen renders header, search and product cards',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          storageRepositoryProvider
              .overrideWithValue(FakeStorageRepository()),
          activeCategoriesProvider
              .overrideWith((ref) => Future.value(testCategories)),
          catalogProductsProvider.overrideWith((ref) => Future.value(
                PaginatedResult<Product>(
                  items: testProducts,
                  totalCount: 1,
                  page: 1,
                  pageSize: 12,
                ),
              )),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(child: CatalogScreen()),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Xác nhận tiêu đề và ô tìm kiếm
    expect(find.text('Tất cả sản phẩm'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);

    // Xác nhận danh mục xuất hiện
    expect(find.text('Áo Polo'), findsOneWidget);
    expect(find.text('Quần Kaki'), findsOneWidget);

    // Xác nhận ProductCard và thông tin sản phẩm
    expect(find.byType(ProductCard), findsOneWidget);
    expect(find.text('Áo Polo Pima Cotton'), findsOneWidget);
    expect(find.text(CurrencyFormatter.format(299000)), findsOneWidget);
    expect(find.text('HOT'), findsOneWidget);
  });

  testWidgets('CatalogScreen renders empty state when no products',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          storageRepositoryProvider
              .overrideWithValue(FakeStorageRepository()),
          activeCategoriesProvider
              .overrideWith((ref) => Future.value(testCategories)),
          catalogProductsProvider.overrideWith((ref) => Future.value(
                const PaginatedResult<Product>(
                  items: [],
                  totalCount: 0,
                  page: 1,
                  pageSize: 12,
                ),
              )),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(child: CatalogScreen()),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Không tìm thấy sản phẩm nào'), findsOneWidget);
  });
}

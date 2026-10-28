import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:moven/core/router/route_names.dart';
import 'package:moven/core/utils/currency_formatter.dart';
import 'package:moven/features/catalog/data/catalog_providers.dart';
import 'package:moven/features/catalog/data/storage_repository.dart';
import 'package:moven/features/catalog/domain/models/banner.dart';
import 'package:moven/features/catalog/domain/models/category.dart';
import 'package:moven/features/catalog/domain/models/product.dart';
import 'package:moven/features/catalog/domain/models/product_variant.dart';
import 'package:moven/features/catalog/presentation/widgets/product_card.dart';
import 'package:moven/features/home/presentation/home_screen.dart';
import 'package:moven/features/home/presentation/widgets/banner_carousel.dart';

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
      title: 'Bộ Sưu Tập Mùa Hè 2026',
      subtitle: 'Phong cách tối giản cho ngày hè năng động',
      imagePath: 'banners/summer.jpg',
      linkType: 'category',
      linkValue: 'ao-thun',
      isActive: true,
      sortOrder: 1,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];

  final testCategories = [
    Category(
      id: 'cat-1',
      name: 'Áo Thun Cao Cấp',
      slug: 'ao-thun',
      isActive: true,
      sortOrder: 1,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];

  final testFeaturedProducts = [
    Product(
      id: 'prod-hot-1',
      categoryId: 'cat-1',
      name: 'Áo Polo Thể Thao Nam',
      slug: 'ao-polo-the-thao-nam',
      targetAudience: 'men',
      isFeatured: true,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      variants: [
        ProductVariant(
          id: 'v1',
          productId: 'prod-hot-1',
          sku: 'POLO-HOT-01',
          price: 320000,
          compareAtPrice: 380000,
          stockQuantity: 20,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ],
    ),
  ];

  testWidgets('HomeScreen renders dynamic banner, categories, and featured products',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 1000);
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
          activeBannersProvider.overrideWith((ref) => Future.value(testBanners)),
          activeCategoriesProvider
              .overrideWith((ref) => Future.value(testCategories)),
          featuredProductsProvider
              .overrideWith((ref) => Future.value(testFeaturedProducts)),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(child: HomeScreen()),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // 1. Kiểm tra Banner Carousel
    expect(find.byType(BannerCarousel), findsOneWidget);
    expect(find.text('Bộ Sưu Tập Mùa Hè 2026'), findsOneWidget);
    expect(find.text('Phong cách tối giản cho ngày hè năng động'), findsOneWidget);

    // 2. Kiểm tra Danh mục động
    expect(find.text('Áo Thun Cao Cấp'), findsOneWidget);

    // 3. Kiểm tra Sản phẩm nổi bật
    expect(find.byType(ProductCard), findsOneWidget);
    expect(find.text('Áo Polo Thể Thao Nam'), findsOneWidget);
    expect(find.text(CurrencyFormatter.format(320000)), findsOneWidget);
  });

  testWidgets(
      'HomeScreen renders error state without overflow when featured products fail',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 600);
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
          activeBannersProvider.overrideWith((ref) => Future.value(testBanners)),
          activeCategoriesProvider
              .overrideWith((ref) => Future.value(testCategories)),
          featuredProductsProvider.overrideWith(
            (ref) => Future.error(
              Exception('Lỗi kết nối cơ sở dữ liệu Supabase: Connection timed out'),
            ),
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(child: HomeScreen()),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Không thể tải sản phẩm nổi bật'), findsOneWidget);
    expect(find.text('Thử lại'), findsOneWidget);
    // Đảm bảo không ném bất kỳ exception overflow nào
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'Tapping "Khám phá ngay" on category banner updates catalogFilterProvider with categorySlug',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final container = ProviderContainer(
      overrides: [
        storageRepositoryProvider
            .overrideWithValue(FakeStorageRepository()),
        activeBannersProvider.overrideWith((ref) => Future.value(testBanners)),
        activeCategoriesProvider
            .overrideWith((ref) => Future.value(testCategories)),
        featuredProductsProvider
            .overrideWith((ref) => Future.value(testFeaturedProducts)),
      ],
    );
    addTearDown(container.dispose);

    final testRouter = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const Scaffold(
            body: SingleChildScrollView(child: HomeScreen()),
          ),
        ),
        GoRoute(
          path: '/catalog',
          name: RouteNames.catalog,
          builder: (context, state) => const Scaffold(
            body: Text('Catalog Page'),
          ),
        ),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          routerConfig: testRouter,
        ),
      ),
    );

    await tester.pumpAndSettle();

    final exploreBtn = find.text('Khám phá ngay');
    expect(exploreBtn, findsOneWidget);
    await tester.tap(exploreBtn);
    await tester.pumpAndSettle();

    // Xác nhận đã điều hướng tới trang Catalog
    expect(find.text('Catalog Page'), findsOneWidget);

    // Xác nhận catalogFilterProvider lưu trữ categorySlug chính xác
    final filter = container.read(catalogFilterProvider);
    expect(filter.categorySlug, 'ao-thun');
    expect(filter.categoryId, isNull);
  });
}

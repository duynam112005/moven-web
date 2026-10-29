import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moven/core/network/supabase_client.dart';
import 'package:moven/core/utils/currency_formatter.dart';
import 'package:moven/features/catalog/data/catalog_providers.dart';
import 'package:moven/features/catalog/data/storage_repository.dart';
import 'package:moven/features/catalog/domain/models/catalog_filter.dart';
import 'package:moven/features/catalog/domain/models/category.dart';
import 'package:moven/features/catalog/domain/models/paginated_result.dart';
import 'package:moven/features/catalog/domain/models/product.dart';
import 'package:moven/features/catalog/domain/models/product_variant.dart';
import 'package:moven/features/catalog/presentation/catalog_screen.dart';
import 'package:moven/features/catalog/presentation/widgets/product_card.dart';
import 'package:supabase_flutter/supabase_flutter.dart'
    show AuthChangeEvent, AuthState;

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

  testWidgets(
      'CatalogScreen retains previous searchKeyword in TextField when re-opened',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final container = ProviderContainer(
      overrides: [
        storageRepositoryProvider.overrideWithValue(FakeStorageRepository()),
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
    );
    addTearDown(container.dispose);

    // Giả lập trạng thái trước đó người dùng đã tìm "áo polo"
    container.read(catalogFilterProvider.notifier).state =
        const CatalogFilter(searchKeyword: 'áo polo');
    container.read(catalogSearchTimestampProvider.notifier).state =
        DateTime.now();

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(child: CatalogScreen()),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Ô tìm kiếm phải hiển thị từ khóa đã tìm kiếm trước đó
    expect(find.text('áo polo'), findsOneWidget);
    // Nút xóa 'X' xuất hiện khi có từ khóa
    expect(find.byIcon(Icons.clear), findsOneWidget);
  });

  testWidgets(
      'CatalogScreen resets search keyword and returns to page 1 when text is completely erased',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final container = ProviderContainer(
      overrides: [
        storageRepositoryProvider.overrideWithValue(FakeStorageRepository()),
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
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(child: CatalogScreen()),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // 1. Nhập từ khóa và submit tìm kiếm
    await tester.enterText(find.byType(TextField), 'áo khoác');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();

    expect(
      container.read(catalogFilterProvider).searchKeyword,
      equals('áo khoác'),
    );
    expect(container.read(catalogSearchTimestampProvider), isNotNull);

    // 2. Xóa toàn bộ ký tự trong ô tìm kiếm (trở về rỗng)
    await tester.enterText(find.byType(TextField), '');
    await tester.pumpAndSettle();

    // Hệ thống lập tức hoàn nguyên searchKeyword về null và page về 1
    expect(container.read(catalogFilterProvider).searchKeyword, isNull);
    expect(container.read(catalogSearchTimestampProvider), isNull);
    expect(container.read(catalogPageProvider), equals(1));
  });

  testWidgets(
      'CatalogScreen clears search keyword and text when tapping clear button (X)',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final container = ProviderContainer(
      overrides: [
        storageRepositoryProvider.overrideWithValue(FakeStorageRepository()),
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
    );
    addTearDown(container.dispose);

    container.read(catalogFilterProvider.notifier).state =
        const CatalogFilter(searchKeyword: 'áo polo');
    container.read(catalogSearchTimestampProvider.notifier).state =
        DateTime.now();

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(child: CatalogScreen()),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.clear), findsOneWidget);

    // Nhấn nút xóa (X)
    await tester.tap(find.byIcon(Icons.clear));
    await tester.pumpAndSettle();

    // Bộ lọc được reset
    expect(container.read(catalogFilterProvider).searchKeyword, isNull);
    expect(container.read(catalogSearchTimestampProvider), isNull);
    expect(container.read(catalogPageProvider), equals(1));
    // Nút xóa biến mất
    expect(find.byIcon(Icons.clear), findsNothing);
  });

  testWidgets(
      'CatalogScreen resets search if lastSearchTime is older than session duration (15 mins)',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final container = ProviderContainer(
      overrides: [
        storageRepositoryProvider.overrideWithValue(FakeStorageRepository()),
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
    );
    addTearDown(container.dispose);

    // Tìm kiếm từ 16 phút trước (> 15 phút)
    container.read(catalogFilterProvider.notifier).state =
        const CatalogFilter(searchKeyword: 'tìm kiếm quá hạn');
    container.read(catalogSearchTimestampProvider.notifier).state =
        DateTime.now().subtract(const Duration(minutes: 16));

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(child: CatalogScreen()),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Bộ lọc đã tự động reset vì quá thời hạn phiên tìm kiếm
    expect(container.read(catalogFilterProvider).searchKeyword, isNull);
    expect(container.read(catalogSearchTimestampProvider), isNull);
    expect(find.text('tìm kiếm quá hạn'), findsNothing);
  });

  test('isCatalogSearchExpired returns correct boolean based on 15 minutes TTL',
      () {
    expect(isCatalogSearchExpired(null), isFalse);
    expect(isCatalogSearchExpired(DateTime.now()), isFalse);
    expect(
      isCatalogSearchExpired(
        DateTime.now().subtract(const Duration(minutes: 10)),
      ),
      isFalse,
    );
    expect(
      isCatalogSearchExpired(
        DateTime.now().subtract(const Duration(minutes: 15, seconds: 1)),
      ),
      isTrue,
    );
  });

  test('catalogFilterProvider resets on user sign out event', () async {
    final authController = StreamController<AuthState>.broadcast();
    addTearDown(authController.close);

    final container = ProviderContainer(
      overrides: [
        authStateChangesProvider.overrideWith((ref) => authController.stream),
      ],
    );
    addTearDown(container.dispose);

    // Kích hoạt provider để thiết lập listener
    container.read(catalogFilterProvider);

    // Giả lập trạng thái đã tìm kiếm trước đó
    container.read(catalogFilterProvider.notifier).state =
        const CatalogFilter(searchKeyword: 'áo polo');
    container.read(catalogSearchTimestampProvider.notifier).state =
        DateTime.now();
    container.read(catalogPageProvider.notifier).state = 2;

    expect(
      container.read(catalogFilterProvider).searchKeyword,
      equals('áo polo'),
    );

    // Phát sự kiện đăng xuất
    authController.add(const AuthState(AuthChangeEvent.signedOut, null));
    await pumpEventQueue();

    // Xác nhận bộ lọc, timestamp và trang đã được reset về ban đầu
    expect(container.read(catalogFilterProvider).searchKeyword, isNull);
    expect(container.read(catalogSearchTimestampProvider), isNull);
    expect(container.read(catalogPageProvider), equals(1));
  });
}

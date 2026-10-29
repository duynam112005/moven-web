import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moven/core/utils/currency_formatter.dart';
import 'package:moven/features/catalog/data/catalog_providers.dart';
import 'package:moven/features/catalog/data/storage_repository.dart';
import 'package:moven/features/catalog/domain/models/category.dart';
import 'package:moven/features/catalog/domain/models/product.dart';
import 'package:moven/features/catalog/domain/models/product_variant.dart';
import 'package:moven/features/product_detail/presentation/product_detail_screen.dart';

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
  final testCategory = Category(
    id: 'cat-1',
    name: 'Áo Thun',
    slug: 'ao-thun',
    isActive: true,
    sortOrder: 1,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  final testProduct = Product(
    id: 'prod-detail-1',
    categoryId: 'cat-1',
    name: 'Áo Thun Cổ Tròn Basic',
    slug: 'ao-thun-co-tron-basic',
    description: 'Chất liệu 100% Cotton chải kỹ, thấm hút mồ hôi tối đa.',
    material: '100% Cotton USA',
    targetAudience: 'men',
    isFeatured: true,
    isActive: true,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    category: testCategory,
    variants: [
      ProductVariant(
        id: 'var-m',
        productId: 'prod-detail-1',
        sku: 'AT-DEN-M',
        size: 'M',
        colorName: 'Đen',
        price: 199000,
        compareAtPrice: 249000,
        stockQuantity: 8,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      ProductVariant(
        id: 'var-l',
        productId: 'prod-detail-1',
        sku: 'AT-DEN-L',
        size: 'L',
        colorName: 'Đen',
        price: 219000,
        compareAtPrice: 269000,
        stockQuantity: 5,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ],
  );

  testWidgets('ProductDetailScreen renders info, variants, dynamic price',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 900);
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
          productDetailProvider('ao-thun-co-tron-basic').overrideWith(
            (ref) => Future.value(testProduct),
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ProductDetailScreen(slug: 'ao-thun-co-tron-basic'),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Xác nhận tiêu đề và thông tin sản phẩm
    expect(find.text('Áo Thun Cổ Tròn Basic'), findsNWidgets(2)); // Breadcrumb + Title
    expect(find.text('ÁO THUN'), findsOneWidget);
    expect(find.text('Chất liệu 100% Cotton chải kỹ, thấm hút mồ hôi tối đa.'),
        findsOneWidget);

    // Mặc định chọn biến thể đầu tiên (M / Đen: 199.000 ₫)
    expect(find.text(CurrencyFormatter.format(199000)), findsOneWidget);
    expect(find.text('M / Đen'), findsOneWidget);
    expect(find.text('L / Đen'), findsOneWidget);

    // Chuyển sang biến thể L / Đen (219.000 ₫)
    await tester.tap(find.text('L / Đen'));
    await tester.pumpAndSettle();

    // Giá cập nhật sang 219.000 ₫
    expect(find.text(CurrencyFormatter.format(219000)), findsOneWidget);
    expect(find.text('Mã SKU: AT-DEN-L'), findsOneWidget);

    // Nút Thêm vào giỏ hàng
    expect(find.text('Thêm vào giỏ hàng'), findsOneWidget);
  });

  testWidgets(
      'ProductDetailScreen tự động đồng bộ khi dữ liệu sản phẩm cập nhật (đổi tên, đổi ảnh)',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final currentProductProvider =
        StateProvider<Product>((ref) => testProduct);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          storageRepositoryProvider
              .overrideWithValue(FakeStorageRepository()),
          productDetailProvider('ao-thun-co-tron-basic').overrideWith(
            (ref) => Future.value(ref.watch(currentProductProvider)),
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ProductDetailScreen(slug: 'ao-thun-co-tron-basic'),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Ban đầu hiển thị tên cũ
    expect(find.text('Áo Thun Cổ Tròn Basic'), findsNWidgets(2));
    expect(find.text('Áo Thun Cổ Tròn Cao Cấp 2026'), findsNothing);

    // Giả lập admin cập nhật tên và mô tả sản phẩm
    final element = tester.element(find.byType(ProductDetailScreen));
    final container = ProviderScope.containerOf(element);
    final updatedProduct = testProduct.copyWith(
      name: 'Áo Thun Cổ Tròn Cao Cấp 2026',
      description: 'Chất liệu nâng cấp 100% Pima Cotton.',
    );
    container.read(currentProductProvider.notifier).state = updatedProduct;

    await tester.pumpAndSettle();

    // Màn hình chi tiết lập tức cập nhật thông tin mới
    expect(find.text('Áo Thun Cổ Tròn Cao Cấp 2026'), findsNWidgets(2));
    expect(find.text('Chất liệu nâng cấp 100% Pima Cotton.'), findsOneWidget);
    expect(find.text('Áo Thun Cổ Tròn Basic'), findsNothing);
  });

  testWidgets(
      'ProductDetailScreen hiển thị ảnh chính với khung hình chữ nhật tỷ lệ 3:4 chuẩn thời trang',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 900);
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
          productDetailProvider('ao-thun-co-tron-basic').overrideWith(
            (ref) => Future.value(testProduct),
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ProductDetailScreen(slug: 'ao-thun-co-tron-basic'),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Xác nhận có AspectRatio tỷ lệ 3:4 (0.75) dành cho ảnh chính của gallery
    final aspectRatioFinder = find.byWidgetPredicate(
      (widget) => widget is AspectRatio && widget.aspectRatio == 3 / 4,
    );
    expect(aspectRatioFinder, findsOneWidget);
  });
}

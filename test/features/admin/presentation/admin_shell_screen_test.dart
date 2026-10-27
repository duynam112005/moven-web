import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:moven/core/router/route_names.dart';
import 'package:moven/features/admin/presentation/admin_shell_screen.dart';
import 'package:moven/features/admin/presentation/banners/admin_banner_screen.dart';
import 'package:moven/features/admin/presentation/catalog/admin_catalog_screen.dart';
import 'package:moven/features/catalog/data/catalog_providers.dart';
import 'package:moven/features/catalog/data/storage_repository.dart';
import 'package:moven/features/catalog/domain/models/banner.dart';
import 'package:moven/features/catalog/domain/models/category.dart';
import 'package:moven/features/catalog/domain/models/paginated_result.dart';
import 'package:moven/features/catalog/domain/models/product.dart';

class FakeStorageRepository implements StorageRepository {
  @override
  String getPublicUrl({required String bucket, required String path}) => '';
  @override
  String getProductImageUrl(String? path) => '';
  @override
  String getBannerImageUrl(String? path) => '';
  @override
  Future<String> uploadProductImage({required Uint8List bytes, required String fileName, String? folder, String contentType = 'image/jpeg'}) async => '';
  @override
  Future<String> uploadBannerImage({required Uint8List bytes, required String fileName, String contentType = 'image/jpeg'}) async => '';
  @override
  Future<void> deleteFile({required String bucket, required String path}) async {}
}

void main() {
  final fakeCategories = [
    Category(
      id: 'cat-1',
      name: 'Áo Nam',
      slug: 'ao-nam',
      isActive: true,
      sortOrder: 1,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];

  final fakeBanners = [
    HomeBanner(
      id: 'ban-1',
      title: 'Khuyến mãi Khai trương',
      imagePath: 'banners/hero.jpg',
      linkType: 'none',
      isActive: true,
      sortOrder: 1,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];

  Widget buildShellWithChild(Widget child) {
    final testRouter = GoRouter(
      initialLocation: '/admin',
      routes: [
        GoRoute(
          path: RouteNames.homePath,
          builder: (context, state) => const Scaffold(body: Text('Storefront Home')),
        ),
        GoRoute(
          path: '/admin',
          builder: (context, state) => Scaffold(
            body: AdminShellScreen(child: child),
          ),
        ),
      ],
    );

    return ProviderScope(
      overrides: [
        storageRepositoryProvider.overrideWithValue(FakeStorageRepository()),
        adminCategoriesProvider.overrideWith((ref) async => fakeCategories),
        adminBannersProvider.overrideWith((ref) async => fakeBanners),
        adminProductsProvider.overrideWith((ref, query) async {
          return const PaginatedResult<Product>(
            items: [],
            totalCount: 0,
            page: 1,
            pageSize: 20,
          );
        }),
      ],
      child: MaterialApp.router(
        routerConfig: testRouter,
      ),
    );
  }

  group('AdminShellScreen Integration & Layout Tests', () {
    testWidgets('1. AdminShellScreen renders sidebar, header and child without unbounded constraints', (tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildShellWithChild(const AdminCatalogScreen()));
      await tester.pumpAndSettle();

      // Sidebar & Header
      expect(find.text('Bảng điều khiển quản trị'), findsOneWidget);
      expect(find.text('Quản trị MOVEN'), findsOneWidget);
      expect(find.text('Quản trị Catalog'), findsOneWidget);
      // No RenderFlex unbounded height exception thrown!
    });

    testWidgets('2. AdminShellScreen with AdminBannerScreen renders smoothly without crash', (tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildShellWithChild(const AdminBannerScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Quản trị Banner'), findsOneWidget);
      expect(find.text('Khuyến mãi Khai trương'), findsOneWidget);
    });

    testWidgets('3. Tapping logout button triggers cleanly without CircularDependencyError', (tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildShellWithChild(const SizedBox()));
      await tester.pumpAndSettle();

      final logoutBtn = find.byTooltip('Đăng xuất');
      expect(logoutBtn, findsOneWidget);
      await tester.tap(logoutBtn);
      await tester.pumpAndSettle();

      expect(find.text('Storefront Home'), findsOneWidget);
    });
  });
}

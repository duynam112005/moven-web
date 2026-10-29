import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moven/features/admin/presentation/catalog/admin_category_form_screen.dart';
import 'package:moven/features/catalog/data/catalog_providers.dart';
import 'package:moven/features/catalog/data/catalog_repository.dart';
import 'package:moven/features/catalog/domain/models/category.dart';

class FakeCatalogRepository implements CatalogRepository {
  Category? lastCreatedCategory;
  Category? lastUpdatedCategory;

  @override
  Future<Category> createCategory(Category category) async {
    lastCreatedCategory = category;
    return category;
  }

  @override
  Future<Category> updateCategory(Category category) async {
    lastUpdatedCategory = category;
    return category;
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
      description: 'Mô tả áo thun',
      isActive: true,
      sortOrder: 1,
      createdAt: DateTime(2025, 1, 1),
      updatedAt: DateTime(2025, 1, 1),
    ),
    Category(
      id: 'cat-2',
      name: 'Quần Jeans Nữ',
      slug: 'quan-jeans-nu',
      description: null,
      isActive: false,
      sortOrder: 2,
      createdAt: DateTime(2025, 1, 1),
      updatedAt: DateTime(2025, 1, 1),
    ),
  ];

  late FakeCatalogRepository fakeCatalogRepo;

  setUp(() {
    fakeCatalogRepo = FakeCatalogRepository();
  });

  Widget buildTestWidget({String? categoryId}) {
    return ProviderScope(
      overrides: [
        catalogRepositoryProvider.overrideWithValue(fakeCatalogRepo),
        adminCategoriesProvider.overrideWith((ref) async => testCategories),
      ],
      child: MaterialApp(
        home: AdminCategoryFormScreen(categoryId: categoryId),
      ),
    );
  }

  group('AdminCategoryFormScreen Widget Tests', () {
    testWidgets('1. Chế độ tạo mới: Render đầy đủ các trường và không bị lỗi layout',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Kiểm tra tiêu đề AppBar
      expect(find.text('Tạo danh mục mới'), findsOneWidget);
      expect(find.text('Lưu'), findsOneWidget);

      // Kiểm tra các trường nhập liệu
      expect(find.text('Tên danh mục *'), findsOneWidget);
      expect(find.text('Slug (URL) *'), findsOneWidget);
      expect(find.text('Mô tả'), findsOneWidget);
      expect(find.text('Thứ tự hiển thị'), findsOneWidget);
      expect(find.text('Hiển thị công khai'), findsOneWidget);

      // Nhập tên và kiểm tra tự động tạo slug
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Tên danh mục *'), 'Áo Sơ Mi');
      await tester.pump();

      expect(find.text('ao-so-mi'), findsOneWidget);
    });

    testWidgets(
        '2. Chế độ chỉnh sửa: Pre-fill đúng thông tin danh mục và SwitchListTile render không lỗi',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(categoryId: 'cat-1'));
      await tester.pumpAndSettle();

      // Tiêu đề chỉnh sửa
      expect(find.text('Chỉnh sửa danh mục'), findsOneWidget);

      // Pre-fill từ category cat-1
      expect(find.text('Áo Thun Nam'), findsOneWidget);
      expect(find.text('ao-thun-nam'), findsOneWidget);
      expect(find.text('Mô tả áo thun'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);

      // Kiểm tra Switch hiển thị công khai bật (true)
      final switchFinder = find.byType(Switch);
      expect(switchFinder, findsOneWidget);
      final switchWidget = tester.widget<Switch>(switchFinder);
      expect(switchWidget.value, isTrue);

      // Bấm Lưu
      await tester.tap(find.text('Lưu'));
      await tester.pumpAndSettle();

      expect(fakeCatalogRepo.lastUpdatedCategory, isNotNull);
      expect(fakeCatalogRepo.lastUpdatedCategory!.id, 'cat-1');
      expect(fakeCatalogRepo.lastUpdatedCategory!.name, 'Áo Thun Nam');
    });

    testWidgets('3. Chế độ chỉnh sửa với categoryId không tồn tại: Form hiển thị an toàn',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(categoryId: 'cat-not-found'));
      await tester.pumpAndSettle();

      expect(find.text('Chỉnh sửa danh mục'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}

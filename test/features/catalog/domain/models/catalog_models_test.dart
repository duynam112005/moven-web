import 'package:flutter_test/flutter_test.dart';
import 'package:moven/features/catalog/domain/models/banner.dart';
import 'package:moven/features/catalog/domain/models/category.dart';
import 'package:moven/features/catalog/domain/models/product.dart';
import 'package:moven/features/catalog/domain/models/product_image.dart';
import 'package:moven/features/catalog/domain/models/product_variant.dart';

void main() {
  group('Category Model', () {
    test('parses from JSON correctly', () {
      final json = {
        'id': 'cat-1',
        'name': 'Áo Thun Nam',
        'slug': 'ao-thun-nam',
        'description': 'Bộ sưu tập áo thun thoáng mát',
        'image_path': 'categories/ao-thun.jpg',
        'is_active': true,
        'sort_order': 1,
        'created_at': '2026-01-01T00:00:00.000Z',
        'updated_at': '2026-01-01T00:00:00.000Z',
      };

      final category = Category.fromJson(json);
      expect(category.id, 'cat-1');
      expect(category.name, 'Áo Thun Nam');
      expect(category.slug, 'ao-thun-nam');
      expect(category.isActive, true);
      expect(category.sortOrder, 1);
    });
  });

  group('ProductVariant Model', () {
    test('calculates discount percent and stock correctly', () {
      final variant = ProductVariant(
        id: 'var-1',
        productId: 'prod-1',
        sku: 'ATN-DEN-L',
        size: 'L',
        colorName: 'Đen',
        price: 250000,
        compareAtPrice: 300000,
        stockQuantity: 10,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(variant.inStock, true);
      expect(variant.hasDiscount, true);
      // (300000 - 250000) / 300000 = 16.66% -> 17%
      expect(variant.discountPercent, 17);
      expect(variant.displayLabel, 'L / Đen');
    });

    test('out of stock when quantity is 0 or inactive', () {
      final variantZeroStock = ProductVariant(
        id: 'var-2',
        productId: 'prod-1',
        sku: 'ATN-DEN-M',
        price: 250000,
        stockQuantity: 0,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      expect(variantZeroStock.inStock, false);

      final variantInactive = ProductVariant(
        id: 'var-3',
        productId: 'prod-1',
        sku: 'ATN-DEN-S',
        price: 250000,
        stockQuantity: 5,
        isActive: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      expect(variantInactive.inStock, false);
    });
  });

  group('Product Model - Dynamic Pricing & Image Fallback', () {
    test('calculates minPrice and maxPrice only from active variants', () {
      final product = Product(
        id: 'prod-1',
        categoryId: 'cat-1',
        name: 'Áo Thun Cotton',
        slug: 'ao-thun-cotton',
        targetAudience: 'men',
        isFeatured: true,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        variants: [
          ProductVariant(
            id: 'v1',
            productId: 'prod-1',
            sku: 'V1',
            price: 200000,
            stockQuantity: 5,
            isActive: true,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          ProductVariant(
            id: 'v2',
            productId: 'prod-1',
            sku: 'V2',
            price: 280000,
            stockQuantity: 3,
            isActive: true,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          // Biến thể giá rẻ hơn nhưng đã ngưng bán (isActive: false) -> không được tính vào minPrice
          ProductVariant(
            id: 'v3',
            productId: 'prod-1',
            sku: 'V3',
            price: 150000,
            stockQuantity: 0,
            isActive: false,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ],
      );

      expect(product.minPrice, 200000);
      expect(product.maxPrice, 280000);
      expect(product.inStock, true);
      expect(product.totalStock, 8);
    });

    test('falls back to primary image or first image', () {
      final img1 = ProductImage(
        id: 'img-1',
        productId: 'prod-1',
        imagePath: 'prod1/thumb.jpg',
        sortOrder: 1,
        isPrimary: false,
        createdAt: DateTime.now(),
      );
      final img2 = ProductImage(
        id: 'img-2',
        productId: 'prod-1',
        imagePath: 'prod1/primary.jpg',
        sortOrder: 2,
        isPrimary: true,
        createdAt: DateTime.now(),
      );

      final product = Product(
        id: 'prod-1',
        categoryId: 'cat-1',
        name: 'Áo Sơ Mi',
        slug: 'ao-so-mi',
        targetAudience: 'men',
        isFeatured: false,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        images: [img1, img2],
      );

      expect(product.primaryImage?.id, 'img-2');
      expect(product.imageForVariant(null)?.id, 'img-2');
    });
  });

  group('HomeBanner Model', () {
    test('evaluates current visibility window accurately', () {
      final now = DateTime(2026, 5, 10, 12, 0);

      final activeBanner = HomeBanner(
        id: 'b-1',
        title: 'Khuyến mãi Hè',
        imagePath: 'banners/summer.jpg',
        linkType: 'category',
        linkValue: 'ao-thun',
        startAt: DateTime(2026, 5, 1),
        endAt: DateTime(2026, 5, 31),
        isActive: true,
        sortOrder: 1,
        createdAt: now,
        updatedAt: now,
      );
      expect(activeBanner.isCurrentlyVisible(now), true);

      final expiredBanner = activeBanner.copyWith(
        endAt: DateTime(2026, 5, 9),
      );
      expect(expiredBanner.isCurrentlyVisible(now), false);

      final inactiveBanner = activeBanner.copyWith(
        isActive: false,
      );
      expect(inactiveBanner.isCurrentlyVisible(now), false);
    });
  });
}

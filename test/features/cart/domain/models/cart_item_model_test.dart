import 'package:flutter_test/flutter_test.dart';
import 'package:moven/features/cart/domain/models/cart_item_model.dart';

void main() {
  group('CartItemModel Tests', () {
    test('Khởi tạo và tính toán lineTotal, inStock chính xác', () {
      final item = CartItemModel(
        id: 'item-1',
        cartId: 'cart-1',
        variantId: 'var-1',
        quantity: 2,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        productName: 'Áo Thun Nam Cotton Compact MOVEN',
        productSlug: 'ao-thun-nam-cotton-compact-moven',
        sku: 'MVN-TSH-BLK-M',
        size: 'M',
        colorName: 'Đen',
        price: 199000,
        compareAtPrice: 249000,
        stockQuantity: 10,
        isActive: true,
      );

      expect(item.lineTotal, 398000);
      expect(item.inStock, true);
      expect(item.displayVariantLabel, 'Size M / Đen');
    });

    test('Báo inStock false khi số lượng yêu cầu vượt tồn kho', () {
      final item = CartItemModel(
        id: 'item-2',
        cartId: 'cart-1',
        variantId: 'var-2',
        quantity: 5,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        productName: 'Áo Polo',
        productSlug: 'ao-polo',
        sku: 'MVN-POL',
        price: 299000,
        stockQuantity: 3,
        isActive: true,
      );

      expect(item.inStock, false);
    });

    test('Báo inStock false khi sản phẩm hoặc biến thể bị ngừng bán (isActive = false)', () {
      final item = CartItemModel(
        id: 'item-3',
        cartId: 'cart-1',
        variantId: 'var-3',
        quantity: 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        productName: 'Áo Sơ Mi',
        productSlug: 'ao-so-mi',
        sku: 'MVN-SMI',
        price: 349000,
        stockQuantity: 10,
        isActive: false,
      );

      expect(item.inStock, false);
    });

    test('Phân tích JSON từ Supabase lồng nhau chính xác', () {
      final mockJson = {
        'id': 'item-123',
        'cart_id': 'cart-456',
        'variant_id': 'var-789',
        'quantity': 3,
        'created_at': '2026-10-25T10:00:00.000Z',
        'updated_at': '2026-10-25T10:00:00.000Z',
        'product_variants': {
          'id': 'var-789',
          'sku': 'MVN-KHK-BEI-30',
          'size': '30',
          'color_name': 'Beige',
          'price': 399000,
          'compare_at_price': 499000,
          'stock_quantity': 15,
          'is_active': true,
          'products': {
            'id': 'prod-001',
            'name': 'Quần Khaki Nam Slim Fit',
            'slug': 'quan-khaki-nam-slim-fit',
            'is_active': true,
            'product_images': [
              {
                'id': 'img-1',
                'variant_id': 'var-789',
                'image_path': 'https://example.com/khaki.jpg',
                'is_primary': true,
              }
            ],
          },
        },
      };

      final model = CartItemModel.fromJson(mockJson);

      expect(model.id, 'item-123');
      expect(model.productName, 'Quần Khaki Nam Slim Fit');
      expect(model.price, 399000);
      expect(model.quantity, 3);
      expect(model.lineTotal, 1197000);
      expect(model.imageUrl, 'https://example.com/khaki.jpg');
      expect(model.displayVariantLabel, 'Size 30 / Beige');
      expect(model.inStock, true);
    });
  });
}

-- ==============================================================================
-- DỮ LIỆU MẪU BAN ĐẦU CHO HỆ THỐNG MOVEN (MOCK SEED DATA)
-- Quy ước UUID chuẩn Hexadecimal (0-9):
--   - Đầu 10000000-xxxx: Mã Danh mục (Categories)
--   - Đầu 20000000-xxxx: Mã Sản phẩm (Products)
--   - Đầu 30000000-xxxx: Mã Biến thể sản phẩm (Variants - Kích cỡ, Màu sắc)
--   - Đầu 40000000-xxxx: Mã Ảnh sản phẩm (Product Images)
--   - Đầu 50000000-xxxx: Mã Banner quảng bá (Hero Banners)
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- 1. CẤU HÌNH CỬA HÀNG (STORE SETTINGS)
-- Bảng Singleton: Chỉ có duy nhất 1 dòng cấu hình chung cho cả shop
-- ------------------------------------------------------------------------------
INSERT INTO public.store_settings (
    store_name,
    contact_email,
    contact_phone,
    default_shipping_fee, -- Phí ship mặc định toàn quốc: 20.000 VNĐ
    low_stock_threshold,  -- Ngưỡng cảnh báo sắp hết hàng: dưới 5 sản phẩm
    is_singleton          -- Khóa đảm bảo chỉ có duy nhất 1 dòng cấu hình
)
VALUES (
    'MOVEN Clothing',
    'support@moven.vn',
    '0901234567',
    20000,
    5,
    true
)
ON CONFLICT (is_singleton) DO UPDATE SET
    store_name = EXCLUDED.store_name,
    contact_email = EXCLUDED.contact_email,
    contact_phone = EXCLUDED.contact_phone,
    default_shipping_fee = EXCLUDED.default_shipping_fee,
    low_stock_threshold = EXCLUDED.low_stock_threshold;

-- ------------------------------------------------------------------------------
-- 2. DANH MỤC SẢN PHẨM (CATEGORIES)
-- Phân loại 4 nhóm chính: Áo Nam, Quần Nam, Áo Nữ, Quần Nữ
-- ------------------------------------------------------------------------------
INSERT INTO public.categories (id, name, slug, description, image_path, sort_order, is_active)
VALUES
    (
        '10000000-0000-0000-0000-000000000001',
        'Áo Nam',
        'ao-nam',
        'Bộ sưu tập áo thun, áo polo, áo sơ mi nam thanh lịch',
        'https://images.unsplash.com/photo-1521572267360-ee0c2909d518?w=500&auto=format&fit=crop&q=80',
        1,
        true
    ),
    (
        '10000000-0000-0000-0000-000000000002',
        'Quần Nam',
        'quan-nam',
        'Quần jeans, quần khaki, quần âu nam hiện đại',
        'https://images.unsplash.com/photo-1624378439575-d8705ad7ae80?w=500&auto=format&fit=crop&q=80',
        2,
        true
    ),
    (
        '10000000-0000-0000-0000-000000000003',
        'Áo Nữ',
        'ao-nu',
        'Áo kiểu, áo thun, sơ mi nữ cao cấp tôn dáng',
        'https://images.unsplash.com/photo-1602810318383-e386cc2a3ccf?w=500&auto=format&fit=crop&q=80',
        3,
        true
    ),
    (
        '10000000-0000-0000-0000-000000000004',
        'Quần Nữ',
        'quan-nu',
        'Quần ống rộng, jeans nữ thời trang phong cách',
        'https://images.unsplash.com/photo-1541099649105-f69ad21f3246?w=500&auto=format&fit=crop&q=80',
        4,
        true
    )
ON CONFLICT (id) DO UPDATE SET
    name = EXCLUDED.name,
    description = EXCLUDED.description,
    image_path = EXCLUDED.image_path,
    sort_order = EXCLUDED.sort_order,
    is_active = EXCLUDED.is_active;

-- ------------------------------------------------------------------------------
-- 3. SẢN PHẨM CHÍNH (PRODUCTS)
-- Theo quyết định D-10: Bỏ base_price ở bảng này, giá sẽ lấy từ bảng biến thể bên dưới
-- ------------------------------------------------------------------------------
INSERT INTO public.products (
    id, category_id, name, slug, description, material, target_audience, is_featured, is_active
)
VALUES
    -- Sản phẩm 1: Áo thun nam (thuộc danh mục Áo Nam)
    (
        '20000000-0000-0000-0000-000000000001',
        '10000000-0000-0000-0000-000000000001',
        'Áo Thun Nam Cotton Compact MOVEN',
        'ao-thun-nam-cotton-compact-moven',
        'Áo thun nam sử dụng chất liệu Cotton Compact 100% co giãn thoáng mát, thấm hút mồ hôi tối đa.',
        '100% Cotton Compact',
        'men',
        true, -- Hiển thị ở mục Sản phẩm nổi bật
        true
    ),
    -- Sản phẩm 2: Áo polo nam (thuộc danh mục Áo Nam)
    (
        '20000000-0000-0000-0000-000000000002',
        '10000000-0000-0000-0000-000000000001',
        'Áo Polo Nam Classic Fit Pique',
        'ao-polo-nam-classic-fit-pique',
        'Áo polo dệt mắt chim cao cấp, cổ dệt bo mềm mại giữ form hoàn hảo cả ngày.',
        'CVC Pique 95% Cotton 5% Spandex',
        'men',
        true,
        true
    ),
    -- Sản phẩm 3: Quần Khaki nam (thuộc danh mục Quần Nam)
    (
        '20000000-0000-0000-0000-000000000003',
        '10000000-0000-0000-0000-000000000002',
        'Quần Khaki Nam Slim Fit Co Giãn',
        'quan-khaki-nam-slim-fit-co-gian',
        'Quần khaki tôn dáng hiện đại, mềm mịn dễ phối đồ đi làm hoặc đi chơi.',
        'Cotton Twill cao cấp',
        'men',
        false,
        true
    ),
    -- Sản phẩm 4: Áo sơ mi nữ (thuộc danh mục Áo Nữ)
    (
        '20000000-0000-0000-0000-000000000004',
        '10000000-0000-0000-0000-000000000003',
        'Áo Sơ Mi Nữ Lụa Satin Cao Cấp',
        'ao-so-mi-nu-lua-satin-cao-cap',
        'Chất liệu lụa satin bóng nhẹ, mềm rủ tự nhiên, sang trọng và quý phái.',
        'Lụa Satin',
        'women',
        true,
        true
    )
ON CONFLICT (id) DO UPDATE SET
    category_id = EXCLUDED.category_id,
    name = EXCLUDED.name,
    slug = EXCLUDED.slug,
    description = EXCLUDED.description,
    material = EXCLUDED.material,
    target_audience = EXCLUDED.target_audience,
    is_featured = EXCLUDED.is_featured,
    is_active = EXCLUDED.is_active;

-- ------------------------------------------------------------------------------
-- 4. BIẾN THỂ SẢN PHẨM (PRODUCT VARIANTS)
-- Quản lý trực tiếp SKU, Size, Màu sắc, Giá bán (VNĐ) và Số lượng tồn kho
-- ------------------------------------------------------------------------------
INSERT INTO public.product_variants (
    id, product_id, sku, size, color_name, color_hex, price, compare_at_price, stock_quantity, is_active
)
VALUES
    -- Biến thể của Áo thun nam (Sản phẩm ID: 20000000-...0001)
    ('30000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001', 'MVN-TSH-BLK-M', 'M', 'Đen', '#000000', 199000, 249000, 30, true),
    ('30000000-0000-0000-0000-000000000002', '20000000-0000-0000-0000-000000000001', 'MVN-TSH-BLK-L', 'L', 'Đen', '#000000', 199000, 249000, 25, true),
    ('30000000-0000-0000-0000-000000000003', '20000000-0000-0000-0000-000000000001', 'MVN-TSH-WHT-M', 'M', 'Trắng', '#FFFFFF', 199000, 249000, 4, true), -- Tồn 4 cái (Dưới ngưỡng 5 để test cảnh báo sắp hết hàng)
    ('30000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000001', 'MVN-TSH-WHT-L', 'L', 'Trắng', '#FFFFFF', 199000, 249000, 20, true),

    -- Biến thể của Áo polo nam (Sản phẩm ID: 20000000-...0002)
    ('30000000-0000-0000-0000-000000000005', '20000000-0000-0000-0000-000000000002', 'MVN-POL-NVY-M', 'M', 'Xanh Navy', '#000080', 299000, 350000, 40, true),
    ('30000000-0000-0000-0000-000000000006', '20000000-0000-0000-0000-000000000002', 'MVN-POL-NVY-L', 'L', 'Xanh Navy', '#000080', 299000, 350000, 35, true),
    ('30000000-0000-0000-0000-000000000007', '20000000-0000-0000-0000-000000000002', 'MVN-POL-GRY-M', 'M', 'Xám Tiêu', '#808080', 299000, 350000, 15, true),

    -- Biến thể của Quần khaki nam (Sản phẩm ID: 20000000-...0003)
    ('30000000-0000-0000-0000-000000000008', '20000000-0000-0000-0000-000000000003', 'MVN-KHK-BEI-30', '30', 'Beige', '#F5F5DC', 399000, 499000, 12, true),
    ('30000000-0000-0000-0000-000000000009', '20000000-0000-0000-0000-000000000003', 'MVN-KHK-BEI-31', '31', 'Beige', '#F5F5DC', 399000, 499000, 18, true),

    -- Biến thể của Áo sơ mi nữ (Sản phẩm ID: 20000000-...0004)
    ('30000000-0000-0000-0000-000000000010', '20000000-0000-0000-0000-000000000004', 'MVN-SMI-CRM-S', 'S', 'Kem', '#FFFDD0', 349000, NULL, 22, true),
    ('30000000-0000-0000-0000-000000000011', '20000000-0000-0000-0000-000000000004', 'MVN-SMI-CRM-M', 'M', 'Kem', '#FFFDD0', 349000, NULL, 16, true)
ON CONFLICT (id) DO UPDATE SET
    price = EXCLUDED.price,
    compare_at_price = EXCLUDED.compare_at_price,
    stock_quantity = EXCLUDED.stock_quantity,
    is_active = EXCLUDED.is_active;

-- ------------------------------------------------------------------------------
-- 5. BỘ SƯU TẬP ẢNH SẢN PHẨM (PRODUCT IMAGES)
-- Có hỗ trợ:
--   - is_primary = true: Là ảnh đại diện chính bên ngoài danh sách sản phẩm
--   - variant_id: Gắn vào biến thể màu sắc, bấm chọn màu nào ảnh tự đổi màu đó
-- ------------------------------------------------------------------------------
INSERT INTO public.product_images (
    id, product_id, variant_id, image_path, alt_text, sort_order, is_primary
)
VALUES
    -- == 1. Ảnh Áo Thun Nam Cotton Compact ==
    (
        '40000000-0000-0000-0000-000000000001',
        '20000000-0000-0000-0000-000000000001',
        '30000000-0000-0000-0000-000000000003', -- Gắn vào áo Trắng
        'https://images.unsplash.com/photo-1521572267360-ee0c2909d518?w=800&auto=format&fit=crop&q=80',
        'Áo thun nam Cotton Compact màu Trắng chính diện',
        1,
        true -- Ảnh đại diện chính ngoài trang chủ
    ),
    (
        '40000000-0000-0000-0000-000000000002',
        '20000000-0000-0000-0000-000000000001',
        '30000000-0000-0000-0000-000000000003', -- Gắn vào áo Trắng
        'https://images.unsplash.com/photo-1581655353564-df123a1eb820?w=800&auto=format&fit=crop&q=80',
        'Cận cảnh chất vải Cotton Compact và cổ áo màu Trắng',
        2,
        false
    ),
    (
        '40000000-0000-0000-0000-000000000003',
        '20000000-0000-0000-0000-000000000001',
        '30000000-0000-0000-0000-000000000001', -- Gắn vào áo Đen
        'https://images.unsplash.com/photo-1503342217505-b0a15ec3261c?w=800&auto=format&fit=crop&q=80',
        'Áo thun nam Cotton Compact màu Đen chính diện',
        3,
        false
    ),
    (
        '40000000-0000-0000-0000-000000000004',
        '20000000-0000-0000-0000-000000000001',
        '30000000-0000-0000-0000-000000000001', -- Gắn vào áo Đen
        'https://images.unsplash.com/photo-1583743814966-8936f5b7be1a?w=800&auto=format&fit=crop&q=80',
        'Chi tiết phom áo và đường may màu Đen',
        4,
        false
    ),

    -- == 2. Ảnh Áo Polo Nam Classic Fit ==
    (
        '40000000-0000-0000-0000-000000000005',
        '20000000-0000-0000-0000-000000000002',
        '30000000-0000-0000-0000-000000000005', -- Gắn vào áo Xanh Navy
        'https://images.unsplash.com/photo-1586363104862-3a5e2ab60d99?w=800&auto=format&fit=crop&q=80',
        'Áo Polo nam Classic Fit Pique màu Xanh Navy',
        1,
        true -- Ảnh đại diện chính
    ),
    (
        '40000000-0000-0000-0000-000000000006',
        '20000000-0000-0000-0000-000000000002',
        '30000000-0000-0000-0000-000000000007', -- Gắn vào áo Xám Tiêu
        'https://images.unsplash.com/photo-1625910513413-5bc1ccbeea3a?w=800&auto=format&fit=crop&q=80',
        'Áo Polo nam phom chuẩn màu Xám Tiêu',
        2,
        false
    ),

    -- == 3. Ảnh Quần Khaki Nam Slim Fit ==
    (
        '40000000-0000-0000-0000-000000000007',
        '20000000-0000-0000-0000-000000000003',
        '30000000-0000-0000-0000-000000000008', -- Gắn vào màu Beige
        'https://images.unsplash.com/photo-1624378439575-d8705ad7ae80?w=800&auto=format&fit=crop&q=80',
        'Quần Khaki nam dáng Slim Fit màu Beige đứng form',
        1,
        true -- Ảnh đại diện chính
    ),
    (
        '40000000-0000-0000-0000-000000000008',
        '20000000-0000-0000-0000-000000000003',
        '30000000-0000-0000-0000-000000000008', -- Gắn vào màu Beige
        'https://images.unsplash.com/photo-1473966968600-fa801b869a1a?w=800&auto=format&fit=crop&q=80',
        'Cận cảnh chất vải Cotton Twill co giãn và chi tiết túi quần',
        2,
        false
    ),

    -- == 4. Ảnh Áo Sơ Mi Nữ Lụa Satin ==
    (
        '40000000-0000-0000-0000-000000000009',
        '20000000-0000-0000-0000-000000000004',
        '30000000-0000-0000-0000-000000000010', -- Gắn vào màu Kem
        'https://images.unsplash.com/photo-1602810318383-e386cc2a3ccf?w=800&auto=format&fit=crop&q=80',
        'Áo sơ mi nữ chất liệu lụa Satin màu Kem sang trọng',
        1,
        true -- Ảnh đại diện chính
    ),
    (
        '40000000-0000-0000-0000-000000000010',
        '20000000-0000-0000-0000-000000000004',
        '30000000-0000-0000-0000-000000000010', -- Gắn vào màu Kem
        'https://images.unsplash.com/photo-1598554747436-c9293d6a588f?w=800&auto=format&fit=crop&q=80',
        'Cận cảnh độ rủ mềm mại và ánh bóng nhẹ của chất lụa Satin',
        2,
        false
    )
ON CONFLICT (id) DO UPDATE SET
    image_path = EXCLUDED.image_path,
    alt_text = EXCLUDED.alt_text,
    sort_order = EXCLUDED.sort_order,
    is_primary = EXCLUDED.is_primary;

-- ------------------------------------------------------------------------------
-- 6. BANNER QUẢNG BÁ TRANG CHỦ (HERO BANNERS)
-- Hiển thị thanh trượt banner lớn trên đầu trang chủ
-- ------------------------------------------------------------------------------
INSERT INTO public.banners (
    id, title, subtitle, image_path, link_type, link_value, sort_order, is_active
)
VALUES
    (
        '50000000-0000-0000-0000-000000000001',
        'Bộ Sưu Tập MOVEN Thu Đông Mới',
        'Trải nghiệm sự tối giản thanh lịch trong từng đường kim mũi chỉ',
        'https://images.unsplash.com/photo-1490481651871-ab68de25d43d?w=1600&auto=format&fit=crop&q=80',
        'category',
        'ao-nam',
        1,
        true
    ),
    (
        '50000000-0000-0000-0000-000000000002',
        'Chất Liệu Tự Nhiên - Thoáng Mát Suốt Ngày',
        'Khám phá dòng sản phẩm Cotton Compact 100% tự nhiên',
        'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=1600&auto=format&fit=crop&q=80',
        'product',
        'ao-thun-nam-cotton-compact-moven',
        2,
        true
    )
ON CONFLICT (id) DO UPDATE SET
    title = EXCLUDED.title,
    subtitle = EXCLUDED.subtitle,
    image_path = EXCLUDED.image_path,
    link_type = EXCLUDED.link_type,
    link_value = EXCLUDED.link_value,
    sort_order = EXCLUDED.sort_order,
    is_active = EXCLUDED.is_active;

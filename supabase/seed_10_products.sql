-- ==============================================================================
-- MOVEN - SCRIPT SEED 10 SẢN PHẨM MẪU CHUẨN THỰC TẾ & BẢNG INVENTORY MOVEMENTS
-- ==============================================================================
-- Script này thiết lập bảng kiểm toán tồn kho và nạp 10 sản phẩm thời trang nam
-- chuẩn phong cách MOVEN với hình ảnh Unsplash phân giải cao chính xác 100%.
-- Đã tích hợp cơ chế chống trùng lặp SKU (Duplicate Key Protection) và tự động
-- tương thích với dữ liệu có sẵn trên Supabase.
-- ==============================================================================

-- 1. TẠO BẢNG INVENTORY_MOVEMENTS (NẾU CHƯA CÓ) VÀ THIẾT LẬP RLS
CREATE TABLE IF NOT EXISTS public.inventory_movements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    variant_id UUID NOT NULL REFERENCES public.product_variants(id) ON DELETE RESTRICT,
    order_id UUID REFERENCES public.orders(id) ON DELETE SET NULL,
    quantity_delta INTEGER NOT NULL,
    reason TEXT NOT NULL CHECK (reason IN ('order_created', 'order_cancelled', 'return_received', 'restock', 'adjustment')),
    note TEXT,
    created_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT clock_timestamp()
);

CREATE INDEX IF NOT EXISTS idx_inventory_movements_variant ON public.inventory_movements (variant_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_inventory_movements_order ON public.inventory_movements (order_id);

ALTER TABLE public.inventory_movements ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies WHERE tablename = 'inventory_movements' AND policyname = 'inventory_movements_admin_all'
    ) THEN
        CREATE POLICY inventory_movements_admin_all ON public.inventory_movements
            FOR ALL
            TO authenticated
            USING (
                EXISTS (
                    SELECT 1 FROM public.profiles
                    WHERE profiles.id = auth.uid() AND profiles.role = 'admin'
                )
            )
            WITH CHECK (
                EXISTS (
                    SELECT 1 FROM public.profiles
                    WHERE profiles.id = auth.uid() AND profiles.role = 'admin'
                )
            );
    END IF;
END $$;

-- 2. TẠO 4 DANH MỤC THỜI TRANG CHUẨN
-- Tránh trùng lặp slug nếu danh mục đã tồn tại với ID khác
UPDATE public.categories
SET slug = slug || '-old-' || substr(id::text, 1, 8)
WHERE slug IN ('ao-thun-polo', 'ao-so-mi', 'quan-tay-kaki', 'quan-jeans-short')
  AND id NOT IN (
    '10000000-0000-0000-0000-000000000001',
    '10000000-0000-0000-0000-000000000002',
    '10000000-0000-0000-0000-000000000003',
    '10000000-0000-0000-0000-000000000004'
  );

INSERT INTO public.categories (id, name, slug, description, sort_order, is_active)
VALUES
    ('10000000-0000-0000-0000-000000000001', 'Áo Thun & Polo', 'ao-thun-polo', 'Áo thun cotton và áo polo dệt bo nam tính, trẻ trung và thoáng mát', 1, true),
    ('10000000-0000-0000-0000-000000000002', 'Áo Sơ Mi Nam', 'ao-so-mi', 'Áo sơ mi Oxford công sở thanh lịch và sơ mi Linen dạo phố phóng khoáng', 2, true),
    ('10000000-0000-0000-0000-000000000003', 'Quần Tây & Kaki', 'quan-tay-kaki', 'Quần tây smart pants dáng đứng chỉn chu và quần chino kaki năng động', 3, true),
    ('10000000-0000-0000-0000-000000000004', 'Quần Jeans & Short', 'quan-jeans-short', 'Quần denim jeans bền đẹp vượt thời gian và quần short thoáng khí', 4, true)
ON CONFLICT (id) DO UPDATE SET
    name = EXCLUDED.name,
    slug = EXCLUDED.slug,
    description = EXCLUDED.description,
    sort_order = EXCLUDED.sort_order,
    is_active = EXCLUDED.is_active;

-- 3. NẠP 10 SẢN PHẨM THỜI TRANG CHUẨN XÁC
-- Tránh trùng lặp slug sản phẩm nếu đã có sản phẩm khác dùng slug này
UPDATE public.products
SET slug = slug || '-old-' || substr(id::text, 1, 8)
WHERE slug IN (
    'ao-thun-nam-cotton-compact-moven-basic',
    'ao-polo-nam-phoi-co-det-bo-moven-premium',
    'ao-so-mi-dai-tay-nam-vai-oxford',
    'ao-so-mi-co-cuba-hoa-tiet-mua-he',
    'quan-tay-nam-dang-slimfit-co-gian',
    'quan-kaki-nam-form-regular-thoang-khi',
    'quan-jeans-nam-dang-suong-phong-cach-vintage',
    'quan-short-kaki-nam-co-gian-thoang-khi',
    'ao-khoac-nam-bomber-minimalist-khang-nuoc-nhe',
    'ao-ba-lo-the-thao-quick-dry-active-tanktop'
)
AND id NOT IN (
    '20000000-0000-0000-0000-000000000001',
    '20000000-0000-0000-0000-000000000002',
    '20000000-0000-0000-0000-000000000003',
    '20000000-0000-0000-0000-000000000004',
    '20000000-0000-0000-0000-000000000005',
    '20000000-0000-0000-0000-000000000006',
    '20000000-0000-0000-0000-000000000007',
    '20000000-0000-0000-0000-000000000008',
    '20000000-0000-0000-0000-000000000009',
    '20000000-0000-0000-0000-000000000010'
);

-- SẢN PHẨM 1: Áo thun nam basic
INSERT INTO public.products (id, category_id, name, slug, description, material, target_audience, is_featured, is_active)
VALUES (
    '20000000-0000-0000-0000-000000000001',
    '10000000-0000-0000-0000-000000000001',
    'Áo Thun Nam Cotton Compact MOVEN Basic',
    'ao-thun-nam-cotton-compact-moven-basic',
    'Áo thun nam cổ tròn tối giản, phom regular tôn dáng. Sợi bông cotton chải kỹ 220gsm hạn chế nhăn xù, thấm hút mồ hôi vượt trội.',
    '100% Cotton Compact 220gsm',
    'men',
    true,
    true
) ON CONFLICT (id) DO UPDATE SET
    category_id = EXCLUDED.category_id,
    name = EXCLUDED.name,
    slug = EXCLUDED.slug,
    description = EXCLUDED.description,
    material = EXCLUDED.material,
    is_featured = EXCLUDED.is_featured,
    is_active = EXCLUDED.is_active;

-- SẢN PHẨM 2: Áo polo nam
INSERT INTO public.products (id, category_id, name, slug, description, material, target_audience, is_featured, is_active)
VALUES (
    '20000000-0000-0000-0000-000000000002',
    '10000000-0000-0000-0000-000000000001',
    'Áo Polo Nam Phối Cổ Dệt Bo MOVEN Premium',
    'ao-polo-nam-phoi-co-det-bo-moven-premium',
    'Áo polo nam cao cấp dệt tổ ong mắt chim thoáng khí. Cổ áo dệt bo dằn sợi kép giữ phom cứng cáp suốt ngày dài.',
    '65% Cotton, 35% Polyester Pique cá sấu',
    'men',
    true,
    true
) ON CONFLICT (id) DO UPDATE SET
    category_id = EXCLUDED.category_id,
    name = EXCLUDED.name,
    slug = EXCLUDED.slug,
    description = EXCLUDED.description,
    material = EXCLUDED.material,
    is_featured = EXCLUDED.is_featured,
    is_active = EXCLUDED.is_active;

-- SẢN PHẨM 3: Áo sơ mi nam tay dài Oxford
INSERT INTO public.products (id, category_id, name, slug, description, material, target_audience, is_featured, is_active)
VALUES (
    '20000000-0000-0000-0000-000000000003',
    '10000000-0000-0000-0000-000000000002',
    'Áo Sơ Mi Nam Dài Tay Công Sở Oxford Classic',
    'ao-so-mi-dai-tay-nam-vai-oxford',
    'Áo sơ mi dài tay dệt sợi Oxford dày dặn, đứng phom và ít nhăn. Cổ bẻ gài nút lịch thiệp, phù hợp môi trường công sở hiện đại.',
    '100% Cotton Oxford chải kỹ',
    'men',
    true,
    true
) ON CONFLICT (id) DO UPDATE SET
    category_id = EXCLUDED.category_id,
    name = EXCLUDED.name,
    slug = EXCLUDED.slug,
    description = EXCLUDED.description,
    material = EXCLUDED.material,
    is_featured = EXCLUDED.is_featured,
    is_active = EXCLUDED.is_active;

-- SẢN PHẨM 4: Áo sơ mi nam cộc tay cổ Cuba
INSERT INTO public.products (id, category_id, name, slug, description, material, target_audience, is_featured, is_active)
VALUES (
    '20000000-0000-0000-0000-000000000004',
    '10000000-0000-0000-0000-000000000002',
    'Áo Sơ Mi Nam Cộc Tay Cổ Cuba Dạo Phố',
    'ao-so-mi-co-cuba-hoa-tiet-mua-he',
    'Áo sơ mi cộc tay dáng relaxed với thiết kế cổ áo bẻ mở Cuba phóng khoáng. Chất vải linen pha mềm mịn, mang lại cảm giác mát mẻ tuyệt đối.',
    '70% Rayon, 30% Linen tự nhiên',
    'men',
    false,
    true
) ON CONFLICT (id) DO UPDATE SET
    category_id = EXCLUDED.category_id,
    name = EXCLUDED.name,
    slug = EXCLUDED.slug,
    description = EXCLUDED.description,
    material = EXCLUDED.material,
    is_featured = EXCLUDED.is_featured,
    is_active = EXCLUDED.is_active;

-- SẢN PHẨM 5: Quần tây nam dáng đứng
INSERT INTO public.products (id, category_id, name, slug, description, material, target_audience, is_featured, is_active)
VALUES (
    '20000000-0000-0000-0000-000000000005',
    '10000000-0000-0000-0000-000000000003',
    'Quần Tây Nam Smart Pants Slimfit Co Giãn',
    'quan-tay-nam-dang-slimfit-co-gian',
    'Quần tây công sở thiết kế cạp ẩn co giãn 4cm thông minh. Ly quần ép nhiệt sắc nét, ống quần suông gọn gàng tôn chiều cao.',
    '78% Polyester, 18% Rayon, 4% Spandex',
    'men',
    true,
    true
) ON CONFLICT (id) DO UPDATE SET
    category_id = EXCLUDED.category_id,
    name = EXCLUDED.name,
    slug = EXCLUDED.slug,
    description = EXCLUDED.description,
    material = EXCLUDED.material,
    is_featured = EXCLUDED.is_featured,
    is_active = EXCLUDED.is_active;

-- SẢN PHẨM 6: Quần kaki Chino nam
INSERT INTO public.products (id, category_id, name, slug, description, material, target_audience, is_featured, is_active)
VALUES (
    '20000000-0000-0000-0000-000000000006',
    '10000000-0000-0000-0000-000000000003',
    'Quần Kaki Chino Nam Regular Thoáng Khí',
    'quan-kaki-nam-form-regular-thoang-khi',
    'Quần Chino nam chất vải kaki cotton đanh chắc, bề mặt mịn màng. Thiết kế túi chéo sâu tiện lợi chứa điện thoại và ví tiền.',
    '98% Cotton Twill, 2% Elastane',
    'men',
    false,
    true
) ON CONFLICT (id) DO UPDATE SET
    category_id = EXCLUDED.category_id,
    name = EXCLUDED.name,
    slug = EXCLUDED.slug,
    description = EXCLUDED.description,
    material = EXCLUDED.material,
    is_featured = EXCLUDED.is_featured,
    is_active = EXCLUDED.is_active;

-- SẢN PHẨM 7: Quần jeans nam xanh indigo
INSERT INTO public.products (id, category_id, name, slug, description, material, target_audience, is_featured, is_active)
VALUES (
    '20000000-0000-0000-0000-000000000007',
    '10000000-0000-0000-0000-000000000004',
    'Quần Jeans Nam Dáng Suông Vintage Indigo',
    'quan-jeans-nam-dang-suong-phong-cach-vintage',
    'Quần denim jeans xanh chàm truyền thống, hiệu ứng wash nhẹ tự nhiên ở đùi và gối. Phom straight-leg cổ điển dễ dàng phối đồ.',
    '100% Cotton Denim 12.5oz',
    'men',
    true,
    true
) ON CONFLICT (id) DO UPDATE SET
    category_id = EXCLUDED.category_id,
    name = EXCLUDED.name,
    slug = EXCLUDED.slug,
    description = EXCLUDED.description,
    material = EXCLUDED.material,
    is_featured = EXCLUDED.is_featured,
    is_active = EXCLUDED.is_active;

-- SẢN PHẨM 8: Quần short nam kaki
INSERT INTO public.products (id, category_id, name, slug, description, material, target_audience, is_featured, is_active)
VALUES (
    '20000000-0000-0000-0000-000000000008',
    '10000000-0000-0000-0000-000000000004',
    'Quần Short Kaki Nam Co Giãn Thoáng Khí',
    'quan-short-kaki-nam-co-gian-thoang-khi',
    'Quần đùi short nam độ dài ngang gối, thiết kế túi chéo và túi sau tiện dụng. Thích hợp cho trang phục thường nhật năng động.',
    '97% Cotton, 3% Spandex co giãn',
    'men',
    false,
    true
) ON CONFLICT (id) DO UPDATE SET
    category_id = EXCLUDED.category_id,
    name = EXCLUDED.name,
    slug = EXCLUDED.slug,
    description = EXCLUDED.description,
    material = EXCLUDED.material,
    is_featured = EXCLUDED.is_featured,
    is_active = EXCLUDED.is_active;

-- SẢN PHẨM 9: Áo khoác bomber nam
INSERT INTO public.products (id, category_id, name, slug, description, material, target_audience, is_featured, is_active)
VALUES (
    '20000000-0000-0000-0000-000000000009',
    '10000000-0000-0000-0000-000000000001',
    'Áo Khoác Nam Bomber Minimalist Kháng Nước Nhẹ',
    'ao-khoac-nam-bomber-minimalist-khang-nuoc-nhe',
    'Áo khoác bomber dáng ôm gọn, khóa kéo kim loại mạ mờ cao cấp. Lớp vải ngoài chống gió cản mưa phùn nhẹ, lót dù êm ái.',
    '100% Polyester tráng màng kháng nước',
    'men',
    true,
    true
) ON CONFLICT (id) DO UPDATE SET
    category_id = EXCLUDED.category_id,
    name = EXCLUDED.name,
    slug = EXCLUDED.slug,
    description = EXCLUDED.description,
    material = EXCLUDED.material,
    is_featured = EXCLUDED.is_featured,
    is_active = EXCLUDED.is_active;

-- SẢN PHẨM 10: Áo ba lỗ tanktop thể thao nam
INSERT INTO public.products (id, category_id, name, slug, description, material, target_audience, is_featured, is_active)
VALUES (
    '20000000-0000-0000-0000-000000000010',
    '10000000-0000-0000-0000-000000000001',
    'Áo Ba Lỗ Thể Thao Quick-Dry Active Tanktop',
    'ao-ba-lo-the-thao-quick-dry-active-tanktop',
    'Áo ba lỗ thể thao nam dệt vi sợi ma trận thoát nhiệt siêu tốc. Đường viền nách khoét chuẩn thể thao giúp chuyển động linh hoạt.',
    '88% Polyester, 12% Spandex Quick-Dry',
    'men',
    false,
    true
) ON CONFLICT (id) DO UPDATE SET
    category_id = EXCLUDED.category_id,
    name = EXCLUDED.name,
    slug = EXCLUDED.slug,
    description = EXCLUDED.description,
    material = EXCLUDED.material,
    is_featured = EXCLUDED.is_featured,
    is_active = EXCLUDED.is_active;

-- 4. TẠO CÁC BIẾN THỂ SIZE, MÀU, GIÁ VÀ TỒN KHO THỰC TẾ
-- BƯỚC QUAN TRỌNG: Giải phóng tạm thời tất cả SKU để loại trừ 100% lỗi xung đột
-- unique constraint "product_variants_sku_key" giữa các bản ghi cũ và mới
UPDATE public.product_variants
SET sku = 'TEMP-' || substr(gen_random_uuid()::text, 1, 8) || '-' || sku
WHERE (id >= '30000000-0000-0000-0000-000000000001' AND id <= '30000000-0000-0000-0000-000000000024')
   OR sku IN (
       'MVN-TSH-WHT-M', 'MVN-TSH-WHT-L', 'MVN-TSH-BLK-M', 'MVN-TSH-BLK-L',
       'MVN-POL-NVY-M', 'MVN-POL-NVY-L', 'MVN-POL-BLK-L', 'MVN-POL-GRY-M',
       'MVN-OXF-WHT-M', 'MVN-OXF-BLU-L',
       'MVN-CUB-BGE-M', 'MVN-CUB-GRN-L',
       'MVN-TRS-BLK-30', 'MVN-TRS-BLK-31', 'MVN-TRS-GRY-31',
       'MVN-CHN-KHK-30', 'MVN-CHN-BLK-31',
       'MVN-JNS-BLU-30', 'MVN-JNS-BLU-31',
       'MVN-SHT-GRY-M', 'MVN-SHT-BLK-L',
       'MVN-JKT-BLK-L', 'MVN-JKT-GRN-XL',
       'MVN-TNK-WHT-M', 'MVN-TNK-BLK-L'
   );

INSERT INTO public.product_variants (id, product_id, sku, size, color_name, color_hex, price, compare_at_price, stock_quantity, is_active)
VALUES
    -- Biến thể Sp 1: Áo thun (199.000₫)
    ('30000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001', 'MVN-TSH-BLK-M', 'M', 'Đen', '#000000', 199000, 250000, 30, true),
    ('30000000-0000-0000-0000-000000000002', '20000000-0000-0000-0000-000000000001', 'MVN-TSH-BLK-L', 'L', 'Đen', '#000000', 199000, 250000, 25, true),
    ('30000000-0000-0000-0000-000000000003', '20000000-0000-0000-0000-000000000001', 'MVN-TSH-WHT-M', 'M', 'Trắng', '#FFFFFF', 199000, 250000, 4, true), -- Sắp hết hàng (Dưới 5 để test cảnh báo)
    ('30000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000001', 'MVN-TSH-WHT-L', 'L', 'Trắng', '#FFFFFF', 199000, 250000, 0, true), -- Hết hàng (0 để test lọc tồn kho)

    -- Biến thể Sp 2: Áo Polo (289.000₫)
    ('30000000-0000-0000-0000-000000000005', '20000000-0000-0000-0000-000000000002', 'MVN-POL-NVY-M', 'M', 'Xanh Navy', '#1E3A8A', 289000, 350000, 18, true),
    ('30000000-0000-0000-0000-000000000006', '20000000-0000-0000-0000-000000000002', 'MVN-POL-NVY-L', 'L', 'Xanh Navy', '#1E3A8A', 289000, 350000, 12, true),
    ('30000000-0000-0000-0000-000000000007', '20000000-0000-0000-0000-000000000002', 'MVN-POL-BLK-L', 'L', 'Đen', '#000000', 289000, 350000, 3, true), -- Sắp hết

    -- Biến thể Sp 3: Áo Sơ mi Oxford (349.000₫)
    ('30000000-0000-0000-0000-000000000008', '20000000-0000-0000-0000-000000000003', 'MVN-OXF-WHT-M', 'M', 'Trắng', '#FFFFFF', 349000, 420000, 25, true),
    ('30000000-0000-0000-0000-000000000009', '20000000-0000-0000-0000-000000000003', 'MVN-OXF-BLU-L', 'L', 'Xanh Nhạt', '#BFDBFE', 349000, 420000, 15, true),

    -- Biến thể Sp 4: Áo Sơ mi Cuba Linen (319.000₫)
    ('30000000-0000-0000-0000-000000000010', '20000000-0000-0000-0000-000000000004', 'MVN-CUB-BGE-M', 'M', 'Beige', '#F5F5DC', 319000, 380000, 22, true),
    ('30000000-0000-0000-0000-000000000011', '20000000-0000-0000-0000-000000000004', 'MVN-CUB-GRN-L', 'L', 'Xanh Rêu', '#4D7C0F', 319000, 380000, 5, true),

    -- Biến thể Sp 5: Quần Tây Smart Pants (399.000₫)
    ('30000000-0000-0000-0000-000000000012', '20000000-0000-0000-0000-000000000005', 'MVN-TRS-BLK-30', '30', 'Đen', '#000000', 399000, 490000, 30, true),
    ('30000000-0000-0000-0000-000000000013', '20000000-0000-0000-0000-000000000005', 'MVN-TRS-BLK-31', '31', 'Đen', '#000000', 399000, 490000, 16, true),
    ('30000000-0000-0000-0000-000000000014', '20000000-0000-0000-0000-000000000005', 'MVN-TRS-GRY-31', '31', 'Xám Đậm', '#374151', 399000, 490000, 2, true), -- Sắp hết

    -- Biến thể Sp 6: Quần Kaki Chino (369.000₫)
    ('30000000-0000-0000-0000-000000000015', '20000000-0000-0000-0000-000000000006', 'MVN-CHN-KHK-30', '30', 'Be Khaki', '#D4B996', 369000, 450000, 20, true),
    ('30000000-0000-0000-0000-000000000016', '20000000-0000-0000-0000-000000000006', 'MVN-CHN-BLK-31', '31', 'Đen', '#000000', 369000, 450000, 14, true),

    -- Biến thể Sp 7: Quần Jeans Denim (449.000₫)
    ('30000000-0000-0000-0000-000000000017', '20000000-0000-0000-0000-000000000007', 'MVN-JNS-BLU-30', '30', 'Xanh Indigo', '#1D4ED8', 449000, 550000, 28, true),
    ('30000000-0000-0000-0000-000000000018', '20000000-0000-0000-0000-000000000007', 'MVN-JNS-BLU-31', '31', 'Xanh Indigo', '#1D4ED8', 449000, 550000, 19, true),

    -- Biến thể Sp 8: Quần Short Kaki (249.000₫)
    ('30000000-0000-0000-0000-000000000019', '20000000-0000-0000-0000-000000000008', 'MVN-SHT-GRY-M', 'M', 'Xám Khói', '#6B7280', 249000, 320000, 25, true),
    ('30000000-0000-0000-0000-000000000020', '20000000-0000-0000-0000-000000000008', 'MVN-SHT-BLK-L', 'L', 'Đen', '#000000', 249000, 320000, 18, true),

    -- Biến thể Sp 9: Áo Khoác Bomber (499.000₫)
    ('30000000-0000-0000-0000-000000000021', '20000000-0000-0000-0000-000000000009', 'MVN-JKT-BLK-L', 'L', 'Đen', '#000000', 499000, 650000, 15, true),
    ('30000000-0000-0000-0000-000000000022', '20000000-0000-0000-0000-000000000009', 'MVN-JKT-GRN-XL', 'XL', 'Xanh Rêu', '#365314', 499000, 650000, 0, true), -- Hết hàng

    -- Biến thể Sp 10: Áo ba lỗ thể thao (159.000₫)
    ('30000000-0000-0000-0000-000000000023', '20000000-0000-0000-0000-000000000010', 'MVN-TNK-WHT-M', 'M', 'Trắng', '#FFFFFF', 159000, 210000, 40, true),
    ('30000000-0000-0000-0000-000000000024', '20000000-0000-0000-0000-000000000010', 'MVN-TNK-BLK-L', 'L', 'Đen', '#000000', 159000, 210000, 25, true)
ON CONFLICT (id) DO UPDATE SET
    product_id = EXCLUDED.product_id,
    sku = EXCLUDED.sku,
    size = EXCLUDED.size,
    color_name = EXCLUDED.color_name,
    color_hex = EXCLUDED.color_hex,
    price = EXCLUDED.price,
    compare_at_price = EXCLUDED.compare_at_price,
    stock_quantity = EXCLUDED.stock_quantity,
    is_active = EXCLUDED.is_active;

-- 5. NẠP HÌNH ẢNH SẢN PHẨM (CHUẨN XÁC 100% VISUAL MATCH VỚI MẶT HÀNG THỰC TẾ)
-- Dọn dẹp các ảnh cũ gắn với 10 sản phẩm mẫu để đồng bộ ảnh mới sạch sẽ
DELETE FROM public.product_images
WHERE product_id IN (
    '20000000-0000-0000-0000-000000000001',
    '20000000-0000-0000-0000-000000000002',
    '20000000-0000-0000-0000-000000000003',
    '20000000-0000-0000-0000-000000000004',
    '20000000-0000-0000-0000-000000000005',
    '20000000-0000-0000-0000-000000000006',
    '20000000-0000-0000-0000-000000000007',
    '20000000-0000-0000-0000-000000000008',
    '20000000-0000-0000-0000-000000000009',
    '20000000-0000-0000-0000-000000000010'
)
OR (id >= '40000000-0000-0000-0000-000000000001' AND id <= '40000000-0000-0000-0000-000000000020');

INSERT INTO public.product_images (id, product_id, image_path, alt_text, sort_order, is_primary)
VALUES
    -- 1. Ảnh ÁO THUN NAM CỔ TRÒN (Trắng basic)
    ('40000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001',
     'https://images.unsplash.com/photo-1521572267360-ee0c2909d518?w=800&auto=format&fit=crop&q=80',
     'Áo thun nam trắng cổ tròn MOVEN', 1, true),

    -- 2. Ảnh ÁO POLO NAM DỆT BO (Xanh navy có cổ)
    ('40000000-0000-0000-0000-000000000002', '20000000-0000-0000-0000-000000000002',
     'https://images.unsplash.com/photo-1625910513413-742299863836?w=800&auto=format&fit=crop&q=80',
     'Áo polo nam dệt bo navy MOVEN', 1, true),

    -- 3. Ảnh ÁO SƠ MI DÀI TAY OXFORD (Cài nút công sở)
    ('40000000-0000-0000-0000-000000000003', '20000000-0000-0000-0000-000000000003',
     'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=800&auto=format&fit=crop&q=80',
     'Áo sơ mi nam tay dài công sở Oxford', 1, true),

    -- 4. Ảnh ÁO SƠ MI CỘC TAY CỔ CUBA (Dạo phố mùa hè)
    ('40000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000004',
     'https://images.unsplash.com/photo-1602810318383-e386cc2a3ccf?w=800&auto=format&fit=crop&q=80',
     'Áo sơ mi nam cộc tay cổ Cuba dạo phố', 1, true),

    -- 5. Ảnh QUẦN TÂY DÁNG ĐỨNG CÔNG SỞ (Chuẩn xác 100% hình quần tây nam)
    ('40000000-0000-0000-0000-000000000005', '20000000-0000-0000-0000-000000000005',
     'https://images.unsplash.com/photo-1624378439575-d8705ad7ae80?w=800&auto=format&fit=crop&q=80',
     'Quần tây nam dáng đứng Smart Pants', 1, true),

    -- 6. Ảnh QUẦN KAKI CHINO (Chuẩn xác 100% hình quần dài kaki be)
    ('40000000-0000-0000-0000-000000000006', '20000000-0000-0000-0000-000000000006',
     'https://images.unsplash.com/photo-1473966968600-fa801b869a1a?w=800&auto=format&fit=crop&q=80',
     'Quần kaki nam Chino be ống suông', 1, true),

    -- 7. Ảnh QUẦN JEANS DENIM XANH (Chuẩn xác 100% hình quần jeans bò)
    ('40000000-0000-0000-0000-000000000007', '20000000-0000-0000-0000-000000000007',
     'https://images.unsplash.com/photo-1542272604-787c3835535d?w=800&auto=format&fit=crop&q=80',
     'Quần jeans nam xanh indigo cổ điển', 1, true),

    -- 8. Ảnh QUẦN SHORT ĐÙI NAM (Chuẩn xác 100% hình quần short)
    ('40000000-0000-0000-0000-000000000008', '20000000-0000-0000-0000-000000000008',
     'https://images.unsplash.com/photo-1591195853828-11db59a44f6b?w=800&auto=format&fit=crop&q=80',
     'Quần short kaki nam thoáng mát', 1, true),

    -- 9. Ảnh ÁO KHOÁC BOMBER (Chuẩn xác 100% hình áo khoác bomber nam)
    ('40000000-0000-0000-0000-000000000009', '20000000-0000-0000-0000-000000000009',
     'https://images.unsplash.com/photo-1551028719-00167b16eac5?w=800&auto=format&fit=crop&q=80',
     'Áo khoác bomber nam minimalist chống nước', 1, true),

    -- 10. Ảnh ÁO BA LỖ THỂ THAO (Chuẩn xác 100% hình áo ba lỗ thể thao)
    ('40000000-0000-0000-0000-000000000010', '20000000-0000-0000-0000-000000000010',
     'https://images.unsplash.com/photo-1581655353564-df123a1eb820?w=800&auto=format&fit=crop&q=80',
     'Áo ba lỗ thể thao nam Quick-Dry', 1, true)
ON CONFLICT (id) DO UPDATE SET
    product_id = EXCLUDED.product_id,
    image_path = EXCLUDED.image_path,
    alt_text = EXCLUDED.alt_text,
    sort_order = EXCLUDED.sort_order,
    is_primary = EXCLUDED.is_primary;

-- 6. TẠO 2 BANNER TRANG CHỦ CHUẨN THỜI TRANG MOVEN
INSERT INTO public.banners (id, title, subtitle, image_path, link_type, link_value, is_active, sort_order)
VALUES
    ('50000000-0000-0000-0000-000000000001',
     'MOVEN New Collection 2026',
     'Phong cách thời trang nam tối giản, sang trọng và chuẩn mực',
     'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=1600&auto=format&fit=crop&q=80',
     'category',
     'ao-thun-polo',
     true,
     1),
    ('50000000-0000-0000-0000-000000000002',
     'Thanh Lịch Nơi Công Sở',
     'Sơ mi Oxford & Quần Tây Smart Pants - Nâng tầm diện mạo',
     'https://images.unsplash.com/photo-1490481651871-ab68de25d43d?w=1600&auto=format&fit=crop&q=80',
     'category',
     'quan-tay-kaki',
     true,
     2)
ON CONFLICT (id) DO UPDATE SET
    title = EXCLUDED.title,
    subtitle = EXCLUDED.subtitle,
    image_path = EXCLUDED.image_path,
    link_type = EXCLUDED.link_type,
    link_value = EXCLUDED.link_value,
    is_active = EXCLUDED.is_active,
    sort_order = EXCLUDED.sort_order;

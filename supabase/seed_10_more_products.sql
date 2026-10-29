-- ==============================================================================
-- MOVEN - SCRIPT SEED BỔ SUNG 10 SẢN PHẨM MỚI ĐA DẠNG & DANH MỤC CHUẨN XÁC
-- ==============================================================================
-- Script này:
-- 1. Thêm 3 danh mục thời trang chuyên biệt mới (Áo Khoác & Blazer, Áo Len & Hoodie, Đồ Thể Thao & Jogger)
-- 2. Tự động chuyển sản phẩm áo khoác cũ (#9) về đúng danh mục Áo Khoác & Blazer
-- 3. Nạp 10 sản phẩm mới (#11 đến #20) với danh mục tương thích 100%, ảnh thực tế visual-match từ Unsplash
-- 4. Tạo đầy đủ các biến thể size, màu, mã SKU duy nhất, tồn kho và giá cả hợp lý
-- ==============================================================================

-- 1. BỔ SUNG CÁC DANH MỤC THỜI TRANG CHUYÊN BIỆT
INSERT INTO public.categories (id, name, slug, description, sort_order, is_active)
VALUES
    ('10000000-0000-0000-0000-000000000005', 'Áo Khoác & Blazer', 'ao-khoac-blazer', 'Áo khoác gió windbreaker, áo khoác denim bò và áo vest blazer nam thời thượng', 5, true),
    ('10000000-0000-0000-0000-000000000006', 'Áo Len & Hoodie', 'ao-len-hoodie', 'Áo hoodie nỉ bông ấm áp, áo len cổ lọ dệt kim cao cấp cho mùa thu đông', 6, true),
    ('10000000-0000-0000-0000-000000000007', 'Đồ Thể Thao & Jogger', 'do-the-thao-jogger', 'Quần jogger nỉ thun năng động, quần short thể thao chạy bộ thoáng khí', 7, true)
ON CONFLICT (id) DO UPDATE SET
    name = EXCLUDED.name,
    slug = EXCLUDED.slug,
    description = EXCLUDED.description,
    sort_order = EXCLUDED.sort_order,
    is_active = EXCLUDED.is_active;

-- Tự động cập nhật Sản phẩm #9 (Áo Khoác Bomber cũ) sang đúng danh mục Áo Khoác & Blazer nếu đã có trong DB
UPDATE public.products
SET category_id = '10000000-0000-0000-0000-000000000005'
WHERE id = '20000000-0000-0000-0000-000000000009';

-- 2. NẠP 10 SẢN PHẨM MỚI ĐA DẠNG CHUẨN XÁC

-- Tránh trùng lặp slug sản phẩm nếu đã có
UPDATE public.products
SET slug = slug || '-old-' || substr(id::text, 1, 8)
WHERE slug IN (
    'ao-hoodie-ni-bong-unisex-form-rong-basic',
    'ao-len-co-lo-nam-det-kim-day-dan-autumn',
    'ao-khoac-gio-nam-2-lop-chong-nuoc-gon-nhe',
    'ao-blazer-nam-may-do-kieu-han-quoc-smart-casual',
    'ao-khoac-denim-bo-nam-co-be-classic-trucker',
    'ao-so-mi-nam-co-tru-vai-dui-tu-nhien-casual',
    'quan-kaki-tui-hop-nam-cargo-pants-outdoor',
    'quan-jeans-nam-rach-goi-ca-tinh-streetwear',
    'quan-jogger-the-thao-nam-ni-thun-day-rut',
    'quan-short-the-thao-du-2-lop-chay-bo-running'
)
AND id NOT IN (
    '20000000-0000-0000-0000-000000000011',
    '20000000-0000-0000-0000-000000000012',
    '20000000-0000-0000-0000-000000000013',
    '20000000-0000-0000-0000-000000000014',
    '20000000-0000-0000-0000-000000000015',
    '20000000-0000-0000-0000-000000000016',
    '20000000-0000-0000-0000-000000000017',
    '20000000-0000-0000-0000-000000000018',
    '20000000-0000-0000-0000-000000000019',
    '20000000-0000-0000-0000-000000000020'
);

-- SẢN PHẨM 11: Áo Hoodie Nỉ Bông Unisex
INSERT INTO public.products (id, category_id, name, slug, description, material, target_audience, is_featured, is_active)
VALUES (
    '20000000-0000-0000-0000-000000000011',
    '10000000-0000-0000-0000-000000000006', -- Danh mục: Áo Len & Hoodie
    'Áo Hoodie Nỉ Bông Unisex Form Rộng Basic',
    'ao-hoodie-ni-bong-unisex-form-rong-basic',
    'Áo nỉ chui đầu có mũ rộng rãi phong cách đường phố trẻ trung. Lớp trong lót bông cotton 350gsm dày dặn, giữ ấm hoàn hảo cho những ngày se lạnh.',
    '80% Cotton, 20% Polyester Nỉ Bông 350gsm',
    'unisex',
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

-- SẢN PHẨM 12: Áo Len Cổ Lọ Nam Dệt Kim
INSERT INTO public.products (id, category_id, name, slug, description, material, target_audience, is_featured, is_active)
VALUES (
    '20000000-0000-0000-0000-000000000012',
    '10000000-0000-0000-0000-000000000006', -- Danh mục: Áo Len & Hoodie
    'Áo Len Cổ Lọ Nam Dệt Kim Dày Dặn Autumn',
    'ao-len-co-lo-nam-det-kim-day-dan-autumn',
    'Áo len nam cổ lọ thiết kế dệt kim vặn thừng cổ điển tinh tế. Sợi len acrylic pha lông cừu mềm mại, không gây ngứa cộm, giữ ấm cổ tối đa.',
    '70% Sợi Dệt Kim Acrylic, 30% Lông Cừu',
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

-- SẢN PHẨM 13: Áo Khoác Gió Nam Windbreaker
INSERT INTO public.products (id, category_id, name, slug, description, material, target_audience, is_featured, is_active)
VALUES (
    '20000000-0000-0000-0000-000000000013',
    '10000000-0000-0000-0000-000000000005', -- Danh mục: Áo Khoác & Blazer
    'Áo Khoác Gió Nam 2 Lớp Chống Nước Gọn Nhẹ',
    'ao-khoac-gio-nam-2-lop-chong-nuoc-gon-nhe',
    'Áo khoác dù gió thể thao cản gió và trượt nước công nghệ nano. Có mũ trùm gập gọn vào cổ áo, túi có khóa zip chống nước tiện lợi.',
    '100% Polyester Chống Thấm Nano',
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

-- SẢN PHẨM 14: Áo Blazer Nam Smart Casual
INSERT INTO public.products (id, category_id, name, slug, description, material, target_audience, is_featured, is_active)
VALUES (
    '20000000-0000-0000-0000-000000000014',
    '10000000-0000-0000-0000-000000000005', -- Danh mục: Áo Khoác & Blazer
    'Áo Blazer Nam May Đo Kiểu Hàn Quốc Smart Casual',
    'ao-blazer-nam-may-do-kieu-han-quoc-smart-casual',
    'Áo vest blazer nam 1 hàng khuy dáng suông hiện đại phong cách Hàn Quốc. Không đệm vai cứng nhắc, tạo nét lịch lãm phóng khoáng khi phối cùng thun hoặc sơ mi.',
    '75% Polyester, 22% Rayon, 3% Spandex',
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

-- SẢN PHẨM 15: Áo Khoác Denim Bò Nam Trucker
INSERT INTO public.products (id, category_id, name, slug, description, material, target_audience, is_featured, is_active)
VALUES (
    '20000000-0000-0000-0000-000000000015',
    '10000000-0000-0000-0000-000000000005', -- Danh mục: Áo Khoác & Blazer
    'Áo Khoác Denim Bò Nam Cổ Bẻ Classic Trucker',
    'ao-khoac-denim-bo-nam-co-be-classic-trucker',
    'Áo khoác bò nam phom trucker cổ bẻ phong trần, 2 túi ngực nắp gập và khuy kim loại đồng mạ lì vintage. Vải denim 13oz dày dặn, đanh bền.',
    '100% Cotton Denim Jean 13oz',
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

-- SẢN PHẨM 16: Áo Sơ Mi Nam Cổ Trụ Vải Đũi
INSERT INTO public.products (id, category_id, name, slug, description, material, target_audience, is_featured, is_active)
VALUES (
    '20000000-0000-0000-0000-000000000016',
    '10000000-0000-0000-0000-000000000002', -- Danh mục: Áo Sơ Mi Nam
    'Áo Sơ Mi Nam Cổ Trụ Vải Đũi Tự Nhiên Casual',
    'ao-so-mi-nam-co-tru-vai-dui-tu-nhien-casual',
    'Áo sơ mi nam cổ trụ (cổ tàu) may từ chất vải đũi tự nhiên thoáng mát. Đường may tỉ mỉ, phom dáng suông nhẹ mang đến phong thái thư thái, lịch sự.',
    '60% Linen Đũi, 40% Cotton Tự Nhiên',
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

-- SẢN PHẨM 17: Quần Kaki Túi Hộp Nam Cargo Pants
INSERT INTO public.products (id, category_id, name, slug, description, material, target_audience, is_featured, is_active)
VALUES (
    '20000000-0000-0000-0000-000000000017',
    '10000000-0000-0000-0000-000000000003', -- Danh mục: Quần Tây & Kaki
    'Quần Kaki Túi Hộp Nam Cargo Pants Outdoor',
    'quan-kaki-tui-hop-nam-cargo-pants-outdoor',
    'Quần dài kaki nam thiết kế túi hộp đôi hai bên sườn đùi phong cách quân đội khỏe khoắn. Gấu quần có khóa khuy rút gọn ống tiện lợi khi di chuyển dã ngoại.',
    '100% Cotton Kaki Twill Dày Dặn',
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

-- SẢN PHẨM 18: Quần Jeans Nam Rách Gối Streetwear
INSERT INTO public.products (id, category_id, name, slug, description, material, target_audience, is_featured, is_active)
VALUES (
    '20000000-0000-0000-0000-000000000018',
    '10000000-0000-0000-0000-000000000004', -- Danh mục: Quần Jeans & Short
    'Quần Jeans Nam Rách Gối Cá Tính Streetwear',
    'quan-jeans-nam-rach-goi-ca-tinh-streetwear',
    'Quần bò nam wash sáng điểm xuyết vết xước rách gối nhẹ nhàng thời trang đường phố. Chất denim pha elastane co giãn tốt, mặc cực kỳ êm chân và thoải mái.',
    '98% Cotton Denim, 2% Spandex Co Giãn',
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

-- SẢN PHẨM 19: Quần Jogger Thể Thao Nam Nỉ Thun
INSERT INTO public.products (id, category_id, name, slug, description, material, target_audience, is_featured, is_active)
VALUES (
    '20000000-0000-0000-0000-000000000019',
    '10000000-0000-0000-0000-000000000007', -- Danh mục: Đồ Thể Thao & Jogger
    'Quần Jogger Thể Thao Nam Nỉ Thun Dây Rút',
    'quan-jogger-the-thao-nam-ni-thun-day-rut',
    'Quần jogger nam bo gấu ống, cạp thun co giãn kết hợp dây rút tiện lợi. Chất nỉ thun cao cấp co giãn 4 chiều, hỗ trợ vận động tối đa khi tập luyện hay chạy bộ.',
    '85% Cotton, 15% Polyester Thun Nỉ 4 Chiều',
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

-- SẢN PHẨM 20: Quần Short Thể Thao Dù 2 Lớp Running
INSERT INTO public.products (id, category_id, name, slug, description, material, target_audience, is_featured, is_active)
VALUES (
    '20000000-0000-0000-0000-000000000020',
    '10000000-0000-0000-0000-000000000007', -- Danh mục: Đồ Thể Thao & Jogger
    'Quần Short Thể Thao Dù 2 Lớp Chạy Bộ Running',
    'quan-short-the-thao-du-2-lop-chay-bo-running',
    'Quần đùi chạy bộ nam 2 lớp chuyên dụng: lớp trong ôm cơ đùi chống cọ xát, lớp ngoài vải dù siêu nhẹ thoáng nhiệt. Lưng thun có ngăn để điện thoại chống xóc.',
    '90% Polyester Dù Thoáng Khí, 10% Spandex Lớp Trong',
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


-- 3. NẠP BIẾN THỂ SIZE, MÀU, GIÁ & TỒN KHO THỰC TẾ
INSERT INTO public.product_variants (id, product_id, sku, size, color_name, color_hex, price, compare_at_price, stock_quantity, is_active)
VALUES
    -- Biến thể Sp 11: Áo Hoodie Nỉ Bông (389.000₫)
    ('30000000-0000-0000-0000-000000000025', '20000000-0000-0000-0000-000000000011', 'MVN-HD-GRY-L', 'L', 'Xám Tiêu', '#9CA3AF', 389000, 480000, 30, true),
    ('30000000-0000-0000-0000-000000000026', '20000000-0000-0000-0000-000000000011', 'MVN-HD-BLK-XL', 'XL', 'Đen', '#000000', 389000, 480000, 20, true),

    -- Biến thể Sp 12: Áo Len Cổ Lọ Nam (450.000₫)
    ('30000000-0000-0000-0000-000000000027', '20000000-0000-0000-0000-000000000012', 'MVN-KNIT-BGE-M', 'M', 'Nâu Be', '#D4B996', 450000, 550000, 18, true),
    ('30000000-0000-0000-0000-000000000028', '20000000-0000-0000-0000-000000000012', 'MVN-KNIT-BLK-L', 'L', 'Đen', '#000000', 450000, 550000, 15, true),

    -- Biến thể Sp 13: Áo Khoác Gió Nam (429.000₫)
    ('30000000-0000-0000-0000-000000000029', '20000000-0000-0000-0000-000000000013', 'MVN-WND-NVY-L', 'L', 'Xanh Navy', '#1E3A8A', 429000, 520000, 25, true),
    ('30000000-0000-0000-0000-000000000030', '20000000-0000-0000-0000-000000000013', 'MVN-WND-BLK-XL', 'XL', 'Đen', '#000000', 429000, 520000, 14, true),

    -- Biến thể Sp 14: Áo Blazer Nam (689.000₫)
    ('30000000-0000-0000-0000-000000000031', '20000000-0000-0000-0000-000000000014', 'MVN-BLZ-BLK-L', 'L', 'Đen Tuyền', '#111827', 689000, 850000, 12, true),
    ('30000000-0000-0000-0000-000000000032', '20000000-0000-0000-0000-000000000014', 'MVN-BLZ-BRN-XL', 'XL', 'Nâu Mocha', '#582F0E', 689000, 850000, 8, true),

    -- Biến thể Sp 15: Áo Khoác Denim Bò (549.000₫)
    ('30000000-0000-0000-0000-000000000033', '20000000-0000-0000-0000-000000000015', 'MVN-DNM-BLU-L', 'L', 'Xanh Bò Vintage', '#2563EB', 549000, 690000, 16, true),
    ('30000000-0000-0000-0000-000000000034', '20000000-0000-0000-0000-000000000015', 'MVN-DNM-BLK-XL', 'XL', 'Đen Wash', '#374151', 549000, 690000, 10, true),

    -- Biến thể Sp 16: Áo Sơ Mi Nam Cổ Trụ (329.000₫)
    ('30000000-0000-0000-0000-000000000035', '20000000-0000-0000-0000-000000000016', 'MVN-SHT-WHT-M', 'M', 'Trắng Sữa', '#F9FAFB', 329000, 410000, 22, true),
    ('30000000-0000-0000-0000-000000000036', '20000000-0000-0000-0000-000000000016', 'MVN-SHT-SKY-L', 'L', 'Xanh Nhạt', '#BAE6FD', 329000, 410000, 17, true),

    -- Biến thể Sp 17: Quần Kaki Túi Hộp (419.000₫)
    ('30000000-0000-0000-0000-000000000037', '20000000-0000-0000-0000-000000000017', 'MVN-CRG-GRN-30', '30', 'Xanh Rêu Lính', '#365314', 419000, 520000, 20, true),
    ('30000000-0000-0000-0000-000000000038', '20000000-0000-0000-0000-000000000017', 'MVN-CRG-BLK-31', '31', 'Đen', '#000000', 419000, 520000, 15, true),

    -- Biến thể Sp 18: Quần Jeans Rách Gối (469.000₫)
    ('30000000-0000-0000-0000-000000000039', '20000000-0000-0000-0000-000000000018', 'MVN-JNS-RIP-30', '30', 'Xanh Sáng Wash', '#60A5FA', 469000, 580000, 24, true),
    ('30000000-0000-0000-0000-000000000040', '20000000-0000-0000-0000-000000000018', 'MVN-JNS-RIP-31', '31', 'Xanh Sáng Wash', '#60A5FA', 469000, 580000, 18, true),

    -- Biến thể Sp 19: Quần Jogger Thể Thao (299.000₫)
    ('30000000-0000-0000-0000-000000000041', '20000000-0000-0000-0000-000000000019', 'MVN-JOG-GRY-L', 'L', 'Xám Ghi', '#6B7280', 299000, 380000, 30, true),
    ('30000000-0000-0000-0000-000000000042', '20000000-0000-0000-0000-000000000019', 'MVN-JOG-BLK-XL', 'XL', 'Đen', '#000000', 299000, 380000, 22, true),

    -- Biến thể Sp 20: Quần Short Chạy Bộ 2 Lớp (219.000₫)
    ('30000000-0000-0000-0000-000000000043', '20000000-0000-0000-0000-000000000020', 'MVN-RUN-BLK-M', 'M', 'Đen', '#000000', 219000, 280000, 35, true),
    ('30000000-0000-0000-0000-000000000044', '20000000-0000-0000-0000-000000000020', 'MVN-RUN-GRN-L', 'L', 'Xanh Rêu', '#4D7C0F', 219000, 280000, 20, true)
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


-- 4. NẠP HÌNH ẢNH SẢN PHẨM CHUẨN XÁC 100% VISUAL-MATCH
DELETE FROM public.product_images
WHERE product_id IN (
    '20000000-0000-0000-0000-000000000011',
    '20000000-0000-0000-0000-000000000012',
    '20000000-0000-0000-0000-000000000013',
    '20000000-0000-0000-0000-000000000014',
    '20000000-0000-0000-0000-000000000015',
    '20000000-0000-0000-0000-000000000016',
    '20000000-0000-0000-0000-000000000017',
    '20000000-0000-0000-0000-000000000018',
    '20000000-0000-0000-0000-000000000019',
    '20000000-0000-0000-0000-000000000020'
)
OR (id >= '40000000-0000-0000-0000-000000000021' AND id <= '40000000-0000-0000-0000-000000000030');

INSERT INTO public.product_images (id, product_id, image_path, alt_text, sort_order, is_primary)
VALUES
    -- 11. Ảnh ÁO HOODIE NỈ BÔNG (Chuẩn áo hoodie nỉ phom rộng có mũ)
    ('40000000-0000-0000-0000-000000000021', '20000000-0000-0000-0000-000000000011',
     'https://images.unsplash.com/photo-1620799140188-3b2a02fd9a77?w=800&auto=format&fit=crop&q=80',
     'Áo hoodie nỉ bông unisex phom rộng MOVEN', 1, true),

    -- 12. Ảnh ÁO LEN CỔ LỌ (Chuẩn áo len dệt kim cổ cao nam)
    ('40000000-0000-0000-0000-000000000022', '20000000-0000-0000-0000-000000000012',
     'https://images.unsplash.com/photo-1614975058789-41316d0e2e9c?w=800&auto=format&fit=crop&q=80',
     'Áo len nam dệt kim cổ lọ thu đông MOVEN', 1, true),

    -- 13. Ảnh ÁO KHOÁC GIÓ WINDBREAKER (Chuẩn áo khoác dù gió thể thao)
    ('40000000-0000-0000-0000-000000000023', '20000000-0000-0000-0000-000000000013',
     'https://images.unsplash.com/photo-1544441893-675973e31985?w=800&auto=format&fit=crop&q=80',
     'Áo khoác gió nam 2 lớp chống thấm MOVEN', 1, true),

    -- 14. Ảnh ÁO BLAZER NAM (Chuẩn áo vest blazer nam lịch lãm)
    ('40000000-0000-0000-0000-000000000024', '20000000-0000-0000-0000-000000000014',
     'https://images.unsplash.com/photo-1507679799987-c73779587ccf?w=800&auto=format&fit=crop&q=80',
     'Áo blazer nam kiểu Hàn Quốc hiện đại MOVEN', 1, true),

    -- 15. Ảnh ÁO KHOÁC DENIM TRUCKER (Chuẩn áo khoác bò jean cổ bẻ)
    ('40000000-0000-0000-0000-000000000025', '20000000-0000-0000-0000-000000000015',
     'https://images.unsplash.com/photo-1576995853123-5a10305d93c0?w=800&auto=format&fit=crop&q=80',
     'Áo khoác denim nam phom trucker cổ điển MOVEN', 1, true),

    -- 16. Ảnh ÁO SƠ MI CỔ TRỤ VẢI ĐŨI (Chuẩn áo sơ mi nam cổ trụ)
    ('40000000-0000-0000-0000-000000000026', '20000000-0000-0000-0000-000000000016',
     'https://images.unsplash.com/photo-1598033129183-c4f50c736f10?w=800&auto=format&fit=crop&q=80',
     'Áo sơ mi nam cổ trụ vải đũi tự nhiên MOVEN', 1, true),

    -- 17. Ảnh QUẦN KAKI TÚI HỘP CARGO (Chuẩn quần cargo pants có túi hộp sườn)
    ('40000000-0000-0000-0000-000000000027', '20000000-0000-0000-0000-000000000017',
     'https://images.unsplash.com/photo-1517445312882-bc9910d016b7?w=800&auto=format&fit=crop&q=80',
     'Quần kaki túi hộp nam cargo pants MOVEN', 1, true),

    -- 18. Ảnh QUẦN JEANS RÁCH GỐI STREETWEAR (Chuẩn quần bò jeans rách)
    ('40000000-0000-0000-0000-000000000028', '20000000-0000-0000-0000-000000000018',
     'https://images.unsplash.com/photo-1541099649105-f69ad21f3246?w=800&auto=format&fit=crop&q=80',
     'Quần jeans nam mài rách gối cá tính MOVEN', 1, true),

    -- 19. Ảnh QUẦN JOGGER THỂ THAO NỈ (Chuẩn quần jogger nỉ thun bo gấu)
    ('40000000-0000-0000-0000-000000000029', '20000000-0000-0000-0000-000000000019',
     'https://images.unsplash.com/photo-1552902865-b72c031ac5ea?w=800&auto=format&fit=crop&q=80',
     'Quần jogger nam nỉ thun thể thao MOVEN', 1, true),

    -- 20. Ảnh QUẦN SHORT CHẠY BỘ 2 LỚP (Chuẩn quần đùi short chạy bộ nam)
    ('40000000-0000-0000-0000-000000000030', '20000000-0000-0000-0000-000000000020',
     'https://images.unsplash.com/photo-1533229277876-002294575f48?w=800&auto=format&fit=crop&q=80',
     'Quần short thể thao dù 2 lớp chạy bộ MOVEN', 1, true);

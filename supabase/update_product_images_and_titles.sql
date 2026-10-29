-- ==============================================================================
-- MOVEN - SCRIPT CẬP NHẬT TỨC THÌ: ĐỒNG BỘ 100% HÌNH ẢNH VÀ TIÊU ĐỀ SẢN PHẨM
-- ==============================================================================
-- Chạy script này trên Supabase SQL Editor để cập nhật ngay lập tức:
-- 1. Sản phẩm #20: Cập nhật ảnh Quần Short Thể Thao Running chuyên dụng chuẩn visual (thay cho ảnh áo thun cũ)
-- 2. Sản phẩm #10: Cập nhật tiêu đề thành Áo Thun Trơn Minimalist White (chuẩn xác với ảnh áo thun trắng có sẵn)
-- 3. Sản phẩm #11: Cập nhật ảnh Áo Hoodie Nỉ Bông phom rộng sắc nét chuẩn form
-- ==============================================================================

-- 1. CẬP NHẬT ẢNH SẢN PHẨM #20 (QUẦN SHORT THỂ THAO CHẠY BỘ RUNNING)
UPDATE public.product_images
SET 
    image_path = 'https://images.unsplash.com/photo-1533229277876-002294575f48?w=800&auto=format&fit=crop&q=80',
    alt_text = 'Quần short thể thao dù 2 lớp chạy bộ MOVEN'
WHERE product_id = '20000000-0000-0000-0000-000000000020'
   OR id = '40000000-0000-0000-0000-000000000030';

-- Đảm bảo sản phẩm #20 giữ đúng danh mục Đồ Thể Thao & Jogger
UPDATE public.products
SET 
    category_id = '10000000-0000-0000-0000-000000000007',
    name = 'Quần Short Thể Thao Dù 2 Lớp Chạy Bộ Running',
    slug = 'quan-short-the-thao-du-2-lop-chay-bo-running',
    description = 'Quần đùi chạy bộ nam 2 lớp chuyên dụng: lớp trong ôm cơ đùi chống cọ xát, lớp ngoài vải dù siêu nhẹ thoáng nhiệt. Lưng thun có ngăn để điện thoại chống xóc.',
    material = '90% Polyester Dù Thoáng Khí, 10% Spandex Lớp Trong',
    updated_at = clock_timestamp()
WHERE id = '20000000-0000-0000-0000-000000000020';

-- 2. CẬP NHẬT SẢN PHẨM #10: ĐỒNG BỘ TIÊU ĐỀ KHỚP VỚI ẢNH ÁO THUN TRẮNG CỔ TRÒN
UPDATE public.products
SET 
    category_id = '10000000-0000-0000-0000-000000000001', -- Áo Thun & Polo
    name = 'Áo Thun Nam Trơn Cổ Tròn Minimalist White',
    slug = 'ao-thun-nam-tron-co-tron-minimalist-white',
    description = 'Áo thun nam màu trắng trơn cổ tròn phom regular tối giản và thanh lịch. Sợi bông cotton chải kỹ mềm mịn, co giãn nhẹ và thấm hút mồ hôi tối đa.',
    material = '100% Cotton Chải Kỹ Cao Cấp',
    updated_at = clock_timestamp()
WHERE id = '20000000-0000-0000-0000-000000000010';

UPDATE public.product_images
SET 
    image_path = 'https://images.unsplash.com/photo-1581655353564-df123a1eb820?w=800&auto=format&fit=crop&q=80',
    alt_text = 'Áo thun nam trắng trơn cổ tròn Minimalist MOVEN'
WHERE product_id = '20000000-0000-0000-0000-000000000010'
   OR id = '40000000-0000-0000-0000-000000000010';

-- 3. CẬP NHẬT ẢNH SẢN PHẨM #11 (ÁO HOODIE NỈ BÔNG PHOM RỘNG)
UPDATE public.product_images
SET 
    image_path = 'https://images.unsplash.com/photo-1620799140188-3b2a02fd9a77?w=800&auto=format&fit=crop&q=80',
    alt_text = 'Áo hoodie nỉ bông unisex phom rộng MOVEN'
WHERE product_id = '20000000-0000-0000-0000-000000000011'
   OR id = '40000000-0000-0000-0000-000000000021';

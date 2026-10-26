-- ==============================================================================
-- MOVEN E-COMMERCE: THIẾT LẬP TOÀN BỘ CƠ SỞ DỮ LIỆU TRÊN SUPABASE (ALL-IN-ONE)
-- Chạy 1 lần duy nhất trong Supabase SQL Editor để thiết lập:
--   1. 16 Bảng dữ liệu + Ràng buộc toàn vẹn + Chỉ mục + Triggers updated_at
--   2. Kích hoạt bảo mật RLS trên 100% các bảng + Phân quyền 3 vai trò (Anon, Customer, Admin)
--   3. Khởi tạo 3 Storage Buckets (product-media, banners, avatars) + Storage Policies
--   4. Dữ liệu mẫu ban đầu kèm bộ sưu tập ảnh thời trang đa góc chụp & đổi theo màu
--
-- Quy ước mã định danh UUID chuẩn Hexadecimal (0-9):
--   - Đầu 10000000-xxxx: Mã Danh mục (Categories)
--   - Đầu 20000000-xxxx: Mã Sản phẩm (Products)
--   - Đầu 30000000-xxxx: Mã Biến thể sản phẩm (Variants)
--   - Đầu 40000000-xxxx: Mã Ảnh sản phẩm (Product Images)
--   - Đầu 50000000-xxxx: Mã Banner quảng bá (Banners)
-- ==============================================================================

-- ==============================================================================
-- PHẦN 1: SCHEMA CƠ SỞ DỮ LIỆU (16 BẢNG NGHIỆP VỤ)
-- ==============================================================================

-- Kích hoạt tiện ích mở rộng UUID
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Hàm trigger tự động cập nhật thời gian updated_at khi có chỉnh sửa dòng
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = clock_timestamp();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 1. PROFILES (Hồ sơ ứng dụng gắn 1:1 với tài khoản auth.users của Supabase)
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    full_name TEXT NOT NULL DEFAULT '',
    phone TEXT,
    role TEXT NOT NULL DEFAULT 'customer' CHECK (role IN ('customer', 'admin')),
    avatar_path TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT clock_timestamp(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT clock_timestamp()
);

DROP TRIGGER IF EXISTS trg_profiles_updated_at ON public.profiles;
CREATE TRIGGER trg_profiles_updated_at
BEFORE UPDATE ON public.profiles
FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- 2. ADDRESSES (Sổ địa chỉ giao hàng của khách)
CREATE TABLE IF NOT EXISTS public.addresses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    recipient_name TEXT NOT NULL,
    phone TEXT NOT NULL,
    province TEXT NOT NULL,
    district TEXT NOT NULL,
    ward TEXT NOT NULL,
    address_line TEXT NOT NULL,
    is_default BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT clock_timestamp(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT clock_timestamp()
);

CREATE UNIQUE INDEX IF NOT EXISTS idx_addresses_user_default ON public.addresses (user_id) WHERE is_default = true;
CREATE INDEX IF NOT EXISTS idx_addresses_user_id ON public.addresses (user_id);

DROP TRIGGER IF EXISTS trg_addresses_updated_at ON public.addresses;
CREATE TRIGGER trg_addresses_updated_at
BEFORE UPDATE ON public.addresses
FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- 3. CATEGORIES (Danh mục phân loại sản phẩm)
CREATE TABLE IF NOT EXISTS public.categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    slug TEXT NOT NULL UNIQUE,
    description TEXT,
    image_path TEXT,
    is_active BOOLEAN NOT NULL DEFAULT true,
    sort_order INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT clock_timestamp(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT clock_timestamp()
);

CREATE INDEX IF NOT EXISTS idx_categories_is_active_sort ON public.categories (is_active, sort_order);

DROP TRIGGER IF EXISTS trg_categories_updated_at ON public.categories;
CREATE TRIGGER trg_categories_updated_at
BEFORE UPDATE ON public.categories
FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- 4. PRODUCTS (Sản phẩm - Bỏ base_price theo quyết định D-10 để tránh xung đột giá)
CREATE TABLE IF NOT EXISTS public.products (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    category_id UUID NOT NULL REFERENCES public.categories(id) ON DELETE RESTRICT,
    name TEXT NOT NULL,
    slug TEXT NOT NULL UNIQUE,
    description TEXT,
    material TEXT,
    target_audience TEXT NOT NULL CHECK (target_audience IN ('men', 'women', 'unisex')),
    is_featured BOOLEAN NOT NULL DEFAULT false,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT clock_timestamp(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT clock_timestamp()
);

CREATE INDEX IF NOT EXISTS idx_products_category_active ON public.products (category_id, is_active);
CREATE INDEX IF NOT EXISTS idx_products_is_featured_active ON public.products (is_featured, is_active);

DROP TRIGGER IF EXISTS trg_products_updated_at ON public.products;
CREATE TRIGGER trg_products_updated_at
BEFORE UPDATE ON public.products
FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- 5. PRODUCT_VARIANTS (Biến thể - Nguồn giá bán và tồn kho có thẩm quyền duy nhất)
CREATE TABLE IF NOT EXISTS public.product_variants (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID NOT NULL REFERENCES public.products(id) ON DELETE RESTRICT,
    sku TEXT NOT NULL UNIQUE,
    size TEXT,
    color_name TEXT,
    color_hex TEXT,
    price BIGINT NOT NULL CHECK (price >= 0),
    compare_at_price BIGINT CHECK (compare_at_price IS NULL OR compare_at_price >= price),
    stock_quantity INTEGER NOT NULL DEFAULT 0 CHECK (stock_quantity >= 0),
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT clock_timestamp(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT clock_timestamp(),
    CONSTRAINT uq_product_variants_combo UNIQUE NULLS NOT DISTINCT (product_id, size, color_name)
);

CREATE INDEX IF NOT EXISTS idx_product_variants_product_active ON public.product_variants (product_id, is_active);

DROP TRIGGER IF EXISTS trg_product_variants_updated_at ON public.product_variants;
CREATE TRIGGER trg_product_variants_updated_at
BEFORE UPDATE ON public.product_variants
FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- 6. PRODUCT_IMAGES (Bộ sưu tập ảnh sản phẩm và ảnh theo biến thể màu)
CREATE TABLE IF NOT EXISTS public.product_images (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
    variant_id UUID REFERENCES public.product_variants(id) ON DELETE SET NULL,
    image_path TEXT NOT NULL,
    alt_text TEXT,
    sort_order INTEGER NOT NULL DEFAULT 0,
    is_primary BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT clock_timestamp()
);

CREATE INDEX IF NOT EXISTS idx_product_images_product_sort ON public.product_images (product_id, sort_order);

-- 7. BANNERS (Banner quảng bá ở đầu trang chủ)
CREATE TABLE IF NOT EXISTS public.banners (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    subtitle TEXT,
    image_path TEXT NOT NULL,
    link_type TEXT NOT NULL DEFAULT 'none' CHECK (link_type IN ('none', 'product', 'category', 'url')),
    link_value TEXT,
    start_at TIMESTAMPTZ,
    end_at TIMESTAMPTZ,
    is_active BOOLEAN NOT NULL DEFAULT true,
    sort_order INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT clock_timestamp(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT clock_timestamp(),
    CONSTRAINT chk_banners_dates CHECK (end_at IS NULL OR start_at IS NULL OR end_at > start_at)
);

CREATE INDEX IF NOT EXISTS idx_banners_active_schedule ON public.banners (is_active, sort_order, start_at, end_at);

DROP TRIGGER IF EXISTS trg_banners_updated_at ON public.banners;
CREATE TRIGGER trg_banners_updated_at
BEFORE UPDATE ON public.banners
FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- 8. CARTS (Giỏ hàng của khách)
CREATE TABLE IF NOT EXISTS public.carts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL UNIQUE REFERENCES public.profiles(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT clock_timestamp(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT clock_timestamp()
);

DROP TRIGGER IF EXISTS trg_carts_updated_at ON public.carts;
CREATE TRIGGER trg_carts_updated_at
BEFORE UPDATE ON public.carts
FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- 9. CART_ITEMS (Sản phẩm trong giỏ hàng)
CREATE TABLE IF NOT EXISTS public.cart_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    cart_id UUID NOT NULL REFERENCES public.carts(id) ON DELETE CASCADE,
    variant_id UUID NOT NULL REFERENCES public.product_variants(id) ON DELETE CASCADE,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    created_at TIMESTAMPTZ NOT NULL DEFAULT clock_timestamp(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT clock_timestamp(),
    CONSTRAINT uq_cart_items_cart_variant UNIQUE (cart_id, variant_id)
);

CREATE INDEX IF NOT EXISTS idx_cart_items_cart_id ON public.cart_items (cart_id);

DROP TRIGGER IF EXISTS trg_cart_items_updated_at ON public.cart_items;
CREATE TRIGGER trg_cart_items_updated_at
BEFORE UPDATE ON public.cart_items
FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- 10. ORDERS (Đơn hàng)
CREATE TABLE IF NOT EXISTS public.orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_code TEXT NOT NULL UNIQUE,
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE RESTRICT,
    status TEXT NOT NULL DEFAULT 'pending_confirmation' CHECK (status IN (
        'pending_confirmation', 'confirmed', 'preparing', 'shipping',
        'delivery_failed', 'delivered', 'cancelled', 'returned'
    )),
    payment_method TEXT NOT NULL DEFAULT 'cod' CHECK (payment_method = 'cod'),
    payment_status TEXT NOT NULL DEFAULT 'unpaid' CHECK (payment_status IN ('unpaid', 'paid', 'failed')),
    recipient_name TEXT NOT NULL,
    recipient_phone TEXT NOT NULL,
    shipping_address JSONB NOT NULL,
    subtotal BIGINT NOT NULL CHECK (subtotal >= 0),
    shipping_fee BIGINT NOT NULL DEFAULT 20000 CHECK (shipping_fee >= 0),
    discount_amount BIGINT NOT NULL DEFAULT 0 CHECK (discount_amount = 0),
    total_amount BIGINT NOT NULL CHECK (total_amount >= 0),
    customer_note TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT clock_timestamp(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT clock_timestamp(),
    cancelled_at TIMESTAMPTZ,
    delivered_at TIMESTAMPTZ,
    CONSTRAINT chk_orders_total_calc CHECK (total_amount = subtotal + shipping_fee - discount_amount)
);

CREATE INDEX IF NOT EXISTS idx_orders_user_created ON public.orders (user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_orders_status_created ON public.orders (status, created_at DESC);

DROP TRIGGER IF EXISTS trg_orders_updated_at ON public.orders;
CREATE TRIGGER trg_orders_updated_at
BEFORE UPDATE ON public.orders
FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- 11. ORDER_ITEMS (Chi tiết dòng hàng snapshot bất biến)
CREATE TABLE IF NOT EXISTS public.order_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL REFERENCES public.orders(id) ON DELETE RESTRICT,
    variant_id UUID REFERENCES public.product_variants(id) ON DELETE SET NULL,
    product_name_snapshot TEXT NOT NULL,
    sku_snapshot TEXT NOT NULL,
    size_snapshot TEXT,
    color_snapshot TEXT,
    unit_price BIGINT NOT NULL CHECK (unit_price >= 0),
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    line_total BIGINT NOT NULL CHECK (line_total >= 0),
    CONSTRAINT chk_order_items_line_total CHECK (line_total = unit_price * quantity)
);

CREATE INDEX IF NOT EXISTS idx_order_items_order_id ON public.order_items (order_id);

-- 12. INVENTORY_MOVEMENTS (Nhật ký biến động kho theo quyết định D-17)
CREATE TABLE IF NOT EXISTS public.inventory_movements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    variant_id UUID NOT NULL REFERENCES public.product_variants(id) ON DELETE RESTRICT,
    order_id UUID REFERENCES public.orders(id) ON DELETE RESTRICT,
    quantity_delta INTEGER NOT NULL CHECK (quantity_delta <> 0),
    reason TEXT NOT NULL CHECK (reason IN (
        'order_created', 'order_cancelled', 'return_received', 'restock', 'adjustment'
    )),
    created_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT clock_timestamp()
);

CREATE INDEX IF NOT EXISTS idx_inventory_movements_variant_created ON public.inventory_movements (variant_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_inventory_movements_order_id ON public.inventory_movements (order_id);

-- 13. REVIEWS (Đánh giá sau khi giao hàng thành công)
CREATE TABLE IF NOT EXISTS public.reviews (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID NOT NULL REFERENCES public.products(id) ON DELETE RESTRICT,
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE RESTRICT,
    order_item_id UUID NOT NULL UNIQUE REFERENCES public.order_items(id) ON DELETE RESTRICT,
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment TEXT CHECK (comment IS NULL OR length(comment) <= 1000),
    is_hidden BOOLEAN NOT NULL DEFAULT false,
    hidden_reason TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT clock_timestamp(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT clock_timestamp(),
    CONSTRAINT uq_reviews_user_product UNIQUE (user_id, product_id)
);

CREATE INDEX IF NOT EXISTS idx_reviews_product_created ON public.reviews (product_id, created_at DESC) WHERE is_hidden = false;

DROP TRIGGER IF EXISTS trg_reviews_updated_at ON public.reviews;
CREATE TRIGGER trg_reviews_updated_at
BEFORE UPDATE ON public.reviews
FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- 14. REVIEW_REPORTS (Báo cáo đánh giá tiêu cực / vi phạm)
CREATE TABLE IF NOT EXISTS public.review_reports (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    review_id UUID NOT NULL REFERENCES public.reviews(id) ON DELETE CASCADE,
    reporter_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE RESTRICT,
    reason TEXT NOT NULL,
    details TEXT,
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'reviewed', 'dismissed')),
    resolved_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    resolution_note TEXT,
    resolved_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT clock_timestamp(),
    CONSTRAINT uq_review_reports_reporter_review UNIQUE (reporter_id, review_id)
);

CREATE INDEX IF NOT EXISTS idx_review_reports_status_created ON public.review_reports (status, created_at ASC);

-- 15. STORE_SETTINGS (Cấu hình cửa hàng Singleton)
CREATE TABLE IF NOT EXISTS public.store_settings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    store_name TEXT NOT NULL DEFAULT 'MOVEN',
    logo_path TEXT,
    contact_email TEXT,
    contact_phone TEXT,
    default_shipping_fee BIGINT NOT NULL DEFAULT 20000 CHECK (default_shipping_fee >= 0),
    low_stock_threshold INTEGER NOT NULL DEFAULT 5 CHECK (low_stock_threshold >= 0),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT clock_timestamp(),
    is_singleton BOOLEAN NOT NULL DEFAULT true UNIQUE CHECK (is_singleton = true)
);

DROP TRIGGER IF EXISTS trg_store_settings_updated_at ON public.store_settings;
CREATE TRIGGER trg_store_settings_updated_at
BEFORE UPDATE ON public.store_settings
FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- 16. ORDER_STATUS_HISTORY (Lịch sử chuyển trạng thái đơn hàng theo D-07)
CREATE TABLE IF NOT EXISTS public.order_status_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL REFERENCES public.orders(id) ON DELETE RESTRICT,
    from_status TEXT CHECK (from_status IS NULL OR from_status IN (
        'pending_confirmation', 'confirmed', 'preparing', 'shipping',
        'delivery_failed', 'delivered', 'cancelled', 'returned'
    )),
    to_status TEXT NOT NULL CHECK (to_status IN (
        'pending_confirmation', 'confirmed', 'preparing', 'shipping',
        'delivery_failed', 'delivered', 'cancelled', 'returned'
    )),
    actor_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE RESTRICT,
    note TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT clock_timestamp()
);

CREATE INDEX IF NOT EXISTS idx_order_status_history_order_created ON public.order_status_history (order_id, created_at DESC);


-- ==============================================================================
-- PHẦN 2: BẢO MẬT ROW LEVEL SECURITY (RLS) & TRIGGERS
-- ==============================================================================

-- 1. Hàm kiểm tra quyền admin
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1
        FROM public.profiles
        WHERE id = auth.uid()
          AND role = 'admin'
    );
END;
$$ LANGUAGE plpgsql STABLE SECURITY DEFINER;

-- 2. Trigger tự động tạo profile an toàn khi user đăng ký qua Supabase Auth
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, full_name, phone, role)
    VALUES (
        NEW.id,
        COALESCE(NEW.raw_user_meta_data->>'full_name', ''),
        NEW.raw_user_meta_data->>'phone',
        'customer'
    )
    ON CONFLICT (id) DO UPDATE
    SET 
        full_name = EXCLUDED.full_name,
        phone = COALESCE(EXCLUDED.phone, public.profiles.phone);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, pg_temp;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
AFTER INSERT ON auth.users
FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- 3. Trigger chặn khách hàng tự nâng role admin
CREATE OR REPLACE FUNCTION public.protect_profile_role()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.role IS DISTINCT FROM OLD.role AND NOT public.is_admin() THEN
        RAISE EXCEPTION 'Security violation: Only administrators can modify roles';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trg_protect_profile_role ON public.profiles;
CREATE TRIGGER trg_protect_profile_role
BEFORE UPDATE ON public.profiles
FOR EACH ROW EXECUTE FUNCTION public.protect_profile_role();

-- 4. Trigger chặn khách tự can thiệp kiểm duyệt review
CREATE OR REPLACE FUNCTION public.protect_review_moderation()
RETURNS TRIGGER AS $$
BEGIN
    IF (NEW.is_hidden IS DISTINCT FROM OLD.is_hidden OR NEW.hidden_reason IS DISTINCT FROM OLD.hidden_reason) AND NOT public.is_admin() THEN
        RAISE EXCEPTION 'Security violation: Only administrators can moderate reviews';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trg_protect_review_moderation ON public.reviews;
CREATE TRIGGER trg_protect_review_moderation
BEFORE UPDATE ON public.reviews
FOR EACH ROW EXECUTE FUNCTION public.protect_review_moderation();

-- BẬT ROW LEVEL SECURITY TRÊN TẤT CẢ 16 BẢNG
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.addresses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.product_variants ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.product_images ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.banners ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.carts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cart_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.inventory_movements ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.review_reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.store_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.order_status_history ENABLE ROW LEVEL SECURITY;

-- POLICIES
DO $$ BEGIN
    DROP POLICY IF EXISTS profiles_select_own_or_admin ON public.profiles;
    DROP POLICY IF EXISTS profiles_update_own_or_admin ON public.profiles;
    DROP POLICY IF EXISTS profiles_insert_own_or_admin ON public.profiles;

    DROP POLICY IF EXISTS addresses_select_own_or_admin ON public.addresses;
    DROP POLICY IF EXISTS addresses_insert_own ON public.addresses;
    DROP POLICY IF EXISTS addresses_update_own ON public.addresses;
    DROP POLICY IF EXISTS addresses_delete_own ON public.addresses;

    DROP POLICY IF EXISTS categories_select_active_or_admin ON public.categories;
    DROP POLICY IF EXISTS categories_admin_all ON public.categories;

    DROP POLICY IF EXISTS products_select_active_or_admin ON public.products;
    DROP POLICY IF EXISTS products_admin_all ON public.products;

    DROP POLICY IF EXISTS product_variants_select_active_or_admin ON public.product_variants;
    DROP POLICY IF EXISTS product_variants_admin_all ON public.product_variants;

    DROP POLICY IF EXISTS product_images_select_active_or_admin ON public.product_images;
    DROP POLICY IF EXISTS product_images_admin_all ON public.product_images;

    DROP POLICY IF EXISTS banners_select_active_or_admin ON public.banners;
    DROP POLICY IF EXISTS banners_admin_all ON public.banners;

    DROP POLICY IF EXISTS carts_select_own ON public.carts;
    DROP POLICY IF EXISTS carts_insert_own ON public.carts;
    DROP POLICY IF EXISTS carts_update_own ON public.carts;
    DROP POLICY IF EXISTS carts_delete_own ON public.carts;

    DROP POLICY IF EXISTS cart_items_select_own ON public.cart_items;
    DROP POLICY IF EXISTS cart_items_insert_own ON public.cart_items;
    DROP POLICY IF EXISTS cart_items_update_own ON public.cart_items;
    DROP POLICY IF EXISTS cart_items_delete_own ON public.cart_items;

    DROP POLICY IF EXISTS orders_select_own_or_admin ON public.orders;
    DROP POLICY IF EXISTS orders_insert_own_or_admin ON public.orders;
    DROP POLICY IF EXISTS orders_update_admin ON public.orders;

    DROP POLICY IF EXISTS order_items_select_own_or_admin ON public.order_items;
    DROP POLICY IF EXISTS order_items_insert_order_owner_or_admin ON public.order_items;

    DROP POLICY IF EXISTS inventory_movements_select_admin ON public.inventory_movements;

    DROP POLICY IF EXISTS reviews_select_public_or_own_or_admin ON public.reviews;
    DROP POLICY IF EXISTS reviews_insert_own ON public.reviews;
    DROP POLICY IF EXISTS reviews_update_own_or_admin ON public.reviews;
    DROP POLICY IF EXISTS reviews_delete_admin ON public.reviews;

    DROP POLICY IF EXISTS review_reports_select_reporter_or_admin ON public.review_reports;
    DROP POLICY IF EXISTS review_reports_insert_own ON public.review_reports;
    DROP POLICY IF EXISTS review_reports_admin_update ON public.review_reports;

    DROP POLICY IF EXISTS store_settings_select_all ON public.store_settings;
    DROP POLICY IF EXISTS store_settings_admin_all ON public.store_settings;

    DROP POLICY IF EXISTS order_status_history_select_own_or_admin ON public.order_status_history;
EXCEPTION WHEN OTHERS THEN NULL;
END $$;

CREATE POLICY profiles_select_own_or_admin ON public.profiles FOR SELECT USING (auth.uid() = id OR public.is_admin());
CREATE POLICY profiles_update_own_or_admin ON public.profiles FOR UPDATE USING (auth.uid() = id OR public.is_admin()) WITH CHECK (auth.uid() = id OR public.is_admin());
CREATE POLICY profiles_insert_own_or_admin ON public.profiles FOR INSERT WITH CHECK (auth.uid() = id OR public.is_admin());

CREATE POLICY addresses_select_own_or_admin ON public.addresses FOR SELECT USING (auth.uid() = user_id OR public.is_admin());
CREATE POLICY addresses_insert_own ON public.addresses FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY addresses_update_own ON public.addresses FOR UPDATE USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
CREATE POLICY addresses_delete_own ON public.addresses FOR DELETE USING (auth.uid() = user_id);

CREATE POLICY categories_select_active_or_admin ON public.categories FOR SELECT USING (is_active = true OR public.is_admin());
CREATE POLICY categories_admin_all ON public.categories FOR ALL USING (public.is_admin()) WITH CHECK (public.is_admin());

CREATE POLICY products_select_active_or_admin ON public.products FOR SELECT USING (is_active = true OR public.is_admin());
CREATE POLICY products_admin_all ON public.products FOR ALL USING (public.is_admin()) WITH CHECK (public.is_admin());

CREATE POLICY product_variants_select_active_or_admin ON public.product_variants FOR SELECT USING (
    (is_active = true AND EXISTS (SELECT 1 FROM public.products p WHERE p.id = product_variants.product_id AND p.is_active = true))
    OR public.is_admin()
);
CREATE POLICY product_variants_admin_all ON public.product_variants FOR ALL USING (public.is_admin()) WITH CHECK (public.is_admin());

CREATE POLICY product_images_select_active_or_admin ON public.product_images FOR SELECT USING (
    EXISTS (SELECT 1 FROM public.products p WHERE p.id = product_images.product_id AND (p.is_active = true OR public.is_admin()))
);
CREATE POLICY product_images_admin_all ON public.product_images FOR ALL USING (public.is_admin()) WITH CHECK (public.is_admin());

CREATE POLICY banners_select_active_or_admin ON public.banners FOR SELECT USING (
    (is_active = true AND (start_at IS NULL OR start_at <= clock_timestamp()) AND (end_at IS NULL OR end_at >= clock_timestamp()))
    OR public.is_admin()
);
CREATE POLICY banners_admin_all ON public.banners FOR ALL USING (public.is_admin()) WITH CHECK (public.is_admin());

CREATE POLICY carts_select_own ON public.carts FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY carts_insert_own ON public.carts FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY carts_update_own ON public.carts FOR UPDATE USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
CREATE POLICY carts_delete_own ON public.carts FOR DELETE USING (auth.uid() = user_id);

CREATE POLICY cart_items_select_own ON public.cart_items FOR SELECT USING (
    EXISTS (SELECT 1 FROM public.carts c WHERE c.id = cart_items.cart_id AND c.user_id = auth.uid())
);
CREATE POLICY cart_items_insert_own ON public.cart_items FOR INSERT WITH CHECK (
    EXISTS (SELECT 1 FROM public.carts c WHERE c.id = cart_items.cart_id AND c.user_id = auth.uid())
);
CREATE POLICY cart_items_update_own ON public.cart_items FOR UPDATE USING (
    EXISTS (SELECT 1 FROM public.carts c WHERE c.id = cart_items.cart_id AND c.user_id = auth.uid())
) WITH CHECK (
    EXISTS (SELECT 1 FROM public.carts c WHERE c.id = cart_items.cart_id AND c.user_id = auth.uid())
);
CREATE POLICY cart_items_delete_own ON public.cart_items FOR DELETE USING (
    EXISTS (SELECT 1 FROM public.carts c WHERE c.id = cart_items.cart_id AND c.user_id = auth.uid())
);

CREATE POLICY orders_select_own_or_admin ON public.orders FOR SELECT USING (auth.uid() = user_id OR public.is_admin());
CREATE POLICY orders_insert_own_or_admin ON public.orders FOR INSERT WITH CHECK (auth.uid() = user_id OR public.is_admin());
CREATE POLICY orders_update_admin ON public.orders FOR UPDATE USING (public.is_admin()) WITH CHECK (public.is_admin());

CREATE POLICY order_items_select_own_or_admin ON public.order_items FOR SELECT USING (
    EXISTS (SELECT 1 FROM public.orders o WHERE o.id = order_items.order_id AND (o.user_id = auth.uid() OR public.is_admin()))
);
CREATE POLICY order_items_insert_order_owner_or_admin ON public.order_items FOR INSERT WITH CHECK (
    EXISTS (SELECT 1 FROM public.orders o WHERE o.id = order_items.order_id AND (o.user_id = auth.uid() OR public.is_admin()))
);

CREATE POLICY inventory_movements_select_admin ON public.inventory_movements FOR SELECT USING (public.is_admin());

CREATE POLICY reviews_select_public_or_own_or_admin ON public.reviews FOR SELECT USING (
    (is_hidden = false AND EXISTS (SELECT 1 FROM public.products p WHERE p.id = reviews.product_id AND p.is_active = true))
    OR auth.uid() = user_id
    OR public.is_admin()
);
CREATE POLICY reviews_insert_own ON public.reviews FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY reviews_update_own_or_admin ON public.reviews FOR UPDATE USING (
    (auth.uid() = user_id AND is_hidden = false) OR public.is_admin()
) WITH CHECK (
    (auth.uid() = user_id AND is_hidden = false) OR public.is_admin()
);
CREATE POLICY reviews_delete_admin ON public.reviews FOR DELETE USING (public.is_admin());

CREATE POLICY review_reports_select_reporter_or_admin ON public.review_reports FOR SELECT USING (auth.uid() = reporter_id OR public.is_admin());
CREATE POLICY review_reports_insert_own ON public.review_reports FOR INSERT WITH CHECK (auth.uid() = reporter_id);
CREATE POLICY review_reports_admin_update ON public.review_reports FOR UPDATE USING (public.is_admin()) WITH CHECK (public.is_admin());

CREATE POLICY store_settings_select_all ON public.store_settings FOR SELECT USING (true);
CREATE POLICY store_settings_admin_all ON public.store_settings FOR ALL USING (public.is_admin()) WITH CHECK (public.is_admin());

CREATE POLICY order_status_history_select_own_or_admin ON public.order_status_history FOR SELECT USING (
    EXISTS (SELECT 1 FROM public.orders o WHERE o.id = order_status_history.order_id AND (o.user_id = auth.uid() OR public.is_admin()))
);

-- ==============================================================================
-- PHẦN 2.5: RPC FUNCTIONS (GIAI ĐOẠN 5 - CHECKOUT COD & TRANSACTION NGUYÊN TỬ)
-- ==============================================================================

CREATE OR REPLACE FUNCTION public.create_order_checkout(
    p_shipping_address JSONB,
    p_items JSONB,
    p_customer_note TEXT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_user_id UUID;
    v_order_id UUID;
    v_order_code TEXT;
    v_shipping_fee BIGINT;
    v_subtotal BIGINT := 0;
    v_total_amount BIGINT := 0;
    v_recipient_name TEXT;
    v_recipient_phone TEXT;
    v_item JSONB;
    v_variant_id UUID;
    v_quantity INTEGER;
    v_variant_record RECORD;
    v_line_total BIGINT;
    v_item_list JSONB := '[]'::JSONB;
BEGIN
    v_user_id := auth.uid();
    IF v_user_id IS NULL THEN
        RAISE EXCEPTION 'Unauthenticated: Bạn cần đăng nhập để thực hiện đặt hàng.'
            USING ERRCODE = 'P0001';
    END IF;

    IF p_shipping_address IS NULL THEN
        RAISE EXCEPTION 'Validation error: Địa chỉ giao hàng không được để trống.'
            USING ERRCODE = 'P0002';
    END IF;

    v_recipient_name := TRIM(COALESCE(p_shipping_address->>'recipient_name', ''));
    v_recipient_phone := TRIM(COALESCE(p_shipping_address->>'phone', ''));

    IF v_recipient_name = '' OR v_recipient_phone = '' THEN
        RAISE EXCEPTION 'Validation error: Tên người nhận và số điện thoại là bắt buộc.'
            USING ERRCODE = 'P0002';
    END IF;

    IF p_items IS NULL OR jsonb_array_length(p_items) = 0 THEN
        RAISE EXCEPTION 'Validation error: Giỏ hàng không có sản phẩm nào để đặt.'
            USING ERRCODE = 'P0002';
    END IF;

    SELECT default_shipping_fee INTO v_shipping_fee
    FROM public.store_settings
    LIMIT 1;

    IF v_shipping_fee IS NULL THEN
        v_shipping_fee := 20000;
    END IF;

    FOR v_item IN SELECT * FROM jsonb_array_elements(p_items)
    LOOP
        v_variant_id := (v_item->>'variant_id')::UUID;
        v_quantity := (v_item->>'quantity')::INTEGER;

        IF v_quantity IS NULL OR v_quantity <= 0 THEN
            RAISE EXCEPTION 'Validation error: Số lượng sản phẩm phải lớn hơn 0.'
                USING ERRCODE = 'P0002';
        END IF;

        SELECT 
            pv.id,
            pv.sku,
            pv.size,
            pv.color_name,
            pv.price,
            pv.stock_quantity,
            pv.is_active AS variant_active,
            p.name AS product_name,
            p.is_active AS product_active
        INTO v_variant_record
        FROM public.product_variants pv
        JOIN public.products p ON p.id = pv.product_id
        WHERE pv.id = v_variant_id
        FOR UPDATE OF pv;

        IF NOT FOUND THEN
            RAISE EXCEPTION 'Không tìm thấy thông tin biến thể sản phẩm.'
                USING ERRCODE = 'P0003';
        END IF;

        IF NOT v_variant_record.variant_active OR NOT v_variant_record.product_active THEN
            RAISE EXCEPTION 'Sản phẩm "%" hiện không còn mở bán.', v_variant_record.product_name
                USING ERRCODE = 'P0004';
        END IF;

        IF v_variant_record.stock_quantity < v_quantity THEN
            RAISE EXCEPTION 'Sản phẩm "%" (SKU: %) chỉ còn % sản phẩm trong kho, không đủ đáp ứng số lượng bạn chọn.',
                v_variant_record.product_name, v_variant_record.sku, v_variant_record.stock_quantity
                USING ERRCODE = 'P0005';
        END IF;

        v_line_total := v_variant_record.price * v_quantity;
        v_subtotal := v_subtotal + v_line_total;

        v_item_list := v_item_list || jsonb_build_object(
            'variant_id', v_variant_record.id,
            'product_name', v_variant_record.product_name,
            'sku', v_variant_record.sku,
            'size', v_variant_record.size,
            'color_name', v_variant_record.color_name,
            'unit_price', v_variant_record.price,
            'quantity', v_quantity,
            'line_total', v_line_total
        );
    END LOOP;

    v_total_amount := v_subtotal + v_shipping_fee;

    LOOP
        v_order_code := 'MVN-' || upper(substring(md5(random()::text || clock_timestamp()::text) from 1 for 8));
        EXIT WHEN NOT EXISTS (SELECT 1 FROM public.orders WHERE order_code = v_order_code);
    END LOOP;

    INSERT INTO public.orders (
        id, order_code, user_id, status, payment_method, payment_status,
        recipient_name, recipient_phone, shipping_address,
        subtotal, shipping_fee, discount_amount, total_amount, customer_note,
        created_at, updated_at
    ) VALUES (
        gen_random_uuid(), v_order_code, v_user_id, 'pending_confirmation', 'cod', 'unpaid',
        v_recipient_name, v_recipient_phone, p_shipping_address,
        v_subtotal, v_shipping_fee, 0, v_total_amount, p_customer_note,
        clock_timestamp(), clock_timestamp()
    ) RETURNING id INTO v_order_id;

    INSERT INTO public.order_status_history (
        id, order_id, from_status, to_status, actor_id, note, created_at
    ) VALUES (
        gen_random_uuid(), v_order_id, NULL, 'pending_confirmation', v_user_id, 'Khách đặt hàng COD thành công', clock_timestamp()
    );

    FOR v_item IN SELECT * FROM jsonb_array_elements(v_item_list)
    LOOP
        INSERT INTO public.order_items (
            id, order_id, variant_id, product_name_snapshot, sku_snapshot,
            size_snapshot, color_snapshot, unit_price, quantity, line_total
        ) VALUES (
            gen_random_uuid(),
            v_order_id,
            (v_item->>'variant_id')::UUID,
            v_item->>'product_name',
            v_item->>'sku',
            v_item->>'size',
            v_item->>'color_name',
            (v_item->>'unit_price')::BIGINT,
            (v_item->>'quantity')::INTEGER,
            (v_item->>'line_total')::BIGINT
        );

        UPDATE public.product_variants
        SET stock_quantity = stock_quantity - (v_item->>'quantity')::INTEGER,
            updated_at = clock_timestamp()
        WHERE id = (v_item->>'variant_id')::UUID;

        INSERT INTO public.inventory_movements (
            id, variant_id, order_id, quantity_delta, reason, created_by, created_at
        ) VALUES (
            gen_random_uuid(),
            (v_item->>'variant_id')::UUID,
            v_order_id,
            -((v_item->>'quantity')::INTEGER),
            'order_created',
            v_user_id,
            clock_timestamp()
        );
    END LOOP;

    DELETE FROM public.cart_items
    WHERE cart_id IN (SELECT id FROM public.carts WHERE user_id = v_user_id)
      AND variant_id IN (
          SELECT (item->>'variant_id')::UUID
          FROM jsonb_array_elements(p_items) AS item
      );

    RETURN jsonb_build_object(
        'success', true,
        'order_id', v_order_id,
        'order_code', v_order_code,
        'subtotal', v_subtotal,
        'shipping_fee', v_shipping_fee,
        'total_amount', v_total_amount
    );
END;
$$;

GRANT EXECUTE ON FUNCTION public.create_order_checkout(JSONB, JSONB, TEXT) TO authenticated;


-- ==============================================================================
-- PHẦN 3: THƯ MỤC LƯU TRỮ ẢNH (STORAGE BUCKETS) & PHÂN QUYỀN
-- ==============================================================================

INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES
    ('product-media', 'product-media', true, 5242880, ARRAY['image/jpeg', 'image/png', 'image/webp']),
    ('banners', 'banners', true, 5242880, ARRAY['image/jpeg', 'image/png', 'image/webp']),
    ('avatars', 'avatars', true, 2097152, ARRAY['image/jpeg', 'image/png', 'image/webp'])
ON CONFLICT (id) DO UPDATE SET
    public = EXCLUDED.public,
    file_size_limit = EXCLUDED.file_size_limit,
    allowed_mime_types = EXCLUDED.allowed_mime_types;

DO $$ BEGIN
    DROP POLICY IF EXISTS product_media_public_select ON storage.objects;
    DROP POLICY IF EXISTS product_media_admin_insert ON storage.objects;
    DROP POLICY IF EXISTS product_media_admin_update ON storage.objects;
    DROP POLICY IF EXISTS product_media_admin_delete ON storage.objects;

    DROP POLICY IF EXISTS banners_public_select ON storage.objects;
    DROP POLICY IF EXISTS banners_admin_insert ON storage.objects;
    DROP POLICY IF EXISTS banners_admin_update ON storage.objects;
    DROP POLICY IF EXISTS banners_admin_delete ON storage.objects;

    DROP POLICY IF EXISTS avatars_public_select ON storage.objects;
    DROP POLICY IF EXISTS avatars_user_insert ON storage.objects;
    DROP POLICY IF EXISTS avatars_user_update ON storage.objects;
    DROP POLICY IF EXISTS avatars_user_delete ON storage.objects;
EXCEPTION WHEN OTHERS THEN NULL;
END $$;

CREATE POLICY product_media_public_select ON storage.objects FOR SELECT USING (bucket_id = 'product-media');
CREATE POLICY product_media_admin_insert ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'product-media' AND public.is_admin());
CREATE POLICY product_media_admin_update ON storage.objects FOR UPDATE USING (bucket_id = 'product-media' AND public.is_admin()) WITH CHECK (bucket_id = 'product-media' AND public.is_admin());
CREATE POLICY product_media_admin_delete ON storage.objects FOR DELETE USING (bucket_id = 'product-media' AND public.is_admin());

CREATE POLICY banners_public_select ON storage.objects FOR SELECT USING (bucket_id = 'banners');
CREATE POLICY banners_admin_insert ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'banners' AND public.is_admin());
CREATE POLICY banners_admin_update ON storage.objects FOR UPDATE USING (bucket_id = 'banners' AND public.is_admin()) WITH CHECK (bucket_id = 'banners' AND public.is_admin());
CREATE POLICY banners_admin_delete ON storage.objects FOR DELETE USING (bucket_id = 'banners' AND public.is_admin());

CREATE POLICY avatars_public_select ON storage.objects FOR SELECT USING (bucket_id = 'avatars');
CREATE POLICY avatars_user_insert ON storage.objects FOR INSERT WITH CHECK (
    bucket_id = 'avatars' AND auth.uid()::text = (storage.foldername(name))[1]
);
CREATE POLICY avatars_user_update ON storage.objects FOR UPDATE USING (
    bucket_id = 'avatars' AND auth.uid()::text = (storage.foldername(name))[1]
) WITH CHECK (
    bucket_id = 'avatars' AND auth.uid()::text = (storage.foldername(name))[1]
);
CREATE POLICY avatars_user_delete ON storage.objects FOR DELETE USING (
    bucket_id = 'avatars' AND auth.uid()::text = (storage.foldername(name))[1]
);


-- ==============================================================================
-- PHẦN 4: DỮ LIỆU MẪU BAN ĐẦU (SEED DATA KÈM ẢNH THỜI TRANG ĐA GÓC CHỤP)
-- ==============================================================================

-- 1. Cấu hình cửa hàng
INSERT INTO public.store_settings (
    store_name, contact_email, contact_phone, default_shipping_fee, low_stock_threshold, is_singleton
)
VALUES (
    'MOVEN Clothing', 'support@moven.vn', '0901234567', 20000, 5, true
)
ON CONFLICT (is_singleton) DO UPDATE SET
    store_name = EXCLUDED.store_name,
    contact_email = EXCLUDED.contact_email,
    contact_phone = EXCLUDED.contact_phone,
    default_shipping_fee = EXCLUDED.default_shipping_fee,
    low_stock_threshold = EXCLUDED.low_stock_threshold;

-- 2. Danh mục sản phẩm kèm ảnh bìa
INSERT INTO public.categories (id, name, slug, description, image_path, sort_order, is_active)
VALUES
    ('10000000-0000-0000-0000-000000000001', 'Áo Nam', 'ao-nam', 'Bộ sưu tập áo thun, áo polo, áo sơ mi nam thanh lịch', 'https://images.unsplash.com/photo-1521572267360-ee0c2909d518?w=500&auto=format&fit=crop&q=80', 1, true),
    ('10000000-0000-0000-0000-000000000002', 'Quần Nam', 'quan-nam', 'Quần jeans, quần khaki, quần âu nam hiện đại', 'https://images.unsplash.com/photo-1624378439575-d8705ad7ae80?w=500&auto=format&fit=crop&q=80', 2, true),
    ('10000000-0000-0000-0000-000000000003', 'Áo Nữ', 'ao-nu', 'Áo kiểu, áo thun, sơ mi nữ cao cấp tôn dáng', 'https://images.unsplash.com/photo-1602810318383-e386cc2a3ccf?w=500&auto=format&fit=crop&q=80', 3, true),
    ('10000000-0000-0000-0000-000000000004', 'Quần Nữ', 'quan-nu', 'Quần ống rộng, jeans nữ thời trang phong cách', 'https://images.unsplash.com/photo-1541099649105-f69ad21f3246?w=500&auto=format&fit=crop&q=80', 4, true)
ON CONFLICT (id) DO UPDATE SET
    name = EXCLUDED.name,
    description = EXCLUDED.description,
    image_path = EXCLUDED.image_path,
    sort_order = EXCLUDED.sort_order,
    is_active = EXCLUDED.is_active;

-- 3. Sản phẩm chính
INSERT INTO public.products (
    id, category_id, name, slug, description, material, target_audience, is_featured, is_active
)
VALUES
    ('20000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000001', 'Áo Thun Nam Cotton Compact MOVEN', 'ao-thun-nam-cotton-compact-moven', 'Áo thun nam sử dụng chất liệu Cotton Compact 100% co giãn thoáng mát, thấm hút mồ hôi tối đa.', '100% Cotton Compact', 'men', true, true),
    ('20000000-0000-0000-0000-000000000002', '10000000-0000-0000-0000-000000000001', 'Áo Polo Nam Classic Fit Pique', 'ao-polo-nam-classic-fit-pique', 'Áo polo dệt mắt chim cao cấp, cổ dệt bo mềm mại giữ form hoàn hảo cả ngày.', 'CVC Pique 95% Cotton 5% Spandex', 'men', true, true),
    ('20000000-0000-0000-0000-000000000003', '10000000-0000-0000-0000-000000000002', 'Quần Khaki Nam Slim Fit Co Giãn', 'quan-khaki-nam-slim-fit-co-gian', 'Quần khaki tôn dáng hiện đại, mềm mịn dễ phối đồ đi làm hoặc đi chơi.', 'Cotton Twill cao cấp', 'men', false, true),
    ('20000000-0000-0000-0000-000000000004', '10000000-0000-0000-0000-000000000003', 'Áo Sơ Mi Nữ Lụa Satin Cao Cấp', 'ao-so-mi-nu-lua-satin-cao-cap', 'Chất liệu lụa satin bóng nhẹ, mềm rủ tự nhiên, sang trọng và quý phái.', 'Lụa Satin', 'women', true, true)
ON CONFLICT (id) DO UPDATE SET
    category_id = EXCLUDED.category_id,
    name = EXCLUDED.name,
    slug = EXCLUDED.slug,
    description = EXCLUDED.description,
    material = EXCLUDED.material,
    target_audience = EXCLUDED.target_audience,
    is_featured = EXCLUDED.is_featured,
    is_active = EXCLUDED.is_active;

-- 4. Biến thể sản phẩm (SKU, Size, Màu sắc, Giá bán, Tồn kho)
INSERT INTO public.product_variants (
    id, product_id, sku, size, color_name, color_hex, price, compare_at_price, stock_quantity, is_active
)
VALUES
    -- Áo thun nam: Đen & Trắng
    ('30000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001', 'MVN-TSH-BLK-M', 'M', 'Đen', '#000000', 199000, 249000, 30, true),
    ('30000000-0000-0000-0000-000000000002', '20000000-0000-0000-0000-000000000001', 'MVN-TSH-BLK-L', 'L', 'Đen', '#000000', 199000, 249000, 25, true),
    ('30000000-0000-0000-0000-000000000003', '20000000-0000-0000-0000-000000000001', 'MVN-TSH-WHT-M', 'M', 'Trắng', '#FFFFFF', 199000, 249000, 4, true),
    ('30000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000001', 'MVN-TSH-WHT-L', 'L', 'Trắng', '#FFFFFF', 199000, 249000, 20, true),

    -- Áo polo nam: Navy & Xám
    ('30000000-0000-0000-0000-000000000005', '20000000-0000-0000-0000-000000000002', 'MVN-POL-NVY-M', 'M', 'Xanh Navy', '#000080', 299000, 350000, 40, true),
    ('30000000-0000-0000-0000-000000000006', '20000000-0000-0000-0000-000000000002', 'MVN-POL-NVY-L', 'L', 'Xanh Navy', '#000080', 299000, 350000, 35, true),
    ('30000000-0000-0000-0000-000000000007', '20000000-0000-0000-0000-000000000002', 'MVN-POL-GRY-M', 'M', 'Xám Tiêu', '#808080', 299000, 350000, 15, true),

    -- Quần khaki: Beige
    ('30000000-0000-0000-0000-000000000008', '20000000-0000-0000-0000-000000000003', 'MVN-KHK-BEI-30', '30', 'Beige', '#F5F5DC', 399000, 499000, 12, true),
    ('30000000-0000-0000-0000-000000000009', '20000000-0000-0000-0000-000000000003', 'MVN-KHK-BEI-31', '31', 'Beige', '#F5F5DC', 399000, 499000, 18, true),

    -- Áo sơ mi: Kem
    ('30000000-0000-0000-0000-000000000010', '20000000-0000-0000-0000-000000000004', 'MVN-SMI-CRM-S', 'S', 'Kem', '#FFFDD0', 349000, NULL, 22, true),
    ('30000000-0000-0000-0000-000000000011', '20000000-0000-0000-0000-000000000004', 'MVN-SMI-CRM-M', 'M', 'Kem', '#FFFDD0', 349000, NULL, 16, true)
ON CONFLICT (id) DO UPDATE SET
    price = EXCLUDED.price,
    compare_at_price = EXCLUDED.compare_at_price,
    stock_quantity = EXCLUDED.stock_quantity,
    is_active = EXCLUDED.is_active;

-- 5. Bộ sưu tập ảnh sản phẩm đa góc chụp & theo màu
INSERT INTO public.product_images (
    id, product_id, variant_id, image_path, alt_text, sort_order, is_primary
)
VALUES
    -- Áo thun nam
    ('40000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001', '30000000-0000-0000-0000-000000000003', 'https://images.unsplash.com/photo-1521572267360-ee0c2909d518?w=800&auto=format&fit=crop&q=80', 'Áo thun nam Cotton Compact màu Trắng chính diện', 1, true),
    ('40000000-0000-0000-0000-000000000002', '20000000-0000-0000-0000-000000000001', '30000000-0000-0000-0000-000000000003', 'https://images.unsplash.com/photo-1581655353564-df123a1eb820?w=800&auto=format&fit=crop&q=80', 'Cận cảnh chất vải Cotton Compact và cổ áo màu Trắng', 2, false),
    ('40000000-0000-0000-0000-000000000003', '20000000-0000-0000-0000-000000000001', '30000000-0000-0000-0000-000000000001', 'https://images.unsplash.com/photo-1503342217505-b0a15ec3261c?w=800&auto=format&fit=crop&q=80', 'Áo thun nam Cotton Compact màu Đen chính diện', 3, false),
    ('40000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000001', '30000000-0000-0000-0000-000000000001', 'https://images.unsplash.com/photo-1583743814966-8936f5b7be1a?w=800&auto=format&fit=crop&q=80', 'Chi tiết phom áo và đường may màu Đen', 4, false),

    -- Áo polo nam
    ('40000000-0000-0000-0000-000000000005', '20000000-0000-0000-0000-000000000002', '30000000-0000-0000-0000-000000000005', 'https://images.unsplash.com/photo-1586363104862-3a5e2ab60d99?w=800&auto=format&fit=crop&q=80', 'Áo Polo nam Classic Fit Pique màu Xanh Navy', 1, true),
    ('40000000-0000-0000-0000-000000000006', '20000000-0000-0000-0000-000000000002', '30000000-0000-0000-0000-000000000007', 'https://images.unsplash.com/photo-1625910513413-5bc1ccbeea3a?w=800&auto=format&fit=crop&q=80', 'Áo Polo nam phom chuẩn màu Xám Tiêu', 2, false),

    -- Quần khaki nam
    ('40000000-0000-0000-0000-000000000007', '20000000-0000-0000-0000-000000000003', '30000000-0000-0000-0000-000000000008', 'https://images.unsplash.com/photo-1624378439575-d8705ad7ae80?w=800&auto=format&fit=crop&q=80', 'Quần Khaki nam dáng Slim Fit màu Beige đứng form', 1, true),
    ('40000000-0000-0000-0000-000000000008', '20000000-0000-0000-0000-000000000003', '30000000-0000-0000-0000-000000000008', 'https://images.unsplash.com/photo-1473966968600-fa801b869a1a?w=800&auto=format&fit=crop&q=80', 'Cận cảnh chất vải Cotton Twill co giãn và chi tiết túi quần', 2, false),

    -- Áo sơ mi nữ
    ('40000000-0000-0000-0000-000000000009', '20000000-0000-0000-0000-000000000004', '30000000-0000-0000-0000-000000000010', 'https://images.unsplash.com/photo-1602810318383-e386cc2a3ccf?w=800&auto=format&fit=crop&q=80', 'Áo sơ mi nữ chất liệu lụa Satin màu Kem sang trọng', 1, true),
    ('40000000-0000-0000-0000-000000000010', '20000000-0000-0000-0000-000000000004', '30000000-0000-0000-0000-000000000010', 'https://images.unsplash.com/photo-1598554747436-c9293d6a588f?w=800&auto=format&fit=crop&q=80', 'Cận cảnh độ rủ mềm mại và ánh bóng nhẹ của chất lụa Satin', 2, false)
ON CONFLICT (id) DO UPDATE SET
    image_path = EXCLUDED.image_path,
    alt_text = EXCLUDED.alt_text,
    sort_order = EXCLUDED.sort_order,
    is_primary = EXCLUDED.is_primary;

-- 6. Hero Banners
INSERT INTO public.banners (
    id, title, subtitle, image_path, link_type, link_value, sort_order, is_active
)
VALUES
    ('50000000-0000-0000-0000-000000000001', 'Bộ Sưu Tập MOVEN Thu Đông Mới', 'Trải nghiệm sự tối giản thanh lịch trong từng đường kim mũi chỉ', 'https://images.unsplash.com/photo-1490481651871-ab68de25d43d?w=1600&auto=format&fit=crop&q=80', 'category', 'ao-nam', 1, true),
    ('50000000-0000-0000-0000-000000000002', 'Chất Liệu Tự Nhiên - Thoáng Mát Suốt Ngày', 'Khám phá dòng sản phẩm Cotton Compact 100% tự nhiên', 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=1600&auto=format&fit=crop&q=80', 'product', 'ao-thun-nam-cotton-compact-moven', 2, true)
ON CONFLICT (id) DO UPDATE SET
    title = EXCLUDED.title,
    subtitle = EXCLUDED.subtitle,
    image_path = EXCLUDED.image_path,
    link_type = EXCLUDED.link_type,
    link_value = EXCLUDED.link_value,
    sort_order = EXCLUDED.sort_order,
    is_active = EXCLUDED.is_active;

-- HOÀN TẤT THIẾT LẬP TOÀN BỘ CƠ SỞ DỮ LIỆU MOVEN!

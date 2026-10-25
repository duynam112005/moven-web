-- MOVEN Phase 2 Migration 02: Row Level Security (RLS) Policies & Helper Functions
-- Spec Reference: SECURITY_SPEC.md, DATABASE_SPEC.md, BUSINESS_FLOWS.md

-- 1. Helper function: Check if current authenticated user is admin
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

-- 2. Auth hook: Handle profile creation on auth.users insert
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
FOR EACH ROW
EXECUTE FUNCTION public.handle_new_user();

-- 3. Security Trigger: Prevent customer from modifying their own role
CREATE OR REPLACE FUNCTION public.protect_profile_role()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.role IS DISTINCT FROM OLD.role AND NOT public.is_admin() THEN
        RAISE EXCEPTION 'Security violation: Only administrators can modify roles';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER trg_protect_profile_role
BEFORE UPDATE ON public.profiles
FOR EACH ROW
EXECUTE FUNCTION public.protect_profile_role();

-- 4. Security Trigger: Prevent customer from moderating reviews
CREATE OR REPLACE FUNCTION public.protect_review_moderation()
RETURNS TRIGGER AS $$
BEGIN
    IF (NEW.is_hidden IS DISTINCT FROM OLD.is_hidden OR NEW.hidden_reason IS DISTINCT FROM OLD.hidden_reason) AND NOT public.is_admin() THEN
        RAISE EXCEPTION 'Security violation: Only administrators can moderate reviews';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER trg_protect_review_moderation
BEFORE UPDATE ON public.reviews
FOR EACH ROW
EXECUTE FUNCTION public.protect_review_moderation();

-- ========================================================
-- ENABLE ROW LEVEL SECURITY ON ALL 16 TABLES
-- ========================================================
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

-- ========================================================
-- TABLE POLICIES
-- ========================================================

-- 1. PROFILES
CREATE POLICY profiles_select_own_or_admin ON public.profiles
    FOR SELECT USING (auth.uid() = id OR public.is_admin());

CREATE POLICY profiles_update_own_or_admin ON public.profiles
    FOR UPDATE USING (auth.uid() = id OR public.is_admin())
    WITH CHECK (auth.uid() = id OR public.is_admin());

CREATE POLICY profiles_insert_own_or_admin ON public.profiles
    FOR INSERT WITH CHECK (auth.uid() = id OR public.is_admin());

-- 2. ADDRESSES
CREATE POLICY addresses_select_own_or_admin ON public.addresses
    FOR SELECT USING (auth.uid() = user_id OR public.is_admin());

CREATE POLICY addresses_insert_own ON public.addresses
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY addresses_update_own ON public.addresses
    FOR UPDATE USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY addresses_delete_own ON public.addresses
    FOR DELETE USING (auth.uid() = user_id);

-- 3. CATEGORIES
CREATE POLICY categories_select_active_or_admin ON public.categories
    FOR SELECT USING (is_active = true OR public.is_admin());

CREATE POLICY categories_admin_all ON public.categories
    FOR ALL USING (public.is_admin())
    WITH CHECK (public.is_admin());

-- 4. PRODUCTS
CREATE POLICY products_select_active_or_admin ON public.products
    FOR SELECT USING (is_active = true OR public.is_admin());

CREATE POLICY products_admin_all ON public.products
    FOR ALL USING (public.is_admin())
    WITH CHECK (public.is_admin());

-- 5. PRODUCT_VARIANTS
CREATE POLICY product_variants_select_active_or_admin ON public.product_variants
    FOR SELECT USING (
        (is_active = true AND EXISTS (
            SELECT 1 FROM public.products p
            WHERE p.id = product_variants.product_id AND p.is_active = true
        )) OR public.is_admin()
    );

CREATE POLICY product_variants_admin_all ON public.product_variants
    FOR ALL USING (public.is_admin())
    WITH CHECK (public.is_admin());

-- 6. PRODUCT_IMAGES
CREATE POLICY product_images_select_active_or_admin ON public.product_images
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.products p
            WHERE p.id = product_images.product_id
              AND (p.is_active = true OR public.is_admin())
        )
    );

CREATE POLICY product_images_admin_all ON public.product_images
    FOR ALL USING (public.is_admin())
    WITH CHECK (public.is_admin());

-- 7. BANNERS
CREATE POLICY banners_select_active_or_admin ON public.banners
    FOR SELECT USING (
        (is_active = true
         AND (start_at IS NULL OR start_at <= clock_timestamp())
         AND (end_at IS NULL OR end_at >= clock_timestamp()))
        OR public.is_admin()
    );

CREATE POLICY banners_admin_all ON public.banners
    FOR ALL USING (public.is_admin())
    WITH CHECK (public.is_admin());

-- 8. CARTS
CREATE POLICY carts_select_own ON public.carts
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY carts_insert_own ON public.carts
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY carts_update_own ON public.carts
    FOR UPDATE USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY carts_delete_own ON public.carts
    FOR DELETE USING (auth.uid() = user_id);

-- 9. CART_ITEMS
CREATE POLICY cart_items_select_own ON public.cart_items
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.carts c
            WHERE c.id = cart_items.cart_id AND c.user_id = auth.uid()
        )
    );

CREATE POLICY cart_items_insert_own ON public.cart_items
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.carts c
            WHERE c.id = cart_items.cart_id AND c.user_id = auth.uid()
        )
    );

CREATE POLICY cart_items_update_own ON public.cart_items
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM public.carts c
            WHERE c.id = cart_items.cart_id AND c.user_id = auth.uid()
        )
    )
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.carts c
            WHERE c.id = cart_items.cart_id AND c.user_id = auth.uid()
        )
    );

CREATE POLICY cart_items_delete_own ON public.cart_items
    FOR DELETE USING (
        EXISTS (
            SELECT 1 FROM public.carts c
            WHERE c.id = cart_items.cart_id AND c.user_id = auth.uid()
        )
    );

-- 10. ORDERS
CREATE POLICY orders_select_own_or_admin ON public.orders
    FOR SELECT USING (auth.uid() = user_id OR public.is_admin());

CREATE POLICY orders_insert_own_or_admin ON public.orders
    FOR INSERT WITH CHECK (auth.uid() = user_id OR public.is_admin());

CREATE POLICY orders_update_admin ON public.orders
    FOR UPDATE USING (public.is_admin())
    WITH CHECK (public.is_admin());

-- 11. ORDER_ITEMS
CREATE POLICY order_items_select_own_or_admin ON public.order_items
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.orders o
            WHERE o.id = order_items.order_id
              AND (o.user_id = auth.uid() OR public.is_admin())
        )
    );

CREATE POLICY order_items_insert_order_owner_or_admin ON public.order_items
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.orders o
            WHERE o.id = order_items.order_id
              AND (o.user_id = auth.uid() OR public.is_admin())
        )
    );

-- 12. INVENTORY_MOVEMENTS (Append-only by server RPC/triggers; Admin read-only)
CREATE POLICY inventory_movements_select_admin ON public.inventory_movements
    FOR SELECT USING (public.is_admin());

-- 13. REVIEWS
CREATE POLICY reviews_select_public_or_own_or_admin ON public.reviews
    FOR SELECT USING (
        (is_hidden = false AND EXISTS (
            SELECT 1 FROM public.products p
            WHERE p.id = reviews.product_id AND p.is_active = true
        ))
        OR auth.uid() = user_id
        OR public.is_admin()
    );

CREATE POLICY reviews_insert_own ON public.reviews
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY reviews_update_own_or_admin ON public.reviews
    FOR UPDATE USING (
        (auth.uid() = user_id AND is_hidden = false)
        OR public.is_admin()
    )
    WITH CHECK (
        (auth.uid() = user_id AND is_hidden = false)
        OR public.is_admin()
    );

CREATE POLICY reviews_delete_admin ON public.reviews
    FOR DELETE USING (public.is_admin());

-- 14. REVIEW_REPORTS
CREATE POLICY review_reports_select_reporter_or_admin ON public.review_reports
    FOR SELECT USING (auth.uid() = reporter_id OR public.is_admin());

CREATE POLICY review_reports_insert_own ON public.review_reports
    FOR INSERT WITH CHECK (auth.uid() = reporter_id);

CREATE POLICY review_reports_admin_update ON public.review_reports
    FOR UPDATE USING (public.is_admin())
    WITH CHECK (public.is_admin());

-- 15. STORE_SETTINGS
CREATE POLICY store_settings_select_all ON public.store_settings
    FOR SELECT USING (true);

CREATE POLICY store_settings_admin_all ON public.store_settings
    FOR ALL USING (public.is_admin())
    WITH CHECK (public.is_admin());

-- 16. ORDER_STATUS_HISTORY (Append-only by server RPC; Order owner or Admin read-only)
CREATE POLICY order_status_history_select_own_or_admin ON public.order_status_history
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.orders o
            WHERE o.id = order_status_history.order_id
              AND (o.user_id = auth.uid() OR public.is_admin())
        )
    );

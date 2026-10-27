-- MOVEN Phase 8 Migration 04: Store Settings Singleton and Admin Dashboard Metrics
-- Spec References: ADR-0005, GLOSSARY.md, BUSINESS_FLOWS.md, DATABASE_SPEC.md, SECURITY_SPEC.md

-- 1. Create store_settings table if not exists
CREATE TABLE IF NOT EXISTS public.store_settings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    store_name TEXT NOT NULL DEFAULT 'MOVEN',
    logo_path TEXT,
    contact_email TEXT DEFAULT 'contact@moven.vn',
    contact_phone TEXT DEFAULT '0901234567',
    default_shipping_fee INTEGER NOT NULL DEFAULT 20000 CHECK (default_shipping_fee >= 0),
    low_stock_threshold INTEGER NOT NULL DEFAULT 5 CHECK (low_stock_threshold >= 0),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- Ensure all required columns exist even if table was created in earlier migrations
ALTER TABLE public.store_settings ADD COLUMN IF NOT EXISTS default_shipping_fee INTEGER NOT NULL DEFAULT 20000;
ALTER TABLE public.store_settings ADD COLUMN IF NOT EXISTS low_stock_threshold INTEGER NOT NULL DEFAULT 5;
ALTER TABLE public.store_settings ADD COLUMN IF NOT EXISTS store_name TEXT NOT NULL DEFAULT 'MOVEN';
ALTER TABLE public.store_settings ADD COLUMN IF NOT EXISTS contact_email TEXT DEFAULT 'contact@moven.vn';
ALTER TABLE public.store_settings ADD COLUMN IF NOT EXISTS contact_phone TEXT DEFAULT '0901234567';
ALTER TABLE public.store_settings ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now());

-- Seed initial row safely ONLY if the table is completely empty (avoids duplicate key on is_singleton or id)
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM public.store_settings LIMIT 1) THEN
        INSERT INTO public.store_settings (
            store_name,
            contact_email,
            contact_phone,
            default_shipping_fee,
            low_stock_threshold
        ) VALUES (
            'MOVEN',
            'contact@moven.vn',
            '0901234567',
            20000,
            5
        );
    END IF;
END $$;

-- 2. Row-Level Security (RLS)
ALTER TABLE public.store_settings ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Public can view store settings" ON public.store_settings;
CREATE POLICY "Public can view store settings" ON public.store_settings
FOR SELECT USING (true);

DROP POLICY IF EXISTS "Admin can update store settings" ON public.store_settings;
CREATE POLICY "Admin can update store settings" ON public.store_settings
FOR UPDATE TO authenticated
USING (public.is_admin())
WITH CHECK (public.is_admin());

-- 3. RPC: admin_update_store_settings
CREATE OR REPLACE FUNCTION public.admin_update_store_settings(
    p_default_shipping_fee INTEGER,
    p_low_stock_threshold INTEGER,
    p_store_name TEXT DEFAULT NULL,
    p_contact_email TEXT DEFAULT NULL,
    p_contact_phone TEXT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_admin_id UUID;
    v_target_id UUID;
    v_updated RECORD;
BEGIN
    -- 1. Check admin permission
    v_admin_id := auth.uid();
    IF v_admin_id IS NULL OR NOT public.is_admin() THEN
        RAISE EXCEPTION 'Unauthorized: Chỉ quản trị viên mới có quyền cập nhật cấu hình cửa hàng.'
            USING ERRCODE = 'P0001';
    END IF;

    -- 2. Validate parameters
    IF p_default_shipping_fee IS NULL OR p_default_shipping_fee < 0 THEN
        RAISE EXCEPTION 'Validation error: Phí vận chuyển mặc định không được âm.'
            USING ERRCODE = 'P0002';
    END IF;

    IF p_low_stock_threshold IS NULL OR p_low_stock_threshold < 0 THEN
        RAISE EXCEPTION 'Validation error: Ngưỡng cảnh báo tồn kho thấp không được âm.'
            USING ERRCODE = 'P0002';
    END IF;

    -- 3. Identify target singleton row ID
    SELECT id INTO v_target_id
    FROM public.store_settings
    LIMIT 1;

    -- If somehow table has no row, insert one
    IF v_target_id IS NULL THEN
        INSERT INTO public.store_settings (
            default_shipping_fee,
            low_stock_threshold,
            store_name,
            contact_email,
            contact_phone
        ) VALUES (
            p_default_shipping_fee,
            p_low_stock_threshold,
            COALESCE(TRIM(p_store_name), 'MOVEN'),
            COALESCE(TRIM(p_contact_email), 'contact@moven.vn'),
            COALESCE(TRIM(p_contact_phone), '0901234567')
        )
        RETURNING * INTO v_updated;
    ELSE
        -- Update existing singleton record
        UPDATE public.store_settings
        SET default_shipping_fee = p_default_shipping_fee,
            low_stock_threshold = p_low_stock_threshold,
            store_name = COALESCE(TRIM(p_store_name), store_name),
            contact_email = COALESCE(TRIM(p_contact_email), contact_email),
            contact_phone = COALESCE(TRIM(p_contact_phone), contact_phone),
            updated_at = timezone('utc'::text, now())
        WHERE id = v_target_id
        RETURNING * INTO v_updated;
    END IF;

    RETURN jsonb_build_object(
        'success', true,
        'message', 'Đã lưu cấu hình cửa hàng thành công.',
        'settings', jsonb_build_object(
            'store_name', v_updated.store_name,
            'default_shipping_fee', v_updated.default_shipping_fee,
            'low_stock_threshold', v_updated.low_stock_threshold,
            'contact_email', v_updated.contact_email,
            'contact_phone', v_updated.contact_phone,
            'updated_at', v_updated.updated_at
        )
    );
END;
$$;

-- 4. RPC: admin_get_dashboard_metrics
-- Computes real-time KPI metrics strictly adhering to ADR-0005:
--   - Revenue is exclusively sum of 'delivered' orders
--   - Order counts broken down by status
--   - Low-stock variants (stock <= low_stock_threshold)
--   - Best-selling products from delivered order items
CREATE OR REPLACE FUNCTION public.admin_get_dashboard_metrics(
    p_start_date TIMESTAMPTZ DEFAULT NULL,
    p_end_date TIMESTAMPTZ DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_admin_id UUID;
    v_threshold INTEGER;
    v_delivered_revenue BIGINT := 0;
    v_status_counts JSONB;
    v_best_sellers JSONB;
    v_low_stock JSONB;
    v_recent_orders JSONB;
BEGIN
    -- 1. Check admin permission
    v_admin_id := auth.uid();
    IF v_admin_id IS NULL OR NOT public.is_admin() THEN
        RAISE EXCEPTION 'Unauthorized: Chỉ quản trị viên mới có quyền xem số liệu Dashboard.'
            USING ERRCODE = 'P0001';
    END IF;

    -- 2. Get low_stock_threshold from settings (dynamic lookup)
    SELECT low_stock_threshold INTO v_threshold
    FROM public.store_settings
    LIMIT 1;

    IF v_threshold IS NULL THEN
        v_threshold := 5;
    END IF;

    -- 3. Delivered revenue (ADR-0005: ONLY delivered orders)
    SELECT COALESCE(SUM(total_amount), 0) INTO v_delivered_revenue
    FROM public.orders
    WHERE status = 'delivered'
      AND (p_start_date IS NULL OR delivered_at >= p_start_date)
      AND (p_end_date IS NULL OR delivered_at <= p_end_date);

    -- 4. Order counts by status
    WITH counts AS (
        SELECT 
            status,
            COUNT(*)::INT AS count
        FROM public.orders
        WHERE (p_start_date IS NULL OR created_at >= p_start_date)
          AND (p_end_date IS NULL OR created_at <= p_end_date)
        GROUP BY status
    )
    SELECT COALESCE(jsonb_object_agg(status, count), '{}'::jsonb) INTO v_status_counts
    FROM counts;

    -- 5. Best sellers (Quantity from delivered order items)
    WITH top_items AS (
        SELECT 
            oi.product_name_snapshot AS product_name,
            pv.product_id,
            SUM(oi.quantity)::INT AS total_sold,
            SUM(oi.line_total)::BIGINT AS total_revenue
        FROM public.order_items oi
        JOIN public.orders o ON o.id = oi.order_id
        LEFT JOIN public.product_variants pv ON pv.id = oi.variant_id
        WHERE o.status = 'delivered'
          AND (p_start_date IS NULL OR o.delivered_at >= p_start_date)
          AND (p_end_date IS NULL OR o.delivered_at <= p_end_date)
        GROUP BY oi.product_name_snapshot, pv.product_id
        ORDER BY total_sold DESC
        LIMIT 5
    )
    SELECT COALESCE(jsonb_agg(
        jsonb_build_object(
            'product_name', product_name,
            'product_id', product_id,
            'total_sold', total_sold,
            'total_revenue', total_revenue
        )
    ), '[]'::jsonb) INTO v_best_sellers
    FROM top_items;

    -- 6. Low stock variants (Active variants with stock <= threshold)
    WITH low_items AS (
        SELECT 
            pv.id AS variant_id,
            pv.sku,
            pv.size,
            pv.color_name,
            pv.stock_quantity,
            p.name AS product_name,
            p.id AS product_id
        FROM public.product_variants pv
        JOIN public.products p ON p.id = pv.product_id
        WHERE pv.is_active = true
          AND p.is_active = true
          AND pv.stock_quantity <= v_threshold
        ORDER BY pv.stock_quantity ASC, pv.updated_at DESC
        LIMIT 10
    )
    SELECT COALESCE(jsonb_agg(
        jsonb_build_object(
            'variant_id', variant_id,
            'sku', sku,
            'size', size,
            'color_name', color_name,
            'stock_quantity', stock_quantity,
            'product_name', product_name,
            'product_id', product_id
        )
    ), '[]'::jsonb) INTO v_low_stock
    FROM low_items;

    -- 7. Recent orders (top 5 newest)
    WITH recent AS (
        SELECT 
            o.id,
            o.order_code,
            o.recipient_name,
            o.total_amount,
            o.status,
            o.payment_status,
            o.created_at
        FROM public.orders o
        ORDER BY o.created_at DESC
        LIMIT 5
    )
    SELECT COALESCE(jsonb_agg(
        jsonb_build_object(
            'id', id,
            'order_code', order_code,
            'recipient_name', recipient_name,
            'total_amount', total_amount,
            'status', status,
            'payment_status', payment_status,
            'created_at', created_at
        )
    ), '[]'::jsonb) INTO v_recent_orders
    FROM recent;

    RETURN jsonb_build_object(
        'delivered_revenue', v_delivered_revenue,
        'low_stock_threshold', v_threshold,
        'status_counts', v_status_counts,
        'best_sellers', v_best_sellers,
        'low_stock_variants', v_low_stock,
        'recent_orders', v_recent_orders
    );
END;
$$;

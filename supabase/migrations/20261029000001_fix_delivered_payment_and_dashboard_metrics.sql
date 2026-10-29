-- MOVEN Migration: Fix Delivered Payment Status and Dashboard Metrics RPC Permissions
-- Spec References: ADR-0001, ADR-0002, ADR-0005, SRS ORDER-007, BUSINESS_FLOWS.md, D-06
--
-- 1. admin_update_order_status:
--    When an admin marks an order as 'delivered', automatically update payment_status to 'paid'
--    per approved MVP Decision D-06 (Option B).
-- 2. customer_confirm_delivery:
--    Ensure customer confirmation also sets payment_status = 'paid'.
-- 3. admin_get_dashboard_metrics:
--    - Robust revenue calculation using COALESCE(delivered_at, updated_at, created_at)
--    - Explicitly GRANT EXECUTE to authenticated users
-- 4. admin_update_store_settings:
--    - Explicitly GRANT EXECUTE to authenticated users

-- ==========================================
-- 1. RPC: admin_update_order_status
-- ==========================================
CREATE OR REPLACE FUNCTION public.admin_update_order_status(
    p_order_id UUID,
    p_new_status TEXT,
    p_note TEXT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_admin_id UUID;
    v_order RECORD;
    v_item RECORD;
    v_note TEXT;
BEGIN
    -- 1. Check admin permission
    v_admin_id := auth.uid();
    IF v_admin_id IS NULL OR NOT public.is_admin() THEN
        RAISE EXCEPTION 'Unauthorized: Chỉ quản trị viên mới có quyền cập nhật trạng thái đơn hàng.'
            USING ERRCODE = 'P0001';
    END IF;

    -- 2. Lock and retrieve order
    SELECT * INTO v_order
    FROM public.orders
    WHERE id = p_order_id
    FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Không tìm thấy đơn hàng với ID %.', p_order_id
            USING ERRCODE = 'P0003';
    END IF;

    -- 3. Validate state machine transition (ADR-0001)
    IF v_order.status = p_new_status THEN
        RETURN jsonb_build_object(
            'success', true,
            'order_id', v_order.id,
            'status', v_order.status,
            'message', 'Trạng thái không đổi.'
        );
    END IF;

    IF v_order.status IN ('cancelled', 'returned') THEN
        RAISE EXCEPTION 'Đơn hàng đã ở trạng thái kết thúc (%) và không thể thay đổi thêm.', v_order.status
            USING ERRCODE = 'P0004';
    END IF;

    IF v_order.status = 'delivered' AND p_new_status <> 'returned' THEN
        RAISE EXCEPTION 'Đơn hàng đã giao thành công, không thể chuyển sang trạng thái %.', p_new_status
            USING ERRCODE = 'P0004';
    END IF;

    -- Validate specific transitions
    IF v_order.status IN ('pending_confirmation', 'confirmed', 'preparing') THEN
        IF p_new_status NOT IN ('shipping', 'cancelled') THEN
            RAISE EXCEPTION 'Đơn hàng đang chờ xử lý chỉ có thể chuyển sang "shipping" hoặc "cancelled".'
                USING ERRCODE = 'P0004';
        END IF;
    ELSIF v_order.status = 'shipping' THEN
        IF p_new_status NOT IN ('delivered', 'delivery_failed') THEN
            RAISE EXCEPTION 'Đơn hàng đang giao chỉ có thể chuyển sang "delivered" hoặc "delivery_failed".'
                USING ERRCODE = 'P0004';
        END IF;
    ELSIF v_order.status = 'delivery_failed' THEN
        IF p_new_status NOT IN ('shipping', 'returned') THEN
            RAISE EXCEPTION 'Đơn giao thất bại chỉ có thể giao lại ("shipping") hoặc nhận hàng hoàn về kho ("returned").'
                USING ERRCODE = 'P0004';
        END IF;
    END IF;

    -- 4. Restock handling (Atomically per ADR-0001)
    IF p_new_status = 'cancelled' THEN
        FOR v_item IN 
            SELECT variant_id, quantity 
            FROM public.order_items 
            WHERE order_id = v_order.id
        LOOP
            IF v_item.variant_id IS NOT NULL THEN
                UPDATE public.product_variants
                SET 
                    stock_quantity = stock_quantity + v_item.quantity,
                    updated_at = clock_timestamp()
                WHERE id = v_item.variant_id;

                INSERT INTO public.inventory_movements (
                    id,
                    variant_id,
                    order_id,
                    quantity_delta,
                    reason,
                    created_by,
                    created_at
                ) VALUES (
                    gen_random_uuid(),
                    v_item.variant_id,
                    v_order.id,
                    v_item.quantity,
                    'order_cancelled',
                    v_admin_id,
                    clock_timestamp()
                );
            END IF;
        END LOOP;
    ELSIF p_new_status = 'returned' THEN
        FOR v_item IN 
            SELECT variant_id, quantity 
            FROM public.order_items 
            WHERE order_id = v_order.id
        LOOP
            IF v_item.variant_id IS NOT NULL THEN
                UPDATE public.product_variants
                SET 
                    stock_quantity = stock_quantity + v_item.quantity,
                    updated_at = clock_timestamp()
                WHERE id = v_item.variant_id;

                INSERT INTO public.inventory_movements (
                    id,
                    variant_id,
                    order_id,
                    quantity_delta,
                    reason,
                    created_by,
                    created_at
                ) VALUES (
                    gen_random_uuid(),
                    v_item.variant_id,
                    v_order.id,
                    v_item.quantity,
                    'return_received',
                    v_admin_id,
                    clock_timestamp()
                );
            END IF;
        END LOOP;
    END IF;

    -- 5. Update Order record (Automatically update payment_status = 'paid' on delivered per D-06)
    v_note := TRIM(COALESCE(p_note, ''));
    UPDATE public.orders
    SET 
        status = p_new_status,
        delivered_at = CASE WHEN p_new_status = 'delivered' THEN clock_timestamp() ELSE delivered_at END,
        payment_status = CASE WHEN p_new_status = 'delivered' THEN 'paid' ELSE payment_status END,
        cancelled_at = CASE WHEN p_new_status = 'cancelled' THEN clock_timestamp() ELSE cancelled_at END,
        cancellation_reason = CASE WHEN p_new_status = 'cancelled' AND v_note <> '' THEN v_note ELSE cancellation_reason END,
        updated_at = clock_timestamp()
    WHERE id = v_order.id;

    -- 6. Record order status history
    INSERT INTO public.order_status_history (
        id,
        order_id,
        from_status,
        to_status,
        actor_id,
        note,
        created_at
    ) VALUES (
        gen_random_uuid(),
        v_order.id,
        v_order.status,
        p_new_status,
        v_admin_id,
        CASE 
            WHEN v_note <> '' THEN v_note 
            ELSE 'Quản trị viên cập nhật trạng thái: ' || p_new_status 
        END,
        clock_timestamp()
    );

    RETURN jsonb_build_object(
        'success', true,
        'order_id', v_order.id,
        'previous_status', v_order.status,
        'new_status', p_new_status,
        'payment_status', CASE WHEN p_new_status = 'delivered' THEN 'paid' ELSE v_order.payment_status END
    );
END;
$$;

-- ==========================================
-- 2. RPC: customer_confirm_delivery
-- ==========================================
CREATE OR REPLACE FUNCTION public.customer_confirm_delivery(
    p_order_code TEXT
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_user_id UUID;
    v_order RECORD;
BEGIN
    -- 1. Check authentication
    v_user_id := auth.uid();
    IF v_user_id IS NULL THEN
        RAISE EXCEPTION 'Unauthenticated: Bạn cần đăng nhập để thực hiện thao tác này.'
            USING ERRCODE = 'P0001';
    END IF;

    -- 2. Lock and retrieve order
    SELECT * INTO v_order
    FROM public.orders
    WHERE order_code = p_order_code
    FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Không tìm thấy đơn hàng với mã %.', p_order_code
            USING ERRCODE = 'P0003';
    END IF;

    -- 3. Check ownership
    IF v_order.user_id <> v_user_id THEN
        RAISE EXCEPTION 'Unauthorized: Bạn không có quyền thao tác trên đơn hàng này.'
            USING ERRCODE = 'P0001';
    END IF;

    -- 4. Validate status (Must be currently shipping)
    IF v_order.status <> 'shipping' THEN
        RAISE EXCEPTION 'Chỉ có thể xác nhận đã nhận hàng khi đơn đang trong trạng thái Đang giao hàng (Hiện tại: %).', v_order.status
            USING ERRCODE = 'P0004';
    END IF;

    -- 5. Update order status to delivered & payment_status to paid
    UPDATE public.orders
    SET 
        status = 'delivered',
        delivered_at = clock_timestamp(),
        payment_status = 'paid',
        updated_at = clock_timestamp()
    WHERE id = v_order.id;

    -- 6. Insert audit trail in order_status_history
    INSERT INTO public.order_status_history (
        id,
        order_id,
        from_status,
        to_status,
        actor_id,
        note,
        created_at
    ) VALUES (
        gen_random_uuid(),
        v_order.id,
        v_order.status,
        'delivered',
        v_user_id,
        'Khách hàng xác nhận đã nhận được hàng COD',
        clock_timestamp()
    );

    RETURN jsonb_build_object(
        'success', true,
        'order_id', v_order.id,
        'order_code', v_order.order_code,
        'status', 'delivered',
        'payment_status', 'paid'
    );
END;
$$;

-- ==========================================
-- 3. RPC: admin_get_dashboard_metrics
-- ==========================================
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
      AND (p_start_date IS NULL OR COALESCE(delivered_at, updated_at, created_at) >= p_start_date)
      AND (p_end_date IS NULL OR COALESCE(delivered_at, updated_at, created_at) <= p_end_date);

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
          AND (p_start_date IS NULL OR COALESCE(o.delivered_at, o.updated_at, o.created_at) >= p_start_date)
          AND (p_end_date IS NULL OR COALESCE(o.delivered_at, o.updated_at, o.created_at) <= p_end_date)
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

-- ==========================================
-- 4. GRANT PERMISSIONS TO AUTHENTICATED USERS
-- ==========================================
GRANT EXECUTE ON FUNCTION public.admin_update_order_status(UUID, TEXT, TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION public.customer_confirm_delivery(TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION public.admin_get_dashboard_metrics(TIMESTAMPTZ, TIMESTAMPTZ) TO authenticated;

-- Safely grant execute on admin_update_store_settings if it exists
DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM pg_proc p 
        JOIN pg_namespace n ON p.pronamespace = n.oid 
        WHERE n.nspname = 'public' AND p.proname = 'admin_update_store_settings'
    ) THEN
        EXECUTE 'GRANT EXECUTE ON FUNCTION public.admin_update_store_settings(INTEGER, INTEGER, TEXT, TEXT, TEXT) TO authenticated;';
    END IF;
END $$;

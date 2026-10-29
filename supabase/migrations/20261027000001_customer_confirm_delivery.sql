-- MOVEN Phase 6 Migration: Customer Delivery Confirmation RPC
-- Spec References: ADR-0001, ADR-0004, GLOSSARY.md, BUSINESS_FLOWS.md

-- RPC: customer_confirm_delivery
-- Allows authenticated customer to confirm delivery of their own order strictly when status is 'shipping'.
-- Atomically:
--   - Validates that caller is the order owner
--   - Validates that current status is 'shipping'
--   - Updates order status to 'delivered' and sets delivered_at timestamp
--   - Inserts order_status_history audit record
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
        'status', 'delivered'
    );
END;
$$;

-- Grant execution permission to authenticated users
GRANT EXECUTE ON FUNCTION public.customer_confirm_delivery(TEXT) TO authenticated;

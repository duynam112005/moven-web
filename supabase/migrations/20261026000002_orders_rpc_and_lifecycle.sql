-- MOVEN Phase 6 Migration 02: Order Lifecycle RPCs & Atomic Restocking
-- Spec References: ADR-0001, ADR-0002, GLOSSARY.md, BUSINESS_FLOWS.md, DATABASE_SPEC.md

-- 1. Ensure cancellation_reason column exists on orders table
ALTER TABLE public.orders 
ADD COLUMN IF NOT EXISTS cancellation_reason TEXT;

-- 2. RPC: customer_cancel_order
-- Allows authenticated customer to cancel an order strictly when status is 'pending_confirmation'
-- Atomically:
--   - Updates order status to 'cancelled' and sets cancellation_reason and cancelled_at
--   - Restocks all order items back to product_variants.stock_quantity
--   - Inserts audit records into inventory_movements (reason: 'order_cancelled')
--   - Inserts order_status_history record
CREATE OR REPLACE FUNCTION public.customer_cancel_order(
    p_order_code TEXT,
    p_cancellation_reason TEXT
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_user_id UUID;
    v_order RECORD;
    v_item RECORD;
    v_trimmed_reason TEXT;
BEGIN
    -- 1. Check authentication
    v_user_id := auth.uid();
    IF v_user_id IS NULL THEN
        RAISE EXCEPTION 'Unauthenticated: Bạn cần đăng nhập để thực hiện thao tác này.'
            USING ERRCODE = 'P0001';
    END IF;

    -- 2. Validate reason
    v_trimmed_reason := TRIM(COALESCE(p_cancellation_reason, ''));
    IF v_trimmed_reason = '' THEN
        RAISE EXCEPTION 'Validation error: Vui lòng cung cấp lý do hủy đơn hàng.'
            USING ERRCODE = 'P0002';
    END IF;

    -- 3. Lock and retrieve order
    SELECT * INTO v_order
    FROM public.orders
    WHERE order_code = p_order_code
    FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Không tìm thấy đơn hàng với mã %.', p_order_code
            USING ERRCODE = 'P0003';
    END IF;

    -- 4. Check ownership
    IF v_order.user_id <> v_user_id THEN
        RAISE EXCEPTION 'Unauthorized: Bạn không có quyền thao tác trên đơn hàng này.'
            USING ERRCODE = 'P0001';
    END IF;

    -- 5. Validate status (ADR-0001: Customer can only cancel during pending state)
    IF v_order.status <> 'pending_confirmation' AND v_order.status <> 'pending' THEN
        RAISE EXCEPTION 'Không thể hủy đơn hàng vì đơn đã được tiếp nhận xử lý hoặc đang vận chuyển (Trạng thái: %).', v_order.status
            USING ERRCODE = 'P0004';
    END IF;

    -- 6. Atomically restock inventory and log inventory_movements
    FOR v_item IN 
        SELECT variant_id, quantity 
        FROM public.order_items 
        WHERE order_id = v_order.id
    LOOP
        IF v_item.variant_id IS NOT NULL THEN
            -- Increment stock
            UPDATE public.product_variants
            SET 
                stock_quantity = stock_quantity + v_item.quantity,
                updated_at = clock_timestamp()
            WHERE id = v_item.variant_id;

            -- Log inventory movement
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
                v_user_id,
                clock_timestamp()
            );
        END IF;
    END LOOP;

    -- 7. Update order status
    UPDATE public.orders
    SET 
        status = 'cancelled',
        cancellation_reason = v_trimmed_reason,
        cancelled_at = clock_timestamp(),
        updated_at = clock_timestamp()
    WHERE id = v_order.id;

    -- 8. Record order status history
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
        'cancelled',
        v_user_id,
        'Khách hủy đơn: ' || v_trimmed_reason,
        clock_timestamp()
    );

    RETURN jsonb_build_object(
        'success', true,
        'order_id', v_order.id,
        'order_code', v_order.order_code,
        'status', 'cancelled'
    );
END;
$$;

-- 3. RPC: admin_update_order_status
-- Allows authorized admin to update order fulfillment status following the state machine (ADR-0001)
-- Transitions allowed:
--   - pending_confirmation / pending -> shipping, cancelled
--   - shipping -> delivered, delivery_failed
--   - delivery_failed -> shipping (retry delivery), returned (restock on receipt)
-- Invariants enforced:
--   - Restocking NEVER occurs on 'delivery_failed'
--   - Restocking ONLY occurs when transitioning to 'returned' or 'cancelled'
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
    -- When moving to 'cancelled'
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
    -- When moving to 'returned' (Confirmed return receipt by admin)
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

    -- 5. Update Order record
    v_note := TRIM(COALESCE(p_note, ''));
    UPDATE public.orders
    SET 
        status = p_new_status,
        delivered_at = CASE WHEN p_new_status = 'delivered' THEN clock_timestamp() ELSE delivered_at END,
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
        'new_status', p_new_status
    );
END;
$$;

-- 4. RPC: admin_update_payment_status
-- Allows admin to reconcile Cash on Delivery payment status independently (ADR-0002)
CREATE OR REPLACE FUNCTION public.admin_update_payment_status(
    p_order_id UUID,
    p_payment_status TEXT,
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
    v_note TEXT;
BEGIN
    -- 1. Check admin permission
    v_admin_id := auth.uid();
    IF v_admin_id IS NULL OR NOT public.is_admin() THEN
        RAISE EXCEPTION 'Unauthorized: Chỉ quản trị viên mới có quyền cập nhật trạng thái thanh toán.'
            USING ERRCODE = 'P0001';
    END IF;

    -- 2. Validate payment status
    IF p_payment_status NOT IN ('unpaid', 'paid', 'failed') THEN
        RAISE EXCEPTION 'Validation error: Trạng thái thanh toán không hợp lệ (%).', p_payment_status
            USING ERRCODE = 'P0002';
    END IF;

    -- 3. Lock and retrieve order
    SELECT * INTO v_order
    FROM public.orders
    WHERE id = p_order_id
    FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Không tìm thấy đơn hàng với ID %.', p_order_id
            USING ERRCODE = 'P0003';
    END IF;

    -- 4. Update payment status
    UPDATE public.orders
    SET 
        payment_status = p_payment_status,
        updated_at = clock_timestamp()
    WHERE id = v_order.id;

    -- 5. Record note if provided
    v_note := TRIM(COALESCE(p_note, ''));
    IF v_note <> '' THEN
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
            v_order.status,
            v_admin_id,
            'Cập nhật thanh toán (' || p_payment_status || '): ' || v_note,
            clock_timestamp()
        );
    END IF;

    RETURN jsonb_build_object(
        'success', true,
        'order_id', v_order.id,
        'payment_status', p_payment_status
    );
END;
$$;

-- 5. Grant permissions to authenticated users
GRANT EXECUTE ON FUNCTION public.customer_cancel_order(TEXT, TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION public.admin_update_order_status(UUID, TEXT, TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION public.admin_update_payment_status(UUID, TEXT, TEXT) TO authenticated;

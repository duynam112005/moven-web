-- MOVEN Migration: QR Code Payment and Expiration Support
-- Spec Reference: GLOSSARY.md, docs/adr/0007-qr-code-payment-and-expiration.md, BUSINESS_FLOWS.md (6.4, 6.5, 6.7)

-- 1. Update constraint on orders.payment_method to allow 'qr_code'
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN (
        SELECT conname
        FROM pg_constraint
        WHERE conrelid = 'public.orders'::regclass
          AND contype = 'c'
          AND pg_get_constraintdef(oid) LIKE '%payment_method%'
    ) LOOP
        EXECUTE 'ALTER TABLE public.orders DROP CONSTRAINT ' || quote_ident(r.conname);
    END LOOP;
END $$;

ALTER TABLE public.orders
ADD CONSTRAINT orders_payment_method_check CHECK (payment_method IN ('cod', 'qr_code'));

-- 2. Add payment_expired_at column if not exists
ALTER TABLE public.orders
ADD COLUMN IF NOT EXISTS payment_expired_at TIMESTAMPTZ DEFAULT NULL;

-- 3. Drop previous 3-param create_order_checkout to avoid overload signature collision
DROP FUNCTION IF EXISTS public.create_order_checkout(JSONB, JSONB, TEXT);

-- 4. Re-create create_order_checkout with p_payment_method support
CREATE OR REPLACE FUNCTION public.create_order_checkout(
    p_shipping_address JSONB,
    p_items JSONB,
    p_customer_note TEXT DEFAULT NULL,
    p_payment_method TEXT DEFAULT 'cod'
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
    v_payment_method TEXT;
    v_payment_expired_at TIMESTAMPTZ := NULL;
    v_history_note TEXT;
BEGIN
    -- 1. Verify authenticated user
    v_user_id := auth.uid();
    IF v_user_id IS NULL THEN
        RAISE EXCEPTION 'Unauthenticated: Bạn cần đăng nhập để thực hiện đặt hàng.'
            USING ERRCODE = 'P0001';
    END IF;

    -- 2. Validate payment method
    v_payment_method := LOWER(TRIM(COALESCE(p_payment_method, 'cod')));
    IF v_payment_method NOT IN ('cod', 'qr_code') THEN
        RAISE EXCEPTION 'Validation error: Phương thức thanh toán không hợp lệ (%).', p_payment_method
            USING ERRCODE = 'P0002';
    END IF;

    IF v_payment_method = 'qr_code' THEN
        v_payment_expired_at := clock_timestamp() + INTERVAL '15 minutes';
        v_history_note := 'Khách đặt hàng chọn thanh toán Quét mã QR (Hạn 15 phút)';
    ELSE
        v_history_note := 'Khách đặt hàng COD thành công';
    END IF;

    -- 3. Validate shipping address
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

    -- 4. Validate items
    IF p_items IS NULL OR jsonb_array_length(p_items) = 0 THEN
        RAISE EXCEPTION 'Validation error: Giỏ hàng không có sản phẩm nào để đặt.'
            USING ERRCODE = 'P0002';
    END IF;

    -- 5. Get authoritative shipping fee from store_settings (singleton)
    SELECT default_shipping_fee INTO v_shipping_fee
    FROM public.store_settings
    LIMIT 1;

    IF v_shipping_fee IS NULL THEN
        v_shipping_fee := 20000;
    END IF;

    -- 6. Process and validate all items with FOR UPDATE locking
    FOR v_item IN SELECT * FROM jsonb_array_elements(p_items)
    LOOP
        v_variant_id := (v_item->>'variant_id')::UUID;
        v_quantity := (v_item->>'quantity')::INTEGER;

        IF v_quantity IS NULL OR v_quantity <= 0 THEN
            RAISE EXCEPTION 'Validation error: Số lượng sản phẩm phải lớn hơn 0.'
                USING ERRCODE = 'P0002';
        END IF;

        -- Lock variant row exclusively to prevent concurrent checkout overselling
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

        -- Collect enriched item info for insertion
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

    -- 7. Total amount calculation (discount_amount = 0 for MVP)
    v_total_amount := v_subtotal + v_shipping_fee;

    -- 8. Generate readable order_code with prefix MVN-
    LOOP
        v_order_code := 'MVN-' || upper(substring(md5(random()::text || clock_timestamp()::text) from 1 for 8));
        EXIT WHEN NOT EXISTS (SELECT 1 FROM public.orders WHERE order_code = v_order_code);
    END LOOP;

    -- 9. Insert Order
    INSERT INTO public.orders (
        id,
        order_code,
        user_id,
        status,
        payment_method,
        payment_status,
        payment_expired_at,
        recipient_name,
        recipient_phone,
        shipping_address,
        subtotal,
        shipping_fee,
        discount_amount,
        total_amount,
        customer_note,
        created_at,
        updated_at
    ) VALUES (
        gen_random_uuid(),
        v_order_code,
        v_user_id,
        'pending_confirmation',
        v_payment_method,
        'unpaid',
        v_payment_expired_at,
        v_recipient_name,
        v_recipient_phone,
        p_shipping_address,
        v_subtotal,
        v_shipping_fee,
        0,
        v_total_amount,
        p_customer_note,
        clock_timestamp(),
        clock_timestamp()
    ) RETURNING id INTO v_order_id;

    -- 10. Insert order status history (Audit log)
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
        v_order_id,
        NULL,
        'pending_confirmation',
        v_user_id,
        v_history_note,
        clock_timestamp()
    );

    -- 11. Insert order items & update inventory movements & decrement stock
    FOR v_item IN SELECT * FROM jsonb_array_elements(v_item_list)
    LOOP
        -- Insert Order Item
        INSERT INTO public.order_items (
            id,
            order_id,
            variant_id,
            product_name_snapshot,
            sku_snapshot,
            size_snapshot,
            color_snapshot,
            unit_price,
            quantity,
            line_total
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

        -- Decrement stock quantity
        UPDATE public.product_variants
        SET 
            stock_quantity = stock_quantity - (v_item->>'quantity')::INTEGER,
            updated_at = clock_timestamp()
        WHERE id = (v_item->>'variant_id')::UUID;

        -- Record inventory movement (reason: order_created per D-17)
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
            (v_item->>'variant_id')::UUID,
            v_order_id,
            -((v_item->>'quantity')::INTEGER),
            'order_created',
            v_user_id,
            clock_timestamp()
        );
    END LOOP;

    -- 12. Clear ordered items from the user's cart
    DELETE FROM public.cart_items
    WHERE cart_id IN (SELECT id FROM public.carts WHERE user_id = v_user_id)
      AND variant_id IN (
          SELECT (item->>'variant_id')::UUID
          FROM jsonb_array_elements(p_items) AS item
      );

    -- 13. Return created order summary
    RETURN jsonb_build_object(
        'success', true,
        'order_id', v_order_id,
        'order_code', v_order_code,
        'subtotal', v_subtotal,
        'shipping_fee', v_shipping_fee,
        'total_amount', v_total_amount,
        'payment_method', v_payment_method,
        'payment_expired_at', v_payment_expired_at
    );
END;
$$;

-- Grant execution permission to authenticated users
GRANT EXECUTE ON FUNCTION public.create_order_checkout(JSONB, JSONB, TEXT, TEXT) TO authenticated;

-- 5. RPC: cancel_expired_qr_orders
-- Scans and cancels all unpaid QR orders whose 15-minute TTL has passed, atomically restocking inventory.
CREATE OR REPLACE FUNCTION public.cancel_expired_qr_orders()
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_order RECORD;
    v_item RECORD;
    v_count INTEGER := 0;
BEGIN
    FOR v_order IN
        SELECT id, order_code, user_id
        FROM public.orders
        WHERE payment_method = 'qr_code'
          AND payment_status = 'unpaid'
          AND status = 'pending_confirmation'
          AND payment_expired_at IS NOT NULL
          AND payment_expired_at < clock_timestamp()
        FOR UPDATE SKIP LOCKED
    LOOP
        -- Restock inventory for each order item
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
                    v_order.user_id,
                    clock_timestamp()
                );
            END IF;
        END LOOP;

        -- Update order status to cancelled
        UPDATE public.orders
        SET 
            status = 'cancelled',
            cancelled_at = clock_timestamp(),
            cancellation_reason = 'Hết hạn thời gian thanh toán mã QR (15 phút)',
            updated_at = clock_timestamp()
        WHERE id = v_order.id;

        -- Insert audit log in order_status_history
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
            'pending_confirmation',
            'cancelled',
            v_order.user_id,
            'Hệ thống tự động hủy đơn do quá hạn thanh toán mã QR 15 phút',
            clock_timestamp()
        );

        v_count := v_count + 1;
    END LOOP;

    RETURN jsonb_build_object(
        'success', true,
        'cancelled_count', v_count
    );
END;
$$;

GRANT EXECUTE ON FUNCTION public.cancel_expired_qr_orders() TO authenticated;
GRANT EXECUTE ON FUNCTION public.cancel_expired_qr_orders() TO anon;

-- 6. Update RPC admin_update_payment_status
-- When admin sets payment_status = 'paid' for an unpaid QR order in 'pending_confirmation',
-- automatically transition order status to 'confirmed' per approved Decision 3.
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
    v_auto_confirm BOOLEAN := false;
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

    -- 4. Check if we should auto-confirm (paid QR order in pending_confirmation)
    IF p_payment_status = 'paid' AND v_order.status = 'pending_confirmation' THEN
        v_auto_confirm := true;
    END IF;

    -- 5. Update payment status & status if auto-confirm
    UPDATE public.orders
    SET 
        payment_status = p_payment_status,
        status = CASE WHEN v_auto_confirm THEN 'confirmed' ELSE status END,
        updated_at = clock_timestamp()
    WHERE id = v_order.id;

    -- 6. Record note and history
    v_note := TRIM(COALESCE(p_note, ''));
    IF v_auto_confirm THEN
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
            'pending_confirmation',
            'confirmed',
            v_admin_id,
            COALESCE(NULLIF(v_note, ''), 'Admin xác nhận thanh toán mã QR: tự động chuyển sang Đã xác nhận (confirmed)'),
            clock_timestamp()
        );
    ELSIF v_note <> '' THEN
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
        'payment_status', p_payment_status,
        'status', CASE WHEN v_auto_confirm THEN 'confirmed' ELSE v_order.status END
    );
END;
$$;

-- Force PostgREST to reload schema cache
NOTIFY pgrst, 'reload schema';


-- MOVEN Phase 5 Migration 01: Checkout RPC & Inventory Atomic Transaction
-- Spec Reference: BUSINESS_FLOWS.md (Section 6.4), DATABASE_SPEC.md, SECURITY_SPEC.md

-- Function: create_order_checkout
-- Executes the full checkout transaction atomically:
-- 1. Validates authenticated caller
-- 2. Validates shipping address and items
-- 3. Locks product variants (FOR UPDATE) to prevent race conditions & overselling
-- 4. Reads authoritative price and stock from DB
-- 5. Calculates subtotal and shipping fee server-side
-- 6. Generates unique order code (MVN-XXXXXXXX)
-- 7. Inserts order, order_items, order_status_history
-- 8. Decrements stock and inserts inventory_movements (reason: order_created)
-- 9. Clears checked-out items from user cart
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
    -- 1. Verify authenticated user
    v_user_id := auth.uid();
    IF v_user_id IS NULL THEN
        RAISE EXCEPTION 'Unauthenticated: Bạn cần đăng nhập để thực hiện đặt hàng.'
            USING ERRCODE = 'P0001';
    END IF;

    -- 2. Validate shipping address
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

    -- 3. Validate items
    IF p_items IS NULL OR jsonb_array_length(p_items) = 0 THEN
        RAISE EXCEPTION 'Validation error: Giỏ hàng không có sản phẩm nào để đặt.'
            USING ERRCODE = 'P0002';
    END IF;

    -- 4. Get authoritative shipping fee from store_settings (singleton)
    SELECT default_shipping_fee INTO v_shipping_fee
    FROM public.store_settings
    LIMIT 1;

    IF v_shipping_fee IS NULL THEN
        v_shipping_fee := 20000;
    END IF;

    -- 5. Process and validate all items with FOR UPDATE locking
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

    -- 6. Total amount calculation (discount_amount = 0 for MVP)
    v_total_amount := v_subtotal + v_shipping_fee;

    -- 7. Generate readable order_code with prefix MVN-
    LOOP
        v_order_code := 'MVN-' || upper(substring(md5(random()::text || clock_timestamp()::text) from 1 for 8));
        EXIT WHEN NOT EXISTS (SELECT 1 FROM public.orders WHERE order_code = v_order_code);
    END LOOP;

    -- 8. Insert Order
    INSERT INTO public.orders (
        id,
        order_code,
        user_id,
        status,
        payment_method,
        payment_status,
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
        'cod',
        'unpaid',
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

    -- 9. Insert order status history (Audit log per Decision D-07)
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
        'Khách đặt hàng COD thành công',
        clock_timestamp()
    );

    -- 10. Insert order items & update inventory movements & decrement stock
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

    -- 11. Clear ordered items from the user's cart
    DELETE FROM public.cart_items
    WHERE cart_id IN (SELECT id FROM public.carts WHERE user_id = v_user_id)
      AND variant_id IN (
          SELECT (item->>'variant_id')::UUID
          FROM jsonb_array_elements(p_items) AS item
      );

    -- 12. Return created order summary
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

-- Grant execution permission to authenticated users
GRANT EXECUTE ON FUNCTION public.create_order_checkout(JSONB, JSONB, TEXT) TO authenticated;

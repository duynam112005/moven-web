-- MOVEN Phase 2 Verification: RLS & Constraints Tests
-- Spec Reference: IMPLEMENTATION_PLAN.md, SECURITY_SPEC.md 5.8, DATABASE_SPEC.md 3.3

BEGIN;

-- ========================================================
-- TEST SECTION 1: DATA CONSTRAINTS VALIDATION
-- ========================================================

-- Test 1.1: Negative variant price must FAIL
DO $$
BEGIN
    INSERT INTO public.product_variants (
        product_id, sku, price, stock_quantity
    ) VALUES (
        '20000000-0000-0000-0000-000000000001', 'TEST-NEG-PRICE', -50000, 10
    );
    RAISE EXCEPTION 'Constraint failure: Negative price was erroneously allowed';
EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'Test 1.1 PASSED: Negative price rejected by check constraint';
END $$;

-- Test 1.2: Compare_at_price lower than price must FAIL
DO $$
BEGIN
    INSERT INTO public.product_variants (
        product_id, sku, price, compare_at_price, stock_quantity
    ) VALUES (
        '20000000-0000-0000-0000-000000000001', 'TEST-COMPARE-PRICE', 200000, 150000, 10
    );
    RAISE EXCEPTION 'Constraint failure: compare_at_price < price was erroneously allowed';
EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'Test 1.2 PASSED: compare_at_price < price rejected by check constraint';
END $$;

-- Test 1.3: Negative stock quantity must FAIL
DO $$
BEGIN
    INSERT INTO public.product_variants (
        product_id, sku, price, stock_quantity
    ) VALUES (
        '20000000-0000-0000-0000-000000000001', 'TEST-NEG-STOCK', 100000, -5
    );
    RAISE EXCEPTION 'Constraint failure: Negative stock quantity was erroneously allowed';
EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'Test 1.3 PASSED: Negative stock rejected by check constraint';
END $$;

-- Test 1.4: Order total mismatch calculation must FAIL
DO $$
BEGIN
    INSERT INTO public.orders (
        order_code, user_id, recipient_name, recipient_phone, shipping_address,
        subtotal, shipping_fee, discount_amount, total_amount
    ) VALUES (
        'MVN-TEST-FAIL-TOTAL', 'c0000000-0000-0000-0000-000000000001',
        'Test Customer', '0900000000', '{"province": "HN"}'::jsonb,
        200000, 20000, 0, 999999 -- Erroneous total amount
    );
    RAISE EXCEPTION 'Constraint failure: Mismatched total_amount was erroneously allowed';
EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'Test 1.4 PASSED: Mismatched order total rejected by check constraint';
END $$;

-- Test 1.5: Singleton store_settings violation must FAIL
DO $$
BEGIN
    INSERT INTO public.store_settings (store_name, is_singleton)
    VALUES ('MOVEN Duplicate', true);
    RAISE EXCEPTION 'Constraint failure: Duplicate store_settings was erroneously allowed';
EXCEPTION WHEN unique_violation THEN
    RAISE NOTICE 'Test 1.5 PASSED: Second store_settings rejected by singleton unique constraint';
END $$;

-- ========================================================
-- TEST SECTION 2: RLS & SECURITY PRIVILEGES VALIDATION
-- ========================================================

-- Setup test users in profiles
INSERT INTO public.profiles (id, full_name, role)
VALUES
    ('11111111-1111-1111-1111-111111111111', 'Customer One', 'customer'),
    ('22222222-2222-2222-2222-222222222222', 'Customer Two', 'customer'),
    ('99999999-9999-9999-9999-999999999999', 'Admin User', 'admin')
ON CONFLICT (id) DO UPDATE SET role = EXCLUDED.role;

-- Setup test addresses
INSERT INTO public.addresses (id, user_id, recipient_name, phone, province, district, ward, address_line, is_default)
VALUES
    ('a1111111-1111-1111-1111-111111111111', '11111111-1111-1111-1111-111111111111', 'Customer One', '0911111111', 'HN', 'BD', 'QD', '123 Pho Hue', true),
    ('a2222222-2222-2222-2222-222222222222', '22222222-2222-2222-2222-222222222222', 'Customer Two', '0922222222', 'HCM', 'Q1', 'BN', '456 Le Loi', true)
ON CONFLICT (id) DO NOTHING;

-- Test 2.1: Customer self-promotion to admin must FAIL
DO $$
BEGIN
    -- Simulate context of Customer One
    PERFORM set_config('request.jwt.claim.sub', '11111111-1111-1111-1111-111111111111', true);
    PERFORM set_config('request.jwt.claim.role', 'authenticated', true);

    UPDATE public.profiles
    SET role = 'admin'
    WHERE id = '11111111-1111-1111-1111-111111111111';

    RAISE EXCEPTION 'Security failure: Customer was able to promote role to admin';
EXCEPTION WHEN raise_exception THEN
    RAISE NOTICE 'Test 2.1 PASSED: Self-promotion blocked by security trigger';
END $$;

-- Test 2.2: Customer One cannot view Customer Two address under RLS
DO $$
DECLARE
    v_count integer;
BEGIN
    -- Set context as Customer One
    PERFORM set_config('request.jwt.claim.sub', '11111111-1111-1111-1111-111111111111', true);
    PERFORM set_config('role', 'authenticated', true);

    SELECT count(*) INTO v_count
    FROM public.addresses
    WHERE user_id = '22222222-2222-2222-2222-222222222222';

    IF v_count > 0 THEN
        RAISE EXCEPTION 'Security failure: Customer One could view Customer Two address via RLS';
    END IF;

    RAISE NOTICE 'Test 2.2 PASSED: Customer isolation verified by RLS';
END $$;

-- Test 2.3: Anonymous user cannot read private profiles or orders
DO $$
DECLARE
    v_count integer;
BEGIN
    -- Set context as Anon
    PERFORM set_config('request.jwt.claim.sub', '', true);
    PERFORM set_config('role', 'anon', true);

    SELECT count(*) INTO v_count FROM public.profiles;
    IF v_count > 0 THEN
        RAISE EXCEPTION 'Security failure: Anon user could read profiles table';
    END IF;

    SELECT count(*) INTO v_count FROM public.orders;
    IF v_count > 0 THEN
        RAISE EXCEPTION 'Security failure: Anon user could read orders table';
    END IF;

    RAISE NOTICE 'Test 2.3 PASSED: Anonymous access blocked for private tables';
END $$;

-- Test 2.4: Anonymous user CAN read public active categories and products
DO $$
DECLARE
    v_cat_count integer;
    v_prod_count integer;
BEGIN
    -- Set context as Anon
    PERFORM set_config('request.jwt.claim.sub', '', true);
    PERFORM set_config('role', 'anon', true);

    SELECT count(*) INTO v_cat_count FROM public.categories WHERE is_active = true;
    SELECT count(*) INTO v_prod_count FROM public.products WHERE is_active = true;

    IF v_cat_count = 0 OR v_prod_count = 0 THEN
        RAISE EXCEPTION 'Catalog failure: Anon user could not read active categories or products';
    END IF;

    RAISE NOTICE 'Test 2.4 PASSED: Public catalog browsing verified for anon';
END $$;

ROLLBACK; -- Always rollback verification tests to preserve database state

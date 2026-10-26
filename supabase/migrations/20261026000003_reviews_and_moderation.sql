-- MOVEN Phase 7 Migration 03: Product Reviews, Eligibility RPCs, and Moderation
-- Spec References: ADR-0004, GLOSSARY.md, BUSINESS_FLOWS.md, DATABASE_SPEC.md, SECURITY_SPEC.md

-- 1. Create reviews table if not exists
CREATE TABLE IF NOT EXISTS public.reviews (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID NOT NULL REFERENCES public.products(id) ON DELETE RESTRICT,
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    order_item_id UUID REFERENCES public.order_items(id) ON DELETE SET NULL,
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment VARCHAR(1000),
    is_hidden BOOLEAN NOT NULL DEFAULT false,
    hidden_reason TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    CONSTRAINT uq_reviews_user_product UNIQUE (user_id, product_id)
);

-- 2. Create review_reports table if not exists
CREATE TABLE IF NOT EXISTS public.review_reports (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    review_id UUID NOT NULL REFERENCES public.reviews(id) ON DELETE CASCADE,
    reporter_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    reason TEXT NOT NULL CHECK (reason IN ('spam', 'inappropriate', 'fake', 'other')),
    details TEXT,
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'reviewed', 'dismissed')),
    resolved_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    resolution_note TEXT,
    resolved_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    CONSTRAINT uq_review_reports_reporter_review UNIQUE (reporter_id, review_id)
);

-- 3. Indexes
CREATE INDEX IF NOT EXISTS idx_reviews_product_visible 
ON public.reviews(product_id, created_at DESC) 
WHERE is_hidden = false;

CREATE INDEX IF NOT EXISTS idx_reviews_user 
ON public.reviews(user_id);

CREATE INDEX IF NOT EXISTS idx_review_reports_status 
ON public.review_reports(status, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_review_reports_review 
ON public.review_reports(review_id);

-- 4. Row-Level Security (RLS)
ALTER TABLE public.reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.review_reports ENABLE ROW LEVEL SECURITY;

-- Reviews RLS Policies
DROP POLICY IF EXISTS "Public can view visible reviews" ON public.reviews;
CREATE POLICY "Public can view visible reviews" ON public.reviews
FOR SELECT USING (is_hidden = false);

DROP POLICY IF EXISTS "Admin can view all reviews" ON public.reviews;
CREATE POLICY "Admin can view all reviews" ON public.reviews
FOR SELECT TO authenticated
USING (public.is_admin());

DROP POLICY IF EXISTS "Users can view their own reviews" ON public.reviews;
CREATE POLICY "Users can view their own reviews" ON public.reviews
FOR SELECT TO authenticated
USING (user_id = auth.uid());

-- Review Reports RLS Policies
DROP POLICY IF EXISTS "Admin can view all review reports" ON public.review_reports;
CREATE POLICY "Admin can view all review reports" ON public.review_reports
FOR SELECT TO authenticated
USING (public.is_admin());

DROP POLICY IF EXISTS "Users can view their own reports" ON public.review_reports;
CREATE POLICY "Users can view their own reports" ON public.review_reports
FOR SELECT TO authenticated
USING (reporter_id = auth.uid());

-- 5. RPC: check_review_eligibility
-- Verifies if the authenticated user has a delivered order for this product
-- and whether they have already submitted a review.
CREATE OR REPLACE FUNCTION public.check_review_eligibility(p_product_id UUID)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_user_id UUID;
    v_has_reviewed BOOLEAN := false;
    v_existing_review RECORD;
    v_order_item RECORD;
BEGIN
    v_user_id := auth.uid();
    IF v_user_id IS NULL THEN
        RETURN jsonb_build_object(
            'is_authenticated', false,
            'is_eligible', false,
            'has_reviewed', false,
            'reason', 'UNAUTHENTICATED',
            'message', 'Vui lòng đăng nhập để đánh giá sản phẩm.'
        );
    END IF;

    -- Check if user already reviewed
    SELECT id, rating, comment, created_at, is_hidden INTO v_existing_review
    FROM public.reviews
    WHERE user_id = v_user_id AND product_id = p_product_id;

    IF FOUND THEN
        RETURN jsonb_build_object(
            'is_authenticated', true,
            'is_eligible', false,
            'has_reviewed', true,
            'reason', 'ALREADY_REVIEWED',
            'message', 'Bạn đã đánh giá sản phẩm này rồi.',
            'existing_review', jsonb_build_object(
                'id', v_existing_review.id,
                'rating', v_existing_review.rating,
                'comment', v_existing_review.comment,
                'created_at', v_existing_review.created_at,
                'is_hidden', v_existing_review.is_hidden
            )
        );
    END IF;

    -- Check if user has a delivered order containing this product
    SELECT oi.id AS order_item_id, oi.product_name_snapshot, oi.size_snapshot, oi.color_snapshot, o.order_code
    INTO v_order_item
    FROM public.order_items oi
    JOIN public.orders o ON o.id = oi.order_id
    JOIN public.product_variants pv ON pv.id = oi.variant_id
    WHERE o.user_id = v_user_id
      AND pv.product_id = p_product_id
      AND o.status = 'delivered'
    ORDER BY o.delivered_at DESC NULLS LAST, o.created_at DESC
    LIMIT 1;

    IF NOT FOUND THEN
        RETURN jsonb_build_object(
            'is_authenticated', true,
            'is_eligible', false,
            'has_reviewed', false,
            'reason', 'NOT_PURCHASED_OR_DELIVERED',
            'message', 'Chỉ khách hàng đã mua và nhận hàng thành công mới có thể đánh giá sản phẩm này.'
        );
    END IF;

    RETURN jsonb_build_object(
        'is_authenticated', true,
        'is_eligible', true,
        'has_reviewed', false,
        'reason', 'ELIGIBLE',
        'message', 'Bạn đủ điều kiện đánh giá sản phẩm này.',
        'order_item_id', v_order_item.order_item_id,
        'order_code', v_order_item.order_code,
        'size_snapshot', v_order_item.size_snapshot,
        'color_snapshot', v_order_item.color_snapshot
    );
END;
$$;

-- 6. RPC: submit_product_review
-- Submits a customer review with strict validation and proof of delivered order
CREATE OR REPLACE FUNCTION public.submit_product_review(
    p_product_id UUID,
    p_rating INTEGER,
    p_comment TEXT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_user_id UUID;
    v_order_item RECORD;
    v_trimmed_comment TEXT;
    v_review_id UUID;
BEGIN
    -- 1. Check authentication
    v_user_id := auth.uid();
    IF v_user_id IS NULL THEN
        RAISE EXCEPTION 'Unauthenticated: Bạn cần đăng nhập để đánh giá sản phẩm.'
            USING ERRCODE = 'P0001';
    END IF;

    -- 2. Validate rating
    IF p_rating IS NULL OR p_rating < 1 OR p_rating > 5 THEN
        RAISE EXCEPTION 'Validation error: Điểm đánh giá phải từ 1 đến 5 sao.'
            USING ERRCODE = 'P0002';
    END IF;

    -- 3. Validate comment
    v_trimmed_comment := TRIM(COALESCE(p_comment, ''));
    IF LENGTH(v_trimmed_comment) > 1000 THEN
        RAISE EXCEPTION 'Validation error: Nội dung đánh giá không được vượt quá 1.000 ký tự.'
            USING ERRCODE = 'P0002';
    END IF;
    IF v_trimmed_comment = '' THEN
        v_trimmed_comment := NULL;
    END IF;

    -- 4. Check for existing review (D-13: 1 review/user/product)
    IF EXISTS (
        SELECT 1 FROM public.reviews 
        WHERE user_id = v_user_id AND product_id = p_product_id
    ) THEN
        RAISE EXCEPTION 'Conflict: Bạn đã đánh giá sản phẩm này rồi.'
            USING ERRCODE = 'P0004';
    END IF;

    -- 5. Find qualifying delivered order item
    SELECT oi.id AS order_item_id
    INTO v_order_item
    FROM public.order_items oi
    JOIN public.orders o ON o.id = oi.order_id
    JOIN public.product_variants pv ON pv.id = oi.variant_id
    WHERE o.user_id = v_user_id
      AND pv.product_id = p_product_id
      AND o.status = 'delivered'
    ORDER BY o.delivered_at DESC NULLS LAST, o.created_at DESC
    LIMIT 1;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Permission denied: Bạn chỉ có thể đánh giá sản phẩm khi đã có đơn hàng giao thành công.'
            USING ERRCODE = 'P0001';
    END IF;

    -- 6. Insert review
    INSERT INTO public.reviews (
        product_id,
        user_id,
        order_item_id,
        rating,
        comment,
        is_hidden
    ) VALUES (
        p_product_id,
        v_user_id,
        v_order_item.order_item_id,
        p_rating,
        v_trimmed_comment,
        false
    )
    RETURNING id INTO v_review_id;

    RETURN jsonb_build_object(
        'success', true,
        'review_id', v_review_id,
        'product_id', p_product_id,
        'rating', p_rating,
        'comment', v_trimmed_comment,
        'message', 'Đánh giá của bạn đã được gửi thành công!'
    );
END;
$$;

-- 7. RPC: report_product_review
-- Submits an abuse report for a review. Anti-spam: max 1 report per user per review.
-- Reports NEVER auto-hide the review.
CREATE OR REPLACE FUNCTION public.report_product_review(
    p_review_id UUID,
    p_reason TEXT,
    p_details TEXT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_reporter_id UUID;
    v_review RECORD;
    v_report_id UUID;
    v_trimmed_reason TEXT;
    v_trimmed_details TEXT;
BEGIN
    -- 1. Check authentication
    v_reporter_id := auth.uid();
    IF v_reporter_id IS NULL THEN
        RAISE EXCEPTION 'Unauthenticated: Bạn cần đăng nhập để báo cáo đánh giá.'
            USING ERRCODE = 'P0001';
    END IF;

    -- 2. Validate reason
    v_trimmed_reason := TRIM(COALESCE(p_reason, ''));
    IF v_trimmed_reason NOT IN ('spam', 'inappropriate', 'fake', 'other') THEN
        RAISE EXCEPTION 'Validation error: Lý do báo cáo không hợp lệ.'
            USING ERRCODE = 'P0002';
    END IF;

    v_trimmed_details := TRIM(COALESCE(p_details, ''));
    IF v_trimmed_details = '' THEN
        v_trimmed_details := NULL;
    END IF;

    -- 3. Verify review existence
    SELECT id, user_id, is_hidden INTO v_review
    FROM public.reviews
    WHERE id = p_review_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Không tìm thấy đánh giá cần báo cáo.'
            USING ERRCODE = 'P0003';
    END IF;

    -- 4. Check reporter is not author
    IF v_review.user_id = v_reporter_id THEN
        RAISE EXCEPTION 'Validation error: Bạn không thể tự báo cáo đánh giá của chính mình.'
            USING ERRCODE = 'P0002';
    END IF;

    -- 5. Check anti-spam: 1 report per reporter per review (D-12)
    IF EXISTS (
        SELECT 1 FROM public.review_reports
        WHERE reporter_id = v_reporter_id AND review_id = p_review_id
    ) THEN
        RAISE EXCEPTION 'Conflict: Bạn đã gửi báo cáo cho đánh giá này rồi. Chúng tôi đang xem xét.'
            USING ERRCODE = 'P0004';
    END IF;

    -- 6. Insert report
    INSERT INTO public.review_reports (
        review_id,
        reporter_id,
        reason,
        details,
        status
    ) VALUES (
        p_review_id,
        v_reporter_id,
        v_trimmed_reason,
        v_trimmed_details,
        'pending'
    )
    RETURNING id INTO v_report_id;

    RETURN jsonb_build_object(
        'success', true,
        'report_id', v_report_id,
        'review_id', p_review_id,
        'status', 'pending',
        'message', 'Cảm ơn bạn. Báo cáo đã được gửi tới quản trị viên để xem xét.'
    );
END;
$$;

-- 8. RPC: admin_moderate_review
-- Allows authorized admin to hide/unhide a review or resolve reports
CREATE OR REPLACE FUNCTION public.admin_moderate_review(
    p_review_id UUID,
    p_action TEXT,
    p_reason TEXT DEFAULT NULL,
    p_report_id UUID DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_admin_id UUID;
    v_review RECORD;
    v_trimmed_reason TEXT;
BEGIN
    -- 1. Check admin permission
    v_admin_id := auth.uid();
    IF v_admin_id IS NULL OR NOT public.is_admin() THEN
        RAISE EXCEPTION 'Unauthorized: Chỉ quản trị viên mới có quyền kiểm duyệt đánh giá.'
            USING ERRCODE = 'P0001';
    END IF;

    -- 2. Validate action
    IF p_action NOT IN ('hide', 'unhide', 'dismiss') THEN
        RAISE EXCEPTION 'Validation error: Hành động kiểm duyệt không hợp lệ (hide, unhide, dismiss).'
            USING ERRCODE = 'P0002';
    END IF;

    v_trimmed_reason := TRIM(COALESCE(p_reason, ''));
    IF v_trimmed_reason = '' THEN
        v_trimmed_reason := NULL;
    END IF;

    -- 3. Verify review
    SELECT * INTO v_review
    FROM public.reviews
    WHERE id = p_review_id
    FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Không tìm thấy đánh giá với ID %.', p_review_id
            USING ERRCODE = 'P0003';
    END IF;

    -- 4. Execute moderation action
    IF p_action = 'hide' THEN
        IF v_trimmed_reason IS NULL THEN
            RAISE EXCEPTION 'Validation error: Vui lòng nhập lý do ẩn đánh giá.'
                USING ERRCODE = 'P0002';
        END IF;

        UPDATE public.reviews
        SET is_hidden = true,
            hidden_reason = v_trimmed_reason,
            updated_at = timezone('utc'::text, now())
        WHERE id = p_review_id;

        -- Resolve related reports
        UPDATE public.review_reports
        SET status = 'reviewed',
            resolved_by = v_admin_id,
            resolution_note = v_trimmed_reason,
            resolved_at = timezone('utc'::text, now())
        WHERE review_id = p_review_id AND status = 'pending';

    ELSIF p_action = 'unhide' THEN
        UPDATE public.reviews
        SET is_hidden = false,
            hidden_reason = NULL,
            updated_at = timezone('utc'::text, now())
        WHERE id = p_review_id;

    ELSIF p_action = 'dismiss' THEN
        -- Dismiss report without hiding review
        IF p_report_id IS NOT NULL THEN
            UPDATE public.review_reports
            SET status = 'dismissed',
                resolved_by = v_admin_id,
                resolution_note = COALESCE(v_trimmed_reason, 'Báo cáo không có căn cứ'),
                resolved_at = timezone('utc'::text, now())
            WHERE id = p_report_id;
        ELSE
            UPDATE public.review_reports
            SET status = 'dismissed',
                resolved_by = v_admin_id,
                resolution_note = COALESCE(v_trimmed_reason, 'Báo cáo không có căn cứ'),
                resolved_at = timezone('utc'::text, now())
            WHERE review_id = p_review_id AND status = 'pending';
        END IF;
    END IF;

    RETURN jsonb_build_object(
        'success', true,
        'review_id', p_review_id,
        'action', p_action,
        'is_hidden', CASE WHEN p_action = 'hide' THEN true WHEN p_action = 'unhide' THEN false ELSE v_review.is_hidden END,
        'message', 'Đã xử lý kiểm duyệt đánh giá thành công.'
    );
END;
$$;

-- 9. RPC: get_product_rating_summary
-- Calculates rating statistics strictly over visible (is_hidden = false) reviews
CREATE OR REPLACE FUNCTION public.get_product_rating_summary(p_product_id UUID)
RETURNS JSONB
LANGUAGE sql
STABLE
SET search_path = public, pg_temp
AS $$
    WITH stats AS (
        SELECT 
            COUNT(*)::INT AS total_reviews,
            COALESCE(ROUND(AVG(rating)::NUMERIC, 1), 0.0)::FLOAT AS average_rating,
            COUNT(*) FILTER (WHERE rating = 5)::INT AS count_5,
            COUNT(*) FILTER (WHERE rating = 4)::INT AS count_4,
            COUNT(*) FILTER (WHERE rating = 3)::INT AS count_3,
            COUNT(*) FILTER (WHERE rating = 2)::INT AS count_2,
            COUNT(*) FILTER (WHERE rating = 1)::INT AS count_1
        FROM public.reviews
        WHERE product_id = p_product_id AND is_hidden = false
    )
    SELECT jsonb_build_object(
        'product_id', p_product_id,
        'total_reviews', total_reviews,
        'average_rating', average_rating,
        'counts', jsonb_build_object(
            '5', count_5,
            '4', count_4,
            '3', count_3,
            '2', count_2,
            '1', count_1
        )
    )
    FROM stats;
$$;

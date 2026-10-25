-- MOVEN Phase 2 Migration 03: Storage Buckets and Storage Security Policies
-- Spec Reference: SECURITY_SPEC.md 5.7

-- 1. Create Storage Buckets with constraints
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES
    ('product-media', 'product-media', true, 5242880, ARRAY['image/jpeg', 'image/png', 'image/webp']),
    ('banners', 'banners', true, 5242880, ARRAY['image/jpeg', 'image/png', 'image/webp']),
    ('avatars', 'avatars', true, 2097152, ARRAY['image/jpeg', 'image/png', 'image/webp'])
ON CONFLICT (id) DO UPDATE SET
    public = EXCLUDED.public,
    file_size_limit = EXCLUDED.file_size_limit,
    allowed_mime_types = EXCLUDED.allowed_mime_types;

-- 2. Storage Policies on storage.objects

-- A. PRODUCT-MEDIA
CREATE POLICY product_media_public_select ON storage.objects
    FOR SELECT USING (bucket_id = 'product-media');

CREATE POLICY product_media_admin_insert ON storage.objects
    FOR INSERT WITH CHECK (bucket_id = 'product-media' AND public.is_admin());

CREATE POLICY product_media_admin_update ON storage.objects
    FOR UPDATE USING (bucket_id = 'product-media' AND public.is_admin())
    WITH CHECK (bucket_id = 'product-media' AND public.is_admin());

CREATE POLICY product_media_admin_delete ON storage.objects
    FOR DELETE USING (bucket_id = 'product-media' AND public.is_admin());

-- B. BANNERS
CREATE POLICY banners_public_select ON storage.objects
    FOR SELECT USING (bucket_id = 'banners');

CREATE POLICY banners_admin_insert ON storage.objects
    FOR INSERT WITH CHECK (bucket_id = 'banners' AND public.is_admin());

CREATE POLICY banners_admin_update ON storage.objects
    FOR UPDATE USING (bucket_id = 'banners' AND public.is_admin())
    WITH CHECK (bucket_id = 'banners' AND public.is_admin());

CREATE POLICY banners_admin_delete ON storage.objects
    FOR DELETE USING (bucket_id = 'banners' AND public.is_admin());

-- C. AVATARS (Scoped to user folder: avatars/{user_id}/*)
CREATE POLICY avatars_public_select ON storage.objects
    FOR SELECT USING (bucket_id = 'avatars');

CREATE POLICY avatars_user_insert ON storage.objects
    FOR INSERT WITH CHECK (
        bucket_id = 'avatars'
        AND auth.uid()::text = (storage.foldername(name))[1]
    );

CREATE POLICY avatars_user_update ON storage.objects
    FOR UPDATE USING (
        bucket_id = 'avatars'
        AND auth.uid()::text = (storage.foldername(name))[1]
    )
    WITH CHECK (
        bucket_id = 'avatars'
        AND auth.uid()::text = (storage.foldername(name))[1]
    );

CREATE POLICY avatars_user_delete ON storage.objects
    FOR DELETE USING (
        bucket_id = 'avatars'
        AND auth.uid()::text = (storage.foldername(name))[1]
    );

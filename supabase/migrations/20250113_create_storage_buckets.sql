-- Migration: Create Storage Buckets for Event and User Images
-- This migration sets up storage buckets for file uploads

-- ============================================
-- CREATE STORAGE BUCKETS
-- ============================================

-- Event images bucket
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'event-images',
  'event-images',
  true,
  5242880, -- 5MB limit
  ARRAY['image/jpeg', 'image/jpg', 'image/png', 'image/gif', 'image/webp']
)
ON CONFLICT (id) DO NOTHING;

-- User avatars bucket
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'avatars',
  'avatars',
  true,
  5242880, -- 5MB limit
  ARRAY['image/jpeg', 'image/jpg', 'image/png', 'image/gif', 'image/webp']
)
ON CONFLICT (id) DO NOTHING;

-- ============================================
-- STORAGE POLICIES - Event Images
-- ============================================

-- Anyone can view event images
CREATE POLICY "Event images are publicly accessible"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'event-images');

-- Authenticated users can upload event images
CREATE POLICY "Authenticated users can upload event images"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'event-images'
    AND auth.role() = 'authenticated'
  );

-- Users can update their own event images
CREATE POLICY "Users can update own event images"
  ON storage.objects FOR UPDATE
  USING (
    bucket_id = 'event-images'
    AND auth.role() = 'authenticated'
  );

-- Users can delete their own event images
CREATE POLICY "Users can delete own event images"
  ON storage.objects FOR DELETE
  USING (
    bucket_id = 'event-images'
    AND auth.role() = 'authenticated'
  );

-- ============================================
-- STORAGE POLICIES - Avatars
-- ============================================

-- Anyone can view avatars
CREATE POLICY "Avatars are publicly accessible"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'avatars');

-- Authenticated users can upload avatars
CREATE POLICY "Authenticated users can upload avatars"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'avatars'
    AND auth.role() = 'authenticated'
  );

-- Users can update their own avatars
CREATE POLICY "Users can update own avatars"
  ON storage.objects FOR UPDATE
  USING (
    bucket_id = 'avatars'
    AND auth.role() = 'authenticated'
  );

-- Users can delete their own avatars
CREATE POLICY "Users can delete own avatars"
  ON storage.objects FOR DELETE
  USING (
    bucket_id = 'avatars'
    AND auth.role() = 'authenticated'
  );

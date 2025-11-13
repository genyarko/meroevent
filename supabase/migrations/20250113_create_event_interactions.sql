-- Migration: Add Event Interaction Tables (Favorites and Shares)
-- This migration adds event_favorites and event_shares tables
-- Also adds RPC functions for event interactions

-- ============================================
-- EVENT FAVORITES TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS public.event_favorites (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  event_id uuid NOT NULL,
  user_id uuid NOT NULL,
  created_at timestamp with time zone NOT NULL DEFAULT now(),

  CONSTRAINT event_favorites_pkey PRIMARY KEY (id),
  CONSTRAINT event_favorites_event_id_fkey FOREIGN KEY (event_id) REFERENCES public.events(id) ON DELETE CASCADE,
  CONSTRAINT event_favorites_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE,
  CONSTRAINT event_favorites_unique UNIQUE (event_id, user_id)
);

CREATE INDEX IF NOT EXISTS idx_event_favorites_event_id ON public.event_favorites(event_id);
CREATE INDEX IF NOT EXISTS idx_event_favorites_user_id ON public.event_favorites(user_id);

-- ============================================
-- EVENT SHARES TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS public.event_shares (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  event_id uuid NOT NULL,
  user_id uuid NOT NULL,
  share_platform text, -- 'facebook', 'twitter', 'whatsapp', 'link', etc.
  created_at timestamp with time zone NOT NULL DEFAULT now(),

  CONSTRAINT event_shares_pkey PRIMARY KEY (id),
  CONSTRAINT event_shares_event_id_fkey FOREIGN KEY (event_id) REFERENCES public.events(id) ON DELETE CASCADE,
  CONSTRAINT event_shares_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_event_shares_event_id ON public.event_shares(event_id);
CREATE INDEX IF NOT EXISTS idx_event_shares_user_id ON public.event_shares(user_id);

-- ============================================
-- ENABLE ROW LEVEL SECURITY
-- ============================================
ALTER TABLE public.event_favorites ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.event_shares ENABLE ROW LEVEL SECURITY;

-- ============================================
-- RLS POLICIES - Event Favorites
-- ============================================

-- Users can view all favorites
CREATE POLICY "Anyone can view event favorites"
  ON public.event_favorites FOR SELECT
  USING (true);

-- Users can add their own favorites
CREATE POLICY "Users can add own favorites"
  ON public.event_favorites FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Users can delete their own favorites
CREATE POLICY "Users can delete own favorites"
  ON public.event_favorites FOR DELETE
  USING (auth.uid() = user_id);

-- ============================================
-- RLS POLICIES - Event Shares
-- ============================================

-- Anyone can view shares (for analytics)
CREATE POLICY "Anyone can view event shares"
  ON public.event_shares FOR SELECT
  USING (true);

-- Authenticated users can record shares
CREATE POLICY "Authenticated users can record shares"
  ON public.event_shares FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- ============================================
-- RPC FUNCTIONS FOR EVENT INTERACTIONS
-- ============================================

-- Function to toggle like on an event
CREATE OR REPLACE FUNCTION toggle_event_like(event_id_param uuid, user_id_param uuid)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  like_exists boolean;
  new_likes_count integer;
BEGIN
  -- Check if like already exists
  SELECT EXISTS(
    SELECT 1 FROM public.event_likes
    WHERE event_id = event_id_param AND user_id = user_id_param
  ) INTO like_exists;

  IF like_exists THEN
    -- Unlike: Remove the like
    DELETE FROM public.event_likes
    WHERE event_id = event_id_param AND user_id = user_id_param;
  ELSE
    -- Like: Add the like
    INSERT INTO public.event_likes (event_id, user_id)
    VALUES (event_id_param, user_id_param);
  END IF;

  -- Get updated count
  SELECT COUNT(*) INTO new_likes_count
  FROM public.event_likes
  WHERE event_id = event_id_param;

  -- Update events table likes_count
  UPDATE public.events
  SET likes_count = new_likes_count
  WHERE id = event_id_param;

  -- Return result
  RETURN jsonb_build_object(
    'is_liked', NOT like_exists,
    'likes_count', new_likes_count
  );
END;
$$;

-- Function to toggle favorite on an event
CREATE OR REPLACE FUNCTION toggle_event_favorite(event_id_param uuid, user_id_param uuid)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  favorite_exists boolean;
BEGIN
  -- Check if favorite already exists
  SELECT EXISTS(
    SELECT 1 FROM public.event_favorites
    WHERE event_id = event_id_param AND user_id = user_id_param
  ) INTO favorite_exists;

  IF favorite_exists THEN
    -- Unfavorite: Remove the favorite
    DELETE FROM public.event_favorites
    WHERE event_id = event_id_param AND user_id = user_id_param;
  ELSE
    -- Favorite: Add the favorite
    INSERT INTO public.event_favorites (event_id, user_id)
    VALUES (event_id_param, user_id_param);
  END IF;

  -- Return result
  RETURN jsonb_build_object(
    'is_favorited', NOT favorite_exists
  );
END;
$$;

-- Function to increment share count
CREATE OR REPLACE FUNCTION increment_share_count(event_id_param uuid)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  UPDATE public.events
  SET shares_count = shares_count + 1
  WHERE id = event_id_param;
END;
$$;

-- Function to record a share with platform tracking
CREATE OR REPLACE FUNCTION record_event_share(
  event_id_param uuid,
  user_id_param uuid,
  platform_param text DEFAULT 'link'
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- Insert share record
  INSERT INTO public.event_shares (event_id, user_id, share_platform)
  VALUES (event_id_param, user_id_param, platform_param);

  -- Increment share count
  UPDATE public.events
  SET shares_count = shares_count + 1
  WHERE id = event_id_param;
END;
$$;

-- Function to increment view count (if not already exists)
CREATE OR REPLACE FUNCTION increment_view_count(event_id_param uuid)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  UPDATE public.events
  SET views_count = views_count + 1
  WHERE id = event_id_param;
END;
$$;

-- Function to check if user has liked an event
CREATE OR REPLACE FUNCTION check_event_like(event_id_param uuid, user_id_param uuid)
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN EXISTS(
    SELECT 1 FROM public.event_likes
    WHERE event_id = event_id_param AND user_id = user_id_param
  );
END;
$$;

-- Function to check if user has favorited an event
CREATE OR REPLACE FUNCTION check_event_favorite(event_id_param uuid, user_id_param uuid)
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN EXISTS(
    SELECT 1 FROM public.event_favorites
    WHERE event_id = event_id_param AND user_id = user_id_param
  );
END;
$$;

-- Function to get user's favorite events
CREATE OR REPLACE FUNCTION get_user_favorite_events(user_id_param uuid, result_limit int DEFAULT 20)
RETURNS SETOF public.events
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  SELECT e.*
  FROM public.events e
  INNER JOIN public.event_favorites ef ON e.id = ef.event_id
  WHERE ef.user_id = user_id_param
  ORDER BY ef.created_at DESC
  LIMIT result_limit;
END;
$$;

-- Function to update event attendee status
CREATE OR REPLACE FUNCTION update_event_attendee_status(
  event_id_param uuid,
  user_id_param uuid,
  new_status text
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  status_exists boolean;
  old_status text;
BEGIN
  -- Check if attendee record exists
  SELECT EXISTS(
    SELECT 1 FROM public.event_attendees
    WHERE event_id = event_id_param AND user_id = user_id_param
  ), status INTO status_exists, old_status
  FROM public.event_attendees
  WHERE event_id = event_id_param AND user_id = user_id_param;

  IF status_exists THEN
    -- Update existing status
    UPDATE public.event_attendees
    SET status = new_status, updated_at = now()
    WHERE event_id = event_id_param AND user_id = user_id_param;
  ELSE
    -- Insert new status
    INSERT INTO public.event_attendees (event_id, user_id, status)
    VALUES (event_id_param, user_id_param, new_status);
  END IF;
END;
$$;

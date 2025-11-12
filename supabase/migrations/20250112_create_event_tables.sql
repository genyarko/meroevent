-- Migration: Add Event Management Tables
-- This migration adds all event-related tables to the existing database
-- The existing profiles table will be used for user management

-- ============================================
-- EVENTS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS public.events (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  title text NOT NULL,
  description text,
  short_description text,
  category text,
  tags text[],

  -- Organizer info
  organizer_id uuid NOT NULL,
  organizer_name text,
  organizer_email text,
  organizer_phone text,

  -- Location
  location text,
  venue text,
  venue_id uuid,
  address text,
  city text,
  state text,
  country text,
  postal_code text,
  latitude double precision,
  longitude double precision,

  -- Date and time
  start_datetime timestamp with time zone NOT NULL,
  end_datetime timestamp with time zone NOT NULL,
  timezone text,

  -- Media
  image_url text,
  cover_image_url text,
  video_url text,
  gallery_images text[],

  -- Ticketing
  is_free boolean DEFAULT false,
  min_price numeric(10, 2),
  max_price numeric(10, 2),
  currency text DEFAULT 'USD',

  -- Capacity
  capacity integer,
  remaining_capacity integer,
  is_sold_out boolean DEFAULT false,

  -- Status
  status text NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'published', 'cancelled', 'completed')),
  is_published boolean DEFAULT false,
  is_featured boolean DEFAULT false,
  is_private boolean DEFAULT false,

  -- Additional info
  age_restriction text,
  dress_code text,
  refund_policy text,
  terms_and_conditions text,
  external_url text,

  -- Social engagement
  views_count integer DEFAULT 0,
  likes_count integer DEFAULT 0,
  shares_count integer DEFAULT 0,
  attendees_count integer DEFAULT 0,
  interested_count integer DEFAULT 0,

  -- Metadata
  metadata jsonb DEFAULT '{}'::jsonb,
  settings jsonb DEFAULT '{}'::jsonb,

  -- Timestamps
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  published_at timestamp with time zone,

  CONSTRAINT events_pkey PRIMARY KEY (id),
  CONSTRAINT events_organizer_id_fkey FOREIGN KEY (organizer_id) REFERENCES auth.users(id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_events_organizer_id ON public.events(organizer_id);
CREATE INDEX IF NOT EXISTS idx_events_start_datetime ON public.events(start_datetime);
CREATE INDEX IF NOT EXISTS idx_events_status ON public.events(status);
CREATE INDEX IF NOT EXISTS idx_events_category ON public.events(category);
CREATE INDEX IF NOT EXISTS idx_events_location ON public.events(latitude, longitude);

-- ============================================
-- VENUES TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS public.venues (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name text NOT NULL,
  description text,
  venue_type text,

  -- Location
  address text,
  city text,
  state text,
  country text,
  postal_code text,
  latitude double precision,
  longitude double precision,

  -- Contact
  phone text,
  email text,
  website text,

  -- Capacity and features
  capacity integer,
  amenities text[],
  accessibility_features text[],
  parking_info text,
  public_transport_info text,

  -- Media
  image_url text,
  images text[],
  seating_chart_url text,

  -- Metadata
  metadata jsonb DEFAULT '{}'::jsonb,

  -- Timestamps
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),

  CONSTRAINT venues_pkey PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_venues_location ON public.venues(latitude, longitude);

-- Add venue foreign key to events
ALTER TABLE public.events
  ADD CONSTRAINT events_venue_id_fkey
  FOREIGN KEY (venue_id) REFERENCES public.venues(id) ON DELETE SET NULL;

-- ============================================
-- TICKET TYPES TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS public.ticket_types (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  event_id uuid NOT NULL,
  name text NOT NULL,
  description text,

  -- Pricing
  price numeric(10, 2) NOT NULL DEFAULT 0,
  currency text NOT NULL DEFAULT 'USD',

  -- Inventory
  total_quantity integer NOT NULL,
  quantity_sold integer NOT NULL DEFAULT 0,
  quantity_available integer,
  min_per_order integer DEFAULT 1,
  max_per_order integer DEFAULT 10,

  -- Sale period
  sale_starts_at timestamp with time zone,
  sale_ends_at timestamp with time zone,

  -- Status
  is_active boolean DEFAULT true,
  is_visible boolean DEFAULT true,

  -- Additional info
  includes text[],
  terms text,

  -- Metadata
  metadata jsonb DEFAULT '{}'::jsonb,

  -- Timestamps
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),

  CONSTRAINT ticket_types_pkey PRIMARY KEY (id),
  CONSTRAINT ticket_types_event_id_fkey FOREIGN KEY (event_id) REFERENCES public.events(id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_ticket_types_event_id ON public.ticket_types(event_id);

-- ============================================
-- TICKET ORDERS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS public.ticket_orders (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  event_id uuid NOT NULL,
  ticket_type_id uuid NOT NULL,
  buyer_id uuid NOT NULL,

  -- Buyer info
  buyer_email text NOT NULL,
  buyer_name text,
  buyer_phone text,

  -- Order details
  quantity integer NOT NULL,
  unit_price numeric(10, 2) NOT NULL,
  subtotal numeric(10, 2) NOT NULL,
  discount numeric(10, 2) DEFAULT 0,
  tax_amount numeric(10, 2) DEFAULT 0,
  service_fee numeric(10, 2) DEFAULT 0,
  total_amount numeric(10, 2) NOT NULL,
  currency text NOT NULL DEFAULT 'USD',

  -- Payment info
  status text NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'processing', 'completed', 'failed', 'cancelled', 'refunded', 'refund_requested')),
  payment_intent_id text,
  payment_method text,
  paid_at timestamp with time zone,

  -- Promo
  promo_code text,
  karma_points_used integer DEFAULT 0,

  -- Metadata
  metadata jsonb DEFAULT '{}'::jsonb,

  -- Timestamps
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),

  CONSTRAINT ticket_orders_pkey PRIMARY KEY (id),
  CONSTRAINT ticket_orders_event_id_fkey FOREIGN KEY (event_id) REFERENCES public.events(id) ON DELETE CASCADE,
  CONSTRAINT ticket_orders_ticket_type_id_fkey FOREIGN KEY (ticket_type_id) REFERENCES public.ticket_types(id) ON DELETE CASCADE,
  CONSTRAINT ticket_orders_buyer_id_fkey FOREIGN KEY (buyer_id) REFERENCES auth.users(id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_ticket_orders_buyer_id ON public.ticket_orders(buyer_id);
CREATE INDEX IF NOT EXISTS idx_ticket_orders_event_id ON public.ticket_orders(event_id);
CREATE INDEX IF NOT EXISTS idx_ticket_orders_status ON public.ticket_orders(status);

-- ============================================
-- TICKETS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS public.tickets (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  order_id uuid NOT NULL,
  event_id uuid NOT NULL,
  ticket_type_id uuid NOT NULL,

  -- Assignment
  assigned_to_id uuid,
  assigned_to_email text,
  assigned_to_name text,

  -- Ticket details
  ticket_number text NOT NULL UNIQUE,
  qr_code text NOT NULL UNIQUE,
  barcode text,
  seat_number text,
  section text,
  row_number text,

  -- Status
  status text NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'used', 'cancelled', 'transferred', 'refunded')),
  is_checked_in boolean DEFAULT false,
  checked_in_at timestamp with time zone,
  checked_in_by uuid,
  check_in_location text,

  -- Transfer
  transferred_from_id uuid,
  transferred_to_id uuid,
  transferred_at timestamp with time zone,

  -- Metadata
  metadata jsonb DEFAULT '{}'::jsonb,

  -- Timestamps
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),

  CONSTRAINT tickets_pkey PRIMARY KEY (id),
  CONSTRAINT tickets_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.ticket_orders(id) ON DELETE CASCADE,
  CONSTRAINT tickets_event_id_fkey FOREIGN KEY (event_id) REFERENCES public.events(id) ON DELETE CASCADE,
  CONSTRAINT tickets_ticket_type_id_fkey FOREIGN KEY (ticket_type_id) REFERENCES public.ticket_types(id) ON DELETE CASCADE,
  CONSTRAINT tickets_assigned_to_id_fkey FOREIGN KEY (assigned_to_id) REFERENCES auth.users(id) ON DELETE SET NULL,
  CONSTRAINT tickets_checked_in_by_fkey FOREIGN KEY (checked_in_by) REFERENCES auth.users(id) ON DELETE SET NULL
);

CREATE INDEX IF NOT EXISTS idx_tickets_order_id ON public.tickets(order_id);
CREATE INDEX IF NOT EXISTS idx_tickets_event_id ON public.tickets(event_id);
CREATE INDEX IF NOT EXISTS idx_tickets_assigned_to_id ON public.tickets(assigned_to_id);
CREATE INDEX IF NOT EXISTS idx_tickets_qr_code ON public.tickets(qr_code);

-- ============================================
-- ORGANIZER PROFILES TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS public.organizer_profiles (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,

  -- Organization info
  organization_name text NOT NULL,
  organization_type text,
  description text,

  -- Contact
  email text,
  phone text,
  website text,

  -- Address
  address text,
  city text,
  state text,
  country text,
  postal_code text,

  -- Verification
  is_verified boolean DEFAULT false,
  verification_status text DEFAULT 'pending' CHECK (verification_status IN ('pending', 'verified', 'rejected')),
  verified_at timestamp with time zone,

  -- Social
  social_links jsonb DEFAULT '{}'::jsonb,

  -- Stats
  total_events_created integer DEFAULT 0,
  total_tickets_sold integer DEFAULT 0,
  total_revenue numeric(10, 2) DEFAULT 0,
  average_rating numeric(3, 2),

  -- Stripe
  stripe_account_id text,
  stripe_account_status text,

  -- Media
  logo_url text,
  banner_url text,

  -- Metadata
  metadata jsonb DEFAULT '{}'::jsonb,

  -- Timestamps
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),

  CONSTRAINT organizer_profiles_pkey PRIMARY KEY (id),
  CONSTRAINT organizer_profiles_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE,
  CONSTRAINT organizer_profiles_user_id_unique UNIQUE (user_id)
);

CREATE INDEX IF NOT EXISTS idx_organizer_profiles_user_id ON public.organizer_profiles(user_id);

-- ============================================
-- EVENT ATTENDEES TABLE (for tracking interest)
-- ============================================
CREATE TABLE IF NOT EXISTS public.event_attendees (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  event_id uuid NOT NULL,
  user_id uuid NOT NULL,
  status text NOT NULL CHECK (status IN ('interested', 'going', 'attended', 'cancelled')),

  -- Timestamps
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),

  CONSTRAINT event_attendees_pkey PRIMARY KEY (id),
  CONSTRAINT event_attendees_event_id_fkey FOREIGN KEY (event_id) REFERENCES public.events(id) ON DELETE CASCADE,
  CONSTRAINT event_attendees_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE,
  CONSTRAINT event_attendees_unique UNIQUE (event_id, user_id)
);

CREATE INDEX IF NOT EXISTS idx_event_attendees_event_id ON public.event_attendees(event_id);
CREATE INDEX IF NOT EXISTS idx_event_attendees_user_id ON public.event_attendees(user_id);

-- ============================================
-- EVENT LIKES TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS public.event_likes (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  event_id uuid NOT NULL,
  user_id uuid NOT NULL,

  -- Timestamps
  created_at timestamp with time zone NOT NULL DEFAULT now(),

  CONSTRAINT event_likes_pkey PRIMARY KEY (id),
  CONSTRAINT event_likes_event_id_fkey FOREIGN KEY (event_id) REFERENCES public.events(id) ON DELETE CASCADE,
  CONSTRAINT event_likes_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE,
  CONSTRAINT event_likes_unique UNIQUE (event_id, user_id)
);

CREATE INDEX IF NOT EXISTS idx_event_likes_event_id ON public.event_likes(event_id);
CREATE INDEX IF NOT EXISTS idx_event_likes_user_id ON public.event_likes(user_id);

-- ============================================
-- ENABLE ROW LEVEL SECURITY
-- ============================================
ALTER TABLE public.events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.venues ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ticket_types ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ticket_orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tickets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.organizer_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.event_attendees ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.event_likes ENABLE ROW LEVEL SECURITY;

-- ============================================
-- RLS POLICIES - Events (Public Read, Organizer Write)
-- ============================================

-- Anyone can view published events
CREATE POLICY "Events are viewable by everyone"
  ON public.events FOR SELECT
  USING (is_published = true OR organizer_id = auth.uid());

-- Organizers can insert their own events
CREATE POLICY "Organizers can create events"
  ON public.events FOR INSERT
  WITH CHECK (auth.uid() = organizer_id);

-- Organizers can update their own events
CREATE POLICY "Organizers can update own events"
  ON public.events FOR UPDATE
  USING (auth.uid() = organizer_id);

-- Organizers can delete their own events
CREATE POLICY "Organizers can delete own events"
  ON public.events FOR DELETE
  USING (auth.uid() = organizer_id);

-- ============================================
-- RLS POLICIES - Tickets (Users can view their own)
-- ============================================

-- Users can view their own tickets
CREATE POLICY "Users can view own tickets"
  ON public.tickets FOR SELECT
  USING (auth.uid() = assigned_to_id);

-- ============================================
-- RLS POLICIES - Orders (Users can view their own)
-- ============================================

-- Users can view their own orders
CREATE POLICY "Users can view own orders"
  ON public.ticket_orders FOR SELECT
  USING (auth.uid() = buyer_id);

-- Users can create orders
CREATE POLICY "Users can create orders"
  ON public.ticket_orders FOR INSERT
  WITH CHECK (auth.uid() = buyer_id);

-- ============================================
-- FUNCTIONS AND TRIGGERS
-- ============================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Add triggers for updated_at
CREATE TRIGGER update_events_updated_at BEFORE UPDATE ON public.events
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_venues_updated_at BEFORE UPDATE ON public.venues
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_ticket_types_updated_at BEFORE UPDATE ON public.ticket_types
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_ticket_orders_updated_at BEFORE UPDATE ON public.ticket_orders
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_tickets_updated_at BEFORE UPDATE ON public.tickets
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_organizer_profiles_updated_at BEFORE UPDATE ON public.organizer_profiles
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Function to update event stats
CREATE OR REPLACE FUNCTION update_event_stats()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_TABLE_NAME = 'event_likes' THEN
    UPDATE public.events
    SET likes_count = (SELECT COUNT(*) FROM public.event_likes WHERE event_id = NEW.event_id)
    WHERE id = NEW.event_id;
  ELSIF TG_TABLE_NAME = 'event_attendees' THEN
    UPDATE public.events
    SET
      interested_count = (SELECT COUNT(*) FROM public.event_attendees WHERE event_id = NEW.event_id AND status = 'interested'),
      attendees_count = (SELECT COUNT(*) FROM public.event_attendees WHERE event_id = NEW.event_id AND status IN ('going', 'attended'))
    WHERE id = NEW.event_id;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers for event stats
CREATE TRIGGER update_event_likes_count AFTER INSERT OR DELETE ON public.event_likes
  FOR EACH ROW EXECUTE FUNCTION update_event_stats();

CREATE TRIGGER update_event_attendees_count AFTER INSERT OR UPDATE OR DELETE ON public.event_attendees
  FOR EACH ROW EXECUTE FUNCTION update_event_stats();

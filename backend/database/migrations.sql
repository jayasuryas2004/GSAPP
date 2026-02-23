-- ============================================================================
-- GSAPP DATABASE PRODUCTION SETUP
-- ============================================================================
-- Complete database initialization with all tables, indexes, and policies
-- This consolidates both schema creation and JSON scheme enhancements
-- ============================================================================

-- ============================================================================
-- STEP 1: DROP ALL EXISTING OBJECTS (Clean slate)
-- ============================================================================
DROP POLICY IF EXISTS "schemes_public_read" ON public.schemes CASCADE;
DROP POLICY IF EXISTS "schemes_public_insert" ON public.schemes CASCADE;
DROP POLICY IF EXISTS "schemes_public_update" ON public.schemes CASCADE;
DROP POLICY IF EXISTS "saved_schemes_user_read" ON public.saved_schemes CASCADE;
DROP POLICY IF EXISTS "saved_schemes_user_insert" ON public.saved_schemes CASCADE;
DROP POLICY IF EXISTS "saved_schemes_user_delete" ON public.saved_schemes CASCADE;
DROP POLICY IF EXISTS "users_own_read" ON public.users CASCADE;
DROP POLICY IF EXISTS "users_own_update" ON public.users CASCADE;
DROP POLICY IF EXISTS "saved_schemes_own_read" ON public.saved_schemes CASCADE;
DROP POLICY IF EXISTS "saved_schemes_own_insert" ON public.saved_schemes CASCADE;
DROP POLICY IF EXISTS "saved_schemes_own_delete" ON public.saved_schemes CASCADE;
DROP POLICY IF EXISTS "analytics_public_read" ON public.scheme_analytics CASCADE;

DROP TRIGGER IF EXISTS update_schemes_updated_at ON public.schemes CASCADE;
DROP TRIGGER IF EXISTS update_analytics_updated_at ON public.scheme_analytics CASCADE;

DROP FUNCTION IF EXISTS public.update_updated_at_column() CASCADE;

DROP INDEX IF EXISTS idx_schemes_state CASCADE;
DROP INDEX IF EXISTS idx_schemes_category CASCADE;
DROP INDEX IF EXISTS idx_schemes_created CASCADE;
DROP INDEX IF EXISTS idx_schemes_is_central CASCADE;
DROP INDEX IF EXISTS idx_schemes_fts CASCADE;
DROP INDEX IF EXISTS idx_schemes_state_category CASCADE;
DROP INDEX IF EXISTS idx_schemes_source CASCADE;
DROP INDEX IF EXISTS idx_users_id CASCADE;
DROP INDEX IF EXISTS idx_users_last_active CASCADE;
DROP INDEX IF EXISTS idx_saved_schemes_user CASCADE;
DROP INDEX IF EXISTS idx_saved_schemes_scheme CASCADE;
DROP INDEX IF EXISTS idx_saved_schemes_user_scheme CASCADE;
DROP INDEX IF EXISTS idx_analytics_saves CASCADE;

DROP TABLE IF EXISTS public.scheme_analytics CASCADE;
DROP TABLE IF EXISTS public.saved_schemes CASCADE;
DROP TABLE IF EXISTS public.users CASCADE;
DROP TABLE IF EXISTS public.schemes CASCADE;

-- ============================================================================
-- STEP 2: CREATE SCHEMES TABLE (Main table with all columns)
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.schemes (
    -- Identifiers
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Basic Info (Multilingual)
    title TEXT NOT NULL,
    title_ta TEXT DEFAULT NULL,
    description TEXT DEFAULT '',
    description_ta TEXT DEFAULT NULL,
    short_description TEXT DEFAULT NULL,
    short_description_ta TEXT DEFAULT NULL,
    
    -- Application & Benefits
    apply_link TEXT NOT NULL,
    benefits TEXT DEFAULT '',
    benefits_ta TEXT DEFAULT NULL,
    
    -- Classification
    state_name TEXT NOT NULL,
    category_name TEXT NOT NULL,
    is_central BOOLEAN DEFAULT FALSE,
    source TEXT DEFAULT 'scrapy',
    
    -- Metadata
    agency TEXT DEFAULT NULL,
    badge TEXT DEFAULT NULL,
    highlight TEXT DEFAULT NULL,
    image_url TEXT DEFAULT NULL,
    source_url TEXT,
    
    -- Eligibility Criteria
    eligibility_age_min INTEGER DEFAULT NULL,
    eligibility_age_max INTEGER DEFAULT NULL,
    eligibility_income_max INTEGER DEFAULT NULL,
    eligibility_gender TEXT DEFAULT 'any',
    last_date DATE DEFAULT NULL,
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Constraints
    CONSTRAINT unique_scheme UNIQUE(title, state_name),
    CONSTRAINT state_not_empty CHECK (state_name != ''),
    CONSTRAINT category_not_empty CHECK (category_name != ''),
    CONSTRAINT central_scheme_check CHECK (
        (is_central = true AND state_name = 'Central') OR 
        (is_central = false AND state_name != 'Central')
    )
);

-- ============================================================================
-- STEP 3: CREATE SCHEMES INDEXES (For fast queries)
-- ============================================================================
CREATE INDEX idx_schemes_state ON public.schemes(state_name);
CREATE INDEX idx_schemes_category ON public.schemes(category_name);
CREATE INDEX idx_schemes_is_central ON public.schemes(is_central);
CREATE INDEX idx_schemes_source ON public.schemes(source);
CREATE INDEX idx_schemes_state_category ON public.schemes(state_name, category_name);
CREATE INDEX idx_schemes_created ON public.schemes(created_at DESC);
CREATE INDEX idx_schemes_fts ON public.schemes USING GIN(
    to_tsvector('english', title || ' ' || COALESCE(description, '') || ' ' || COALESCE(benefits, ''))
);

-- ============================================================================
-- STEP 4: CREATE USERS TABLE (UUID-based, no authentication)
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    preferred_state TEXT DEFAULT 'Central',
    preferred_language TEXT DEFAULT 'en',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_active TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    CONSTRAINT valid_state CHECK (preferred_state != '')
);

CREATE INDEX idx_users_id ON public.users(id);
CREATE INDEX idx_users_last_active ON public.users(last_active DESC);

-- ============================================================================
-- STEP 5: CREATE SAVED_SCHEMES TABLE (User wishlists)
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.saved_schemes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    scheme_id UUID NOT NULL REFERENCES public.schemes(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    CONSTRAINT unique_user_scheme UNIQUE(user_id, scheme_id)
);

CREATE INDEX idx_saved_schemes_user ON public.saved_schemes(user_id);
CREATE INDEX idx_saved_schemes_scheme ON public.saved_schemes(scheme_id);
CREATE INDEX idx_saved_schemes_user_scheme ON public.saved_schemes(user_id, created_at DESC);

-- ============================================================================
-- STEP 6: CREATE SCHEME_ANALYTICS TABLE (Popularity tracking)
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.scheme_analytics (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    scheme_id UUID NOT NULL REFERENCES public.schemes(id) ON DELETE CASCADE,
    views_count BIGINT DEFAULT 0,
    saves_count BIGINT DEFAULT 0,
    applies_count BIGINT DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    CONSTRAINT unique_scheme_analytics UNIQUE(scheme_id)
);

CREATE INDEX idx_analytics_saves ON public.scheme_analytics(saves_count DESC);

-- ============================================================================
-- STEP 7: CREATE TRIGGER FUNCTION
-- ============================================================================
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- STEP 8: CREATE TRIGGERS
-- ============================================================================
CREATE TRIGGER update_schemes_updated_at
    BEFORE UPDATE ON public.schemes
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_analytics_updated_at
    BEFORE UPDATE ON public.scheme_analytics
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_column();

-- ============================================================================
-- STEP 9: ENABLE ROW LEVEL SECURITY
-- ============================================================================
ALTER TABLE public.schemes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.saved_schemes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.scheme_analytics ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- STEP 10: CREATE ROW LEVEL SECURITY POLICIES
-- ============================================================================

-- SCHEMES: Complete public access
CREATE POLICY "schemes_public_read" ON public.schemes
    FOR SELECT USING (true);

CREATE POLICY "schemes_public_insert" ON public.schemes
    FOR INSERT WITH CHECK (true);

CREATE POLICY "schemes_public_update" ON public.schemes
    FOR UPDATE USING (true) WITH CHECK (true);

-- USERS: Complete public access
CREATE POLICY "users_own_read" ON public.users
    FOR SELECT USING (true);

CREATE POLICY "users_own_update" ON public.users
    FOR UPDATE USING (true) WITH CHECK (true);

-- SAVED_SCHEMES: Complete public access
CREATE POLICY "saved_schemes_own_read" ON public.saved_schemes
    FOR SELECT USING (true);

CREATE POLICY "saved_schemes_own_insert" ON public.saved_schemes
    FOR INSERT WITH CHECK (true);

CREATE POLICY "saved_schemes_own_delete" ON public.saved_schemes
    FOR DELETE USING (true);

-- ANALYTICS: Public read
CREATE POLICY "analytics_public_read" ON public.scheme_analytics
    FOR SELECT USING (true);

-- ============================================================================
-- VERIFICATION: Check all tables created successfully
-- ============================================================================
SELECT 'Database setup complete!' as status;
SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' ORDER BY table_name;

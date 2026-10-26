-- ==============================================================================
-- STYLE X — DEDICATED WEB PUSH NOTIFICATIONS SUPABASE MIGRATION
-- Run this in the Supabase Dashboard -> SQL Editor -> New Query -> Run
-- ==============================================================================

BEGIN;

-- 1. Create push_subscriptions table
CREATE TABLE IF NOT EXISTS public.push_subscriptions (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
    user_id TEXT,
    endpoint TEXT NOT NULL UNIQUE,
    p256dh TEXT NOT NULL,
    auth TEXT NOT NULL,
    device_info TEXT,
    browser TEXT,
    platform TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    last_used_at TIMESTAMPTZ DEFAULT NOW(),
    is_active BOOLEAN DEFAULT true
);

-- 2. Create performance indexes
CREATE INDEX IF NOT EXISTS idx_push_subscriptions_user_id ON public.push_subscriptions(user_id);
CREATE INDEX IF NOT EXISTS idx_push_subscriptions_endpoint ON public.push_subscriptions(endpoint);
CREATE INDEX IF NOT EXISTS idx_push_subscriptions_active ON public.push_subscriptions(is_active);

-- 3. Enable Row Level Security (RLS)
ALTER TABLE public.push_subscriptions ENABLE ROW LEVEL SECURITY;

-- 4. Idempotent Security Policies
DROP POLICY IF EXISTS "allow_subscription_insert" ON public.push_subscriptions;
CREATE POLICY "allow_subscription_insert" ON public.push_subscriptions
    FOR INSERT WITH CHECK (true);

DROP POLICY IF EXISTS "allow_subscription_select" ON public.push_subscriptions;
CREATE POLICY "allow_subscription_select" ON public.push_subscriptions
    FOR SELECT USING (
        auth.uid() IS NULL 
        OR auth.uid()::text = user_id 
        OR current_user = 'service_role'
        OR current_user = 'postgres'
    );

DROP POLICY IF EXISTS "allow_subscription_update" ON public.push_subscriptions;
CREATE POLICY "allow_subscription_update" ON public.push_subscriptions
    FOR UPDATE USING (
        auth.uid() IS NULL 
        OR auth.uid()::text = user_id 
        OR current_user = 'service_role'
        OR current_user = 'postgres'
    );

DROP POLICY IF EXISTS "allow_subscription_delete" ON public.push_subscriptions;
CREATE POLICY "allow_subscription_delete" ON public.push_subscriptions
    FOR DELETE USING (
        auth.uid() IS NULL 
        OR auth.uid()::text = user_id 
        OR current_user = 'service_role'
        OR current_user = 'postgres'
    );

COMMIT;

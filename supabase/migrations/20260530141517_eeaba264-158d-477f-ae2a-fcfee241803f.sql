
-- 1) Add missing columns on existing tables
ALTER TABLE public.projects
  ADD COLUMN IF NOT EXISTS files_snapshot jsonb,
  ADD COLUMN IF NOT EXISTS linked_supabase_url text;

ALTER TABLE public.ai_project_snapshots
  ADD COLUMN IF NOT EXISTS file_count integer NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS total_bytes bigint NOT NULL DEFAULT 0;

-- 2) project_drafts
CREATE TABLE IF NOT EXISTS public.project_drafts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  project_id uuid NOT NULL,
  content text NOT NULL DEFAULT '',
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (user_id, project_id)
);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.project_drafts TO authenticated;
GRANT ALL ON public.project_drafts TO service_role;
ALTER TABLE public.project_drafts ENABLE ROW LEVEL SECURITY;
CREATE POLICY "drafts_select_own" ON public.project_drafts FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "drafts_insert_own" ON public.project_drafts FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "drafts_update_own" ON public.project_drafts FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "drafts_delete_own" ON public.project_drafts FOR DELETE USING (auth.uid() = user_id);

-- 3) project_visits
CREATE TABLE IF NOT EXISTS public.project_visits (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id uuid NOT NULL,
  path text NOT NULL DEFAULT '/',
  referrer text,
  ua_hash text,
  country text,
  device text,
  created_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_project_visits_project_created ON public.project_visits(project_id, created_at DESC);
GRANT SELECT, INSERT ON public.project_visits TO anon, authenticated;
GRANT ALL ON public.project_visits TO service_role;
ALTER TABLE public.project_visits ENABLE ROW LEVEL SECURITY;
CREATE POLICY "visits_insert_any" ON public.project_visits FOR INSERT WITH CHECK (true);
CREATE POLICY "visits_select_owner" ON public.project_visits FOR SELECT USING (
  EXISTS (SELECT 1 FROM public.projects p WHERE p.id = project_visits.project_id AND p.user_id = auth.uid())
);

-- 4) ai_project_usage
CREATE TABLE IF NOT EXISTS public.ai_project_usage (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id uuid NOT NULL,
  user_id uuid,
  action text NOT NULL DEFAULT 'chat',
  model text,
  prompt_tokens integer NOT NULL DEFAULT 0,
  completion_tokens integer NOT NULL DEFAULT 0,
  mc_cost numeric NOT NULL DEFAULT 0,
  duration_ms integer NOT NULL DEFAULT 0,
  created_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_ai_project_usage_project_created ON public.ai_project_usage(project_id, created_at DESC);
GRANT SELECT, INSERT ON public.ai_project_usage TO authenticated;
GRANT ALL ON public.ai_project_usage TO service_role;
ALTER TABLE public.ai_project_usage ENABLE ROW LEVEL SECURITY;
CREATE POLICY "usage_select_owner" ON public.ai_project_usage FOR SELECT USING (
  EXISTS (SELECT 1 FROM public.projects p WHERE p.id = ai_project_usage.project_id AND p.user_id = auth.uid())
);
CREATE POLICY "usage_insert_owner" ON public.ai_project_usage FOR INSERT WITH CHECK (
  EXISTS (SELECT 1 FROM public.projects p WHERE p.id = ai_project_usage.project_id AND p.user_id = auth.uid())
);

-- 5) project_custom_domains
CREATE TABLE IF NOT EXISTS public.project_custom_domains (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  project_id uuid NOT NULL,
  domain text NOT NULL UNIQUE,
  verification_status text NOT NULL DEFAULT 'pending',
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.project_custom_domains TO authenticated;
GRANT ALL ON public.project_custom_domains TO service_role;
ALTER TABLE public.project_custom_domains ENABLE ROW LEVEL SECURITY;
CREATE POLICY "domains_select_own" ON public.project_custom_domains FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "domains_insert_own" ON public.project_custom_domains FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "domains_update_own" ON public.project_custom_domains FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "domains_delete_own" ON public.project_custom_domains FOR DELETE USING (auth.uid() = user_id);

-- 6) project_versions
CREATE TABLE IF NOT EXISTS public.project_versions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id uuid NOT NULL,
  user_id uuid,
  message text,
  created_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_project_versions_project_created ON public.project_versions(project_id, created_at DESC);
GRANT SELECT, INSERT, DELETE ON public.project_versions TO authenticated;
GRANT ALL ON public.project_versions TO service_role;
ALTER TABLE public.project_versions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "versions_select_owner" ON public.project_versions FOR SELECT USING (
  EXISTS (SELECT 1 FROM public.projects p WHERE p.id = project_versions.project_id AND p.user_id = auth.uid())
);
CREATE POLICY "versions_insert_owner" ON public.project_versions FOR INSERT WITH CHECK (
  EXISTS (SELECT 1 FROM public.projects p WHERE p.id = project_versions.project_id AND p.user_id = auth.uid())
);

-- 7) user_memory_entries
CREATE TABLE IF NOT EXISTS public.user_memory_entries (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  workspace_id uuid,
  title text,
  summary text,
  scope text,
  created_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_user_memory_user_created ON public.user_memory_entries(user_id, created_at DESC);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.user_memory_entries TO authenticated;
GRANT ALL ON public.user_memory_entries TO service_role;
ALTER TABLE public.user_memory_entries ENABLE ROW LEVEL SECURITY;
CREATE POLICY "memory_select_own" ON public.user_memory_entries FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "memory_insert_own" ON public.user_memory_entries FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "memory_update_own" ON public.user_memory_entries FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "memory_delete_own" ON public.user_memory_entries FOR DELETE USING (auth.uid() = user_id);

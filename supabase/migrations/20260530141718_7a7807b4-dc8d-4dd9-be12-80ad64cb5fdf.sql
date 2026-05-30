
ALTER TABLE public.ai_project_snapshots
  ADD COLUMN IF NOT EXISTS user_id uuid;

ALTER TABLE public.project_custom_domains
  DROP CONSTRAINT IF EXISTS project_custom_domains_project_id_fkey;
ALTER TABLE public.project_custom_domains
  ADD CONSTRAINT project_custom_domains_project_id_fkey
  FOREIGN KEY (project_id) REFERENCES public.projects(id) ON DELETE CASCADE;

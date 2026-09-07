import { createClient } from '@supabase/supabase-js';

export const supabase = createClient(
  'https://vmapqymgcmzhwairmgmn.supabase.co',
  'sb_publishable_CGCyHvqZ0HfViivpCcOeMA_EsTjeaHC',
  { auth: { persistSession: false } },
);

import {createClient} from "https://esm.sh/@supabase/supabase-js@2";

// Ces valeurs sont publiques côté navigateur. La sécurité est appliquée par les règles RLS.
export const SUPABASE_URL="https://rstorgkwvrgqypqrbygm.supabase.co";
export const SUPABASE_ANON_KEY="sb_publishable_InwZfAgaB1IfSJu5JMJXjQ_szc6gPMR";
export const ADMINS=["thosane90@gmail.com"].map(email=>email.toLowerCase());

export const supabase=createClient(SUPABASE_URL,SUPABASE_ANON_KEY);
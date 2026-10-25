import {createClient} from "https://esm.sh/@supabase/supabase-js@2";

// Ces valeurs sont publiques côté navigateur. La sécurité est appliquée par les règles RLS.
export const SUPABASE_URL="https://VOTRE_PROJET.supabase.co";
export const SUPABASE_ANON_KEY="COLLEZ_VOTRE_CLE_PUBLIQUE_ICI";
export const ADMINS=["votre.email@gmail.com"].map(email=>email.toLowerCase());

export const supabase=createClient(SUPABASE_URL,SUPABASE_ANON_KEY);
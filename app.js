const SUPABASE_URL = "https://aakvyrujjynvdwnsvnbt.supabase.co";
const SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFha3Z5cnVqanludmR3bnN2bmJ0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzgxNjIzNTYsImV4cCI6MjA5MzczODM1Nn0.4z_qfMFgIjrcE_Ha4oC3Z-xWyg8CnhPm4dHKkEvfo70";

if (window.supabase) {
  window.supabaseClient = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY, {
    auth: {
      persistSession: true,
      autoRefreshToken: true,
      detectSessionInUrl: true
    }
  });
}

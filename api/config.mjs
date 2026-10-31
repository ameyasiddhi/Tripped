// Serves the Supabase settings from Vercel's Environment Variables,
// so they never have to be typed into the code.
// Only the Project URL and the PUBLISHABLE key belong here; both are meant to be public.
export default function handler(req, res) {
  const url = (process.env.SUPABASE_URL || "").trim();
  const key = (process.env.SUPABASE_PUBLISHABLE_KEY || "").trim();
  res.setHeader("Content-Type", "application/javascript; charset=utf-8");
  res.setHeader("Cache-Control", "public, max-age=60");
  if (!url || !key || key.startsWith("sb_secret_")) { res.end("/* Supabase not configured: demo mode */"); return; }
  res.end("window.TRIPPED_CONFIG = " + JSON.stringify({ supabaseUrl: url, supabaseAnonKey: key }) + ";");
}

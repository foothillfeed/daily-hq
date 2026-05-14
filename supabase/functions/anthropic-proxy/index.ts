// ============================================================
// FOOTHILL FEED · DAILY HQ · Anthropic Proxy Edge Function
// Supabase Edge Function: anthropic-proxy
// Keeps the Anthropic API key server-side (never in the browser)
// ============================================================

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

const ANTHROPIC_API_KEY = Deno.env.get("ANTHROPIC_API_KEY") ?? "";
const ALLOWED_ORIGIN = "*"; // Lock down to your GitHub Pages URL in production

const corsHeaders = {
  "Access-Control-Allow-Origin": ALLOWED_ORIGIN,
  "Access-Control-Allow-Headers": "content-type, x-hq-secret",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

// Simple shared secret so only your dashboard can call this function.
// Set HQ_SECRET as a Supabase secret (same command as ANTHROPIC_API_KEY below).
const HQ_SECRET = Deno.env.get("HQ_SECRET") ?? "foothillfeed-hq-2026";

serve(async (req: Request) => {
  // CORS preflight
  if (req.method === "OPTIONS") {
    return new Response(null, { headers: corsHeaders });
  }

  // Validate secret header
  const clientSecret = req.headers.get("x-hq-secret");
  if (clientSecret !== HQ_SECRET) {
    return new Response(JSON.stringify({ error: "Unauthorized" }), {
      status: 401,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }

  if (!ANTHROPIC_API_KEY) {
    return new Response(JSON.stringify({ error: "API key not configured" }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }

  try {
    const body = await req.json();

    // Forward to Anthropic
    const anthropicRes = await fetch("https://api.anthropic.com/v1/messages", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "x-api-key": ANTHROPIC_API_KEY,
        "anthropic-version": "2023-06-01",
      },
      body: JSON.stringify(body),
    });

    const data = await anthropicRes.json();

    return new Response(JSON.stringify(data), {
      status: anthropicRes.status,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (err) {
    return new Response(JSON.stringify({ error: String(err) }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});

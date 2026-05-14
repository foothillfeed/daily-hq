# Foothill Feed · Daily HQ Setup

## Step 1 — Supabase Tables (30 seconds)
1. Go to: https://supabase.com/dashboard/project/fvwqjwbxrgfejkdzbxqi/sql
2. Click **New Query**
3. Paste the contents of `supabase_setup.sql`
4. Click **Run**
5. You should see: `Daily HQ tables created successfully ✓`

## Step 2 — Deploy the Anthropic Proxy Edge Function (~5 minutes)

### Install Supabase CLI (if not already installed):
```bash
npm install -g supabase
```

### Login and link your project:
```bash
supabase login
supabase link --project-ref fvwqjwbxrgfejkdzbxqi
```

### Set secrets (replace YOUR_KEY with your Anthropic API key):
```bash
supabase secrets set ANTHROPIC_API_KEY=YOUR_ANTHROPIC_KEY_HERE
supabase secrets set HQ_SECRET=foothillfeed-hq-2026
```

### Deploy the function:
```bash
supabase functions deploy anthropic-proxy --no-verify-jwt
```

## Step 3 — Open Your Dashboard
Live URL: **https://foothillfeed.github.io/daily-hq/**

Bookmark it on every device — tasks sync automatically via Supabase.

## What Syncs Across Devices
- Daily / weekly / monthly task completion
- Extra tasks you add
- Quick capture notes
- Vendor skip toggles
- Focus pill text
- AI motivation (cached once per day in Supabase)

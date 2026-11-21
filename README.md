# WSID?

Flutter app for **What Should I Do?** (Supabase backend).

## Environment setup (required after clone)

The app loads secrets from a **local** `.env` file. That file is **not** in git.

1. Copy the template:
   ```bash
   cp .env.example .env
   ```
   On Windows (PowerShell):
   ```powershell
   Copy-Item .env.example .env
   ```
2. Fill in values (ask the project owner or use a team secret store):
   - `SUPABASE_URL` — Supabase **Project URL**
   - `SUPABASE_ANON_KEY` — Supabase **anon** / **public** key (not the service_role key)

   In [Supabase](https://supabase.com/dashboard): **Project Settings → API**.

3. Run the app:
   ```bash
   flutter pub get
   flutter run
   ```

If `SUPABASE_URL` or `SUPABASE_ANON_KEY` is missing, the app asserts on startup.

**Sharing secrets with teammates:** send the two values over a private channel (DM, password manager, Supabase project invite). Do not paste them into issues, PRs, or chat logs.

/// Supabase table and RPC function name constants.
///
/// Use these instead of raw strings throughout the data layer to avoid
/// typos and make future renames a single-point change.
abstract final class SupabaseTables {
  // ── Tables ──────────────────────────────────────────────────────────────
  static const String profiles = 'profiles';
  static const String categories = 'categories';
  static const String tasks = 'tasks';

  // ── RPC Functions ────────────────────────────────────────────────────────
  static const String getRandomTaskSuggestion = 'get_random_task_suggestion';
  static const String deleteUserAccount = 'delete_user_account';
}

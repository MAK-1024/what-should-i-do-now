-- ============================================================================
-- Migration: 02_delete_user_account_rpc.sql
-- Description: SECURITY DEFINER RPC function allowing authenticated users to
--              permanently delete their own account and all related application data.
-- ============================================================================

CREATE OR REPLACE FUNCTION public.delete_user_account()
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, auth, pg_temp
AS $$
DECLARE
  current_user_id uuid;
BEGIN
  -- 1. Resolve currently authenticated user ID from request JWT
  current_user_id := auth.uid();

  IF current_user_id IS NULL THEN
    RAISE EXCEPTION 'Unauthorized: No active authenticated session found.';
  END IF;

  -- 2. Explicit cascade deletions across public child tables
  -- This safeguards against failure in environments where foreign key constraints
  -- do not have ON DELETE CASCADE configured against auth.users.
  DELETE FROM public.tasks WHERE user_id = current_user_id;
  DELETE FROM public.categories WHERE user_id = current_user_id;
  DELETE FROM public.profiles WHERE id = current_user_id;

  -- 3. Delete authentication identity from auth.users
  DELETE FROM auth.users WHERE id = current_user_id;

  RETURN true;
EXCEPTION
  WHEN OTHERS THEN
    RAISE;
END;
$$;

-- Revoke default public execution privileges and restrict to authenticated role
REVOKE EXECUTE ON FUNCTION public.delete_user_account() FROM public;
GRANT EXECUTE ON FUNCTION public.delete_user_account() TO authenticated;

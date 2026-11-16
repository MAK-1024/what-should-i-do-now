-- ============================================================================
-- Migration: 01_single_active_task_constraint.sql
-- Description: Enforces at most one active ('in_progress') task per user using
--              a PostgreSQL partial unique index.
-- ============================================================================

-- Race Condition Prevention Explanation:
-- Application-level verification (such as querying for existing active tasks
-- prior to updating state) is prone to race conditions under concurrent workloads
-- (e.g., rapid double-taps, network retries, multi-device usage). Two concurrent
-- transactions can each check for active tasks, observe zero in-progress rows,
-- and subsequently update distinct tasks to 'in_progress'.
--
-- By defining a partial unique index on (user_id) WHERE status = 'in_progress',
-- PostgreSQL's MVCC and b-tree indexing atomically enforce uniqueness at the
-- storage engine layer. If any transaction attempts to transition a second task to
-- 'in_progress' for the same user while an active task already exists, the database
-- rejects the operation with a unique_violation error (code 23505). This eliminates
-- any race window without requiring heavyweight external locking mechanisms.

CREATE UNIQUE INDEX IF NOT EXISTS idx_tasks_single_active_per_user
ON public.tasks (user_id)
WHERE status = 'in_progress';

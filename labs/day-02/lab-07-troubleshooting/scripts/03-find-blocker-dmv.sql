-- >>> Edit your prefix (T-SQL editor — no SQLCMD mode) <<<
DECLARE @StudentPrefix sysname = N's01';
DECLARE @DbName sysname = @StudentPrefix + N'_AdventureWorks';

-- Find blocker chain while Scenario B is active
SELECT
    blocked.session_id AS blocked_spid,
    blocked.blocking_session_id AS blocker_spid,
    blocked.wait_type,
    blocked.wait_time AS wait_time_ms,
    DB_NAME(blocked.database_id) AS database_name,
    blocked_s.login_name AS blocked_login,
    blocker_s.login_name AS blocker_login,
    blocker_s.status AS blocker_status,
    SUBSTRING(
        blocked_text.text,
        (blocked.statement_start_offset / 2) + 1,
        (
            CASE blocked.statement_end_offset
                WHEN -1 THEN DATALENGTH(blocked_text.text)
                ELSE blocked.statement_end_offset
            END - blocked.statement_start_offset
        ) / 2 + 1
    ) AS blocked_statement,
    SUBSTRING(
        blocker_text.text,
        (blocker.statement_start_offset / 2) + 1,
        (
            CASE blocker.statement_end_offset
                WHEN -1 THEN DATALENGTH(blocker_text.text)
                ELSE blocker.statement_end_offset
            END - blocker.statement_start_offset
        ) / 2 + 1
    ) AS blocker_statement
FROM sys.dm_exec_requests AS blocked
JOIN sys.dm_exec_sessions AS blocked_s ON blocked_s.session_id = blocked.session_id
LEFT JOIN sys.dm_exec_requests AS blocker
    ON blocker.session_id = blocked.blocking_session_id
LEFT JOIN sys.dm_exec_sessions AS blocker_s ON blocker_s.session_id = blocker.session_id
OUTER APPLY sys.dm_exec_sql_text(blocked.sql_handle) AS blocked_text
OUTER APPLY sys.dm_exec_sql_text(blocker.sql_handle) AS blocker_text
WHERE blocked.blocking_session_id <> 0
  AND DB_NAME(blocked.database_id) = @DbName
ORDER BY blocked.wait_time DESC;

PRINT N'Resolution options: ask blocker session to COMMIT/ROLLBACK, or KILL <blocker_spid> (last resort).';
GO

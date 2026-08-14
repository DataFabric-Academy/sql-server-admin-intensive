-- >>> Edit your prefix (T-SQL editor — no SQLCMD mode) <<<
DECLARE @StudentPrefix sysname = N's01';
DECLARE @DbName sysname = @StudentPrefix + N'_AdventureWorks';

SELECT
    r.session_id,
    s.login_name,
    DB_NAME(r.database_id) AS database_name,
    r.status,
    r.command,
    r.blocking_session_id,
    r.wait_type,
    r.wait_time,
    r.cpu_time,
    r.total_elapsed_time,
    SUBSTRING(
        qt.text,
        (r.statement_start_offset / 2) + 1,
        (
            CASE r.statement_end_offset
                WHEN -1 THEN DATALENGTH(qt.text)
                ELSE r.statement_end_offset
            END - r.statement_start_offset
        ) / 2 + 1
    ) AS running_statement
FROM sys.dm_exec_requests AS r
JOIN sys.dm_exec_sessions AS s ON s.session_id = r.session_id
OUTER APPLY sys.dm_exec_sql_text(r.sql_handle) AS qt
WHERE r.session_id <> @@SPID
  AND (
        DB_NAME(r.database_id) = @DbName
        OR r.blocking_session_id <> 0
      )
ORDER BY r.blocking_session_id DESC, r.session_id;
GO

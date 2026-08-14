-- >>> Edit your prefix (T-SQL editor — no SQLCMD mode) <<<
DECLARE @StudentPrefix sysname = N's01';
DECLARE @XEventRoot nvarchar(260) = N'D:\SqlLabs\xevents';

USE master;

DECLARE @session sysname = @StudentPrefix + N'_TrackSlowQuery';
DECLARE @dbName sysname = @StudentPrefix + N'_AdventureWorks';
DECLARE @xelPath nvarchar(400) = @XEventRoot + N'\' + @StudentPrefix + N'\SlowQuery.xel';
DECLARE @sql nvarchar(max);

IF EXISTS (SELECT 1 FROM sys.server_event_sessions WHERE name = @session)
BEGIN
    SET @sql = N'ALTER EVENT SESSION ' + QUOTENAME(@session)
        + N' ON SERVER STATE = STOP; DROP EVENT SESSION ' + QUOTENAME(@session) + N' ON SERVER;';
    EXEC sys.sp_executesql @sql;
END

SET @sql = N'CREATE EVENT SESSION ' + QUOTENAME(@session) + N' ON SERVER
ADD EVENT sqlserver.sql_statement_completed(
    SET collect_statement = 1
    ACTION(
        sqlserver.client_app_name,
        sqlserver.database_name,
        sqlserver.session_id,
        sqlserver.sql_text,
        sqlserver.username
    )
    WHERE (
        [duration] >= 500000
        AND [database_name] = N''' + REPLACE(@dbName, N'''', N'''''') + N'''
    )
)
ADD TARGET package0.event_file(
    SET filename = N''' + REPLACE(@xelPath, N'''', N'''''') + N''',
        max_file_size = 10,
        max_rollover_files = 2
)
WITH (STARTUP_STATE = OFF, MAX_MEMORY = 16 MB, EVENT_RETENTION_MODE = ALLOW_SINGLE_EVENT_LOSS);';

EXEC sys.sp_executesql @sql;

SET @sql = N'ALTER EVENT SESSION ' + QUOTENAME(@session) + N' ON SERVER STATE = START;';
EXEC sys.sp_executesql @sql;

SELECT name FROM sys.server_event_sessions WHERE name = @session;
GO

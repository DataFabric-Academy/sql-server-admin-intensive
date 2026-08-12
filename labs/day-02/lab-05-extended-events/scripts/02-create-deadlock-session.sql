:setvar StudentPrefix s01
:setvar XEventRoot D:\SqlLabs\xevents

USE master;
GO

DECLARE @session sysname = N'$(StudentPrefix)_CaptureDeadlocks';

IF EXISTS (SELECT 1 FROM sys.server_event_sessions WHERE name = @session)
BEGIN
    DECLARE @sql nvarchar(max) = N'ALTER EVENT SESSION ' + QUOTENAME(@session) + N' ON SERVER STATE = STOP; DROP EVENT SESSION ' + QUOTENAME(@session) + N' ON SERVER;';
    EXEC sys.sp_executesql @sql;
END
GO

CREATE EVENT SESSION [$(StudentPrefix)_CaptureDeadlocks] ON SERVER
ADD EVENT sqlserver.xml_deadlock_report
ADD TARGET package0.event_file(
    SET filename = N'$(XEventRoot)\$(StudentPrefix)\Deadlock.xel',
        max_file_size = 10,
        max_rollover_files = 2
)
WITH (STARTUP_STATE = OFF, MAX_MEMORY = 16 MB, EVENT_RETENTION_MODE = ALLOW_SINGLE_EVENT_LOSS);
GO

ALTER EVENT SESSION [$(StudentPrefix)_CaptureDeadlocks] ON SERVER STATE = START;
GO

SELECT name FROM sys.server_event_sessions WHERE name = N'$(StudentPrefix)_CaptureDeadlocks';
GO

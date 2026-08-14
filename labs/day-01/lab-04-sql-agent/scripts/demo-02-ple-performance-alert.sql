/*
  Instructor demo only — Module 04
  Performance Condition Alert: Page life expectancy < 300 (Alert type 3 of 3)
  + optional Response Job (dump expensive queries)

  Prerequisites:
    - Run demo-01 first (creates Demo_DBA operator) OR this script recreates it
    - SQL Server Agent running
    - sysadmin
*/
USE msdb;
GO

DECLARE @operator sysname = N'Demo_DBA';
DECLARE @alert    sysname = N'Demo_Low_PLE';
DECLARE @job      sysname = N'Demo_Dump_QueryStats';

/* ---- Ensure Operator exists ---- */
IF NOT EXISTS (SELECT 1 FROM dbo.sysoperators WHERE name = @operator)
BEGIN
    EXEC dbo.sp_add_operator
        @name = @operator,
        @enabled = 1,
        @email_address = N'dba@company.local';
END

/* ---- Optional response job ---- */
BEGIN TRY
    EXEC dbo.sp_delete_job @job_name = @job, @delete_unused_schedule = 1;
END TRY
BEGIN CATCH
    IF ERROR_NUMBER() NOT IN (14262) THROW;
END CATCH;

EXEC dbo.sp_add_job
    @job_name = @job,
    @enabled = 1,
    @description = N'Demo response: capture top CPU queries when PLE alert fires';

EXEC dbo.sp_add_jobstep
    @job_name = @job,
    @step_name = N'Dump top CPU queries',
    @subsystem = N'TSQL',
    @database_name = N'master',
    @command = N'
SELECT TOP (20)
    qs.total_worker_time / NULLIF(qs.execution_count, 0) AS avg_worker_time,
    qs.execution_count,
    qs.total_logical_reads,
    SUBSTRING(st.text, (qs.statement_start_offset / 2) + 1,
        ((CASE qs.statement_end_offset WHEN -1 THEN DATALENGTH(st.text)
          ELSE qs.statement_end_offset END - qs.statement_start_offset) / 2) + 1) AS statement_text
FROM sys.dm_exec_query_stats AS qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS st
ORDER BY qs.total_worker_time DESC;
',
    @on_success_action = 1,
    @on_fail_action = 2;

EXEC dbo.sp_add_jobserver @job_name = @job, @server_name = N'(LOCAL)';

DECLARE @job_id uniqueidentifier =
    (SELECT job_id FROM dbo.sysjobs WHERE name = @job);

/* ---- PLE Performance Condition Alert ---- */
IF EXISTS (SELECT 1 FROM dbo.sysalerts WHERE name = @alert)
    EXEC dbo.sp_delete_alert @name = @alert;

-- Format: Object|Counter|Instance|Comparator|Value
EXEC dbo.sp_add_alert
    @name = @alert,
    @enabled = 1,
    @delay_between_responses = 600,
    @include_event_description_in = 1,
    @notification_message = N'Demo: Page life expectancy below 300 seconds',
    @performance_condition = N'SQLServer:Buffer Manager|Page life expectancy||<|300',
    @job_id = @job_id;

BEGIN TRY
    EXEC dbo.sp_add_notification
        @alert_name = @alert,
        @operator_name = @operator,
        @notification_method = 1;
END TRY
BEGIN CATCH
    PRINT N'Notification skipped: ' + ERROR_MESSAGE();
END CATCH;
GO

SELECT name, performance_condition, job_id, enabled
FROM msdb.dbo.sysalerts
WHERE name = N'Demo_Low_PLE';

SELECT j.name AS response_job
FROM msdb.dbo.sysalerts a
JOIN msdb.dbo.sysjobs j ON a.job_id = j.job_id
WHERE a.name = N'Demo_Low_PLE';
GO

PRINT N'Demo tip: show current PLE with:';
PRINT N'  SELECT cntr_value FROM sys.dm_os_performance_counters';
PRINT N'  WHERE object_name LIKE ''%Buffer Manager%'' AND counter_name = ''Page life expectancy'';';
PRINT N'On a healthy lab box PLE is often >> 300 — explain threshold conceptually,';
PRINT N'or temporarily raise the alert threshold for a live fire demo.';
GO

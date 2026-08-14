/*
  Instructor demo only — Module 04
  Operator + Severity Alert (Alert type 2 of 3)

  Prerequisites:
    - SQL Server Agent running
    - sysadmin (Windows Auth on lab server)
    - Database Mail optional (notification still wires without SMTP)

  Student lab uses Error Number alert (51001). This demo shows Severity.
*/
USE msdb;
GO

DECLARE @operator sysname = N'Demo_DBA';
DECLARE @alert    sysname = N'Demo_Severity_19';

/* ---- Severity Alert first (so Operator delete is not blocked by notification) ---- */
IF EXISTS (SELECT 1 FROM dbo.sysalerts WHERE name = @alert)
    EXEC dbo.sp_delete_alert @name = @alert;

/* ---- Operator ---- */
IF EXISTS (SELECT 1 FROM dbo.sysoperators WHERE name = @operator)
    EXEC dbo.sp_delete_operator @name = @operator;

EXEC dbo.sp_add_operator
    @name = @operator,
    @enabled = 1,
    @email_address = N'dba@company.local',
    @pager_address = NULL,
    @weekday_pager_start_time = 090000,
    @weekday_pager_end_time = 180000,
    @pager_days = 0,
    @category_name = N'[Uncategorized]';

PRINT N'Operator created: Demo_DBA';

/* ---- Severity Alert (17–19 resource / 19+ shown here) ---- */

EXEC dbo.sp_add_alert
    @name = @alert,
    @message_id = 0,
    @severity = 19,
    @enabled = 1,
    @delay_between_responses = 300,
    @include_event_description_in = 1,
    @notification_message = N'Demo: severity >= 19 fired',
    @job_id = 0x00;

-- Wire email notification (needs Database Mail + profile to actually send)
BEGIN TRY
    EXEC dbo.sp_add_notification
        @alert_name = @alert,
        @operator_name = @operator,
        @notification_method = 1; -- 1 = email
END TRY
BEGIN CATCH
    PRINT N'Notification skipped: ' + ERROR_MESSAGE();
    PRINT N'Create Database Mail profile/account if you need real email in class.';
END CATCH;
GO

SELECT name, email_address, enabled
FROM msdb.dbo.sysoperators
WHERE name = N'Demo_DBA';

SELECT name, message_id, severity, enabled, delay_between_responses
FROM msdb.dbo.sysalerts
WHERE name = N'Demo_Severity_19';
GO

PRINT N'Demo tip: raise a severity-19+ error in another window to fire this alert,';
PRINT N'  or show SSMS: SQL Server Agent → Alerts → Demo_Severity_19 → History.';
GO

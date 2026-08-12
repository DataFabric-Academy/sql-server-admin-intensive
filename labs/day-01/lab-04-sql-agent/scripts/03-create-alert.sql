/*
  Creates per-student SQL Agent alert for shared message_id 51001
  (message created by instructor: labs/00-env-setup/scripts/03-create-lab04-message.sql)
*/
:setvar StudentPrefix s01
:setvar MessageId 51001

USE msdb;
GO

DECLARE @alert sysname = N'$(StudentPrefix)_Lab04_Alert';

IF EXISTS (SELECT 1 FROM dbo.sysalerts WHERE name = @alert)
    EXEC dbo.sp_delete_alert @name = @alert;

EXEC dbo.sp_add_alert
    @name = @alert,
    @message_id = $(MessageId),
    @severity = 0,
    @enabled = 1,
    @delay_between_responses = 60,
    @include_event_description_in = 1,
    @notification_message = N'Lab 04 student alert',
    @job_id = 0x00;
GO

SELECT name, message_id, severity, enabled
FROM msdb.dbo.sysalerts
WHERE name = N'$(StudentPrefix)_Lab04_Alert';
GO

/*
  Instructor: create shared Lab 04 user-defined message (once per instance).
  Students raise this message_id in lab-04 scripts/04-test-alert.sql
*/

USE master;
GO

IF NOT EXISTS (SELECT 1 FROM sys.messages WHERE message_id = 51001 AND language_id = 1033)
BEGIN
    EXEC sp_addmessage
        @msgnum = 51001,
        @severity = 16,
        @msgtext = N'Lab04 alert triggered by %s (%s)',
        @lang = N'us_english',
        @with_log = N'true';
END
ELSE
BEGIN
    EXEC sp_altermessage @message_id = 51001, @parameter = N'WITH_LOG', @parameter_value = N'true';
END
GO

SELECT message_id, severity, text, is_event_logged
FROM sys.messages
WHERE message_id = 51001 AND language_id = 1033;
GO

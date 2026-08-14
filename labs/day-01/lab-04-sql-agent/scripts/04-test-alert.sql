/*
  Lab 04 — fire user-defined error so Alert can capture it
  (WITH LOG already on message 51001 from env-setup)
  Edit the DECLARE block only (T-SQL editor — no SQLCMD mode).
*/
DECLARE @StudentPrefix sysname = N's01';
DECLARE @MessageId int = 51001;

RAISERROR(@MessageId, 16, 1, @StudentPrefix, N'Lab04 test');
GO

-- Optional: check recent error log entries (requires elevated permission)
BEGIN TRY
    EXEC sys.xp_readerrorlog 0, 1, N'Lab04 alert';
END TRY
BEGIN CATCH
    PRINT N'xp_readerrorlog skipped — use SSMS Error Log viewer or sp_readerrorlog as instructor.';
END CATCH;
GO

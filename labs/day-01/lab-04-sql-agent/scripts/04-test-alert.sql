:setvar StudentPrefix s01
:setvar MessageId 51001

-- Fire the user-defined error so Alert can capture it (WITH LOG already on message)
RAISERROR($(MessageId), 16, 1, N'$(StudentPrefix)', N'Lab04 test');
GO

-- Optional: check recent error log entries (requires elevated permission)
BEGIN TRY
    EXEC sys.xp_readerrorlog 0, 1, N'Lab04 alert';
END TRY
BEGIN CATCH
    PRINT N'xp_readerrorlog skipped — use SSMS Error Log viewer or sp_readerrorlog as instructor.';
END CATCH;
GO

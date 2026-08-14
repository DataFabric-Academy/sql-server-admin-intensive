-- >>> Edit your prefix (T-SQL editor — no SQLCMD mode) <<<
DECLARE @StudentPrefix sysname = N's01';

-- Recent error log entries (login failed, backup, agent)
EXEC sys.sp_readerrorlog 0, 1, N'Login failed';

EXEC sys.sp_readerrorlog 0, 1, N'backup';

-- Optional: search for student prefix in messages
EXEC sys.sp_readerrorlog 0, 1, @StudentPrefix;
GO

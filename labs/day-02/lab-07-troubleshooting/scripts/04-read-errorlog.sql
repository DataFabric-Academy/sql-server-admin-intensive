:setvar StudentPrefix s01

-- Recent error log entries (login failed, backup, agent)
EXEC sys.sp_readerrorlog 0, 1, N'Login failed';
GO

EXEC sys.sp_readerrorlog 0, 1, N'backup';
GO

-- Optional: search for student prefix in messages
EXEC sys.sp_readerrorlog 0, 1, N'$(StudentPrefix)';
GO

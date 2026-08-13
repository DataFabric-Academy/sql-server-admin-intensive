/*
  Instructor setup: create SQL Auth logins for students (s01..sNN)
  Run as sysadmin (Windows Auth). Change @StudentCount and password before class.
  Do NOT commit real production passwords.
*/

USE master;
GO

DECLARE @StudentCount int = 30;          -- adjust per class size
DECLARE @Pwd sysname = N'ChangeMe!Lab01'; -- temporary class password
DECLARE @i int = 1;
DECLARE @login sysname;
DECLARE @sql nvarchar(max);

WHILE @i <= @StudentCount
BEGIN
    SET @login = N's' + RIGHT(N'0' + CAST(@i AS nvarchar(10)), 2);

    IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = @login)
    BEGIN
        SET @sql = N'CREATE LOGIN ' + QUOTENAME(@login)
                 + N' WITH PASSWORD = ' + QUOTENAME(@Pwd, '''')
                 + N', CHECK_POLICY = ON, CHECK_EXPIRATION = OFF;';
        EXEC sys.sp_executesql @sql;
        PRINT N'Created login ' + @login;
    END
    ELSE
        PRINT N'Skip existing login ' + @login;

    SET @i += 1;
END
GO

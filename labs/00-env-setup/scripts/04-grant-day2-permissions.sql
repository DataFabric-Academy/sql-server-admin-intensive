/*
  Instructor setup: Day 2 permissions for DMV and Extended Events labs.
  Run after 02-grant-baseline-permissions.sql
*/

USE master;
GO

DECLARE @StudentCount int = 30;
DECLARE @i int = 1;
DECLARE @login sysname;
DECLARE @sql nvarchar(max);

WHILE @i <= @StudentCount
BEGIN
    SET @login = N's' + RIGHT(N'0' + CAST(@i AS nvarchar(10)), 2);

    IF SUSER_ID(@login) IS NULL
    BEGIN
        PRINT N'Skip missing login ' + @login;
        SET @i += 1;
        CONTINUE;
    END

    IF NOT EXISTS (
        SELECT 1 FROM sys.server_permissions p
        JOIN sys.server_principals sp ON p.grantee_principal_id = sp.principal_id
        WHERE sp.name = @login AND p.permission_name = N'VIEW SERVER STATE' AND p.state = N'G'
    )
    BEGIN
        SET @sql = N'GRANT VIEW SERVER STATE TO ' + QUOTENAME(@login) + N';';
        EXEC sys.sp_executesql @sql;
    END

    IF NOT EXISTS (
        SELECT 1 FROM sys.server_permissions p
        JOIN sys.server_principals sp ON p.grantee_principal_id = sp.principal_id
        WHERE sp.name = @login AND p.permission_name = N'VIEW ANY DEFINITION' AND p.state = N'G'
    )
    BEGIN
        SET @sql = N'GRANT VIEW ANY DEFINITION TO ' + QUOTENAME(@login) + N';';
        EXEC sys.sp_executesql @sql;
    END

    IF NOT EXISTS (
        SELECT 1 FROM sys.server_permissions p
        JOIN sys.server_principals sp ON p.grantee_principal_id = sp.principal_id
        WHERE sp.name = @login AND p.permission_name = N'ALTER ANY EVENT SESSION' AND p.state = N'G'
    )
    BEGIN
        SET @sql = N'GRANT ALTER ANY EVENT SESSION TO ' + QUOTENAME(@login) + N';';
        EXEC sys.sp_executesql @sql;
    END

    PRINT N'Day 2 permissions granted for ' + @login;
    SET @i += 1;
END
GO

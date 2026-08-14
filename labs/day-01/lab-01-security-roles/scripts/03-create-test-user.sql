/*
  Creates a SQL login/user for permission testing.
  Requires ALTER ANY LOGIN (instructor may run this for the class).
  Edit the DECLARE block only (T-SQL editor — no SQLCMD mode).
*/

-- >>> Edit your prefix (T-SQL editor — no SQLCMD mode) <<<
DECLARE @StudentPrefix sysname = N's01';
DECLARE @db sysname = @StudentPrefix + N'_AdventureWorks';
DECLARE @login sysname = @StudentPrefix + N'_tester';
DECLARE @role sysname = @StudentPrefix + N'_HRUsers';
DECLARE @sql nvarchar(max);

USE master;

IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = @login)
BEGIN
    SET @sql = N'CREATE LOGIN ' + QUOTENAME(@login)
        + N' WITH PASSWORD = N''ChangeMe!Tester01'','
        + N' CHECK_POLICY = ON,'
        + N' CHECK_EXPIRATION = OFF;';
    EXEC sys.sp_executesql @sql;
END

SET @sql = N'
USE ' + QUOTENAME(@db) + N';

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = @loginName)
    CREATE USER ' + QUOTENAME(@login) + N' FOR LOGIN ' + QUOTENAME(@login) + N';

IF EXISTS (
    SELECT 1 FROM sys.database_principals
    WHERE name = @roleName AND type = ''R''
)
    ALTER ROLE ' + QUOTENAME(@role) + N' ADD MEMBER ' + QUOTENAME(@login) + N';

PRINT N''Test user '' + @loginName + N'' is ready'';
';

EXEC sys.sp_executesql
    @sql,
    N'@loginName sysname, @roleName sysname',
    @loginName = @login,
    @roleName = @role;
GO

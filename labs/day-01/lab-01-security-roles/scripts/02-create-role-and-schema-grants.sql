/*
  Lab 01 — create role + schema grants
  Edit the DECLARE block only (T-SQL editor — no SQLCMD mode).
*/

-- >>> Edit your prefix (T-SQL editor — no SQLCMD mode) <<<
DECLARE @StudentPrefix sysname = N's01';
DECLARE @db sysname = @StudentPrefix + N'_AdventureWorks';
DECLARE @role sysname = @StudentPrefix + N'_HRUsers';
DECLARE @sql nvarchar(max);

SET @sql = N'
USE ' + QUOTENAME(@db) + N';

IF NOT EXISTS (
    SELECT 1 FROM sys.database_principals
    WHERE name = @roleName AND type = ''R''
)
    CREATE ROLE ' + QUOTENAME(@role) + N';

GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::HumanResources TO ' + QUOTENAME(@role) + N';
GRANT SELECT ON SCHEMA::Sales TO ' + QUOTENAME(@role) + N';

PRINT N''Role and schema grants applied for '' + @roleName;
';

EXEC sys.sp_executesql @sql, N'@roleName sysname', @roleName = @role;
GO

/*
  Lab 01 — verify login / DB user / sample schemas
  Edit the DECLARE block only (T-SQL editor — no SQLCMD mode).
*/

-- >>> Edit your prefix (T-SQL editor — no SQLCMD mode) <<<
DECLARE @StudentPrefix sysname = N's01';
DECLARE @db sysname = @StudentPrefix + N'_AdventureWorks';
DECLARE @sql nvarchar(max);

SELECT
    SUSER_SNAME() AS current_login,
    ORIGINAL_LOGIN() AS original_login,
    DB_NAME() AS current_db;

SET @sql = N'
USE ' + QUOTENAME(@db) + N';

SELECT name AS db_user, type_desc, authentication_type_desc
FROM sys.database_principals
WHERE name = @prefix OR name = SUSER_SNAME();

SELECT s.name AS schema_name, o.name AS table_name
FROM sys.tables o
JOIN sys.schemas s ON o.schema_id = s.schema_id
WHERE s.name IN (N''HumanResources'', N''Sales'')
ORDER BY s.name, o.name;
';

EXEC sys.sp_executesql @sql, N'@prefix sysname', @prefix = @StudentPrefix;
GO

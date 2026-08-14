/*
  Lab 02 — inspect recovery model / log space / files
  Edit the DECLARE block only (T-SQL editor — no SQLCMD mode).
*/

-- >>> Edit your prefix (T-SQL editor — no SQLCMD mode) <<<
DECLARE @StudentPrefix sysname = N's01';
DECLARE @db sysname = @StudentPrefix + N'_AdventureWorks';
DECLARE @sql nvarchar(max);

SET @sql = N'
USE ' + QUOTENAME(@db) + N';

SELECT
    name,
    recovery_model_desc,
    log_reuse_wait_desc,
    log_reuse_wait
FROM sys.databases
WHERE name = @dbName;

DBCC SQLPERF(logspace);

SELECT
    name AS logical_name,
    type_desc,
    size * 8 / 1024 AS size_mb,
    max_size,
    growth,
    is_percent_growth
FROM sys.database_files;
';

EXEC sys.sp_executesql @sql, N'@dbName sysname', @dbName = @db;
GO

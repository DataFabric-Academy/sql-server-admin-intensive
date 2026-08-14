/*
  Lab 02 — inspect VLFs via sys.dm_db_log_info
  Edit the DECLARE block only (T-SQL editor — no SQLCMD mode).
*/

-- >>> Edit your prefix (T-SQL editor — no SQLCMD mode) <<<
DECLARE @StudentPrefix sysname = N's01';
DECLARE @db sysname = @StudentPrefix + N'_AdventureWorks';
DECLARE @sql nvarchar(max);

SET @sql = N'
USE ' + QUOTENAME(@db) + N';

-- SQL Server 2016+ : sys.dm_db_log_info
SELECT
    database_id,
    DB_NAME(database_id) AS database_name,
    vlf_sequence_number,
    vlf_size_mb,
    vlf_active,
    vlf_status
FROM sys.dm_db_log_info(DB_ID())
ORDER BY vlf_begin_offset;

SELECT
    COUNT(*) AS vlf_count,
    SUM(CASE WHEN vlf_active = 1 THEN 1 ELSE 0 END) AS active_vlfs
FROM sys.dm_db_log_info(DB_ID());
';

EXEC sys.sp_executesql @sql;
GO

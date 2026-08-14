/*
  Lab 02 — SIMPLE recovery workload + CHECKPOINT reuse
  Edit the DECLARE block only (T-SQL editor — no SQLCMD mode).
*/

-- >>> Edit your prefix (T-SQL editor — no SQLCMD mode) <<<
DECLARE @StudentPrefix sysname = N's01';
DECLARE @db sysname = @StudentPrefix + N'_AdventureWorks';
DECLARE @sql nvarchar(max);

USE master;

SET @sql = N'ALTER DATABASE ' + QUOTENAME(@db) + N' SET RECOVERY SIMPLE;';
EXEC sys.sp_executesql @sql;

SET @sql = N'
USE ' + QUOTENAME(@db) + N';

PRINT N''--- Before workload (SIMPLE) ---'';
DBCC SQLPERF(logspace);

INSERT INTO dbo.LabAudit (Note)
SELECT CONCAT(N''simple-'', v.number)
FROM master..spt_values AS v
WHERE v.type = N''P'' AND v.number BETWEEN 1 AND 8000;

PRINT N''--- After insert ---'';
DBCC SQLPERF(logspace);

CHECKPOINT;

PRINT N''--- After CHECKPOINT (expect reuse in SIMPLE) ---'';
DBCC SQLPERF(logspace);

SELECT name, recovery_model_desc, log_reuse_wait_desc
FROM sys.databases
WHERE name = @dbName;
';

EXEC sys.sp_executesql @sql, N'@dbName sysname', @dbName = @db;
GO

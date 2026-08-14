/*
  Lab 02 — FULL recovery, full backup, workload, log backup
  Edit the DECLARE block only (T-SQL editor — no SQLCMD mode).
*/

-- >>> Edit your prefix (T-SQL editor — no SQLCMD mode) <<<
DECLARE @StudentPrefix sysname = N's01';
DECLARE @BackupRoot nvarchar(260) = N'D:/SqlLabs/backups';
DECLARE @db sysname = @StudentPrefix + N'_AdventureWorks';
DECLARE @fullBak nvarchar(4000) =
    @BackupRoot + N'/' + @StudentPrefix + N'/' + @StudentPrefix + N'_AdventureWorks_full.bak';
DECLARE @logBak nvarchar(4000) =
    @BackupRoot + N'/' + @StudentPrefix + N'/' + @StudentPrefix + N'_AdventureWorks_lab02.trn';
DECLARE @sql nvarchar(max);

USE master;

SET @sql = N'ALTER DATABASE ' + QUOTENAME(@db) + N' SET RECOVERY FULL;';
EXEC sys.sp_executesql @sql;

-- Full backup required before first log backup
SET @sql = N'BACKUP DATABASE ' + QUOTENAME(@db)
    + N' TO DISK = N''' + REPLACE(@fullBak, N'''', N'''''')
    + N''' WITH INIT, COMPRESSION, STATS = 10;';
EXEC sys.sp_executesql @sql;

SET @sql = N'
USE ' + QUOTENAME(@db) + N';

PRINT N''--- Before workload (FULL) ---'';
DBCC SQLPERF(logspace);

INSERT INTO dbo.LabAudit (Note)
SELECT CONCAT(N''full-'', v.number)
FROM master..spt_values AS v
WHERE v.type = N''P'' AND v.number BETWEEN 1 AND 8000;

CHECKPOINT;

PRINT N''--- After CHECKPOINT (FULL often still waits for LOG_BACKUP) ---'';
SELECT name, recovery_model_desc, log_reuse_wait_desc
FROM sys.databases
WHERE name = @dbName;
DBCC SQLPERF(logspace);
';

EXEC sys.sp_executesql @sql, N'@dbName sysname', @dbName = @db;

SET @sql = N'BACKUP LOG ' + QUOTENAME(@db)
    + N' TO DISK = N''' + REPLACE(@logBak, N'''', N'''''')
    + N''' WITH INIT, COMPRESSION;';
EXEC sys.sp_executesql @sql;

PRINT N'--- After LOG backup ---';
SELECT name, recovery_model_desc, log_reuse_wait_desc
FROM sys.databases
WHERE name = @db;
DBCC SQLPERF(logspace);
GO

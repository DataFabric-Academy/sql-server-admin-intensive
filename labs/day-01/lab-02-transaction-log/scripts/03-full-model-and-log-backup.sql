:setvar StudentPrefix s01
:setvar BackupRoot "D:/SqlLabs/backups"

USE master;
GO

ALTER DATABASE [$(StudentPrefix)_AdventureWorks] SET RECOVERY FULL;
GO

-- Full backup required before first log backup
BACKUP DATABASE [$(StudentPrefix)_AdventureWorks]
TO DISK = N'$(BackupRoot)/$(StudentPrefix)/$(StudentPrefix)_AdventureWorks_full.bak'
WITH INIT, COMPRESSION, STATS = 10;
GO

USE [$(StudentPrefix)_AdventureWorks];
GO

PRINT N'--- Before workload (FULL) ---';
DBCC SQLPERF(logspace);

INSERT INTO dbo.LabAudit (Note)
SELECT CONCAT(N'full-', v.number)
FROM master..spt_values AS v
WHERE v.type = N'P' AND v.number BETWEEN 1 AND 8000;

CHECKPOINT;

PRINT N'--- After CHECKPOINT (FULL often still waits for LOG_BACKUP) ---';
SELECT name, recovery_model_desc, log_reuse_wait_desc
FROM sys.databases
WHERE name = N'$(StudentPrefix)_AdventureWorks';
DBCC SQLPERF(logspace);
GO

BACKUP LOG [$(StudentPrefix)_AdventureWorks]
TO DISK = N'$(BackupRoot)/$(StudentPrefix)/$(StudentPrefix)_AdventureWorks_lab02.trn'
WITH INIT, COMPRESSION;
GO

PRINT N'--- After LOG backup ---';
SELECT name, recovery_model_desc, log_reuse_wait_desc
FROM sys.databases
WHERE name = N'$(StudentPrefix)_AdventureWorks';
DBCC SQLPERF(logspace);
GO

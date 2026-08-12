:setvar StudentPrefix s01

USE master;
GO

ALTER DATABASE [$(StudentPrefix)_AdventureWorks] SET RECOVERY SIMPLE;
GO

USE [$(StudentPrefix)_AdventureWorks];
GO

PRINT N'--- Before workload (SIMPLE) ---';
DBCC SQLPERF(logspace);

INSERT INTO dbo.LabAudit (Note)
SELECT CONCAT(N'simple-', v.number)
FROM master..spt_values AS v
WHERE v.type = N'P' AND v.number BETWEEN 1 AND 8000;

PRINT N'--- After insert ---';
DBCC SQLPERF(logspace);

CHECKPOINT;

PRINT N'--- After CHECKPOINT (expect reuse in SIMPLE) ---';
DBCC SQLPERF(logspace);

SELECT name, recovery_model_desc, log_reuse_wait_desc
FROM sys.databases
WHERE name = N'$(StudentPrefix)_AdventureWorks';
GO

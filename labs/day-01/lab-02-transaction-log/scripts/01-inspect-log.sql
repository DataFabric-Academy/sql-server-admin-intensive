:setvar StudentPrefix s01

USE [$(StudentPrefix)_AdventureWorks];
GO

SELECT
    name,
    recovery_model_desc,
    log_reuse_wait_desc,
    log_reuse_wait
FROM sys.databases
WHERE name = N'$(StudentPrefix)_AdventureWorks';
GO

DBCC SQLPERF(logspace);
GO

SELECT
    name AS logical_name,
    type_desc,
    size * 8 / 1024 AS size_mb,
    max_size,
    growth,
    is_percent_growth
FROM sys.database_files;
GO

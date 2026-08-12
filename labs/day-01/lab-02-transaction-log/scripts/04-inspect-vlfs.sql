:setvar StudentPrefix s01

USE [$(StudentPrefix)_AdventureWorks];
GO

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
GO

SELECT
    COUNT(*) AS vlf_count,
    SUM(CASE WHEN vlf_active = 1 THEN 1 ELSE 0 END) AS active_vlfs
FROM sys.dm_db_log_info(DB_ID());
GO

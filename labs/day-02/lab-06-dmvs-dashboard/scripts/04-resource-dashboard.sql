-- >>> Edit your prefix (T-SQL editor — no SQLCMD mode) <<<
DECLARE @StudentPrefix sysname = N's01';
DECLARE @DbName sysname = @StudentPrefix + N'_AdventureWorks';

-- Grid 1: Instance CPU / uptime
SELECT
    cpu_count,
    hyperthread_ratio,
    sqlserver_start_time,
    DATEDIFF(minute, sqlserver_start_time, SYSDATETIME()) AS uptime_minutes
FROM sys.dm_os_sys_info;

-- Grid 2: Memory
SELECT
    physical_memory_in_use_kb / 1024 AS physical_memory_in_use_mb,
    locked_page_allocations_kb / 1024 AS locked_pages_mb,
    total_virtual_address_space_kb / 1024 AS virtual_address_mb,
    process_physical_memory_low,
    process_virtual_memory_low
FROM sys.dm_os_process_memory;

-- Grid 3: I/O per database file (student DB)
SELECT
    DB_NAME(vfs.database_id) AS database_name,
    mf.type_desc,
    mf.name AS file_name,
    mf.physical_name,
    vfs.num_of_reads,
    vfs.num_of_writes,
    vfs.io_stall_read_ms,
    vfs.io_stall_write_ms,
    CASE WHEN vfs.num_of_reads = 0 THEN 0
         ELSE vfs.io_stall_read_ms / vfs.num_of_reads END AS avg_read_stall_ms,
    CASE WHEN vfs.num_of_writes = 0 THEN 0
         ELSE vfs.io_stall_write_ms / vfs.num_of_writes END AS avg_write_stall_ms
FROM sys.dm_io_virtual_file_stats(NULL, NULL) AS vfs
JOIN sys.master_files AS mf
    ON mf.database_id = vfs.database_id
   AND mf.file_id = vfs.file_id
WHERE DB_NAME(vfs.database_id) = @DbName
ORDER BY mf.type_desc, mf.file_id;

-- Grid 4: Active requests count by database
SELECT
    DB_NAME(r.database_id) AS database_name,
    COUNT(*) AS active_requests
FROM sys.dm_exec_requests AS r
WHERE r.session_id <> @@SPID
GROUP BY DB_NAME(r.database_id)
ORDER BY active_requests DESC;
GO

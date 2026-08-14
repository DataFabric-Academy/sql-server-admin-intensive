-- >>> Edit your prefix (T-SQL editor — no SQLCMD mode) <<<
DECLARE @StudentPrefix sysname = N's01';
-- Prefix reserved for lab consistency (wait stats are instance-wide)

-- Top waits (excluding common benign types)
SELECT TOP 15
    wait_type,
    waiting_tasks_count,
    wait_time_ms,
    signal_wait_time_ms,
    CAST(wait_time_ms - signal_wait_time_ms AS bigint) AS resource_wait_ms,
    CASE WHEN waiting_tasks_count = 0 THEN 0
         ELSE wait_time_ms / waiting_tasks_count END AS avg_wait_ms
FROM sys.dm_os_wait_stats
WHERE wait_type NOT LIKE N'SLEEP%'
  AND wait_type NOT LIKE N'LAZYWRITER%'
  AND wait_type NOT LIKE N'REQUEST_FOR%'
  AND wait_type NOT IN (
        N'BROKER_EVENTHANDLER', N'BROKER_RECEIVE_WAITFOR', N'BROKER_TASK_STOP',
        N'BROKER_TO_FLUSH', N'BROKER_TRANSMITTER', N'CHECKPOINT_QUEUE',
        N'CLR_AUTO_EVENT', N'CLR_MANUAL_EVENT', N'DIRTY_PAGE_POLL',
        N'DISPATCHER_QUEUE_SEMAPHORE', N'FT_IFTS_SCHEDULER_IDLE_WAIT',
        N'HADR_FILESTREAM_IOMGR_IOCOMPLETION', N'LOGMGR_QUEUE',
        N'ONDEMAND_TASK_QUEUE', N'PREEMPTIVE_OS_LIBRARYOPS',
        N'PREEMPTIVE_OS_GENERICOPS', N'PREEMPTIVE_OS_FILEOPS',
        N'QDS_PERSIST_TASK_MAIN_LOOP_SLEEP', N'QDS_ASYNC_QUEUE',
        N'RESOURCE_QUEUE', N'SQLTRACE_BUFFER_FLUSH',
        N'SQLTRACE_INCREMENTAL_FLUSH_SLEEP', N'SQLTRACE_WAIT_ENTRIES',
        N'WAITFOR', N'XE_BUFFERMGR_ALLPROCESSED_EVENT',
        N'XE_DISPATCHER_JOIN', N'XE_DISPATCHER_WAIT', N'XE_TIMER_EVENT'
  )
ORDER BY wait_time_ms DESC;

PRINT N'Note: sys.dm_os_wait_stats is cumulative since restart. Compare relative ranking, not absolute values.';
GO

/*
  Lab 03 Step 03 — Tail-Log capture (shared-instance variant)
  Original generic_backup uses CONTINUE_AFTER_ERROR after .mdf crash (instructor demo).
  Students: capture remaining log while database is ONLINE (log file intact).
*/
:setvar StudentPrefix s01
:setvar BackupRoot "D:/SqlLabs/backups"

USE master;
GO

BACKUP LOG [$(StudentPrefix)_AdventureWorks]
TO DISK = N'$(BackupRoot)/$(StudentPrefix)/$(StudentPrefix)_TailLog.bak'
WITH
    NAME = N'Tail-Log Backup',
    STATS = 10,
    FORMAT;
GO

SELECT TOP 1
    database_name, type, backup_start_date, backup_finish_date,
    backup_size / 1024.0 / 1024.0 AS BackupSizeMB
FROM msdb.dbo.backupset
WHERE database_name = N'$(StudentPrefix)_AdventureWorks'
ORDER BY backup_finish_date DESC;
GO

/*
  Instructor demo (after simulated crash / RECOVERY_PENDING):

  BACKUP LOG [sXX_AdventureWorks]
  TO DISK = N'D:\SqlLabs\backups\sXX\sXX_TailLog.bak'
  WITH CONTINUE_AFTER_ERROR, NO_TRUNCATE, FORMAT, STATS = 10;
*/

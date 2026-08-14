/*
  Lab 03 Step 03 — Tail-Log capture (shared-instance variant)
  Original generic_backup uses CONTINUE_AFTER_ERROR after .mdf crash (instructor demo).
  Students: capture remaining log while database is ONLINE (log file intact).
  Edit the DECLARE block only (T-SQL editor — no SQLCMD mode).
*/

-- >>> Edit your prefix (T-SQL editor — no SQLCMD mode) <<<
DECLARE @StudentPrefix sysname = N's01';
DECLARE @BackupRoot nvarchar(260) = N'D:/SqlLabs/backups';
DECLARE @db sysname = @StudentPrefix + N'_AdventureWorks';
DECLARE @tailBak nvarchar(4000) =
    @BackupRoot + N'/' + @StudentPrefix + N'/' + @StudentPrefix + N'_TailLog.bak';
DECLARE @sql nvarchar(max);

USE master;

SET @sql = N'BACKUP LOG ' + QUOTENAME(@db)
    + N' TO DISK = N''' + REPLACE(@tailBak, N'''', N'''''')
    + N''' WITH'
    + N' NAME = N''Tail-Log Backup'','
    + N' STATS = 10,'
    + N' FORMAT;';
EXEC sys.sp_executesql @sql;

SELECT TOP 1
    database_name, type, backup_start_date, backup_finish_date,
    backup_size / 1024.0 / 1024.0 AS BackupSizeMB
FROM msdb.dbo.backupset
WHERE database_name = @db
ORDER BY backup_finish_date DESC;

/*
  Instructor demo (after simulated crash / RECOVERY_PENDING):

  BACKUP LOG [sXX_AdventureWorks]
  TO DISK = N'D:\SqlLabs\backups\sXX\sXX_TailLog.bak'
  WITH CONTINUE_AFTER_ERROR, NO_TRUNCATE, FORMAT, STATS = 10;
*/
GO

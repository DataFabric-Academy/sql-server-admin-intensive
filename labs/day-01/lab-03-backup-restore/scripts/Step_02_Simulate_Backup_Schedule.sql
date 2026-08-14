/*
  Lab 03 Step 02 — adapted from generic_backup/Step_02_Simulate_Backup_Schedule.sql
  Timeline: Full → Logs → Diff → Logs → Diff+IT Auditor → Logs → UPDATE Person (not backed up)
  Edit the DECLARE block only (T-SQL editor — no SQLCMD mode).
*/

-- >>> Edit your prefix (T-SQL editor — no SQLCMD mode) <<<
DECLARE @StudentPrefix sysname = N's01';
DECLARE @BackupRoot nvarchar(260) = N'D:/SqlLabs/backups';
DECLARE @db sysname = @StudentPrefix + N'_AdventureWorks';
DECLARE @bak nvarchar(4000) =
    @BackupRoot + N'/' + @StudentPrefix + N'/' + @StudentPrefix + N'_myDevice.bak';
DECLARE @disk nvarchar(max) = N'N''' + REPLACE(@bak, N'''', N'''''') + N'''';
DECLARE @sql nvarchar(max);

USE master;

-- Saturday 22:00 — Full (File #1)
SET @sql = N'BACKUP DATABASE ' + QUOTENAME(@db)
    + N' TO DISK = ' + @disk
    + N' WITH FORMAT, INIT, MEDIANAME = N''My Media'', NAME = N''Full Backup'', STATS = 10;';
EXEC sys.sp_executesql @sql;

-- Monday 09-11 — Log backups (#2-4)
SET @sql = N'BACKUP LOG ' + QUOTENAME(@db)
    + N' TO DISK = ' + @disk
    + N' WITH MEDIANAME = N''My Media'';';
EXEC sys.sp_executesql @sql;
WAITFOR DELAY '00:00:03';
EXEC sys.sp_executesql @sql;
WAITFOR DELAY '00:00:03';
EXEC sys.sp_executesql @sql;

-- Monday 22:00 — Differential (#5)
SET @sql = N'BACKUP DATABASE ' + QUOTENAME(@db)
    + N' TO DISK = ' + @disk
    + N' WITH DIFFERENTIAL, MEDIANAME = N''My Media'';';
EXEC sys.sp_executesql @sql;

-- Tuesday 09-11 — Log backups (#6-8)
SET @sql = N'BACKUP LOG ' + QUOTENAME(@db)
    + N' TO DISK = ' + @disk
    + N' WITH MEDIANAME = N''My Media'';';
EXEC sys.sp_executesql @sql;
WAITFOR DELAY '00:00:03';
EXEC sys.sp_executesql @sql;
WAITFOR DELAY '00:00:03';
EXEC sys.sp_executesql @sql;

-- Tuesday 22:00 — Diff + IT Auditor (#9)
SET @sql = N'
USE ' + QUOTENAME(@db) + N';

INSERT INTO Person.ContactType (Name, ModifiedDate)
SELECT N''IT Auditor'', GETDATE()
WHERE NOT EXISTS (SELECT 1 FROM Person.ContactType WHERE Name = N''IT Auditor'');
';
EXEC sys.sp_executesql @sql;

SET @sql = N'BACKUP DATABASE ' + QUOTENAME(@db)
    + N' TO DISK = ' + @disk
    + N' WITH DIFFERENTIAL, MEDIANAME = N''My Media'';';
EXEC sys.sp_executesql @sql;

-- Wednesday 09-10 — Log backups (#10-11) last scheduled
SET @sql = N'BACKUP LOG ' + QUOTENAME(@db)
    + N' TO DISK = ' + @disk
    + N' WITH MEDIANAME = N''My Media'';';
EXEC sys.sp_executesql @sql;
WAITFOR DELAY '00:00:03';
EXEC sys.sp_executesql @sql;

-- Wednesday 12:14 — Critical UPDATE (NOT in backup yet)
SET @sql = N'
USE ' + QUOTENAME(@db) + N';
UPDATE Person.Person SET ModifiedDate = GETDATE();
';
EXEC sys.sp_executesql @sql;

PRINT N'Critical UPDATE applied. Run Step_03 before any new log backup overwrites the scenario.';
GO

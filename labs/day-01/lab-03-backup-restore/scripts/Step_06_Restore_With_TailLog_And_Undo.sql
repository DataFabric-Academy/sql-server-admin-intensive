/*
  Lab 03 Step 06 (Optional/Advanced) — Tail-log with NORECOVERY then manual RECOVERY
  Adapted from generic_backup/Step_06_Restore_With_TailLog_And_Undo.sql (simplified)
*/
:setvar StudentPrefix s01
:setvar BackupRoot "D:/SqlLabs/backups"
:setvar DataPath D:\SqlLabs\data
:setvar LogPath D:\SqlLabs\logs

USE master;
GO

DECLARE @restoreDb sysname = N'$(StudentPrefix)_AdventureWorks_Restore';
DECLARE @sql nvarchar(max);

IF DB_ID(@restoreDb) IS NOT NULL
BEGIN
    SET @sql = N'ALTER DATABASE ' + QUOTENAME(@restoreDb)
             + N' SET SINGLE_USER WITH ROLLBACK IMMEDIATE; DROP DATABASE ' + QUOTENAME(@restoreDb) + N';';
    EXEC sys.sp_executesql @sql;
END
GO

RESTORE DATABASE [$(StudentPrefix)_AdventureWorks_Restore]
FROM DISK = N'$(BackupRoot)/$(StudentPrefix)/$(StudentPrefix)_myDevice.bak'
WITH FILE = 1, NORECOVERY, REPLACE,
     MOVE N'AdventureWorks' TO N'$(DataPath)\$(StudentPrefix)_AdventureWorks_Restore.mdf',
     MOVE N'AdventureWorks_Log' TO N'$(LogPath)\$(StudentPrefix)_AdventureWorks_Restore_log.ldf',
     STATS = 10;
GO

RESTORE DATABASE [$(StudentPrefix)_AdventureWorks_Restore]
FROM DISK = N'$(BackupRoot)/$(StudentPrefix)/$(StudentPrefix)_myDevice.bak'
WITH FILE = 9, NORECOVERY, STATS = 10;
GO

RESTORE LOG [$(StudentPrefix)_AdventureWorks_Restore]
FROM DISK = N'$(BackupRoot)/$(StudentPrefix)/$(StudentPrefix)_myDevice.bak'
WITH FILE = 10, NORECOVERY;
GO

RESTORE LOG [$(StudentPrefix)_AdventureWorks_Restore]
FROM DISK = N'$(BackupRoot)/$(StudentPrefix)/$(StudentPrefix)_myDevice.bak'
WITH FILE = 11, NORECOVERY;
GO

-- Tail-log leaves DB in RESTORING — inspect before final recovery
RESTORE LOG [$(StudentPrefix)_AdventureWorks_Restore]
FROM DISK = N'$(BackupRoot)/$(StudentPrefix)/$(StudentPrefix)_TailLog.bak'
WITH NORECOVERY;
GO

SELECT name, state_desc FROM sys.databases WHERE name = N'$(StudentPrefix)_AdventureWorks_Restore';
GO

-- Finalize when ready
RESTORE DATABASE [$(StudentPrefix)_AdventureWorks_Restore] WITH RECOVERY;
GO

SELECT name, state_desc FROM sys.databases WHERE name = N'$(StudentPrefix)_AdventureWorks_Restore';
GO

/*
  Lab 03 Step 05 — Restore WITH tail-log → zero data loss (recommended)
  Adapted from generic_backup/Step_05_Restore_With_TailLog.sql
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

RESTORE LOG [$(StudentPrefix)_AdventureWorks_Restore]
FROM DISK = N'$(BackupRoot)/$(StudentPrefix)/$(StudentPrefix)_TailLog.bak'
WITH RECOVERY;
GO

SELECT name, state_desc FROM sys.databases WHERE name = N'$(StudentPrefix)_AdventureWorks_Restore';
GO

USE [$(StudentPrefix)_AdventureWorks_Restore];

SELECT ContactTypeID, Name, ModifiedDate
FROM Person.ContactType
WHERE Name = N'IT Auditor';

SELECT COUNT(*) AS PersonRowsUpdatedToday
FROM Person.Person
WHERE CAST(ModifiedDate AS DATE) = CAST(GETDATE() AS DATE);

SELECT TOP 5 BusinessEntityID, FirstName, LastName, ModifiedDate
FROM Person.Person
ORDER BY BusinessEntityID;
GO

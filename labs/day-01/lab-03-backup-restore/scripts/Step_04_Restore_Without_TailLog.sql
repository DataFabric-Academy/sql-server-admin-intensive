/*
  Lab 03 Step 04 (Optional) — Restore WITHOUT tail-log → data loss
  Restores to $(StudentPrefix)_AdventureWorks_Restore for shared-instance safety.
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
WITH FILE = 11, RECOVERY;
GO

USE [$(StudentPrefix)_AdventureWorks_Restore];
SELECT N'IT Auditor exists?' AS CheckName,
       CASE WHEN EXISTS (SELECT 1 FROM Person.ContactType WHERE Name = N'IT Auditor') THEN N'YES' ELSE N'NO' END AS Result;
SELECT COUNT(*) AS PersonRowsUpdatedToday
FROM Person.Person
WHERE CAST(ModifiedDate AS DATE) = CAST(GETDATE() AS DATE);
GO

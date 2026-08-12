/*
  Lab 03 Step 02 — adapted from generic_backup/Step_02_Simulate_Backup_Schedule.sql
  Timeline: Full → Logs → Diff → Logs → Diff+IT Auditor → Logs → UPDATE Person (not backed up)
*/
:setvar StudentPrefix s01
:setvar BackupRoot "D:/SqlLabs/backups"

USE master;
GO

-- Saturday 22:00 — Full (File #1)
BACKUP DATABASE [$(StudentPrefix)_AdventureWorks]
TO DISK = N'$(BackupRoot)/$(StudentPrefix)/$(StudentPrefix)_myDevice.bak'
WITH FORMAT, INIT, MEDIANAME = N'My Media', NAME = N'Full Backup', STATS = 10;
GO

-- Monday 09-11 — Log backups (#2-4)
BACKUP LOG [$(StudentPrefix)_AdventureWorks] TO DISK = N'$(BackupRoot)/$(StudentPrefix)/$(StudentPrefix)_myDevice.bak' WITH MEDIANAME = N'My Media';
WAITFOR DELAY '00:00:03';
BACKUP LOG [$(StudentPrefix)_AdventureWorks] TO DISK = N'$(BackupRoot)/$(StudentPrefix)/$(StudentPrefix)_myDevice.bak' WITH MEDIANAME = N'My Media';
WAITFOR DELAY '00:00:03';
BACKUP LOG [$(StudentPrefix)_AdventureWorks] TO DISK = N'$(BackupRoot)/$(StudentPrefix)/$(StudentPrefix)_myDevice.bak' WITH MEDIANAME = N'My Media';
GO

-- Monday 22:00 — Differential (#5)
BACKUP DATABASE [$(StudentPrefix)_AdventureWorks]
TO DISK = N'$(BackupRoot)/$(StudentPrefix)/$(StudentPrefix)_myDevice.bak'
WITH DIFFERENTIAL, MEDIANAME = N'My Media';
GO

-- Tuesday 09-11 — Log backups (#6-8)
BACKUP LOG [$(StudentPrefix)_AdventureWorks] TO DISK = N'$(BackupRoot)/$(StudentPrefix)/$(StudentPrefix)_myDevice.bak' WITH MEDIANAME = N'My Media';
WAITFOR DELAY '00:00:03';
BACKUP LOG [$(StudentPrefix)_AdventureWorks] TO DISK = N'$(BackupRoot)/$(StudentPrefix)/$(StudentPrefix)_myDevice.bak' WITH MEDIANAME = N'My Media';
WAITFOR DELAY '00:00:03';
BACKUP LOG [$(StudentPrefix)_AdventureWorks] TO DISK = N'$(BackupRoot)/$(StudentPrefix)/$(StudentPrefix)_myDevice.bak' WITH MEDIANAME = N'My Media';
GO

-- Tuesday 22:00 — Diff + IT Auditor (#9)
USE [$(StudentPrefix)_AdventureWorks];
GO

INSERT INTO Person.ContactType (Name, ModifiedDate)
SELECT N'IT Auditor', GETDATE()
WHERE NOT EXISTS (SELECT 1 FROM Person.ContactType WHERE Name = N'IT Auditor');
GO

USE master;
GO

BACKUP DATABASE [$(StudentPrefix)_AdventureWorks]
TO DISK = N'$(BackupRoot)/$(StudentPrefix)/$(StudentPrefix)_myDevice.bak'
WITH DIFFERENTIAL, MEDIANAME = N'My Media';
GO

-- Wednesday 09-10 — Log backups (#10-11) last scheduled
BACKUP LOG [$(StudentPrefix)_AdventureWorks] TO DISK = N'$(BackupRoot)/$(StudentPrefix)/$(StudentPrefix)_myDevice.bak' WITH MEDIANAME = N'My Media';
WAITFOR DELAY '00:00:03';
BACKUP LOG [$(StudentPrefix)_AdventureWorks] TO DISK = N'$(BackupRoot)/$(StudentPrefix)/$(StudentPrefix)_myDevice.bak' WITH MEDIANAME = N'My Media';
GO

-- Wednesday 12:14 — Critical UPDATE (NOT in backup yet)
USE [$(StudentPrefix)_AdventureWorks];
GO

UPDATE Person.Person SET ModifiedDate = GETDATE();
GO

PRINT N'Critical UPDATE applied. Run Step_03 before any new log backup overwrites the scenario.';
GO

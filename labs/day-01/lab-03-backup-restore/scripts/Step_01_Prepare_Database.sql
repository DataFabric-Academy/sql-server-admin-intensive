/*

  Lab 03 Step 01 — Prepare database for backup lab (shared-instance safe)

  Uses DISK paths directly — students do not need sp_addumpdevice (sysadmin).

*/

:setvar StudentPrefix s01

:setvar BackupRoot "D:/SqlLabs/backups"



USE master;

GO



ALTER DATABASE [$(StudentPrefix)_AdventureWorks] SET RECOVERY FULL WITH NO_WAIT;

GO



SELECT name, recovery_model_desc, state_desc

FROM sys.databases

WHERE name = N'$(StudentPrefix)_AdventureWorks';



PRINT N'Backup path: $(BackupRoot)/$(StudentPrefix)/$(StudentPrefix)_myDevice.bak';

GO


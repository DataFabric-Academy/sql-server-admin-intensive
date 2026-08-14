/*
  Lab 03 Step 01 — Prepare database for backup lab (shared-instance safe)

  Uses DISK paths directly — students do not need sp_addumpdevice (sysadmin).
  Edit the DECLARE block only (T-SQL editor — no SQLCMD mode).
*/

-- >>> Edit your prefix (T-SQL editor — no SQLCMD mode) <<<
DECLARE @StudentPrefix sysname = N's01';
DECLARE @BackupRoot nvarchar(260) = N'D:/SqlLabs/backups';
DECLARE @db sysname = @StudentPrefix + N'_AdventureWorks';
DECLARE @bak nvarchar(4000) =
    @BackupRoot + N'/' + @StudentPrefix + N'/' + @StudentPrefix + N'_myDevice.bak';
DECLARE @sql nvarchar(max);

USE master;

SET @sql = N'ALTER DATABASE ' + QUOTENAME(@db)
    + N' SET RECOVERY FULL WITH NO_WAIT;';
EXEC sys.sp_executesql @sql;

SELECT name, recovery_model_desc, state_desc
FROM sys.databases
WHERE name = @db;

PRINT N'Backup path: ' + @bak;
GO

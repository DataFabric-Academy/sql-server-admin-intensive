/*
  Lab 03 Step 05 — Restore WITH tail-log → zero data loss (recommended)
  Adapted from generic_backup/Step_05_Restore_With_TailLog.sql
  Edit the DECLARE block only (T-SQL editor — no SQLCMD mode).
*/

-- >>> Edit your prefix (T-SQL editor — no SQLCMD mode) <<<
DECLARE @StudentPrefix sysname = N's01';
DECLARE @BackupRoot nvarchar(260) = N'D:/SqlLabs/backups';
DECLARE @DataPath nvarchar(260) = N'D:\SqlLabs\data';
DECLARE @LogPath nvarchar(260) = N'D:\SqlLabs\logs';

DECLARE @restoreDb sysname = @StudentPrefix + N'_AdventureWorks_Restore';
DECLARE @bak nvarchar(4000) =
    @BackupRoot + N'/' + @StudentPrefix + N'/' + @StudentPrefix + N'_myDevice.bak';
DECLARE @tailBak nvarchar(4000) =
    @BackupRoot + N'/' + @StudentPrefix + N'/' + @StudentPrefix + N'_TailLog.bak';
DECLARE @mdf nvarchar(4000) =
    @DataPath + N'\' + @StudentPrefix + N'_AdventureWorks_Restore.mdf';
DECLARE @ldf nvarchar(4000) =
    @LogPath + N'\' + @StudentPrefix + N'_AdventureWorks_Restore_log.ldf';
DECLARE @sql nvarchar(max);

USE master;

IF DB_ID(@restoreDb) IS NOT NULL
BEGIN
    SET @sql = N'ALTER DATABASE ' + QUOTENAME(@restoreDb)
             + N' SET SINGLE_USER WITH ROLLBACK IMMEDIATE; DROP DATABASE '
             + QUOTENAME(@restoreDb) + N';';
    EXEC sys.sp_executesql @sql;
END

SET @sql = N'RESTORE DATABASE ' + QUOTENAME(@restoreDb)
    + N' FROM DISK = N''' + REPLACE(@bak, N'''', N'''''')
    + N''' WITH FILE = 1, NORECOVERY, REPLACE,'
    + N' MOVE N''AdventureWorks'' TO N''' + REPLACE(@mdf, N'''', N'''''') + N''','
    + N' MOVE N''AdventureWorks_Log'' TO N''' + REPLACE(@ldf, N'''', N'''''') + N''','
    + N' STATS = 10;';
EXEC sys.sp_executesql @sql;

SET @sql = N'RESTORE DATABASE ' + QUOTENAME(@restoreDb)
    + N' FROM DISK = N''' + REPLACE(@bak, N'''', N'''''')
    + N''' WITH FILE = 9, NORECOVERY, STATS = 10;';
EXEC sys.sp_executesql @sql;

SET @sql = N'RESTORE LOG ' + QUOTENAME(@restoreDb)
    + N' FROM DISK = N''' + REPLACE(@bak, N'''', N'''''')
    + N''' WITH FILE = 10, NORECOVERY;';
EXEC sys.sp_executesql @sql;

SET @sql = N'RESTORE LOG ' + QUOTENAME(@restoreDb)
    + N' FROM DISK = N''' + REPLACE(@bak, N'''', N'''''')
    + N''' WITH FILE = 11, NORECOVERY;';
EXEC sys.sp_executesql @sql;

SET @sql = N'RESTORE LOG ' + QUOTENAME(@restoreDb)
    + N' FROM DISK = N''' + REPLACE(@tailBak, N'''', N'''''')
    + N''' WITH RECOVERY;';
EXEC sys.sp_executesql @sql;

SELECT name, state_desc FROM sys.databases WHERE name = @restoreDb;

SET @sql = N'
USE ' + QUOTENAME(@restoreDb) + N';

SELECT ContactTypeID, Name, ModifiedDate
FROM Person.ContactType
WHERE Name = N''IT Auditor'';

SELECT COUNT(*) AS PersonRowsUpdatedToday
FROM Person.Person
WHERE CAST(ModifiedDate AS DATE) = CAST(GETDATE() AS DATE);

SELECT TOP 5 BusinessEntityID, FirstName, LastName, ModifiedDate
FROM Person.Person
ORDER BY BusinessEntityID;
';
EXEC sys.sp_executesql @sql;
GO

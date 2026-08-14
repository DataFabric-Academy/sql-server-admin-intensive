/*
  Lab 03 Step 04 (Optional) — Restore WITHOUT tail-log → data loss
  Restores to {prefix}_AdventureWorks_Restore for shared-instance safety.
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
    + N''' WITH FILE = 11, RECOVERY;';
EXEC sys.sp_executesql @sql;

SET @sql = N'
USE ' + QUOTENAME(@restoreDb) + N';

SELECT N''IT Auditor exists?'' AS CheckName,
       CASE WHEN EXISTS (SELECT 1 FROM Person.ContactType WHERE Name = N''IT Auditor'')
            THEN N''YES'' ELSE N''NO'' END AS Result;

SELECT COUNT(*) AS PersonRowsUpdatedToday
FROM Person.Person
WHERE CAST(ModifiedDate AS DATE) = CAST(GETDATE() AS DATE);
';
EXEC sys.sp_executesql @sql;
GO

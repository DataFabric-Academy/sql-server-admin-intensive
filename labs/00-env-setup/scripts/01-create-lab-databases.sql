/*
  Instructor setup: restore per-student sample databases from shared backups.
  Source: D:\Setupfiles\AdventureWorks.bak, D:\Setupfiles\TSQL1.bak
  Target: s01_AdventureWorks, s01_TSQL (TSQL1.bak restores database logical name "TSQL")
*/

USE master;
GO

DECLARE @StudentCount int = 20;
DECLARE @i int = 1;
DECLARE @prefix sysname;
DECLARE @awDb sysname;
DECLARE @tsqlDb sysname;
DECLARE @sql nvarchar(max);
DECLARE @dataPath nvarchar(260) = N'D:\SqlLabs\data\';
DECLARE @logPath nvarchar(260) = N'D:\SqlLabs\logs\';
DECLARE @awBak nvarchar(260) = N'D:\Setupfiles\AdventureWorks.bak';
DECLARE @tsqlBak nvarchar(260) = N'D:\Setupfiles\TSQL1.bak';

WHILE @i <= @StudentCount
BEGIN
    SET @prefix = N's' + RIGHT(N'0' + CAST(@i AS nvarchar(10)), 2);
    SET @awDb = @prefix + N'_AdventureWorks';
    SET @tsqlDb = @prefix + N'_TSQL';

    IF DB_ID(@awDb) IS NULL
    BEGIN
        SET @sql = N'
RESTORE DATABASE ' + QUOTENAME(@awDb) + N'
FROM DISK = N''' + @awBak + N'''
WITH
    MOVE N''AdventureWorks'' TO N''' + @dataPath + @awDb + N'.mdf'',
    MOVE N''AdventureWorks_Log'' TO N''' + @logPath + @awDb + N'_log.ldf'',
    RECOVERY,
    STATS = 10;';
        EXEC sys.sp_executesql @sql;
        PRINT N'Restored ' + @awDb;
    END
    ELSE
        PRINT N'Skip existing ' + @awDb;

    IF DB_ID(@tsqlDb) IS NULL
    BEGIN
        SET @sql = N'
RESTORE DATABASE ' + QUOTENAME(@tsqlDb) + N'
FROM DISK = N''' + @tsqlBak + N'''
WITH
    MOVE N''TSQL'' TO N''' + @dataPath + @tsqlDb + N'.mdf'',
    MOVE N''TSQL_log'' TO N''' + @logPath + @tsqlDb + N'_log.ldf'',
    RECOVERY,
    STATS = 10;';
        EXEC sys.sp_executesql @sql;
        PRINT N'Restored ' + @tsqlDb;
    END
    ELSE
        PRINT N'Skip existing ' + @tsqlDb;

    SET @sql = N'ALTER DATABASE ' + QUOTENAME(@awDb) + N' SET RECOVERY FULL;';
    EXEC sys.sp_executesql @sql;

    SET @sql = N'
USE ' + QUOTENAME(@awDb) + N';
IF OBJECT_ID(N''dbo.LabAudit'', N''U'') IS NULL
BEGIN
    CREATE TABLE dbo.LabAudit (
        AuditID int IDENTITY(1,1) PRIMARY KEY,
        Note nvarchar(200) NOT NULL,
        CreatedAt datetime2(0) NOT NULL CONSTRAINT DF_LabAudit_CreatedAt DEFAULT SYSUTCDATETIME()
    );
END
';
    EXEC sys.sp_executesql @sql;

    SET @i += 1;
END
GO

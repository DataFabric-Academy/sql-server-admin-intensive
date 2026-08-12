/*
  Reset s01 lab artifacts for clean validation (sysadmin only).
*/
USE master;
GO

-- Drop XEvent sessions
DECLARE @name sysname, @sql nvarchar(max);
DECLARE c CURSOR LOCAL FAST_FORWARD FOR
    SELECT name FROM sys.server_event_sessions WHERE name LIKE N's01_%';
OPEN c;
FETCH NEXT FROM c INTO @name;
WHILE @@FETCH_STATUS = 0
BEGIN
    SET @sql = N'ALTER EVENT SESSION ' + QUOTENAME(@name) + N' ON SERVER STATE = STOP; DROP EVENT SESSION ' + QUOTENAME(@name) + N' ON SERVER;';
    BEGIN TRY EXEC(@sql); END TRY BEGIN CATCH PRINT ERROR_MESSAGE(); END CATCH;
    FETCH NEXT FROM c INTO @name;
END
CLOSE c; DEALLOCATE c;
GO

-- Drop DBs (including stuck restoring)
DECLARE @db sysname, @sql nvarchar(max);
DECLARE d CURSOR LOCAL FAST_FORWARD FOR
    SELECT name FROM sys.databases WHERE name LIKE N's01_%';
OPEN d;
FETCH NEXT FROM d INTO @db;
WHILE @@FETCH_STATUS = 0
BEGIN
    BEGIN TRY
        SET @sql = N'ALTER DATABASE ' + QUOTENAME(@db) + N' SET SINGLE_USER WITH ROLLBACK IMMEDIATE; DROP DATABASE ' + QUOTENAME(@db) + N';';
        EXEC(@sql);
    END TRY
    BEGIN CATCH
        BEGIN TRY
            SET @sql = N'DROP DATABASE ' + QUOTENAME(@db) + N';';
            EXEC(@sql);
        END TRY
        BEGIN CATCH PRINT ERROR_MESSAGE(); END CATCH
    END CATCH
    FETCH NEXT FROM d INTO @db;
END
CLOSE d; DEALLOCATE d;
GO

IF EXISTS (SELECT 1 FROM sys.server_principals WHERE name = N's01_tester')
    DROP LOGIN [s01_tester];
GO

USE msdb;
GO
BEGIN TRY EXEC dbo.sp_delete_job @job_name = N's01_Backup_AdventureWorks', @delete_unused_schedule = 1; END TRY BEGIN CATCH END CATCH;
BEGIN TRY EXEC dbo.sp_delete_alert @name = N's01_Lab04_Alert'; END TRY BEGIN CATCH END CATCH;
WHILE EXISTS (SELECT 1 FROM dbo.sysschedules WHERE name LIKE N's01_%')
BEGIN
    DECLARE @sid int = (SELECT MIN(schedule_id) FROM dbo.sysschedules WHERE name LIKE N's01_%');
    EXEC dbo.sp_delete_schedule @schedule_id = @sid, @force_delete = 1;
END
GO
EXEC msdb.dbo.sp_delete_database_backuphistory @database_name = N's01_AdventureWorks';
EXEC msdb.dbo.sp_delete_database_backuphistory @database_name = N's01_AdventureWorks_Restore';
GO

USE master;
GO
EXEC sp_configure 'show advanced options', 1; RECONFIGURE;
EXEC sp_configure 'xp_cmdshell', 1; RECONFIGURE;
GO
EXEC xp_cmdshell 'del /Q D:\SqlLabs\backups\s01\*.* 2>nul & del /Q D:\SqlLabs\xevents\s01\*.* 2>nul & del /Q D:\SqlLabs\workload\s01\*.* 2>nul';
GO
EXEC sp_configure 'xp_cmdshell', 0; RECONFIGURE;
EXEC sp_configure 'show advanced options', 0; RECONFIGURE;
GO
PRINT N's01 reset complete';
GO

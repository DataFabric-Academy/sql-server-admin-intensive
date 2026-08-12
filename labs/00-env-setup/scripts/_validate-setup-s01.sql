/*
  One-time validation setup for s01 on shared lab server.
  Instructor/sysadmin only — not for students.
*/
USE master;
GO

-- Folders (requires xp_cmdshell — enable temporarily if needed)
EXEC sp_configure 'show advanced options', 1; RECONFIGURE;
EXEC sp_configure 'xp_cmdshell', 1; RECONFIGURE;
GO

EXEC xp_cmdshell 'mkdir D:\SqlLabs\data 2>nul & mkdir D:\SqlLabs\logs 2>nul & mkdir D:\SqlLabs\backups\s01 2>nul & mkdir D:\SqlLabs\xevents\s01 2>nul & mkdir D:\SqlLabs\workload\s01 2>nul';
GO

IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = N's01')
    CREATE LOGIN [s01] WITH PASSWORD = N'ChangeMe!Lab01', CHECK_POLICY = ON, CHECK_EXPIRATION = OFF;
GO

IF DB_ID(N's01_AdventureWorks') IS NULL
BEGIN
    RESTORE DATABASE [s01_AdventureWorks]
    FROM DISK = N'D:\Setupfiles\AdventureWorks.bak'
    WITH
        MOVE N'AdventureWorks' TO N'D:\SqlLabs\data\s01_AdventureWorks.mdf',
        MOVE N'AdventureWorks_Log' TO N'D:\SqlLabs\logs\s01_AdventureWorks_log.ldf',
        RECOVERY, STATS = 5;
END
GO

IF DB_ID(N's01_TSQL') IS NULL
BEGIN
    RESTORE DATABASE [s01_TSQL]
    FROM DISK = N'D:\Setupfiles\TSQL1.bak'
    WITH
        MOVE N'TSQL' TO N'D:\SqlLabs\data\s01_TSQL.mdf',
        MOVE N'TSQL_log' TO N'D:\SqlLabs\logs\s01_TSQL_log.ldf',
        RECOVERY, STATS = 5;
END
GO

ALTER DATABASE [s01_AdventureWorks] SET RECOVERY FULL;
GO

USE [s01_AdventureWorks];
IF OBJECT_ID(N'dbo.LabAudit', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.LabAudit (
        AuditID int IDENTITY(1,1) PRIMARY KEY,
        Note nvarchar(200) NOT NULL,
        CreatedAt datetime2(0) NOT NULL CONSTRAINT DF_LabAudit_CreatedAt DEFAULT SYSUTCDATETIME()
    );
END
GO

USE master;
GRANT CREATE ANY DATABASE TO [s01];
GRANT VIEW SERVER STATE TO [s01];
GRANT VIEW ANY DEFINITION TO [s01];
GRANT ALTER ANY EVENT SESSION TO [s01];
GO

USE [s01_AdventureWorks];
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = N's01')
    CREATE USER [s01] FOR LOGIN [s01];
ALTER ROLE db_owner ADD MEMBER [s01];
GO

USE [s01_TSQL];
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = N's01')
    CREATE USER [s01] FOR LOGIN [s01];
ALTER ROLE db_owner ADD MEMBER [s01];
GO

USE msdb;
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = N's01')
    CREATE USER [s01] FOR LOGIN [s01];
ALTER ROLE SQLAgentUserRole ADD MEMBER [s01];
ALTER ROLE SQLAgentReaderRole ADD MEMBER [s01];
ALTER ROLE SQLAgentOperatorRole ADD MEMBER [s01];
GO

IF NOT EXISTS (SELECT 1 FROM sys.messages WHERE message_id = 51001 AND language_id = 1033)
    EXEC sp_addmessage @msgnum = 51001, @severity = 16,
        @msgtext = N'Lab04 alert triggered by %s (%s)', @lang = N'us_english', @with_log = N'true';
GO

EXEC sp_configure 'xp_cmdshell', 0; RECONFIGURE;
EXEC sp_configure 'show advanced options', 0; RECONFIGURE;
GO

PRINT N's01 validation setup complete';
GO

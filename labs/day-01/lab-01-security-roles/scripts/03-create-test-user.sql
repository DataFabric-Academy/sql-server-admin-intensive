/*
  Creates a SQL login/user for permission testing.
  Requires ALTER ANY LOGIN (instructor may run this for the class).
*/
:setvar StudentPrefix s01

USE master;
GO

IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = N'$(StudentPrefix)_tester')
BEGIN
    CREATE LOGIN [$(StudentPrefix)_tester]
        WITH PASSWORD = N'ChangeMe!Tester01',
             CHECK_POLICY = ON,
             CHECK_EXPIRATION = OFF;
END
GO

USE [$(StudentPrefix)_AdventureWorks];
GO

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = N'$(StudentPrefix)_tester')
    CREATE USER [$(StudentPrefix)_tester] FOR LOGIN [$(StudentPrefix)_tester];
GO

IF EXISTS (
    SELECT 1 FROM sys.database_principals
    WHERE name = N'$(StudentPrefix)_HRUsers' AND type = 'R'
)
    ALTER ROLE [$(StudentPrefix)_HRUsers] ADD MEMBER [$(StudentPrefix)_tester];
GO

PRINT N'Test user $(StudentPrefix)_tester is ready';
GO

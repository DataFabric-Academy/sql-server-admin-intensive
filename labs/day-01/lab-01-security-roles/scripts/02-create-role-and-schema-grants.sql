:setvar StudentPrefix s01

USE [$(StudentPrefix)_AdventureWorks];
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.database_principals
    WHERE name = N'$(StudentPrefix)_HRUsers' AND type = 'R'
)
    CREATE ROLE [$(StudentPrefix)_HRUsers];
GO

GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::HumanResources TO [$(StudentPrefix)_HRUsers];
GRANT SELECT ON SCHEMA::Sales TO [$(StudentPrefix)_HRUsers];
GO

PRINT N'Role and schema grants applied for $(StudentPrefix)_HRUsers';
GO

:setvar StudentPrefix s01

SELECT
    SUSER_SNAME() AS current_login,
    ORIGINAL_LOGIN() AS original_login,
    DB_NAME() AS current_db;

USE [$(StudentPrefix)_AdventureWorks];
GO

SELECT name AS db_user, type_desc, authentication_type_desc
FROM sys.database_principals
WHERE name = N'$(StudentPrefix)' OR name = SUSER_SNAME();
GO

SELECT s.name AS schema_name, o.name AS table_name
FROM sys.tables o
JOIN sys.schemas s ON o.schema_id = s.schema_id
WHERE s.name IN (N'HumanResources', N'Sales')
ORDER BY s.name, o.name;
GO

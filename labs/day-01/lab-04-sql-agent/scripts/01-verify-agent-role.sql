/*
  Lab 04 — verify SQLAgent* role membership
  Run in normal T-SQL editor (no SQLCMD mode).
*/
SELECT SUSER_SNAME() AS login_name;

USE msdb;
GO

SELECT r.name AS role_name, m.name AS member_name
FROM sys.database_role_members rm
JOIN sys.database_principals r ON rm.role_principal_id = r.principal_id
JOIN sys.database_principals m ON rm.member_principal_id = m.principal_id
WHERE m.name = SUSER_SNAME()
  AND r.name LIKE N'SQLAgent%';
GO

-- Agent service status (requires VIEW SERVER STATE; may be empty for students)
SELECT servicename, status_desc
FROM sys.dm_server_services
WHERE servicename LIKE N'SQL Server Agent%';
GO

:setvar StudentPrefix s01
:setvar BcpRoot "D:/SqlLabs/workload"

/*
  Scenario E — Light BCP (optional, run from cmd/PowerShell on machine with bcp.exe)

  Prerequisites:
  - Folder D:\SqlLabs\workload\$(StudentPrefix)\ exists (instructor may create)
  - Table Employees exists in $(StudentPrefix)_TSQL (standard TSQL1.bak sample)

  Step 1 — Export (run in cmd, replace server/login/password):
  bcp "SELECT TOP 100 EmployeeID, LastName, FirstName FROM $(StudentPrefix)_TSQL.dbo.Employees" queryout "$(BcpRoot)\$(StudentPrefix)\employees.dat" -S <server>,1433 -U $(StudentPrefix) -P <password> -c -t"|"

  Step 2 — Create staging table (run in SSMS):
*/
USE [$(StudentPrefix)_TSQL];
GO

IF OBJECT_ID(N'dbo.Employees_BcpStaging', N'U') IS NOT NULL
    DROP TABLE dbo.Employees_BcpStaging;
GO

CREATE TABLE dbo.Employees_BcpStaging
(
    EmployeeID int NOT NULL,
    LastName nvarchar(50) NOT NULL,
    FirstName nvarchar(50) NOT NULL
);
GO

/*
  Step 3 — Import:
  bcp $(StudentPrefix)_TSQL.dbo.Employees_BcpStaging in "$(BcpRoot)\$(StudentPrefix)\employees.dat" -S <server>,1433 -U $(StudentPrefix) -P <password> -c -t"|"
*/

-- Verify row count
SELECT COUNT(*) AS imported_rows FROM dbo.Employees_BcpStaging;
GO

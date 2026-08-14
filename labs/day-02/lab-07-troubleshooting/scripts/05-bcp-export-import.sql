-- >>> Edit your prefix (T-SQL editor — no SQLCMD mode) <<<
DECLARE @StudentPrefix sysname = N's01';
DECLARE @BcpRoot nvarchar(260) = N'D:/SqlLabs/workload';
DECLARE @DbName sysname = @StudentPrefix + N'_TSQL';
DECLARE @outFile nvarchar(400) = @BcpRoot + N'\' + @StudentPrefix + N'\employees.dat';
DECLARE @sql nvarchar(max);

/*
  Scenario E — Light BCP (optional, run from cmd/PowerShell on machine with bcp.exe)

  Prerequisites:
  - Folder D:\SqlLabs\workload\<prefix>\ exists (instructor may create)
  - Table Employees exists in <prefix>_TSQL (standard TSQL1.bak sample)
*/

-- Step 1 — Export (copy printed command to cmd; replace server/password):
PRINT N'bcp "SELECT TOP 100 EmployeeID, LastName, FirstName FROM '
    + @DbName + N'.dbo.Employees" queryout "'
    + @outFile + N'" -S <server>,1433 -U ' + @StudentPrefix + N' -P <password> -c -t"|"';

-- Step 2 — Create staging table
SET @sql = N'USE ' + QUOTENAME(@DbName) + N';
IF OBJECT_ID(N''dbo.Employees_BcpStaging'', N''U'') IS NOT NULL
    DROP TABLE dbo.Employees_BcpStaging;

CREATE TABLE dbo.Employees_BcpStaging
(
    EmployeeID int NOT NULL,
    LastName nvarchar(50) NOT NULL,
    FirstName nvarchar(50) NOT NULL
);';
EXEC sys.sp_executesql @sql;

-- Step 3 — Import (copy printed command to cmd after export):
PRINT N'bcp ' + @DbName + N'.dbo.Employees_BcpStaging in "'
    + @outFile + N'" -S <server>,1433 -U ' + @StudentPrefix + N' -P <password> -c -t"|"';

PRINT N'After bcp import, run the VERIFY batch below (F5 on selection).';
GO

-- ========== VERIFY (re-run after bcp import) ==========
-- >>> Edit your prefix (T-SQL editor — no SQLCMD mode) <<<
DECLARE @StudentPrefix sysname = N's01';
DECLARE @DbName sysname = @StudentPrefix + N'_TSQL';
DECLARE @sql nvarchar(max) = N'USE ' + QUOTENAME(@DbName) + N';
SELECT COUNT(*) AS imported_rows FROM dbo.Employees_BcpStaging;';
EXEC sys.sp_executesql @sql;
GO

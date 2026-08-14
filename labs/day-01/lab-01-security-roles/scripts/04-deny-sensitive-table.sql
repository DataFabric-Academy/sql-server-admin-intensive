/*
  Lab 01 — DENY on sensitive pay history table
  Edit the DECLARE block only (T-SQL editor — no SQLCMD mode).
*/

-- >>> Edit your prefix (T-SQL editor — no SQLCMD mode) <<<
DECLARE @StudentPrefix sysname = N's01';
DECLARE @db sysname = @StudentPrefix + N'_AdventureWorks';
DECLARE @role sysname = @StudentPrefix + N'_HRUsers';
DECLARE @login sysname = @StudentPrefix + N'_tester';
DECLARE @sql nvarchar(max);

SET @sql = N'
USE ' + QUOTENAME(@db) + N';

-- Role-level DENY on sensitive pay history (overrides schema GRANT for members)
DENY SELECT, INSERT, UPDATE, DELETE
    ON OBJECT::HumanResources.EmployeePayHistory
    TO ' + QUOTENAME(@role) + N';

PRINT N''DENY applied on HumanResources.EmployeePayHistory for '' + @roleName;
';

EXEC sys.sp_executesql @sql, N'@roleName sysname', @roleName = @role;

PRINT N'';
PRINT N'Manual test (connect as ' + @login + N'):';
PRINT N'';
PRINT N'  USE ' + QUOTENAME(@db) + N';';
PRINT N'  SELECT * FROM HumanResources.Employee;              -- expect SUCCESS';
PRINT N'  SELECT * FROM HumanResources.EmployeePayHistory;    -- expect FAIL (DENY)';
GO

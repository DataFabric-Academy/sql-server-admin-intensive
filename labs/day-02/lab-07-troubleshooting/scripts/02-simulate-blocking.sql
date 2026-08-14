-- >>> Edit your prefix (T-SQL editor — no SQLCMD mode) <<<
DECLARE @StudentPrefix sysname = N's01';
DECLARE @DbName sysname = @StudentPrefix + N'_AdventureWorks';
DECLARE @comment nvarchar(200) = N'Blocking drill - ' + @StudentPrefix;
DECLARE @sql nvarchar(max);

/*
  Scenario B — Simulate blocking (2 SSMS windows)

  Window 1: Run STEP A below (starts transaction, holds lock)
  Window 2: Run STEP B (will block until Window 1 COMMITs or you run Lab 03)
*/

-- ========== STEP A — Window 1 (blocker) ==========
SET @sql = N'UPDATE ' + QUOTENAME(@DbName) + N'.Sales.SalesOrderHeader
SET Comment = @p_comment
WHERE SalesOrderID = 43659;';

BEGIN TRAN;

EXEC sys.sp_executesql @sql, N'@p_comment nvarchar(200)', @p_comment = @comment;

PRINT N'Window 1: Lock held on SalesOrderID 43659. Leave transaction open.';
PRINT N'Now run STEP B in Window 2, then run 03-find-blocker-dmv.sql in a 3rd window.';
GO

-- ========== STEP B — Window 2 (blocked session) ==========
-- Edit @StudentPrefix to match yours, then uncomment and run in Window 2:
/*
DECLARE @StudentPrefix sysname = N's01';
DECLARE @DbName sysname = @StudentPrefix + N'_AdventureWorks';
DECLARE @comment nvarchar(200) = N'Blocked session - ' + @StudentPrefix;
DECLARE @sql nvarchar(max) =
    N'UPDATE ' + QUOTENAME(@DbName) + N'.Sales.SalesOrderHeader
     SET Comment = @p_comment
     WHERE SalesOrderID = 43659;';

BEGIN TRAN;
EXEC sys.sp_executesql @sql, N'@p_comment nvarchar(200)', @p_comment = @comment;
-- Should wait until Window 1 commits
COMMIT TRAN;
*/

-- ========== CLEANUP — Window 1 after drill ==========
/*
COMMIT TRAN;
-- or ROLLBACK TRAN;
*/

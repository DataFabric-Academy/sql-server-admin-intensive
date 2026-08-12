:setvar StudentPrefix s01

/*
  Scenario B — Simulate blocking (2 SSMS windows)

  Window 1: Run STEP A below (starts transaction, holds lock)
  Window 2: Run STEP B (will block until Window 1 COMMITs or you run Lab 03)
*/
USE [$(StudentPrefix)_AdventureWorks];
GO

-- ========== STEP A — Window 1 (blocker) ==========
BEGIN TRAN;

UPDATE Sales.SalesOrderHeader
SET Comment = N'Blocking drill - $(StudentPrefix)'
WHERE SalesOrderID = 43659;

PRINT N'Window 1: Lock held on SalesOrderID 43659. Leave transaction open.';
PRINT N'Now run STEP B in Window 2, then run 03-find-blocker-dmv.sql in a 3rd window.';
GO

-- ========== STEP B — Window 2 (blocked session) ==========
/*
BEGIN TRAN;

UPDATE Sales.SalesOrderHeader
SET Comment = N'Blocked session - $(StudentPrefix)'
WHERE SalesOrderID = 43659;

-- Should wait until Window 1 commits
COMMIT TRAN;
*/

-- ========== CLEANUP — Window 1 after drill ==========
/*
COMMIT TRAN;
-- or ROLLBACK TRAN;
*/

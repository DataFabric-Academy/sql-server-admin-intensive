:setvar StudentPrefix s01

USE [$(StudentPrefix)_AdventureWorks];
GO

-- Role-level DENY on sensitive pay history (overrides schema GRANT for members)
DENY SELECT, INSERT, UPDATE, DELETE
    ON OBJECT::HumanResources.EmployeePayHistory
    TO [$(StudentPrefix)_HRUsers];
GO

PRINT N'DENY applied on HumanResources.EmployeePayHistory for $(StudentPrefix)_HRUsers';
GO

/*
  Manual test (connect as $(StudentPrefix)_tester):

  USE [$(StudentPrefix)_AdventureWorks];
  SELECT * FROM HumanResources.Employee;              -- expect SUCCESS
  SELECT * FROM HumanResources.EmployeePayHistory;    -- expect FAIL (DENY)
*/

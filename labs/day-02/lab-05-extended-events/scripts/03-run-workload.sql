-- >>> Edit your prefix (T-SQL editor — no SQLCMD mode) <<<
DECLARE @StudentPrefix sysname = N's01';
DECLARE @DbName sysname = @StudentPrefix + N'_AdventureWorks';

-- Generate CPU/IO workload (slow scans) — run while XEvent session is STARTed
DECLARE @sql nvarchar(max) = N'USE ' + QUOTENAME(@DbName) + N';
DECLARE @i int = 0;
WHILE @i < 15
BEGIN
    SELECT p.FirstName, p.LastName, soh.OrderDate, SUM(sod.LineTotal) AS Total
    FROM Sales.SalesOrderHeader AS soh
    JOIN Sales.SalesOrderDetail AS sod ON sod.SalesOrderID = soh.SalesOrderID
    JOIN Production.Product AS pr ON pr.ProductID = sod.ProductID
    JOIN Person.Person AS p ON p.BusinessEntityID = soh.CustomerID
    GROUP BY p.FirstName, p.LastName, soh.OrderDate
    ORDER BY Total DESC;

    WAITFOR DELAY ''00:00:02'';
    SET @i += 1;
END
';
EXEC sys.sp_executesql @sql;

PRINT N'Workload complete. Run 04-query-xel-files.sql';
GO

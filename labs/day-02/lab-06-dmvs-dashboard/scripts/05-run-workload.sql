-- >>> Edit your prefix (T-SQL editor — no SQLCMD mode) <<<
DECLARE @StudentPrefix sysname = N's01';
DECLARE @DbName sysname = @StudentPrefix + N'_AdventureWorks';

-- Adapted from NAS Lab13 workload1 — heavy joins on Sales/Person
DECLARE @sql nvarchar(max) = N'USE ' + QUOTENAME(@DbName) + N';
DECLARE @i int = 0;
WHILE @i < 20
BEGIN
    SELECT TOP 500
        p.FirstName,
        p.LastName,
        pr.Name AS ProductName,
        SUM(sod.LineTotal) AS LineTotal
    FROM Sales.SalesOrderDetail AS sod
    JOIN Production.Product AS pr ON pr.ProductID = sod.ProductID
    JOIN Sales.SalesOrderHeader AS soh ON soh.SalesOrderID = sod.SalesOrderID
    JOIN Person.Person AS p ON p.BusinessEntityID = soh.CustomerID
    GROUP BY p.FirstName, p.LastName, pr.Name
    ORDER BY LineTotal DESC;

    WAITFOR DELAY ''00:00:01'';
    SET @i += 1;
END
';
EXEC sys.sp_executesql @sql;

PRINT N'Re-run 01-wait-stats-snapshot.sql, 02-active-requests-blocking.sql, and 04-resource-dashboard.sql';
GO

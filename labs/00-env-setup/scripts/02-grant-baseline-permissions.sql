/*
  Instructor setup: map student logins to their AdventureWorks + TSQL databases.
  Adjust @StudentCount to match 00-create-student-logins.sql
*/

USE master;
GO

DECLARE @StudentCount int = 20;
DECLARE @i int = 1;
DECLARE @login sysname;
DECLARE @awDb sysname;
DECLARE @tsqlDb sysname;
DECLARE @sql nvarchar(max);

WHILE @i <= @StudentCount
BEGIN
    SET @login = N's' + RIGHT(N'0' + CAST(@i AS nvarchar(10)), 2);
    SET @awDb = @login + N'_AdventureWorks';
    SET @tsqlDb = @login + N'_TSQL';

    IF SUSER_ID(@login) IS NULL
    BEGIN
        PRINT N'Skip missing login ' + @login;
        SET @i += 1;
        CONTINUE;
    END

    IF NOT EXISTS (
        SELECT 1
        FROM sys.server_permissions p
        JOIN sys.server_principals sp ON p.grantee_principal_id = sp.principal_id
        WHERE sp.name = @login AND p.permission_name = N'CREATE ANY DATABASE' AND p.state = N'G'
    )
    BEGIN
        SET @sql = N'GRANT CREATE ANY DATABASE TO ' + QUOTENAME(@login) + N';';
        EXEC sys.sp_executesql @sql;
    END

    IF DB_ID(@awDb) IS NOT NULL
    BEGIN
        SET @sql = N'
USE ' + QUOTENAME(@awDb) + N';
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = N''' + @login + N''')
    CREATE USER ' + QUOTENAME(@login) + N' FOR LOGIN ' + QUOTENAME(@login) + N';
ALTER ROLE db_owner ADD MEMBER ' + QUOTENAME(@login) + N';
';
        EXEC sys.sp_executesql @sql;
    END

    IF DB_ID(@tsqlDb) IS NOT NULL
    BEGIN
        SET @sql = N'
USE ' + QUOTENAME(@tsqlDb) + N';
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = N''' + @login + N''')
    CREATE USER ' + QUOTENAME(@login) + N' FOR LOGIN ' + QUOTENAME(@login) + N';
ALTER ROLE db_owner ADD MEMBER ' + QUOTENAME(@login) + N';
';
        EXEC sys.sp_executesql @sql;
    END

    SET @sql = N'
USE msdb;
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = N''' + @login + N''')
    CREATE USER ' + QUOTENAME(@login) + N' FOR LOGIN ' + QUOTENAME(@login) + N';
ALTER ROLE SQLAgentUserRole ADD MEMBER ' + QUOTENAME(@login) + N';
ALTER ROLE SQLAgentReaderRole ADD MEMBER ' + QUOTENAME(@login) + N';
ALTER ROLE SQLAgentOperatorRole ADD MEMBER ' + QUOTENAME(@login) + N';
';
    EXEC sys.sp_executesql @sql;

    PRINT N'Granted baseline permissions for ' + @login;
    SET @i += 1;
END
GO

/*
  Optional PowerShell (instructor):
  1..20 | ForEach-Object {
    $p = 's{0:D2}' -f $_
    New-Item -Path "D:\SqlLabs\backups\$p" -ItemType Directory -Force | Out-Null
  }
*/

/*
  Instructor demo only — Module 04
  Service Account concept → Credential → Proxy (CmdExec) → Job Step

  Prerequisites (do BEFORE running):
    1. Create a Windows account for the proxy, e.g. local:
         net user SqlLabCmdExec <StrongPassword> /add
       Or use an existing domain service account.
    2. Grant that account Modify on D:\SqlLabs\backups\demo\ (create folder)
    3. Edit the DECLARE block below
    4. Optionally set @GrantLogin to a non-sysadmin student login (e.g. s01)

  Talk track:
    - Agent Service Account ≠ account used by every CmdExec/PowerShell step
    - Without Proxy, non-TSQL steps push people toward sysadmin
    - Credential stores Windows identity; Proxy maps it to a subsystem

  Run in normal T-SQL editor (no SQLCMD mode).
*/
USE master;
GO

/* >>> Edit these values for your lab server <<< */
DECLARE @WinIdentity nvarchar(128) = N'COMPUTERNAME\SqlLabCmdExec';
DECLARE @WinSecret   nvarchar(128) = N'ChangeMe_LabOnly!';
DECLARE @GrantLogin  sysname       = N's01';
DECLARE @DemoPath    nvarchar(260) = N'D:\SqlLabs\backups\demo';

DECLARE @sql nvarchar(max);

IF EXISTS (SELECT 1 FROM sys.credentials WHERE name = N'cred_DemoCmdExec')
    DROP CREDENTIAL [cred_DemoCmdExec];

SET @sql = N'CREATE CREDENTIAL [cred_DemoCmdExec] WITH IDENTITY = '
    + QUOTENAME(@WinIdentity, '''')
    + N', SECRET = '
    + QUOTENAME(@WinSecret, '''')
    + N';';
EXEC sys.sp_executesql @sql;

DECLARE @proxy sysname = N'proxy_DemoCmdExec';

USE msdb;

IF EXISTS (SELECT 1 FROM dbo.sysproxies WHERE name = @proxy)
BEGIN
    DECLARE @login sysname;
    DECLARE c CURSOR LOCAL FAST_FORWARD FOR
        SELECT sp.name
        FROM dbo.sysproxylogin pl
        JOIN sys.server_principals sp ON pl.sid = sp.sid
        JOIN dbo.sysproxies p ON pl.proxy_id = p.proxy_id
        WHERE p.name = @proxy;
    OPEN c;
    FETCH NEXT FROM c INTO @login;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        EXEC dbo.sp_revoke_login_from_proxy @name = @login, @proxy_name = @proxy;
        FETCH NEXT FROM c INTO @login;
    END
    CLOSE c; DEALLOCATE c;

    EXEC dbo.sp_delete_proxy @proxy_name = @proxy;
END

EXEC dbo.sp_add_proxy
    @proxy_name = @proxy,
    @credential_name = N'cred_DemoCmdExec',
    @enabled = 1,
    @description = N'Lab demo CmdExec proxy (Least Privilege)';

EXEC dbo.sp_grant_proxy_to_subsystem
    @proxy_name = @proxy,
    @subsystem_id = 3; -- Operating system (CmdExec)

IF EXISTS (SELECT 1 FROM sys.server_principals WHERE name = @GrantLogin)
BEGIN
    EXEC dbo.sp_grant_login_to_proxy
        @proxy_name = @proxy,
        @login_name = @GrantLogin;
    PRINT N'Granted proxy to login ' + @GrantLogin;
END
ELSE
    PRINT N'Login ' + @GrantLogin + N' not found — grant later via sp_grant_login_to_proxy.';

DECLARE @job sysname = N'Demo_CmdExec_Proxy';
DECLARE @cmd nvarchar(4000) =
    N'cmd /c echo ProxyDemoOK %DATE% %TIME%>> "' + @DemoPath + N'\proxy_demo.txt"';

BEGIN TRY
    EXEC dbo.sp_delete_job @job_name = @job, @delete_unused_schedule = 1;
END TRY
BEGIN CATCH
    IF ERROR_NUMBER() NOT IN (14262) THROW;
END CATCH;

EXEC dbo.sp_add_job
    @job_name = @job,
    @enabled = 1,
    @description = N'Demo: CmdExec step runs as Proxy (not sysadmin / not Agent service account)';

EXEC dbo.sp_add_jobstep
    @job_name = @job,
    @step_name = N'Write file via Proxy',
    @subsystem = N'CmdExec',
    @command = @cmd,
    @proxy_name = N'proxy_DemoCmdExec',
    @on_success_action = 1,
    @on_fail_action = 2;

EXEC dbo.sp_add_jobserver @job_name = @job, @server_name = N'(LOCAL)';

SELECT c.name AS credential_name, c.credential_identity
FROM sys.credentials AS c
WHERE c.name = N'cred_DemoCmdExec';

SELECT p.name AS proxy_name, p.enabled, c.name AS credential_name
FROM msdb.dbo.sysproxies AS p
JOIN sys.credentials AS c ON p.credential_id = c.credential_id
WHERE p.name = N'proxy_DemoCmdExec';

SELECT p.name AS proxy_name, s.subsystem
FROM msdb.dbo.sysproxies AS p
JOIN msdb.dbo.sysproxysubsystem AS ps ON p.proxy_id = ps.proxy_id
JOIN msdb.dbo.syssubsystems AS s ON ps.subsystem_id = s.subsystem_id
WHERE p.name = N'proxy_DemoCmdExec';

SELECT j.name AS job_name, js.step_name, js.subsystem, js.proxy_id
FROM msdb.dbo.sysjobs AS j
JOIN msdb.dbo.sysjobsteps AS js ON j.job_id = js.job_id
WHERE j.name = N'Demo_CmdExec_Proxy';

PRINT N'Create folder if needed: mkdir ' + @DemoPath;
PRINT N'Start job Demo_CmdExec_Proxy from SSMS, then check ' + @DemoPath + N'\proxy_demo.txt';
PRINT N'If job fails: wrong @WinIdentity/password, or ACL on folder for that Windows account.';
GO

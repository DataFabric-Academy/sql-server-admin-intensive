/*
  Instructor demo only — Module 04
  Remove Demo_* Agent objects created by demo-01 / demo-02 / demo-03

  Does NOT drop student sXX_ jobs/alerts.
  Does NOT drop Windows OS account (remove manually if created for class).
*/
USE msdb;
GO

BEGIN TRY EXEC dbo.sp_delete_job @job_name = N'Demo_CmdExec_Proxy', @delete_unused_schedule = 1; END TRY BEGIN CATCH END CATCH;
BEGIN TRY EXEC dbo.sp_delete_job @job_name = N'Demo_Dump_QueryStats', @delete_unused_schedule = 1; END TRY BEGIN CATCH END CATCH;

BEGIN TRY EXEC dbo.sp_delete_alert @name = N'Demo_Low_PLE'; END TRY BEGIN CATCH END CATCH;
BEGIN TRY EXEC dbo.sp_delete_alert @name = N'Demo_Severity_19'; END TRY BEGIN CATCH END CATCH;

-- Revoke proxy logins then delete proxy
IF EXISTS (SELECT 1 FROM dbo.sysproxies WHERE name = N'proxy_DemoCmdExec')
BEGIN
    DECLARE @login sysname;
    DECLARE c CURSOR LOCAL FAST_FORWARD FOR
        SELECT sp.name
        FROM dbo.sysproxylogin pl
        JOIN sys.server_principals sp ON pl.sid = sp.sid
        JOIN dbo.sysproxies p ON pl.proxy_id = p.proxy_id
        WHERE p.name = N'proxy_DemoCmdExec';
    OPEN c;
    FETCH NEXT FROM c INTO @login;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        BEGIN TRY
            EXEC dbo.sp_revoke_login_from_proxy @name = @login, @proxy_name = N'proxy_DemoCmdExec';
        END TRY
        BEGIN CATCH END CATCH;
        FETCH NEXT FROM c INTO @login;
    END
    CLOSE c; DEALLOCATE c;

    BEGIN TRY EXEC dbo.sp_delete_proxy @proxy_name = N'proxy_DemoCmdExec'; END TRY BEGIN CATCH END CATCH;
END

BEGIN TRY EXEC dbo.sp_delete_operator @name = N'Demo_DBA'; END TRY BEGIN CATCH END CATCH;
GO

USE master;
GO
IF EXISTS (SELECT 1 FROM sys.credentials WHERE name = N'cred_DemoCmdExec')
    DROP CREDENTIAL [cred_DemoCmdExec];
GO

PRINT N'Module 04 instructor demo objects cleaned.';
GO

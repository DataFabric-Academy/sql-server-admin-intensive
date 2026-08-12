:setvar StudentPrefix s01
:setvar BackupRoot "D:/SqlLabs/backups"

USE msdb;
GO

DECLARE @job sysname = N'$(StudentPrefix)_Backup_AdventureWorks';
DECLARE @sched sysname = N'$(StudentPrefix)_Backup_Hourly';
DECLARE @cmd nvarchar(max) =
    N'BACKUP DATABASE [$(StudentPrefix)_AdventureWorks] TO DISK = N''$(BackupRoot)/$(StudentPrefix)/$(StudentPrefix)_agent_full.bak'' WITH INIT, COMPRESSION;';

BEGIN TRY
    EXEC dbo.sp_delete_job @job_name = @job, @delete_unused_schedule = 1;
END TRY
BEGIN CATCH
    IF ERROR_NUMBER() NOT IN (14262) THROW; -- job does not exist
END CATCH;

BEGIN TRY
    EXEC dbo.sp_delete_schedule @schedule_name = @sched, @force_delete = 1;
END TRY
BEGIN CATCH
    IF ERROR_NUMBER() NOT IN (14262) THROW; -- schedule does not exist
END CATCH;

EXEC dbo.sp_add_job
    @job_name = @job,
    @enabled = 1,
    @description = N'Lab 04 full backup for student database';

EXEC dbo.sp_add_jobstep
    @job_name = @job,
    @step_name = N'Full backup',
    @subsystem = N'TSQL',
    @command = @cmd,
    @retry_attempts = 1,
    @retry_interval = 1,
    @on_success_action = 1,
    @on_fail_action = 2;

BEGIN TRY
    EXEC dbo.sp_add_schedule
        @schedule_name = @sched,
        @freq_type = 4,
        @freq_interval = 1,
        @freq_subday_type = 0x8,
        @freq_subday_interval = 1,
        @active_start_time = 080000,
        @active_end_time = 170000;
END TRY
BEGIN CATCH
    IF ERROR_NUMBER() NOT IN (14261) THROW; -- schedule already exists
END CATCH;

BEGIN TRY
    EXEC dbo.sp_attach_schedule @job_name = @job, @schedule_name = @sched;
END TRY
BEGIN CATCH
    IF ERROR_NUMBER() NOT IN (14269) THROW; -- schedule already attached
END CATCH;

EXEC dbo.sp_add_jobserver
    @job_name = @job,
    @server_name = N'(LOCAL)';
GO

-- Optional: start job manually from SSMS after SQL Server Agent is running
PRINT N'Job created. Start $(StudentPrefix)_Backup_AdventureWorks from SSMS when Agent is running.';
GO

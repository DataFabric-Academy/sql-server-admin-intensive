/*
  Lab 04 — create backup job + hourly schedule
  Edit the DECLARE block only (T-SQL editor — no SQLCMD mode).
*/
USE msdb;
GO

DECLARE @StudentPrefix sysname = N's01';
DECLARE @BackupRoot nvarchar(260) = N'D:/SqlLabs/backups';

DECLARE @job sysname = @StudentPrefix + N'_Backup_AdventureWorks';
DECLARE @sched sysname = @StudentPrefix + N'_Backup_Hourly';
DECLARE @db sysname = @StudentPrefix + N'_AdventureWorks';
DECLARE @bak nvarchar(4000) =
    @BackupRoot + N'/' + @StudentPrefix + N'/' + @StudentPrefix + N'_agent_full.bak';
DECLARE @cmd nvarchar(max) =
    N'BACKUP DATABASE ' + QUOTENAME(@db)
    + N' TO DISK = N''' + REPLACE(@bak, N'''', N'''''')
    + N''' WITH INIT, COMPRESSION;';

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

PRINT N'Job created: ' + @job + N'. Start it from SSMS when Agent is running.';
GO

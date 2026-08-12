:setvar StudentPrefix s01
:setvar XEventRoot D:\SqlLabs\xevents

SELECT
    xe.event_data.value('(/event/@name)[1]', 'varchar(100)') AS event_name,
    xe.event_data.value('(/event/@timestamp)[1]', 'datetime2(3)') AS event_time,
    xe.event_data.value('(/event/data[@name="duration"]/value)[1]', 'bigint') / 1000 AS duration_ms,
    xe.event_data.value('(/event/action[@name="database_name"]/value)[1]', 'sysname') AS database_name,
    xe.event_data.value('(/event/action[@name="sql_text"]/value)[1]', 'nvarchar(max)') AS sql_text
FROM (
    SELECT CAST(event_data AS xml) AS event_data
    FROM sys.fn_xe_file_target_read_file(
        N'$(XEventRoot)\$(StudentPrefix)\SlowQuery*.xel', NULL, NULL, NULL
    )
) AS xe
WHERE xe.event_data.value('(/event/@name)[1]', 'varchar(100)') = N'sql_statement_completed'
ORDER BY event_time DESC;
GO

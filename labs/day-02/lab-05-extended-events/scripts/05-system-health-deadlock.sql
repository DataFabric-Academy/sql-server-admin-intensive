/*
  Adapted from NAS Lab12 Exercise 01 — system_health deadlock reports
  Hint: find .xel path from sys.dm_xe_sessions / targets if needed
*/
:setvar StudentPrefix s01

SELECT
    xe_event.c.value('@timestamp', 'datetime2(3)') AS event_time,
    xe_event.c.value('@name', 'varchar(100)') AS event_name,
    xe_event.c.query('/event/data/value/deadlock') AS deadlock_xml
FROM (
    SELECT CAST(event_data AS xml) AS xe_data
    FROM sys.fn_xe_file_target_read_file('system_health*.xel', NULL, NULL, NULL)
) AS xe_data
CROSS APPLY xe_data.nodes('/event') AS xe_event(c)
WHERE xe_event.c.value('@name', 'varchar(100)') = N'xml_deadlock_report'
ORDER BY event_time DESC;
GO

-- Optional: query student's custom deadlock session
/*
SELECT
    xe_event.c.value('@timestamp', 'datetime2(3)') AS event_time,
    xe_event.c.query('/event/data/value/deadlock') AS deadlock_xml
FROM (
    SELECT CAST(event_data AS xml) AS xe_data
    FROM sys.fn_xe_file_target_read_file(N'D:\SqlLabs\xevents\s01\Deadlock*.xel', NULL, NULL, NULL)
) AS xe_data
CROSS APPLY xe_data.nodes('/event') AS xe_event(c)
WHERE xe_event.c.value('@name', 'varchar(100)') = N'xml_deadlock_report';
*/

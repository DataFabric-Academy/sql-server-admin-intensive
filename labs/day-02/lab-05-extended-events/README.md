---
module: M-06
duration_minutes: 90
type: lab
difficulty: intermediate
prerequisites:
  - lesson: lessons/day-02/module-06-extended-events/lesson.md
  - env: labs/00-env-setup/scripts/04-grant-day2-permissions.sql
---

# Lab 05: Extended Events Diagnostics

## เป้าหมาย

- สร้าง XEvent sessions ชื่อ `<prefix>_TrackSlowQuery` และ `<prefix>_CaptureDeadlocks`
- รัน workload แล้วดัก slow statements
- อ่าน deadlock จาก `system_health` (ดัดจาก NAS Lab12)

## สิ่งที่ต้องเตรียม

```sql
DECLARE @StudentPrefix sysname = N's01';
DECLARE @XEventRoot nvarchar(260) = N'D:\SqlLabs\xevents';
```

- DB: `<prefix>_AdventureWorks`
- โฟลเดอร์ `D:\SqlLabs\xevents\<prefix>\` สร้างแล้ว (env-setup)
- รันใน T-SQL editor ปกติ — ไม่ต้องเปิด SQLCMD Mode

## ขั้นตอน

| Task | Script |
|------|--------|
| 1 Slow query session | [`01-create-slow-query-session.sql`](scripts/01-create-slow-query-session.sql) |
| 2 Deadlock session | [`02-create-deadlock-session.sql`](scripts/02-create-deadlock-session.sql) |
| 3 Workload | [`03-run-workload.sql`](scripts/03-run-workload.sql) |
| 4 Query .xel | [`04-query-xel-files.sql`](scripts/04-query-xel-files.sql) |
| 5 system_health | [`05-system-health-deadlock.sql`](scripts/05-system-health-deadlock.sql) |

## ตรวจสอบผล (Verification)

```sql
DECLARE @StudentPrefix sysname = N's01';

SELECT name, create_time
FROM sys.server_event_sessions
WHERE name LIKE @StudentPrefix + N'_%';

-- After workload + flush:
-- SELECT COUNT(*) FROM ... fn_xe_file_target_read_file SlowQuery*.xel
```

## Troubleshooting

| ปัญหา | สาเหตุ | แก้ไข |
|-------|--------|-------|
| CREATE EVENT SESSION denied | ไม่มี ALTER ANY EVENT SESSION | รัน script 04 |
| Cannot create .xel file | Path / ACL | ตรวจ xevents folder |
| No events in .xel | Session ไม่ START / predicate สูงเกิน | ลด duration threshold |
| system_health empty | ยังไม่เกิด deadlock | รัน blocking script ใน Lab 07 |

## Challenge (Optional)

- อ่าน NAS Lab12 Exercise 02 (page splits) — เชื่อม 10987C index tuning

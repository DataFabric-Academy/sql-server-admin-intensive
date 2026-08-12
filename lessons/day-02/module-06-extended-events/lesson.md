---
sidebar_position: 6
module: M-06
duration_minutes: 120
type: lesson
---

# Module 06: Tracing with Extended Events (XEvents)

## วัตถุประสงค์

- อธิบายเหตุผลที่ XEvents แทน SQL Profiler บน Production
- สร้าง session สำหรับ Slow Query, Deadlock และ Wait Stats
- อ่านผลจาก `.xel` และ `system_health` session

## ทำไมสำคัญต่อ Performance Tuning

> XEvents คือเครื่องมือหลักใน 10987C สำหรับ query diagnostics — overhead ต่ำ กรองได้ละเอียด เปิดบน prod ได้

## เนื้อหา

### 1) Profiler vs XEvents

| หัวข้อ | Profiler | XEvents |
|--------|----------|---------|
| Overhead | สูง (20–30%) | ต่ำ (<1–2%) |
| Filtering | Post-filter | Predicate ที่ engine |
| Wait stats | ไม่รองรับ | รองรับ |
| Targets | .trc, table | event_file, ring_buffer |

### 2) Session anatomy

- **Events** — เช่น `sql_statement_completed`, `xml_deadlock_report`
- **Predicates** — `WHERE duration > 1000000` (microseconds)
- **Actions** — `sql_text`, `username`, `query_plan_hash`
- **Targets** — `event_file` (.xel), `ring_buffer`

### 3) สถานการณ์หลัก

1. Slow queries — `sql_statement_completed` + duration predicate
2. Deadlocks — `xml_deadlock_report`
3. Waits — `wait_info` (optional ใน advanced)

## Demo (วิทยากร)

```sql
CREATE EVENT SESSION [Track_SlowQuery] ON SERVER
ADD EVENT sqlserver.sql_statement_completed(
    ACTION(sqlserver.sql_text, sqlserver.client_app_name)
    WHERE duration > 1000000
)
ADD TARGET package0.event_file(
    SET filename = N'D:\SqlLabs\xevents\demo\SlowQuery.xel',
        max_file_size = 10, max_rollover_files = 2
);
ALTER EVENT SESSION [Track_SlowQuery] ON SERVER STATE = START;
```

## สรุป

- หยุดใช้ Profiler บน production workload
- ใช้ prefix `sXX_` สำหรับ session และ path แยกโฟลเดอร์
- `system_health` เก็บ deadlock อัตโนมัติ — อ่านด้วย `fn_xe_file_target_read_file`

## ต่อไป

- Lab: [Lab 05 — XEvents Diagnostics](../../../labs/day-02/lab-05-extended-events/README.md)

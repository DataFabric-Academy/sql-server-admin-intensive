---
sidebar_position: 7
module: M-07
duration_minutes: 90
type: lesson
---

# Module 07: DMVs & Resource Dashboard

## วัตถุประสงค์

- จำแนก DMV หลัก: `sys.dm_os_*`, `sys.dm_exec_*`, `sys.dm_io_*`
- อ่าน wait stats และแยก benign waits ออกจากสัญญาณปัญหา
- ใช้ DMVs หา blocking, expensive queries และ resource snapshot
- สร้าง Resource Dashboard ใน SSMS (multi-result script)

## ทำไมสำคัญต่อ Performance Tuning

> DMVs คือ "real-time dashboard" ของ SQL Server — 10987C ใช้ร่วมกับ XEvents เพื่อ isolate bottleneck (CPU / Memory / Disk / Blocking)

## เนื้อหา

### 1) หมวด DMV

| หมวด | ตัวอย่าง | ใช้เมื่อ |
|------|----------|----------|
| OS | `sys.dm_os_wait_stats`, `sys.dm_os_sys_info` | Waits, CPU, uptime |
| Exec | `sys.dm_exec_requests`, `sys.dm_exec_query_stats` | Active sessions, top queries |
| I/O | `sys.dm_io_virtual_file_stats` | File latency, read/write |

### 2) Wait stats

- **PAGEIOLATCH_*** — disk I/O ช้า / buffer pool pressure
- **LCK_M_*** — blocking / lock contention
- **CXPACKET / CXCONSUMER** — parallelism (ตีความร่วม query plan)
- **SLEEP_***, **BROKER_***, **XE_*** — มักเป็น benign (filter ออก)

### 3) Activity Monitor vs DMV

- Activity Monitor สะดวกแต่ snapshot จำกัด
- DMV script ปรับ filter ได้ — เหมาะกับ shared instance (`sXX_`)

### 4) ขั้นตอนวิเคราะห์ Performance (4 ขั้น)

1. **Gather** — wait stats, active requests, expensive queries
2. **Isolate** — CPU vs I/O vs blocking
3. **Apply** — index, query rewrite, config (10987C ลึกกว่า)
4. **Verify** — รัน workload ซ้ำ เปรียบเทียบ waits

## Demo (วิทยากร)

```sql
SELECT TOP 10 wait_type, wait_time_ms, waiting_tasks_count
FROM sys.dm_os_wait_stats
WHERE wait_type NOT LIKE 'SLEEP%'
  AND wait_type NOT IN (N'BROKER_EVENTHANDLER', N'XE_TIMER_EVENT')
ORDER BY wait_time_ms DESC;
```

## สรุป

- DMVs ต้องมี `VIEW SERVER STATE` (env-setup script 04)
- Filter benign waits ก่อนสรุป root cause
- Resource Dashboard = รวม CPU + memory + I/O ใน script เดียว

## ต่อไป

- Lab: [Lab 06 — DMVs & Resource Dashboard](../../../labs/day-02/lab-06-dmvs-dashboard/README.md)

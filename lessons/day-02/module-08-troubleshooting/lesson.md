---
sidebar_position: 8
module: M-08
duration_minutes: 60
type: lesson
---

# Module 08: Troubleshooting & Data Movement

## วัตถุประสงค์

- ใช้ methodology 4 ขั้น: Gather → Isolate → Apply → Verify
- ตรวจ connectivity แบบ layer-by-layer (OS → Service → Port → Auth)
- แมปเครื่องมือ diagnostic: Error Log, XEvents, DMVs
- รู้จัก data movement พื้นฐาน (BCP overview) — bridge 10987C

## ทำไมสำคัญต่อ Performance Tuning

> Troubleshooting ที่เป็นระบบลดเวลา MTTR — 10987C ต่อจากจุดนี้ด้วย query plan analysis และ index tuning

## เนื้อหา

### 1) Methodology 4 ขั้น

| ขั้น | กิจกรรม | เครื่องมือ |
|------|---------|-----------|
| Gather | รวบรวมอาการ, timestamp, error | Error Log, XEvents, DMVs |
| Isolate | แยก layer (connectivity / perf / data) | Connectivity checklist, waits |
| Apply | แก้ root cause | Config, query, index, kill blocker |
| Verify | ทดสอบซ้ำ | Workload, monitoring |

### 2) Connectivity layers

1. **OS / Network** — ping, firewall, port 1433
2. **Service** — SQL Server + Browser (named instance)
3. **Port / Protocol** — TCP enabled, correct port
4. **Authentication** — SQL Auth login, database access, blocked account

### 3) Performance triad

- **CPU** — expensive queries, parallelism waits
- **Memory** — PLE, memory grants, external pressure
- **Disk** — PAGEIOLATCH, file latency (`dm_io_virtual_file_stats`)

### 4) Diagnostic tools map

| อาการ | เครื่องมือ |
|-------|-----------|
| Login failed | Error Log, Audit |
| Slow queries | XEvents, `dm_exec_query_stats` |
| Blocking | `dm_exec_requests`, Activity Monitor |
| Deadlock | `system_health`, XEvent deadlock session |

### 5) Data movement (overview)

| วิธี | เหมาะกับ |
|------|----------|
| BCP | Bulk export/import ตาราง |
| BULK INSERT | Load จากไฟล์ใน T-SQL |
| Backup/Restore | DB-level move (Day 1) |

Intensive: ทดลอง BCP เบาๆ บน `sXX_TSQL` (optional)

### 6) Common errors

| Error | ความหมาย |
|-------|----------|
| 18456 | Login failed |
| 26 / 10060 | Network / instance not found |
| LCK_M_* | Blocking / lock wait |

## สรุป

- ใช้ DMVs + XEvents ที่เรียน Day 2 ร่วมกับ Error Log
- Shared instance: แยกปัญหาด้วย prefix `sXX_` และ database ของตน
- 10987C จะลงลึก query plan, statistics, index design

## ต่อไป

- Lab: [Lab 07 — Troubleshooting Scenarios](../../../labs/day-02/lab-07-troubleshooting/README.md)

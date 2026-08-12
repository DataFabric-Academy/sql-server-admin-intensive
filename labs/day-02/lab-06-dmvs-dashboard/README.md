---
module: M-07
duration_minutes: 75
type: lab
difficulty: intermediate
prerequisites:
  - lesson: lessons/day-02/module-07-dmvs/lesson.md
  - env: labs/00-env-setup/scripts/04-grant-day2-permissions.sql
---

# Lab 06: DMVs & Resource Dashboard

## เป้าหมาย

- Snapshot wait stats (filter benign)
- หา active requests และ blocking chain
- ดู expensive queries จาก plan cache
- รัน Resource Dashboard สำหรับ `$(StudentPrefix)_AdventureWorks`
- รัน workload แล้วสังเกตการเปลี่ยนแปลง

## สิ่งที่ต้องเตรียม

```sql
:setvar StudentPrefix s01
```

- DB: `$(StudentPrefix)_AdventureWorks`
- สิทธิ์ `VIEW SERVER STATE`

## ขั้นตอน

| Task | Script |
|------|--------|
| 1 Wait stats | [`01-wait-stats-snapshot.sql`](scripts/01-wait-stats-snapshot.sql) |
| 2 Blocking | [`02-active-requests-blocking.sql`](scripts/02-active-requests-blocking.sql) |
| 3 Expensive queries | [`03-expensive-queries.sql`](scripts/03-expensive-queries.sql) |
| 4 Dashboard | [`04-resource-dashboard.sql`](scripts/04-resource-dashboard.sql) |
| 5 Workload | [`05-run-workload.sql`](scripts/05-run-workload.sql) |

> รัน Task 1 และ 4 **ก่อน** workload แล้วรันซ้ำหลัง Task 5 เพื่อเปรียบเทียบ

## ตรวจสอบผล (Verification)

- หลัง workload: เห็น active requests หรือ wait type เปลี่ยน (เช่น `PAGEIOLATCH`, `CXPACKET`)
- Dashboard แสดง CPU, memory, I/O latency ของไฟล์ใน `$(StudentPrefix)_AdventureWorks`
- บันทึก Top 3 wait types และ expensive query 1 รายการ

## Troubleshooting

| ปัญหา | สาเหตุ | แก้ไข |
|-------|--------|-------|
| Permission denied on DMV | ไม่มี VIEW SERVER STATE | รัน script 04 |
| Empty query stats | Plan cache ว่าง / DB ใหม่ | รัน workload ก่อน |
| ไม่เห็น blocking | ไม่มี session ค้าง | ใช้ Lab 07 scenario B |

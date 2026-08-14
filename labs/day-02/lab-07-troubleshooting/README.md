---
module: M-08
duration_minutes: 60
type: lab
difficulty: intermediate
prerequisites:
  - lesson: lessons/day-02/module-08-troubleshooting/lesson.md
  - labs: labs/day-02/lab-06-dmvs-dashboard/
---

# Lab 07: Troubleshooting Scenarios

## เป้าหมาย

- ตรวจ connectivity จากเครื่องตนเอง
- จำลอง blocking 2 session แล้วหา blocker ด้วย DMV
- อ่าน Error Log หา login / backup errors
- (Optional) BCP export/import ตารางเล็กจาก `<prefix>_TSQL`

## สิ่งที่ต้องเตรียม

```sql
DECLARE @StudentPrefix sysname = N's01';
```

- DB: `<prefix>_AdventureWorks`, `<prefix>_TSQL`
- SSMS 2 query windows (สำหรับ blocking drill)
- รันใน T-SQL editor ปกติ — ไม่ต้องเปิด SQLCMD Mode

## ขั้นตอน

| Scenario | ไฟล์ |
|----------|------|
| A Connectivity | [`01-connectivity-checklist.md`](scripts/01-connectivity-checklist.md) |
| B Simulate blocking | [`02-simulate-blocking.sql`](scripts/02-simulate-blocking.sql) |
| C Find blocker | [`03-find-blocker-dmv.sql`](scripts/03-find-blocker-dmv.sql) |
| D Error log | [`04-read-errorlog.sql`](scripts/04-read-errorlog.sql) |
| E Light BCP (optional) | [`05-bcp-export-import.sql`](scripts/05-bcp-export-import.sql) |

## ตรวจสอบผล (Verification)

1. ส่งผล `03-find-blocker-dmv.sql` ที่ระบุ **blocker SPID** และวิธีแก้ (COMMIT / KILL)
2. สรุป 1 หน้า: *"ถ้าไป 10987C จะใช้ DMV/XEvent ตรงไหน"* — อย่างน้อย 2 ตัวอย่าง

## Troubleshooting

| ปัญหา | แก้ไข |
|-------|--------|
| Blocking ไม่เกิด | รัน Window 1 ก่อน แล้ว Window 2 ทันที |
| BCP ไม่พบ command | ติดตั้ง SQL Server Command Line Utilities / ใช้ path `bcp.exe` จาก client tools |
| Error log ว่าง | ขยาย range หรือ `EXEC xp_readerrorlog 0, 1` |

## ตัดออกจาก Lab เก่า

- SSIS, DACPAC, multi-server (sql2), AD user setup — อยู่นอกขอบเขต Intensive

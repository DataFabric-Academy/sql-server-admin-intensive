---
module: M-02
duration_minutes: 75
type: lab
difficulty: intermediate
prerequisites:
  - lesson: lessons/day-01/module-02-transaction-log/lesson.md
---

# Lab 02: Transaction Log & Recovery Models

## เป้าหมาย

- สลับ Recovery Model บน DB ของคุณและสังเกตผลต่อ log reuse
- สร้าง workload แล้ววัด Log Space Used
- ใน Full model ทำ Log Backup เพื่อ truncate log (ไม่ทำ crash restore — อยู่ใน Lab 03)

## สิ่งที่ต้องเตรียม

- SQL Auth ด้วย Login ของคุณ
- สิทธิ์ `db_owner` บน `$(StudentPrefix)_AdventureWorks`
- โฟลเดอร์ backup: `D:\SqlLabs\backups\$(StudentPrefix)\` (วิทยากรสร้างให้แล้ว)

```sql
:setvar StudentPrefix s01
```

## ขั้นตอน

### Task 1: ดูสถานะ Log ปัจจุบัน

รัน [`scripts/01-inspect-log.sql`](scripts/01-inspect-log.sql)

### Task 2: ทดสอบโหมด Simple

รัน [`scripts/02-simple-model-workload.sql`](scripts/02-simple-model-workload.sql)

สังเกตว่าหลัง `CHECKPOINT` ค่า Log Space Used (%) มีแนวโน้มลดลง

### Task 3: ทดสอบโหมด Full + Log Backup

รัน [`scripts/03-full-model-and-log-backup.sql`](scripts/03-full-model-and-log-backup.sql)

เปรียบเทียบ: หลัง Checkpoint ใน Full อาจยัง `LOG_BACKUP` — ต้อง `BACKUP LOG` จึง reuse ได้

### Task 4: อ่าน VLF เบื้องต้น

รัน [`scripts/04-inspect-vlfs.sql`](scripts/04-inspect-vlfs.sql)

## ตรวจสอบผล (Verification)

```sql
:setvar StudentPrefix s01

SELECT name, recovery_model_desc, log_reuse_wait_desc
FROM sys.databases
WHERE name = N'$(StudentPrefix)_AdventureWorks';

DBCC SQLPERF(logspace);
```

คาดหวังหลังจบ Lab: DB กลับเป็น **FULL** และ `log_reuse_wait_desc` ไม่ค้างที่ `LOG_BACKUP` (หลัง Log Backup สำเร็จ)

## Troubleshooting

| ปัญหา | สาเหตุ | แก้ไข |
|-------|--------|-------|
| Cannot open backup device | Path ไม่มี / สิทธิ์ SQL service | แจ้งวิทยากรสร้าง `D:\SqlLabs\backups\sXX\` |
| BACKUP LOG fails | DB ยังไม่เคย Full backup ใน Full model | สคริปต์ Task 3 มี Full backup ให้แล้ว |
| Log ไม่ลด | มี open transaction | ตรวจ `DBCC OPENTRAN` |
| Permission denied ALTER DATABASE | ไม่ใช่ db_owner | ตรวจ env-setup |

## Challenge (Optional)

- เปิด transaction ค้างใน session หนึ่ง แล้วดู `ACTIVE_TRANSACTION` ในอีก session
- อธิบายว่าทำไมการขยาย `.ldf` ทีละนิดหลายครั้งทำให้ VLF เยอะ

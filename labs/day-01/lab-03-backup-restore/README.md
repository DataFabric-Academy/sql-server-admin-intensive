---
module: M-03
duration_minutes: 90
type: lab
difficulty: intermediate
prerequisites:
  - lesson: lessons/day-01/module-03-backup-restore/lesson.md
  - lab: labs/day-01/lab-02-transaction-log/README.md
  - env: labs/00-env-setup/README.md
---

# Lab 03: Backup, Restore & Disaster Recovery

## เป้าหมาย

ทำ Lab ตาม flow ของ [generic_backup](https://github.com/phakkhaphong/SQLServerBackupRestore/tree/main/generic_backup) บน AdventureWorks ของคุณ (`sXX_AdventureWorks`) โดย:

- จำลอง Full / Diff / Log backup schedule
- บันทึกธุรกรรมสำคัญ (`IT Auditor`, `UPDATE Person.Person`) หลัง backup ล่าสุด
- ทำ Tail-Log backup แล้ว restore แบบ **zero data loss** (Step 05)

## สิ่งที่ต้องเตรียม

ในทุกสคริปต์แก้เฉพาะ DECLARE (T-SQL editor ปกติ — ไม่ต้องเปิด SQLCMD Mode):

```sql
DECLARE @StudentPrefix sysname = N's01';
DECLARE @BackupRoot nvarchar(260) = N'D:/SqlLabs/backups';
DECLARE @DataPath nvarchar(260) = N'D:\SqlLabs\data';
DECLARE @LogPath nvarchar(260) = N'D:\SqlLabs\logs';
```

- DB `<prefix>_AdventureWorks` restore จาก `D:\Setupfiles\AdventureWorks.bak` แล้ว (env-setup)
- Recovery model **FULL**
- โฟลเดอร์ `D:\SqlLabs\backups\<prefix>\` สร้างแล้ว

## ความต่างจาก generic_backup ต้นฉบับ

| ต้นฉบับ | Lab นี้ (Instance ร่วม) |
|---------|-------------------------|
| DB ชื่อ `AdventureWorks` | `<prefix>_AdventureWorks` |
| `D:\Adv\`, `D:\Backups\myDevice.bak` | `D:\SqlLabs\...`, `<prefix>_myDevice.bak` |
| Crash: ลบ `.mdf` + stop service | **วิทยากร Demo** crash ให้ดู; นักเรียนทำ Tail-Log ขณะ DB online |
| Restore ทับ DB เดิม | Restore ไป `<prefix>_AdventureWorks_Restore` |

## ขั้นตอน (ตาม generic_backup)

| Step | ไฟล์ | คำอธิบาย |
|------|------|----------|
| 1 | [`Step_01_Prepare_Database.sql`](scripts/Step_01_Prepare_Database.sql) | FULL recovery + backup device |
| 2 | [`Step_02_Simulate_Backup_Schedule.sql`](scripts/Step_02_Simulate_Backup_Schedule.sql) | Schedule + IT Auditor + UPDATE Person |
| 3 | [`Step_03_Backup_TailLog.sql`](scripts/Step_03_Backup_TailLog.sql) | Tail-Log (online — ไม่ต้อง crash) |
| 5 ⭐ | [`Step_05_Restore_With_TailLog.sql`](scripts/Step_05_Restore_With_TailLog.sql) | Zero data loss → `_Restore` |
| 4 (Optional) | [`Step_04_Restore_Without_TailLog.sql`](scripts/Step_04_Restore_Without_TailLog.sql) | มี data loss — เปรียบเทียบ |
| 6 (Optional) | [`Step_06_Restore_With_TailLog_And_Undo.sql`](scripts/Step_06_Restore_With_TailLog_And_Undo.sql) | Advanced STANDBY/NORECOVERY |

## ตรวจสอบผล (Verification)

```sql
DECLARE @StudentPrefix sysname = N's01';
DECLARE @restoreDb sysname = @StudentPrefix + N'_AdventureWorks_Restore';
DECLARE @sql nvarchar(max) = N'
USE ' + QUOTENAME(@restoreDb) + N';

SELECT ContactTypeID, Name, ModifiedDate
FROM Person.ContactType
WHERE Name = N''IT Auditor'';

SELECT COUNT(*) AS UpdatedRowsToday
FROM Person.Person
WHERE CAST(ModifiedDate AS DATE) = CAST(GETDATE() AS DATE);
';
EXEC sys.sp_executesql @sql;
```

## Troubleshooting

| ปัญหา | สาเหตุ | แก้ไข |
|-------|--------|-------|
| Cannot open backup device | Path / ACL | ตรวจ `D:\SqlLabs\backups\sXX\` |
| Logical file name mismatch | AdventureWorks edition ต่าง | ดู `RESTORE FILELISTONLY` แล้วแก้ MOVE |
| Restore permission | ไม่มี CREATE DATABASE | แจ้งวิทยากร / ใช้สิทธิ์จาก env-setup |

## Challenge (Optional)

- เปรียบเทียบ Step 04 vs 05 ว่า `IT Auditor` หายหรือไม่
- ดูวิทยากร Demo crash + `CONTINUE_AFTER_ERROR` แล้วเปรียบกับ Step 03 แบบ online

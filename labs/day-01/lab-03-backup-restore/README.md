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

```sql
:setvar StudentPrefix s01
:setvar BackupRoot "D:/SqlLabs/backups"
:setvar DataPath D:\SqlLabs\data
:setvar LogPath D:\SqlLabs\logs
```

- DB `$(StudentPrefix)_AdventureWorks` restore จาก `D:\Setupfiles\AdventureWorks.bak` แล้ว (env-setup)
- Recovery model **FULL**
- โฟลเดอร์ `$(BackupRoot)\$(StudentPrefix)\` สร้างแล้ว

## ความต่างจาก generic_backup ต้นฉบับ

| ต้นฉบับ | Lab นี้ (Instance ร่วม) |
|---------|-------------------------|
| DB ชื่อ `AdventureWorks` | `$(StudentPrefix)_AdventureWorks` |
| `D:\Adv\`, `D:\Backups\myDevice.bak` | `D:\SqlLabs\...`, `$(StudentPrefix)_myDevice.bak` |
| Crash: ลบ `.mdf` + stop service | **วิทยากร Demo** crash ให้ดู; นักเรียนทำ Tail-Log ขณะ DB online |
| Restore ทับ DB เดิม | Restore ไป `$(StudentPrefix)_AdventureWorks_Restore` |

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
:setvar StudentPrefix s01

USE [$(StudentPrefix)_AdventureWorks_Restore];

-- จาก Step 02 / Tail-Log chain
SELECT ContactTypeID, Name, ModifiedDate
FROM Person.ContactType
WHERE Name = N'IT Auditor';

SELECT COUNT(*) AS UpdatedRowsToday
FROM Person.Person
WHERE CAST(ModifiedDate AS DATE) = CAST(GETDATE() AS DATE);
```

```sql
RESTORE HEADERONLY
FROM DISK = N'D:\SqlLabs\backups\s01\s01_myDevice.bak';
```

## Troubleshooting

| ปัญหา | สาเหตุ | แก้ไข |
|-------|--------|-------|
| Cannot open backup device | Path/ACL | ตรวจ `D:\SqlLabs\backups\sXX\` |
| BACKUP LOG cannot run | ยังไม่มี Full backup | รัน Step 01–02 ใหม่ |
| LSN chain broken | ข้าม Step / FILE ผิด | ใช้ `RESTORE HEADERONLY` ดู FILE # |
| Restore MOVE failed | Logical name ผิด | ใช้ `AdventureWorks` / `AdventureWorks_Log` |

## Challenge

- อ่าน [README ต้นฉบับ](https://github.com/phakkhaphong/SQLServerBackupRestore/blob/main/generic_backup/README.md) แล้วสรุบ RPO ของ Step 04 vs Step 05
- ดูวิทยากร Demo crash + `CONTINUE_AFTER_ERROR` แล้วเปรียบกับ Step 03 แบบ online

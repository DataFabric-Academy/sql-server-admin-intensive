---
module: M-04
duration_minutes: 60
type: lab
difficulty: intermediate
prerequisites:
  - lesson: lessons/day-01/module-04-sql-agent/lesson.md
  - env: labs/00-env-setup/README.md
---

# Lab 04: SQL Agent Jobs & Alerts

## เป้าหมาย

- สร้าง SQL Agent Job สำรอง `<prefix>_AdventureWorks` ของคุณ
- ผูก Schedule และรัน Job ทดสอบ
- สร้าง Alert แบบ **Error Number** จาก user-defined message `51001` (เปิด `WITH_LOG` ผ่าน `sp_altermessage` ใน env-setup)

> ทฤษฎีครบใน Lesson: Operator, Alert 3 แบบ (Error / Severity / Perf Condition), และ Service Account → Credential → Proxy — Lab นี้โฟกัส Job + Event Alert ของคุณ

## สิ่งที่ต้องเตรียม

- SQL Server Agent กำลังทำงาน
- Login ของคุณเป็นสมาชิก `SQLAgentUserRole` ใน `msdb`
- Path: `D:\SqlLabs\backups\<prefix>\` (เช่น `D:\SqlLabs\backups\s01\`)

ในทุกสคริปต์ Lab แก้เฉพาะบรรทัดนี้ให้ตรงรหัสของคุณ (รันใน T-SQL editor ปกติได้ — **ไม่ต้อง** เปิด SQLCMD Mode):

```sql
DECLARE @StudentPrefix sysname = N's01';
DECLARE @BackupRoot nvarchar(260) = N'D:/SqlLabs/backups';  -- ใช้ในสคริปต์ 02
```

## ขั้นตอน

### Task 1: ตรวจสิทธิ์ Agent

รัน [`scripts/01-verify-agent-role.sql`](scripts/01-verify-agent-role.sql)

### Task 2: สร้าง Backup Job + Schedule

รัน [`scripts/02-create-backup-job.sql`](scripts/02-create-backup-job.sql)  
จากนั้น Start Job จาก SSMS หรือสคริปต์ในไฟล์

### Task 3: สร้าง Alert แบบ Error Number (message กลางจากวิทยากร)

Message `51001` ถูกสร้าง/เปิด `WITH_LOG` แล้วใน [env-setup script 03](../../00-env-setup/scripts/03-create-lab04-message.sql) (`sp_addmessage` / `sp_altermessage`)

รัน [`scripts/03-create-alert.sql`](scripts/03-create-alert.sql) เพื่อสร้าง Alert ชื่อ `<prefix>_Lab04_Alert`

> ถ้า `sp_add_alert` ถูกปฏิเสธ ให้วิทยากรสร้าง Alert ให้ หรือข้ามไปทดสอบ `RAISERROR` แล้วดู Error Log  
> Operator + Database Mail ไม่บังคับใน Lab — ดูประวัติ Alert ใน SSMS ได้

### Task 4: ทดสอบ Alert

รัน [`scripts/04-test-alert.sql`](scripts/04-test-alert.sql) แล้วดู Job/Alert history ใน SSMS

## ตรวจสอบผล (Verification)

```sql
DECLARE @StudentPrefix sysname = N's01';
DECLARE @job sysname = @StudentPrefix + N'_Backup_AdventureWorks';

USE msdb;
SELECT job_id, name, enabled
FROM dbo.sysjobs
WHERE name = @job;

SELECT TOP 10 j.name, h.run_date, h.run_time, h.run_status, h.message
FROM dbo.sysjobhistory h
JOIN dbo.sysjobs j ON h.job_id = j.job_id
WHERE j.name = @job
ORDER BY h.instance_id DESC;

SELECT name, message_id, severity, enabled
FROM dbo.sysalerts
WHERE name LIKE @StudentPrefix + N'%';
```

## Troubleshooting

| ปัญหา | สาเหตุ | แก้ไข |
|-------|--------|-------|
| Agent XPs disabled / Agent stopped | Service ไม่ได้ start | วิทยากร start SQL Server Agent |
| Permission denied create job | ไม่ใช่ SQLAgentUserRole | รัน env-setup script 02 |
| Job failed backup path | ACL / path | ตรวจ `D:\SqlLabs\backups\sXX\` |
| Cannot add message/alert | ต้องการสิทธิ์สูง | วิทยากรรัน Task 3 ให้ |

## Challenge (Optional)

- เพิ่ม Job Step ที่ `BACKUP LOG` หลัง Full
- ดู Demo วิทยากร: **Operator + Perf Condition Alert (PLE)** และ **Credential → Proxy (CmdExec)** แล้วสรุปความต่างจาก Event Alert ที่คุณทำใน Lab
- อธิบายสั้น ๆ ว่าทำไม CmdExec ไม่ควรใช้บัญชี sysadmin โดยตรง (ใช้ Proxy แทน)

## Demo วิทยากร (ไม่ใช่ Task นักเรียน)

รันด้วย Windows Auth / sysadmin บน lab server ตามลำดับ:

| ลำดับ | ไฟล์ | เนื้อหา |
|------|------|---------|
| 1 | [`scripts/demo-01-operator-severity-alert.sql`](scripts/demo-01-operator-severity-alert.sql) | Operator + Severity Alert |
| 2 | [`scripts/demo-02-ple-performance-alert.sql`](scripts/demo-02-ple-performance-alert.sql) | PLE Performance Alert + Response Job |
| 3 | [`scripts/demo-03-credential-proxy-cmdexec.sql`](scripts/demo-03-credential-proxy-cmdexec.sql) | Credential → Proxy (CmdExec) → Job |
| 99 | [`scripts/demo-99-cleanup.sql`](scripts/demo-99-cleanup.sql) | ลบวัตถุ `Demo_*` หลังจบคลาส |

> Event Alert + `sp_altermessage` อยู่ที่ [env-setup `03-create-lab04-message.sql`](../../00-env-setup/scripts/03-create-lab04-message.sql) — นักเรียนทดสอบต่อใน Task 3–4

## ต่อไป (Day 2)

- Lesson: [Module 05 — PowerShell + dbatools (Demo)](../../../lessons/day-02/module-05-powershell-dbatools/lesson.md)
- วิทยากรเตรียม: [env-setup Day 2 checklist](../../00-env-setup/README.md#checklist--day-2-ก่อนวันที่-2)

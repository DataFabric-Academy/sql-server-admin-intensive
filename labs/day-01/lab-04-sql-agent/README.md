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

- สร้าง SQL Agent Job สำรอง `$(StudentPrefix)_AdventureWorks` ของคุณ
- ผูก Schedule และรัน Job ทดสอบ
- สร้าง Alert จาก user-defined message (แนว Automating-SQL-Server) ภายใต้ prefix ของคุณ

## สิ่งที่ต้องเตรียม

- SQL Server Agent กำลังทำงาน
- Login ของคุณเป็นสมาชิก `SQLAgentUserRole` ใน `msdb`
- Path: `D:\SqlLabs\backups\$(StudentPrefix)\`

```sql
:setvar StudentPrefix s01
:setvar BackupRoot "D:/SqlLabs/backups"
:setvar XEventRoot D:\SqlLabs\xevents
```

## ขั้นตอน

### Task 1: ตรวจสิทธิ์ Agent

รัน [`scripts/01-verify-agent-role.sql`](scripts/01-verify-agent-role.sql)

### Task 2: สร้าง Backup Job + Schedule

รัน [`scripts/02-create-backup-job.sql`](scripts/02-create-backup-job.sql)  
จากนั้น Start Job จาก SSMS หรือสคริปต์ในไฟล์

### Task 3: สร้าง Alert (message กลางจากวิทยากร)

Message `51001` ถูกสร้างแล้วใน [env-setup script 03](../../00-env-setup/scripts/03-create-lab04-message.sql)

รัน [`scripts/03-create-alert.sql`](scripts/03-create-alert.sql) เพื่อสร้าง Alert ชื่อ `$(StudentPrefix)_Lab04_Alert`

> ถ้า `sp_add_alert` ถูกปฏิเสธ ให้วิทยากรสร้าง Alert ให้ หรือข้ามไปทดสอบ `RAISERROR` แล้วดู Error Log

### Task 4: ทดสอบ Alert

รัน [`scripts/04-test-alert.sql`](scripts/04-test-alert.sql) แล้วดู Job/Alert history ใน SSMS

## ตรวจสอบผล (Verification)

```sql
:setvar StudentPrefix s01

USE msdb;
SELECT job_id, name, enabled
FROM dbo.sysjobs
WHERE name = N'$(StudentPrefix)_Backup_AdventureWorks';

SELECT TOP 10 j.name, h.run_date, h.run_time, h.run_status, h.message
FROM dbo.sysjobhistory h
JOIN dbo.sysjobs j ON h.job_id = j.job_id
WHERE j.name = N'$(StudentPrefix)_Backup_AdventureWorks'
ORDER BY h.instance_id DESC;

SELECT name, message_id, severity, enabled
FROM dbo.sysalerts
WHERE name LIKE N'$(StudentPrefix)%';
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
- ดู Demo Proxy ของวิทยากร แล้วสรุปว่าทำไม CmdExec ไม่ควรใช้บัญชี sysadmin โดยตรง

## ต่อไป (Day 2)

- Lesson: [Module 05 — PowerShell + dbatools (Demo)](../../../lessons/day-02/module-05-powershell-dbatools/lesson.md)
- วิทยากรเตรียม: [env-setup Day 2 checklist](../../00-env-setup/README.md#checklist--day-2-ก่อนวันที่-2)

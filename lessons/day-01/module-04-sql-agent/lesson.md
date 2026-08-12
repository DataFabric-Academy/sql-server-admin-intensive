---
sidebar_position: 4
module: M-04
duration_minutes: 75
type: lesson
---

# Module 04: SQL Server Agent & Automation

## วัตถุประสงค์

- สร้าง Job / Step / Schedule สำหรับงานบำรุงรักษา (เช่น Backup)
- ตั้ง Operator และ Alert เพื่อแจ้งเตือนก่อนระบบมีปัญหา
- อธิบาย Credential + Proxy ตามหลัก **Least Privilege**
- ใช้ `SQLAgentUserRole` ให้ผู้ใช้ที่ไม่ใช่ sysadmin รัน Job ของตนเองได้

## ทำไมสำคัญต่อ Performance Tuning

> Alert และ Job ที่ออกแบบดีช่วยจับอาการ (disk, long-running, failed backup) ก่อนกลายเป็น outage  
> เป็นสะพานสู่ proactive monitoring ก่อนใช้ XEvents/DMVs เชิงลึกใน Day 2

## เนื้อหา

### 1) องค์ประกอบหลัก

| องค์ประกอบ | หน้าที่ |
|------------|--------|
| Job | ชุดงาน (หลาย Step ได้) |
| Step | คำสั่งจริง (TSQL, CmdExec, PowerShell, …) |
| Schedule | One-time / Recurring / Agent start |
| Operator | ผู้รับแจ้งเตือน (email/pager) |
| Alert | เงื่อนไขจาก Error Number / Severity / Performance condition |

### 2) Least Privilege กับ Agent

- อย่าให้ทุกคนเป็น `sysadmin` แค่เพื่อรัน Job
- ใส่ Login เข้า `msdb` role: `SQLAgentUserRole` / `SQLAgentReaderRole` / `SQLAgentOperatorRole` ตามหน้าที่
- **Credential** เก็บ identity ของ Windows account → **Proxy** map ไปยัง subsystem (CmdExec, PowerShell) แล้วมอบสิทธิ์เฉพาะคนที่จำเป็น

ในคลาส Intensive: นักเรียนสร้าง **TSQL Job** บน DB ของตัวเอง — Proxy เป็น Demo วิทยากร

### 3) Alert แบบง่าย

แนวทางจาก [Automating-SQL-Server](https://github.com/phakkhaphong/Automating-SQL-Server):

- สร้าง user-defined message (`sp_addmessage`) + `WITH_LOG`
- สร้าง Alert จับ message_id / severity
- ทดสอบด้วย `RAISERROR`

## Demo (สำหรับวิทยากร)

สร้าง Job backup (แนว Demo_01):

```sql
USE msdb;
GO

-- Illustrative names — Lab uses sXX_ prefix
EXEC dbo.sp_add_job @job_name = N's01_Backup_AdventureWorks', @enabled = 1;
EXEC dbo.sp_add_jobstep
    @job_name = N's01_Backup_AdventureWorks',
    @step_name = N'Full backup',
    @subsystem = N'TSQL',
    @command = N'BACKUP DATABASE [s01_AdventureWorks] TO DISK = N''D:\SqlLabs\backups\s01\s01_agent.bak'' WITH INIT, COMPRESSION;';
EXEC dbo.sp_add_jobserver @job_name = N's01_Backup_AdventureWorks', @server_name = N'(LOCAL)';
```

Demo Proxy (วิทยากร alone): สร้าง Credential → Proxy สำหรับ CmdExec → grant เฉพาะ Login ทดสอบ

## สรุป

- Job + Schedule ทำให้ preventive maintenance ทำซ้ำได้
- Alert ช่วย proactive ก่อน Performance ทรุด
- Proxy/Credential แยกสิทธิ์จาก sysadmin
- นักเรียนใช้ `SQLAgentUserRole` + TSQL steps
- Day 2 จะต่อด้วย dbatools (Demo) และ XEvents/DMVs

## ต่อไป

- Lab: [Lab 04 — SQL Agent Jobs & Alerts](../../../labs/day-01/lab-04-sql-agent/README.md)
- Day 2: [Module 05 — PowerShell + dbatools (Demo)](../../day-02/module-05-powershell-dbatools/lesson.md)

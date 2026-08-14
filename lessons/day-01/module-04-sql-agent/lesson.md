---
sidebar_position: 4
module: M-04
duration_minutes: 75
type: lesson
---

# Module 04: SQL Server Agent & Automation

## วัตถุประสงค์

- อธิบายองค์ประกอบ Job / Step / Schedule / Operator / Alert และบทบาท Database Mail
- ออกแบบสิทธิ์ Agent: **Service Account** → **Credential** → **Proxy** ตาม Least Privilege
- ใช้ `SQLAgentUserRole` ให้ผู้ใช้ที่ไม่ใช่ sysadmin สร้าง/รัน Job ของตนเองได้
- แยกประเภท Alert ทั้ง 3 แบบ และใช้ `sp_addmessage` / `sp_altermessage` ให้ Event เข้า Error Log

## ทำไมสำคัญต่อ Performance Tuning

> Alert และ Job ที่ออกแบบดีช่วยจับอาการ (disk, long-running, failed backup, PLE ต่ำ) ก่อนกลายเป็น outage  
> เป็นสะพานสู่ proactive monitoring ก่อนใช้ XEvents/DMVs เชิงลึกใน Day 2

## เนื้อหา

### 1) องค์ประกอบหลัก

| องค์ประกอบ | หน้าที่ |
|------------|--------|
| Job | ชุดงาน (หลาย Step ได้) |
| Step | คำสั่งจริง (TSQL, CmdExec, PowerShell, SSIS, …) |
| Schedule | One-time / Recurring / Agent start |
| Job History | บันทึก Success / Failure และข้อความย้อนหลัง |
| Operator | ผู้รับแจ้งเตือน (Email / Pager / Fail-safe Operator) |
| Alert | เงื่อนไขจาก **Error Number** / **Severity** / **Performance Condition** |
| Database Mail | ช่องทางส่งอีเมลผ่าน SMTP (ต้องตั้งก่อน Operator ใช้งานจริงได้) |

```text
Event / Counter / Severity
        │
        ▼
     Alert ──notify──► Operator (Database Mail)
        │
        └──response──► Job (optional diagnostic / remediation)
```

### 2) Security: Service Account → Credential → Proxy

#### 2.1 Service Account ของ SQL Server Agent

- บัญชีที่รัน **SQL Server Agent Windows Service** เป็น identity พื้นฐานของ Agent
- Step ชนิด **TSQL** รันในบริบทของ SQL Login เจ้าของ Job (หรือตาม job owner) — ไม่ใช้ Proxy
- Step ชนิด **CmdExec / PowerShell / SSIS** ที่ไม่ได้ผูก Proxy จะพยายามใช้สิทธิ์สูง (มักต้องเป็น sysadmin) → เสี่ยงต่อทั้ง instance

แนวทาง production:

- ใช้ Domain service account แยกสำหรับ Agent (ไม่ใช้ Local System เป็นค่าเริ่มต้นระยะยาว)
- จำกัดสิทธิ์ OS ของบัญชีนั้นเฉพาะ path ที่จำเป็น (เช่น `D:\SqlLabs\backups\`)

#### 2.2 Credential

- เก็บ **Windows identity + password** ไว้ใน SQL Server (ไม่ใช่ SQL Login)
- ใช้เป็น “ตัวแทน” สำหรับงานที่ต้องแตะ OS / ไฟล์ / SSIS ด้วยบัญชีเฉพาะงาน
- แยกบัญชีตามหน้าที่ (เช่น backup copy, SSIS package) และจำกัด ACL บนโฟลเดอร์ที่เกี่ยวข้อง

```sql
-- Instructor demo only (requires CREATE CREDENTIAL)
CREATE CREDENTIAL [cred_LabCmdExec]
WITH IDENTITY = N'DOMAIN\svc_sql_cmdexec',
     SECRET = N'<password>';
```

#### 2.3 Proxy Account

ลำดับ Least Privilege:

```text
Windows / Service Account
        │
        ▼
   Credential  (เก็บ identity ใน SQL)
        │
        ▼
   Proxy       (map ไปยัง subsystem: CmdExec, PowerShell, SSIS, …)
        │
        ▼
   Grant เฉพาะ Login ที่จำเป็น (เช่น SQLAgentUserRole user)
```

| ปัญหาถ้าไม่มี Proxy | แนวทางที่ถูกต้อง |
|---------------------|------------------|
| ต้องเป็น `sysadmin` แค่เพื่อรัน CmdExec/PowerShell/SSIS | สร้าง Proxy ต่อ subsystem ที่เกี่ยวข้องเท่านั้น |
| Job รันด้วยสิทธิ์กว้างเกิน | Grant Proxy เฉพาะ Login ที่สร้าง Job นั้น |
| บัญชีเดียวใช้ทุกงาน | แยก Credential/Proxy ตามงาน (Subsystem Isolation) |

ในคลาส Intensive: นักเรียนสร้าง **TSQL Job** บน DB ของตัวเอง — **Proxy เป็น Demo วิทยากร**

Agent roles ใน `msdb` (ใช้คู่กับ TSQL jobs ของนักเรียน):

| Role | สิทธิ์โดยย่อ |
|------|----------------|
| `SQLAgentUserRole` | สร้าง/จัดการ Job ของตนเอง |
| `SQLAgentReaderRole` | ดู Job/ประวัติได้กว้างขึ้น |
| `SQLAgentOperatorRole` | รัน/หยุด Job ของผู้อื่นได้บางส่วน |

### 3) Operator

Operator = ผู้รับการแจ้งเตือนเมื่อ Alert ทำงาน หรือเมื่อ Job ตั้ง Notify ไว้

- ระบุ **Email** / **Pager** และเปิดช่องทางที่ Database Mail รองรับ
- ตั้ง **Fail-safe Operator** ที่ระดับ Agent properties สำหรับกรณีส่งไม่ถึง Operator หลัก
- ผูกกับ Alert ผ่าน `sp_add_notification` (หรือหน้า Alert → Response ใน SSMS)

```sql
USE msdb;
GO
EXEC dbo.sp_add_operator
    @name = N'DBA_Admin',
    @enabled = 1,
    @email_address = N'dba@company.com';
```

> Lab นักเรียนอาจไม่มี Database Mail — ยังสร้าง/ทดสอบ Alert ให้ขึ้นใน Agent history / Error Log ได้ โดยไม่บังคับให้มีอีเมลจริง

### 4) Alert ทั้ง 3 แบบ

SQL Server Agent รองรับ Alert หลัก 3 ประเภท (ตรงกับ outline หลักสูตร):

| ประเภท | จับจาก | ตัวอย่าง | การตอบสนองที่พบบ่อย |
|--------|--------|----------|---------------------|
| **1. Event / Error Number** | `message_id` ใน Error Log | Error **9002** (log full), user-defined `51001` | Email + รัน Job วินิจฉัย |
| **2. Severity Level** | ช่วง severity ของ error ที่ถูก log | Severity **17–19** (resource), **20–25** (fatal) | Email ด่วน / fail-safe job |
| **3. Performance Condition** | SQL performance counter | `Page life expectancy` &lt; 300 | แจ้ง DBA วิเคราะห์ memory pressure |

#### 4.1 Event-based (Error Number) + `sp_addmessage` / `sp_altermessage`

Alert ประเภทนี้ทำงานเมื่อข้อความถูกเขียนลง **SQL Server Error Log**  
ดังนั้น user-defined message ต้องเปิด **WITH_LOG** — ไม่เช่นนั้น `RAISERROR` จะไม่จุด Alert

```sql
-- สร้าง message ใหม่ (instructor / once per instance)
EXEC sp_addmessage
    @msgnum = 51001,
    @severity = 16,
    @msgtext = N'Lab04 alert triggered by %s (%s)',
    @lang = N'us_english',
    @with_log = N'true';

-- ถ้ามี message อยู่แล้ว แต่ยังไม่ log → ใช้ sp_altermessage
EXEC sp_altermessage
    @message_id = 51001,
    @parameter = N'WITH_LOG',
    @parameter_value = N'true';

-- ตรวจว่าถูก mark เป็น event-logged
SELECT message_id, severity, text, is_event_logged
FROM sys.messages
WHERE message_id = 51001 AND language_id = 1033;
```

ทดสอบจุด Alert:

```sql
RAISERROR(51001, 16, 1, N's01', N'Lab04 test');
```

#### 4.2 Severity Alert

- ดักทั้งกลุ่มความรุนแรงโดยไม่ต้องรู้ error number ทีละตัว
- แนวทางจากสไลด์หลักสูตร: Severity **19–25** สำหรับเหตุวิกฤต; **17–19** สำหรับ resource pressure
- ใช้ร่วมกับ Error Number alert สำหรับเคสเฉพาะ (เช่น 9002)

```sql
EXEC msdb.dbo.sp_add_alert
    @name = N'Severity_19_Plus',
    @message_id = 0,
    @severity = 19,
    @enabled = 1,
    @delay_between_responses = 300,
    @include_event_description_in = 1;
```

#### 4.3 Performance Condition Alert

- เทียบค่า counter แบบ `Object|Counter|Instance|Comparator|Value`
- Demo หลักของ Module นี้ใน outline: **PLE &lt; 300**

```sql
EXEC msdb.dbo.sp_add_alert
    @name = N'Low_PLE_Alert',
    @performance_condition = N'SQLServer:Buffer Manager|Page life expectancy||<|300',
    @enabled = 1,
    @delay_between_responses = 600,
    @include_event_description_in = 1;

EXEC msdb.dbo.sp_add_notification
    @alert_name = N'Low_PLE_Alert',
    @operator_name = N'DBA_Admin',
    @notification_method = 1;  -- email
```

> ใน Intensive: นักเรียน Lab ใช้ Alert แบบ **Error Number** (message `51001`) — Severity / Perf Condition เป็น **Demo วิทยากร**

## Demo (สำหรับวิทยากร)

สคริปต์พร้อมรันอยู่ที่ `labs/day-01/lab-04-sql-agent/scripts/demo-*.sql`

| Demo | สคริปต์ | สิ่งที่โชว์ |
|------|---------|------------|
| A | นักเรียน Lab `02-create-backup-job.sql` | Job / Step / Schedule (TSQL) |
| B | [`demo-01-operator-severity-alert.sql`](../../../labs/day-01/lab-04-sql-agent/scripts/demo-01-operator-severity-alert.sql) | Operator + Severity Alert |
| C | [`demo-02-ple-performance-alert.sql`](../../../labs/day-01/lab-04-sql-agent/scripts/demo-02-ple-performance-alert.sql) | Perf Condition (PLE) + Response Job |
| D | [`demo-03-credential-proxy-cmdexec.sql`](../../../labs/day-01/lab-04-sql-agent/scripts/demo-03-credential-proxy-cmdexec.sql) | Credential → Proxy (CmdExec) |
| — | [`demo-99-cleanup.sql`](../../../labs/day-01/lab-04-sql-agent/scripts/demo-99-cleanup.sql) | ลบวัตถุ `Demo_*` |

Event Alert + `sp_altermessage`: [env-setup `03-create-lab04-message.sql`](../../../labs/00-env-setup/scripts/03-create-lab04-message.sql) แล้วให้นักเรียนรัน Lab Task 3–4

ก่อน Demo D: สร้าง Windows account + โฟลเดอร์ `D:\SqlLabs\backups\demo` แล้วแก้ `@WinIdentity` / `@WinSecret` ในสคริปต์

## สรุป

- Job + Schedule ทำให้ preventive maintenance ทำซ้ำได้
- **Operator** คือผู้รับแจ้งเตือน; ต้องมี Database Mail ถ้าจะส่งอีเมลจริง
- Alert มี 3 แบบ: **Error Number**, **Severity**, **Performance Condition**
- `sp_altermessage ... WITH_LOG` ทำให้ user-defined message จุด Event Alert ได้
- **Service Account** ของ Agent ≠ บัญชีรันทุก Job Step — ใช้ **Credential → Proxy** สำหรับ non-TSQL ตาม Least Privilege
- นักเรียนใช้ `SQLAgentUserRole` + TSQL steps; Proxy / Perf Alert เป็น Demo วิทยากร
- Day 2 จะต่อด้วย dbatools (Demo) และ XEvents/DMVs

## ต่อไป

- Lab: [Lab 04 — SQL Agent Jobs & Alerts](../../../labs/day-01/lab-04-sql-agent/README.md)
- Day 2: [Module 05 — PowerShell + dbatools (Demo)](../../day-02/module-05-powershell-dbatools/lesson.md)

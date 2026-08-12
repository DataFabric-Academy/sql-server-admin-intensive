---
sidebar_position: 2
module: M-02
duration_minutes: 120
type: lesson
---

# Module 02: Transaction Log Internals & Recovery Models

## วัตถุประสงค์

- อธิบาย Write-Ahead Logging (WAL) และผลต่อ I/O / latency ของการ Commit
- เปรียบเทียบ Recovery Models: Simple, Full, Bulk-Logged ในเชิงปฏิบัติการ
- อ่าน `log_reuse_wait_desc` และจัดการสถานการณ์ Log เต็มอย่างถูกต้อง
- เชื่อมโยงความถี่ Log Backup กับ **RPO**

## ทำไมสำคัญต่อ Performance Tuning

> ปัญหาประสิทธิภาพจำนวนมากมาจาก I/O และ Transaction Log  
> เข้าใจ WAL และ VLF / log reuse ก่อนเข้า Query Tuning (10987C) จะลดเวลาวิเคราะห์คอขวดได้มาก

## เนื้อหา

### 1) Transaction Log คืออะไร

- ไฟล์ `.ldf` เก็บลำดับการเปลี่ยนแปลงก่อนเขียน Data File (WAL)
- Commit ต้องรอให้ Log Record ถูก flush แบบ sequential → latency ของดิสก์ Log สำคัญมาก
- Best practice: แยก Log ไป SSD/NVMe หรือ volume ที่เน้น write latency ต่ำ

### 2) Recovery Models

| Model | Log reuse | Point-in-time | ใช้เมื่อ |
|-------|-----------|---------------|---------|
| Simple | หลัง Checkpoint | ไม่ได้ | Dev / DB ที่ยอมรับ data loss ถึง Full backup ล่าสุด |
| Full | หลัง **Log Backup** | ได้ | Production ที่ต้องการ RPO ต่ำ |
| Bulk-Logged | หลัง Log Backup (บาง bulk op ถูก minimize) | จำกัดช่วง bulk | ETL / Index rebuild ชั่วคราว แล้วสลับกลับ Full |

### 3) สาเหตุ Log เต็ม (`log_reuse_wait_desc`)

ตัวอย่างที่พบบ่อย:

- `LOG_BACKUP` — ยังไม่ทำ Log Backup (Full / Bulk-Logged)
- `ACTIVE_TRANSACTION` — transaction ค้างนาน
- `DATABASE_MIRRORING` / `AVAILABILITY_REPLICA` — รอ replica (นอกขอบเขตคลาสนี้)
- `CHECKPOINT` — รอ checkpoint (Simple)

แนวแก้: ทำ Log Backup, จัดการ long-running transaction, อย่าพึ่ง Autogrowth เป็นทางออกระยะยาวเพียงอย่างเดียว

### 4) ดูการใช้ Log

```sql
DBCC SQLPERF(logspace);

SELECT name, recovery_model_desc, log_reuse_wait_desc
FROM sys.databases
WHERE name = DB_NAME();
```

## Demo (สำหรับวิทยากร)

จำลองแนวทางจาก Lab เก่า Mod05 (LogComparison):

```sql
USE s01_AdventureWorks;
GO

-- Baseline
DBCC SQLPERF(logspace);

-- Workload
INSERT INTO dbo.LabAudit (Note)
SELECT CONCAT(N'demo-', v.number)
FROM master..spt_values AS v
WHERE v.type = N'P' AND v.number BETWEEN 1 AND 5000;

CHECKPOINT;
SELECT name, recovery_model_desc, log_reuse_wait_desc
FROM sys.databases WHERE name = N's01_AdventureWorks';

-- In FULL, checkpoint alone does not truncate — need LOG backup
BACKUP LOG s01_AdventureWorks
TO DISK = N'D:\SqlLabs\backups\s01\s01_AdventureWorks_demo.trn'
WITH INIT;
```

## สรุป

- WAL ทำให้ Commit พึ่งพาความเร็วของ Log disk
- Full model ต้องมี Log Backup ตาม RPO
- อ่าน `log_reuse_wait_desc` ก่อนขยายไฟล์ Log
- Simple ตัด log ได้ง่าย แต่เสีย Point-in-time
- Lab ถัดไปเปรียบเทียบ Simple vs Full ด้วย workload จริงบน DB ของคุณ

## ต่อไป

- Lab: [Lab 02 — Transaction Log & Recovery Models](../../../labs/day-01/lab-02-transaction-log/README.md)

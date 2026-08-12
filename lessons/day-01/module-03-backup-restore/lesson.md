---
sidebar_position: 3
module: M-03
duration_minutes: 75
type: lesson
---

# Module 03: High-Performance Backup & Restore Strategies

## วัตถุประสงค์

- เลือกใช้ Full / Differential / Transaction Log Backup ให้สอดคล้อง **RTO / RPO**
- อธิบายลำดับ Restore และบทบาทของ Tail-Log Backup
- ทำ Point-in-time recovery แนวคิดบน Lab DB ของตนเอง
- รู้จัก Backup Compression เบื้องต้น (ลดขนาดและ I/O)

## ทำไมสำคัญต่อ Performance Tuning

> Backup/Restore ที่ออกแบบผิดทำให้ RTO พุ่ง และ Log Backup ที่ไม่สม่ำเสมอกระทบทั้ง RPO และขนาด Transaction Log  
> เป็นพื้นฐานก่อนไปวิเคราะห์ I/O wait ในหลักสูตร Tuning

## เนื้อหา

### 1) ประเภท Backup

| ประเภท | เก็บอะไร | ใช้คู่กับ |
|--------|----------|-----------|
| Full | ทั้งฐานข้อมูล | จุดเริ่มต้นของทุก restore chain |
| Differential | เปลี่ยนแปลงตั้งแต่ Full ล่าสุด | ลดจำนวน Log ที่ต้อง restore |
| Log | Transaction log ตั้งแต่ LSN ล่าสุด | Full recovery + point-in-time |
| Tail-Log | Log สุดท้ายก่อน/ตอน disaster | ลด data loss ให้ใกล้ศูนย์ |

### 2) RTO / RPO

- **RPO** (Recovery Point Objective) — ยอมเสียข้อมูลได้เท่าไร → กำหนดความถี่ Log Backup
- **RTO** (Recovery Time Objective) — กู้คืนให้ทันภายในเวลาเท่าไร → ออกแบบ Full/Diff/striping/compression

### 3) Restore Sequence (Full recovery)

```text
RESTORE DATABASE ... WITH NORECOVERY   -- Full
RESTORE DATABASE ... WITH NORECOVERY   -- Diff (optional, latest)
RESTORE LOG ... WITH NORECOVERY        -- Log chain
RESTORE LOG ... WITH RECOVERY          -- last log or STOPAT / tail-log
```

### 4) Tail-Log

เมื่อ data file มีปัญหาแต่ log ยังอ่านได้: `BACKUP LOG ... WITH NORECOVERY` (หรือ `CONTINUE_AFTER_ERROR` ตามสถานการณ์) เพื่อเก็บธุรกรรมสุดท้ายก่อน restore

ใน Intensive Lab เราจำลองด้วยการ backup log หลังธุรกรรมสำคัญ แล้ว restore ไปยัง DB ชื่อใหม่ โดยไม่ต้องหยุด SQL Service

## Demo (สำหรับวิทยากร)

```sql
-- Compression + stripped concept (single file shown)
BACKUP DATABASE s01_AdventureWorks
TO DISK = N'D:\SqlLabs\backups\s01\demo_full.bak'
WITH INIT, COMPRESSION, STATS = 10;

BACKUP LOG s01_AdventureWorks
TO DISK = N'D:\SqlLabs\backups\s01\demo_log.trn'
WITH INIT, COMPRESSION;
```

## สรุป

- Full + Diff + Log ออกแบบจาก RTO/RPO ไม่ใช่จากนิสัย
- Restore ต้องรักษา NORECOVERY จนถึงขั้นสุดท้าย
- Tail-Log คือกุญแจของ zero / near-zero data loss
- Compression ช่วยทั้งพื้นที่และเวลา backup
- Lab 03 ย่อจาก [SQLServerBackupRestore/generic_backup](https://github.com/phakkhaphong/SQLServerBackupRestore/tree/main/generic_backup) — Step 01–06 บน `sXX_AdventureWorks`

## ต่อไป

- Lab: [Lab 03 — Backup, Restore & Point-in-Time](../../../labs/day-01/lab-03-backup-restore/README.md)

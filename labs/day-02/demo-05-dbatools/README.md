# Demo 05 — dbatools (วิทยากรเท่านั้น)

สคริปต์ PowerShell สำหรับ Module 5 Demo บน lab server (Windows Auth)

## Prerequisites

```powershell
Install-Module dbatools -Scope CurrentUser -Force
Import-Module dbatools
```

- รันบน GCP Member Server ด้วย Windows Auth
- ไม่ให้นักเรียนรัน (ไม่มี dbatools บนเครื่องนักเรียนจำเป็น)

## Scripts

| ลำดับ | ไฟล์ | เนื้อหา |
|------|------|---------|
| 1 | [`01-inventory.ps1`](01-inventory.ps1) | Instance, disk, services |
| 2 | [`02-backup-health.ps1`](02-backup-health.ps1) | Last backup status |
| 3 | [`03-drift-detection.ps1`](03-drift-detection.ps1) | sp_configure + Auto-Shrink |
| 4 | [`04-security-audit.ps1`](04-security-audit.ps1) | Orphan users, permissions |

## การ Demo ในห้อง

1. เปิด PowerShell ISE / Terminal บน projector
2. รันทีละไฟล์ อธิบาย output
3. เชื่อมกับ Day 1: "DB ไหน backup ล่าสุดเมื่อไหร่" จาก Lab 03/04
4. ปิดท้าย: "Lab ถัดไปนักเรียนจะใช้ XEvents/DMV ดู query-level"

## อ้างอิง

- [Automating-SQL-Server/Powershell](https://github.com/phakkhaphong/Automating-SQL-Server/tree/main/Powershell)
- [dbatools docs](https://docs.dbatools.io/)

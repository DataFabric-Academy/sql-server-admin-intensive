---
sidebar_position: 5
module: M-05
duration_minutes: 90
type: lesson
audience: instructor-demo
---

# Module 05: PowerShell + dbatools (Demo วิทยากร)

## วัตถุประสงค์

- อธิบายบทบาท dbatools ในการบริหาร SQL Server แบบ On-Premise
- สาธิต Inventory, Health Check และ Drift Detection บน lab instance
- เชื่อมโยงกับงาน Day 1 (Backup, Agent) และ Day 2 (DMVs/XEvents)

> **หมายเหตุ:** Module นี้ **ไม่มี Student Lab** — นักเรียนดู Demo วิทยากร (Windows Auth บน GCP)

## ทำไมสำคัญต่อ Performance Tuning

> ก่อนลงมือ Tune query ต้องรู้ว่า instance ตั้งค่าถูกต้อง backup ครบ และไม่มี drift  
> dbatools ช่วย audit แบบรวมศูนย์ — ส complement กับ DMVs/XEvents ที่นักเรียนจะใช้เองใน Lab ถัดไป

## เนื้อหา

### 1) dbatools คืออะไร

- Open-source PowerShell module (500+ commands)
- Multi-instance, no SQL Agent required on target
- Best-practice defaults จาก SQL Server MVPs

### 2) Inventory & Health

| คำสั่ง | ใช้เมื่อ |
|--------|---------|
| `Connect-DbaInstance` | เชื่อมต่อ + ดู version, edition, clustered |
| `Get-DbaDiskSpace` | พื้นที่ดิสก์ / DB size |
| `Get-DbaService` | SQL services ที่ไม่ running |
| `Get-DbaLastBackup` | DB ที่ไม่มี full backup ตาม SLA |

### 3) Security Audit

- `Get-DbaOrphanUser` — users ไม่ map login
- `Get-DbaUserPermission` — sysadmin / db_owner ทั่ว instance

### 4) Drift Detection

- `Test-DbaSpConfigure` — เปรียบเทียบ sp_configure กับ baseline
- `Get-DbaDatabase | Where AutoShrink -eq $true` — DB ที่เปิด Auto-Shrink

## Demo (วิทยากร)

สคริปต์: [`labs/day-02/demo-05-dbatools/`](../../labs/day-02/demo-05-dbatools/)

```powershell
# Prerequisites on instructor machine
Install-Module dbatools -Scope CurrentUser -Force
Import-Module dbatools
Set-DbatoolsConfig -FullName sql.connection.trustcert -Value $true

Connect-DbaInstance -SqlInstance $env:COMPUTERNAME -TrustServerCertificate |
    Select-Object ComputerName, InstanceName, Version, Edition, IsClustered
Get-DbaLastBackup -SqlInstance localhost | Where-Object { $_.LastFullBackup -lt (Get-Date).AddDays(-1) }
```

## สรุป

- dbatools = automation layer สำหรับ DBA (inventory, health, compliance)
- ไม่แทน XEvents/DMVs สำหรับ query-level tuning — ใช้คู่กัน
- นักเรียนจะ hands-on ด้วย XEvents และ DMVs ใน Module 6–7

## ต่อไป

- Module 06: [Extended Events](../module-06-extended-events/lesson.md)
- Lab: [Lab 05 — XEvents](../../../labs/day-02/lab-05-extended-events/README.md)

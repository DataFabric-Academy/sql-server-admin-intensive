---
module: ENV
duration_minutes: 30
type: setup
audience: instructor
---

# Lab Environment Setup (วิทยากร)

เตรียม Member Server / SQL Instance ก่อนวันสอน Day 1 และ Day 2

## Checklist — Day 1

- [ ] SQL Server 2019+ On-Prem (GCP Member Server ใน Domain ได้)
- [ ] **Mixed Mode** Authentication เปิดแล้ว + restart service แล้ว
- [ ] วิทยากร login ได้ด้วย Windows Auth
- [ ] มีไฟล์ต้นทาง: `D:\Setupfiles\AdventureWorks.bak`, `D:\Setupfiles\TSQL1.bak`
- [ ] Disk `D:` เพียงพอ (~250 MB × จำนวนนักเรียน × 2 DB + backup ระหว่าง Lab)

```powershell
New-Item -Path 'D:\SqlLabs\backups','D:\SqlLabs\data','D:\SqlLabs\logs','D:\SqlLabs\xevents' -ItemType Directory -Force
# Grant Modify ให้บัญชีที่รัน SQL Server service
```

- [ ] รันสคริปต์ด้านล่างตามลำดับ (Windows Auth / sysadmin)
- [ ] ทดสอบ SQL Auth จากเครื่องอื่นด้วย Login `s01`
- [ ] SQL Server Agent ทำงาน (สำหรับ Lab 04) — เปิด Agent XPs + start service
- [ ] Database Mail / Operator (optional — สำหรับ Alert demo)

## Scripts (รันตามลำดับ)

1. [`scripts/00-create-student-logins.sql`](scripts/00-create-student-logins.sql) — สร้าง SQL Login `s01`…`sNN`
2. [`scripts/01-create-lab-databases.sql`](scripts/01-create-lab-databases.sql) — restore `sXX_AdventureWorks` + `sXX_TSQL` จาก `D:\Setupfiles\*.bak`
3. [`scripts/02-grant-baseline-permissions.sql`](scripts/02-grant-baseline-permissions.sql) — สิทธิ์ขั้นต่ำสำหรับ Lab (ไม่ให้ sysadmin)
4. [`scripts/03-create-lab04-message.sql`](scripts/03-create-lab04-message.sql) — user-defined message `51001` สำหรับ Alert
5. สร้างโฟลเดอร์ backup ต่อคน:

```powershell
1..30 | ForEach-Object {
  $p = 's{0:D2}' -f $_
  New-Item -Path "D:\SqlLabs\backups\$p" -ItemType Directory -Force | Out-Null
}
```

## Checklist — Day 2 (ก่อนวันที่ 2)

- [ ] รัน [`scripts/04-grant-day2-permissions.sql`](scripts/04-grant-day2-permissions.sql) — `VIEW SERVER STATE`, `VIEW ANY DEFINITION`, `ALTER ANY EVENT SESSION`
- [ ] รัน [`scripts/05-create-xevent-folders.ps1.txt`](scripts/05-create-xevent-folders.ps1.txt) — สร้าง `D:\SqlLabs\xevents\sXX\` และ `workload\sXX\`
- [ ] ติดตั้ง dbatools บนเครื่องวิทยากร (Module 5 Demo): `Install-Module dbatools -Scope CurrentUser`

## สิทธิ์ที่ grant (สรุป)

| สิทธิ์ | เหตุผล |
|--------|--------|
| `db_owner` บน `sXX_AdventureWorks` และ `sXX_TSQL` | Lab หลัก + อ้างอิง MS-SQL-Essential |
| `CREATE ANY DATABASE` (หรือให้วิทยากรสร้าง DB ล่วงหน้า) | Lab 02–03 ถ้าสร้าง DB เอง |
| `SQLAgentUserRole` ใน `msdb` | Lab 04 สร้าง Job ของตัวเอง |
| `VIEW SERVER STATE` | Lab 06–07 อ่าน DMVs |
| `ALTER ANY EVENT SESSION` | Lab 05 สร้าง XEvent session ชื่อ `sXX_*` |
| ไม่ให้ `sysadmin` | กันกระทบ Instance ร่วม |

## Connection string ที่แจกนักเรียน

- Server: `<GCP-public-or-VPN-hostname>,1433`
- Authentication: SQL Server Authentication
- Login: `s01` (ตามที่ได้รับ)
- Password: ตามที่แจกในคลาส
- Database (Lab หลัก): `s01_AdventureWorks`
- Database (อ้างอิง): `s01_TSQL`

## หมายเหตุ

- ไม่ต้องเปิด Instance ให้ AI ตั้งค่าตอนเขียนเนื้อหา — ใช้ checklist นี้ก่อนวันสอน
- อย่า commit รหัสผ่านจริงลง Git

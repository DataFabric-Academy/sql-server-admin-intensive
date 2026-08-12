---
module: M-01
duration_minutes: 60
type: lab
difficulty: intermediate
prerequisites:
  - lesson: lessons/day-01/module-01-security/lesson.md
  - env: labs/00-env-setup/README.md
---

# Lab 01: Security Roles & Schema-based Access

## เป้าหมาย

- สร้าง SQL Login/User ทดสอบเพิ่มเติมภายใต้ prefix ของคุณ
- สร้าง User-defined Database Role และ GRANT ระดับ Schema
- ทดสอบสิทธิ์จริงด้วย Login ทดสอบ + ใช้ DENY กับตารางความลับ

## สิ่งที่ต้องเตรียม

- SSMS 22 เปิด repo นี้ผ่าน Git
- Connect ด้วย SQL Auth Login ของคุณ (เช่น `s01`)
- Database: `s01_AdventureWorks` (สร้างจาก env-setup)
- ตั้งค่า prefix:

```sql
:setvar StudentPrefix s01
```

> ถ้า SSMS ไม่รองรับ `:setvar` ให้ค้นหาแทนที่ `s01` ด้วย prefix ของคุณทั้งไฟล์

## ขั้นตอน

### Task 1: ตรวจ Login / User ของคุณ

รัน [`scripts/01-verify-identity.sql`](scripts/01-verify-identity.sql)

### Task 2: สร้าง Role + GRANT Schema

รัน [`scripts/02-create-role-and-schema-grants.sql`](scripts/02-create-role-and-schema-grants.sql)

สร้าง Role `s01_HRUsers` (ชื่อขึ้นต้นด้วย prefix) แล้ว GRANT บน `SCHEMA::HumanResources`

### Task 3: สร้าง Login ทดสอบและ Map เป็นสมาชิก Role

รัน [`scripts/03-create-test-user.sql`](scripts/03-create-test-user.sql)

จะได้ Login `s01_tester` (ต้องการสิทธิ์สร้าง Login — ถ้าถูกปฏิเสธ ให้วิทยากรรันสคริปต์นี้ให้)

### Task 4: ทดสอบสิทธิ์ + DENY ตารางเงินเดือน

1. เปิด Connection ใหม่ด้วย `s01_tester`
2. ลอง `SELECT` จาก `HumanResources.Employee` (ควรสำเร็จ)
3. ลอง `SELECT` จาก `HumanResources.EmployeePayHistory` (หลัง DENY ควรล้มเหลว)
4. รัน Verification ด้านล่างด้วย Login หลักของคุณ

สคริปต์ DENY: [`scripts/04-deny-sensitive-table.sql`](scripts/04-deny-sensitive-table.sql)

## ตรวจสอบผล (Verification)

```sql
:setvar StudentPrefix s01

USE [$(StudentPrefix)_AdventureWorks];
GO

SELECT dp.name AS role_name, mp.name AS member_name
FROM sys.database_role_members rm
JOIN sys.database_principals dp ON rm.role_principal_id = dp.principal_id
JOIN sys.database_principals mp ON rm.member_principal_id = mp.principal_id
WHERE dp.name = N'$(StudentPrefix)_HRUsers';

SELECT pr.name AS principal_name, pe.permission_name, pe.state_desc, pe.class_desc,
       SCHEMA_NAME(o.schema_id) AS schema_name, o.name AS object_name
FROM sys.database_permissions pe
JOIN sys.database_principals pr ON pe.grantee_principal_id = pr.principal_id
LEFT JOIN sys.objects o ON pe.major_id = o.object_id
WHERE pr.name IN (N'$(StudentPrefix)_HRUsers', N'$(StudentPrefix)_tester')
ORDER BY pr.name, pe.permission_name;
```

## Troubleshooting

| ปัญหา | สาเหตุ | แก้ไข |
|-------|--------|-------|
| Login failed | Mixed Mode ยังไม่เปิด / password ผิด | แจ้งวิทยากรตรวจ Server Authentication |
| Cannot create login | ไม่มีสิทธิ์ `ALTER ANY LOGIN` | ให้วิทยากรรัน `03-create-test-user.sql` |
| SELECT ตารางเงินเดือนยังผ่าน | ยังไม่ DENY หรือ member ผิด Role | รัน Task 4 ใหม่แล้ว reconnect |
| DB not accessible | ยังไม่ Map User | ตรวจ env-setup script 02 |

## Challenge (Optional)

- สร้าง Role `$(StudentPrefix)_SalesReaders` ที่ SELECT ได้เฉพาะ `SCHEMA::Sales`
- ทดลอง REVOKE DENY แล้วยืนยันว่าสิทธิ์จาก Role กลับมาใช้งานได้

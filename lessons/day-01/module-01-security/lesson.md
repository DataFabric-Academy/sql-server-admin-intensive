---
sidebar_position: 1
module: M-01
duration_minutes: 90
type: lesson
---

# Module 01: Security & Access Control Infrastructure

## วัตถุประสงค์

- อธิบายความต่างของ Windows Authentication กับ SQL Authentication และเหตุผลที่ต้องเปิด Mixed Mode ใน Lab นี้
- แยก Security Boundary ระหว่าง **Login (Instance)** กับ **User (Database)**
- ออกแบบสิทธิ์แบบ Schema-based + User-defined Database Roles ตามหลัก Least Privilege
- ใช้ GRANT / DENY / REVOKE อย่างถูกต้อง (DENY มีลำดับสูงสุด)

## ทำไมสำคัญต่อ Performance Tuning

> สิทธิ์ที่กว้างเกินจำเป็นทำให้ troubleshooting ยาก และเพิ่มภาระ Engine (ownership chain, elevated context)  
> Schema-based security ช่วยให้แอปและ DBA แยก workload ได้ชัด ก่อนเข้าสู่หลักสูตร 10987C / Query Tuning

## เนื้อหา

### 1) Authentication

| โหมด | ใช้เมื่อ | จุดสำคัญ |
|------|---------|-----------|
| Windows Auth | Domain / Local account | ปลอดภัยตามนโยบายองค์กร — วิทยากรใช้โหมดนี้บน Member Server |
| SQL Auth | Client นอก Domain / Lab ระยะไกล | ต้องเปิด Mixed Mode + restart service |

ในคลาสนี้: นักเรียนเชื่อมด้วย **SQL Auth** จากเครื่องตนเอง ส่วนวิทยากรสาธิต Windows Auth คู่กันบน Instance เดียวกัน

### 2) Security Boundary: Login ↔ User

```text
Client → Login (server principal) → User (database principal) → Permissions on Securables
```

- มี Login แต่ยังไม่ Map เป็น User ใน DB → เข้า Instance ได้ แต่ใช้ DB ไม่ได้
- Securables หลักที่ Lab เน้น: **Object / Schema / Database**

### 3) Permissions: GRANT / DENY / REVOKE

- **GRANT** — อนุญาต
- **DENY** — ปฏิเสธ และชนะ GRANT จาก Role อื่น
- **REVOKE** — ถอน GRANT หรือ DENY ที่เคยตั้ง

### 4) Schema-based Security

Schema เป็น Container + Security Boundary (ตั้งแต่ SQL Server 2005)  
ให้สิทธิ์ระดับ `SCHEMA::Sales` แทนการ GRANT ทีละตาราง → บริหารง่ายและสอดคล้อง Least Privilege

### 5) User-defined Database Roles

1. สร้าง Role (เช่น `HRUsers`)
2. GRANT สิทธิ์บน Schema ให้ Role
3. `ALTER ROLE ... ADD MEMBER`
4. ใช้ DENY ตารางความลับ (เช่น `EmployeePayHistory`) เป็นรายบุคคลเมื่อจำเป็น

## Demo (สำหรับวิทยากร)

แสดง Windows Auth ของวิทยากร แล้วสลับไป SQL Auth ของนักเรียนบน Instance เดียวกัน:

```sql
-- Run as instructor (Windows Auth / sysadmin)
SELECT SUSER_SNAME() AS login_name, ORIGINAL_LOGIN() AS original_login;

-- Show Mixed Mode is enabled (advanced option view via SSMS Server Properties is fine)
SELECT CASE SERVERPROPERTY('IsIntegratedSecurityOnly')
         WHEN 1 THEN 'Windows only'
         ELSE 'Mixed Mode'
       END AS auth_mode;
```

ตัวอย่าง Role + Schema (แนวคิดจาก MS-SQL-Essential):

```sql
USE s01_AdventureWorks; -- demo DB
GO

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = N'HRUsers' AND type = 'R')
    CREATE ROLE HRUsers;
GO

GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::HumanResources TO HRUsers;
DENY SELECT, INSERT, UPDATE, DELETE ON OBJECT::HumanResources.EmployeePayHistory TO HRUsers;
GO
```

## สรุป

- Login ≠ User — ต้อง Map ให้ครบก่อนใช้งาน DB
- Schema + Role ทำให้บริหารสิทธิ์รวมศูนย์
- DENY ใช้ sparingly สำหรับข้อมูลความลับ
- Lab ใช้ prefix `sXX_` เพื่อไม่ชนกันบน Instance ร่วม
- Least Privilege เป็นพื้นฐานก่อนลงมือ Backup/Agent ใน Module ถัดไป

## ต่อไป

- Lab: [Lab 01 — Security Roles & Schema](../../../labs/day-01/lab-01-security-roles/README.md)

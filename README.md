# SQL Server Administration for Performance Readiness (2-Day Intensive)

รหัสหลักสูตร: `SQL-ADMIN-2D-TUNE`  
สัดส่วน: ทฤษฎี 40% | Lab 60%  
ขอบเขต: **On-Premise** (Bridge Course สู่ Performance Tuning / 10987C)

## สภาพแวดล้อม Lab

| บทบาท | Authentication | เครื่องมือ |
|--------|----------------|------------|
| วิทยากร | Windows Auth (Domain) บน Member Server | SSMS บนเซิร์ฟเวอร์ GCP |
| นักเรียน | **SQL Auth** จากเครื่องตนเอง | SSMS 22 + Git |

- Instance ร่วมเครื่องเดียว — แยกงานด้วย prefix `sXX_` (เช่น `s01`, `s02`)
- Path กลางบนเซิร์ฟเวอร์: `D:\SqlLabs\`
- Module 5 (PowerShell / dbatools) = **Demo วิทยากรเท่านั้น**

## เปิด Lab ด้วย SSMS 22 + Git

1. ติดตั้ง [SSMS 22](https://learn.microsoft.com/sql/ssms/download-sql-server-management-studio-ssms) ที่มี Git integration
2. Clone repo นี้ไปยังเครื่องนักเรียน (หรือเปิดจาก Git ใน SSMS)
3. Connect ไปยัง Lab Instance ด้วย **SQL Authentication** (Login ที่วิทยากรแจก เช่น `s01`)
4. ตั้งค่า prefix ของคุณในทุกสคริปต์ (T-SQL editor ปกติ — **ไม่ต้อง** เปิด SQLCMD Mode):

```sql
DECLARE @StudentPrefix sysname = N's01';
```

5. เริ่มจาก Lesson ของ Module แล้วทำ Lab ตามลำดับ

## โครงสร้าง Day 1

| Module | Lesson | Lab |
|--------|--------|-----|
| 1 Security | [lesson.md](lessons/day-01/module-01-security/lesson.md) | [lab-01-security-roles](labs/day-01/lab-01-security-roles/) |
| 2 Transaction Log | [lesson.md](lessons/day-01/module-02-transaction-log/lesson.md) | [lab-02-transaction-log](labs/day-01/lab-02-transaction-log/) |
| 3 Backup & Restore | [lesson.md](lessons/day-01/module-03-backup-restore/lesson.md) | [lab-03-backup-restore](labs/day-01/lab-03-backup-restore/) |
| 4 SQL Server Agent | [lesson.md](lessons/day-01/module-04-sql-agent/lesson.md) | [lab-04-sql-agent](labs/day-01/lab-04-sql-agent/) |

วิทยากร: เตรียม Instance ตาม [labs/00-env-setup](labs/00-env-setup/)

## โครงสร้าง Day 2

| Module | Lesson | Lab / Demo |
|--------|--------|------------|
| 5 PowerShell + dbatools | [lesson.md](lessons/day-02/module-05-powershell-dbatools/lesson.md) | [demo-05-dbatools](labs/day-02/demo-05-dbatools/) *(วิทยากร)* |
| 6 Extended Events | [lesson.md](lessons/day-02/module-06-extended-events/lesson.md) | [lab-05-extended-events](labs/day-02/lab-05-extended-events/) |
| 7 DMVs | [lesson.md](lessons/day-02/module-07-dmvs/lesson.md) | [lab-06-dmvs-dashboard](labs/day-02/lab-06-dmvs-dashboard/) |
| 8 Troubleshooting | [lesson.md](lessons/day-02/module-08-troubleshooting/lesson.md) | [lab-07-troubleshooting](labs/day-02/lab-07-troubleshooting/) |

วิทยากร: เตรียม Day 2 ตาม [env-setup Day 2 checklist](labs/00-env-setup/README.md#checklist--day-2-ก่อนวันที่-2)

## เอกสารต้นทาง (local only)

- `SQL Server Admin Intensive.docx` / `.pptx` — gitignored ไม่ขึ้น GitHub

# Scenario A: Connectivity Checklist

ทำจาก **เครื่องนักเรียน** (ไม่ใช่ RDP บนเซิร์ฟเวอร์) ก่อนเปิด ticket ว่า "connect ไม่ได้"

## 1. Network reachability

```powershell
Test-NetConnection -ComputerName <lab-server-ip-or-hostname> -Port 1433
```

- `TcpTestSucceeded = True` → port เปิด
- ล้มเหลว → firewall, wrong IP, SQL ไม่ listen TCP

## 2. SSMS connection string

| Field | ค่าที่ใช้ในคลาส |
|-------|----------------|
| Server name | `<ip>,1433` หรือ hostname |
| Authentication | SQL Server Authentication |
| Login | `s01` (แทนด้วย login ของคุณ) |

## 3. Layer checklist

| Layer | ตรวจ | ผลของคุณ |
|-------|------|----------|
| OS / Network | ping / Test-NetConnection | ☐ |
| SQL Service | วิทยากรยืนยัน service running | ☐ |
| TCP / Port | 1433 reachable | ☐ |
| Auth | Login exists, not disabled | ☐ |
| Authorization | User mapped to `sXX_*` databases | ☐ |

## 4. Common errors

| Message / Error | Layer |
|-----------------|-------|
| Timeout (10060) | Network / firewall / wrong port |
| Server not found (26) | Wrong instance name / Browser |
| Login failed (18456) | Auth — wrong password or no permission |

## 5. บันทึกผล

- เวลาที่ทดสอบ: ___________
- Server ที่ connect: ___________
- สถานะ: ☐ Success  ☐ Failed — error: ___________

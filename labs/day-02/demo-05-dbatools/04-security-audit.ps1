# Demo 05-04: Security Audit
param(
    [string]$SqlInstance = 'localhost'
)

Import-Module dbatools -ErrorAction Stop
Set-DbatoolsConfig -FullName sql.connection.trustcert -Value $true

Write-Host "=== Orphan Users ===" -ForegroundColor Cyan
Get-DbaOrphanUser -SqlInstance $SqlInstance |
    Select-Object SqlInstance, Database, User, LastLogon |
    Format-Table -AutoSize

Write-Host "`n=== sysadmin members ===" -ForegroundColor Yellow
Get-DbaLogin -SqlInstance $SqlInstance -IncludeSysLogins |
    Where-Object { $_.IsSysAdmin -eq $true } |
    Select-Object Name, LoginType, IsDisabled |
    Format-Table -AutoSize

Write-Host "`n=== db_owner on user databases (sample) ===" -ForegroundColor Cyan
Get-DbaUserPermission -SqlInstance $SqlInstance |
    Where-Object { $_.Role -eq 'db_owner' -and $_.Database -like 's*_AdventureWorks' } |
    Select-Object Database, User, Role |
    Sort-Object Database, User |
    Format-Table -AutoSize

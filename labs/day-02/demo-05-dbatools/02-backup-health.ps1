# Demo 05-02: Backup Health (connects to Day 1 labs)
param(
    [string]$SqlInstance = 'localhost',
    [int]$MaxDaysWithoutFull = 1
)

Import-Module dbatools -ErrorAction Stop

$cutoff = (Get-Date).AddDays(-$MaxDaysWithoutFull)

Write-Host "=== Databases without Full Backup in last $MaxDaysWithoutFull day(s) ===" -ForegroundColor Cyan
Get-DbaLastBackup -SqlInstance $SqlInstance |
    Where-Object { $null -eq $_.LastFullBackup -or $_.LastFullBackup -lt $cutoff } |
    Select-Object Database, LastFullBackup, LastDiffBackup, LastLogBackup |
    Format-Table -AutoSize

Write-Host "`n=== All user DB backup summary ===" -ForegroundColor Cyan
Get-DbaLastBackup -SqlInstance $SqlInstance |
    Where-Object { $_.Database -notin 'master','model','msdb','tempdb' } |
    Select-Object Database, LastFullBackup, LastLogBackup |
    Sort-Object Database |
    Format-Table -AutoSize

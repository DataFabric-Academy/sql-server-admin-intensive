# Demo 05-01: Instance Inventory
# Run as Windows Auth on lab server

param(
    [string]$SqlInstance = 'localhost'
)

Import-Module dbatools -ErrorAction Stop

Write-Host "=== Instance ===" -ForegroundColor Cyan
Get-DbaInstance -SqlInstance $SqlInstance |
    Select-Object ComputerName, InstanceName, SqlVersion, Edition, IsClustered

Write-Host "`n=== Disk Space ===" -ForegroundColor Cyan
Get-DbaDiskSpace -SqlInstance $SqlInstance |
    Select-Object ComputerName, Name, Size, Free, PercentFree

Write-Host "`n=== SQL Services ===" -ForegroundColor Cyan
Get-DbaService -SqlInstance $SqlInstance |
    Select-Object ServiceType, ServiceName, State, StartMode

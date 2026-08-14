# Demo 05-01: Instance Inventory
# Run as Windows Auth on lab server

param(
    [string]$SqlInstance = 'localhost'
)

Import-Module dbatools -ErrorAction Stop
# Lab: self-signed / untrusted SQL cert (Microsoft.Data.SqlClient default)
Set-DbatoolsConfig -FullName sql.connection.trustcert -Value $true

Write-Host "=== Instance ===" -ForegroundColor Cyan
Connect-DbaInstance -SqlInstance $SqlInstance -TrustServerCertificate |
    Select-Object ComputerName, InstanceName, Version, Edition, IsClustered, ProductLevel

Write-Host "`n=== Disk Space ===" -ForegroundColor Cyan
Get-DbaDiskSpace -ComputerName $SqlInstance |
    Select-Object ComputerName, Name, Capacity, Free, PercentFree

Write-Host "`n=== SQL Services ===" -ForegroundColor Cyan
Get-DbaService -ComputerName $SqlInstance |
    Select-Object ServiceType, ServiceName, State, StartMode

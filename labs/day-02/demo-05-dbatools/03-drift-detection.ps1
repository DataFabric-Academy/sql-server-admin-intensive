# Demo 05-03: Configuration Drift Detection
param(
    [string]$SqlInstance = 'localhost'
)

Import-Module dbatools -ErrorAction Stop

Write-Host "=== sp_configure not compliant with best practice ===" -ForegroundColor Cyan
Test-DbaSpConfigure -SqlInstance $SqlInstance |
    Where-Object { $_.IsBestPractice -eq $false } |
    Select-Object Name, ConfiguredValue, RecommendedValue, IsBestPractice |
    Format-Table -AutoSize

Write-Host "`n=== Databases with AUTO_SHRINK ON ===" -ForegroundColor Yellow
Get-DbaDatabase -SqlInstance $SqlInstance |
    Where-Object { $_.IsAutoShrink -eq $true } |
    Select-Object Name, RecoveryModel, IsAutoShrink |
    Format-Table -AutoSize

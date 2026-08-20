# 1. Get current script path automatically
$scriptPath = $MyInvocation.MyCommand.Path
$taskName = "SmoothScroll_Update"

# 2. Check and register scheduled task (only if not created)
if (-not (Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue)) {
    $trigger = New-ScheduledTaskTrigger -Daily -At 00:00
    $action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -WindowStyle Hidden -File '$scriptPath'"
    Register-ScheduledTask -TaskName $taskName -Trigger $trigger -Action $action -Description "Run update.ps1 daily at 00:00" | Out-Null
    Write-Host "Scheduled task '$taskName' created successfully."
} else {
    Write-Host "Scheduled task '$taskName' already exists, skipping creation."
}

# 3. Modify registry logic
$currentTS = [int64](Get-Date -UFormat %s) - 36000

$regPath = "HKCU:\SOFTWARE\SmoothScroll"
if (-not (Test-Path $regPath)) {
    New-Item -Path $regPath -Force | Out-Null
}
Set-ItemProperty -Path $regPath -Name "kSSInstallDate" -Value $currentTS.ToString() -ErrorAction Stop

$offsetTS = $currentTS + 594875
Set-ItemProperty -Path $regPath -Name "kSSStatsDisabledSentAt" -Value $offsetTS.ToString() -ErrorAction Stop

Write-Host "----------------------------------------"
Write-Host "kSSInstallDate         : $currentTS"
Write-Host "----------------------------------------"
Write-Host "Registry updated successfully."
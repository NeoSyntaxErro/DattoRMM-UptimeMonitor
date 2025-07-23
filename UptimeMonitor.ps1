# Endpoint Uptime RMM Monitoring Component.
# Scripted by: Steffen Teall (neosyntaxerro)

# This monitoring component requires NO remediation component to be associated with it.
# Monitoring Component runs ONCE daily, checks to see if there is an older reboot task in the task
# library and removes it (since self deleting tasks rarely work due to their execution logic).
# The component will then grab the endpoints current uptime.  If it exceeds five days a task will be 
# registered to reboot the endpoint outside of working hours.

# The component will only generate a failed response (1) if the reboot task fails to register.
# Which can be configured in your RMM to generate a ticket indicating an issue with the components
# task registration execution. Not the endpoint iteself.

$LastBootUpTime = (Get-CimInstance -ClassName Win32_OperatingSystem).LastBootUpTime

if ($LastBootUpTime -isnot [datetime]) {
    $LastBootUpTime = [Management.ManagementDateTimeConverter]::ToDateTime($LastBootUpTime)
}

$Uptime = (Get-Date) - $LastBootUpTime
$UptimeDays = $Uptime.Days

$existingTask = Get-ScheduledTask -TaskName "Routine Reboot" -ErrorAction SilentlyContinue

if ($existingTask) {
    if ($UptimeDays -gt 5) {
        Write-Host "<-Start Result->"
        Write-Host "STATUS=REBOOT SCHEDULED"
        Write-Host "<-End Result->"
        exit 0
    } else {
        Unregister-ScheduledTask -TaskPath "\" -TaskName "Routine Reboot" -Confirm:$false -ErrorAction SilentlyContinue
    }
}

if ($UptimeDays -gt 5) {
    schtasks.exe /Create /SC ONCE /TN "Routine Reboot" /TR "shutdown /r /f /t 0" /ST 23:30 /RU "SYSTEM" /F
    $exitCode = $LASTEXITCODE

    if ($exitCode -ne 0) {
        Write-Host '<-Start Result->'
        Write-Host 'STATUS=COMP ERROR'
        Write-Host '<-End Result->'
        exit 1
    } else {
        Write-Host '<-Start Result->'
        Write-Host 'STATUS=EXCEEDED'
        Write-Host '<-End Result->'
        exit 0
    }
} else {
    Write-Host '<-Start Result->'
    Write-Host 'STATUS=OK'
    Write-Host '<-End Result->'
    exit 0    
}


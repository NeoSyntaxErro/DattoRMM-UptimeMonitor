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

### P R E V I O U S   T A S K   C L E A N - U P ###
if (Get-ScheduledTask -TaskName "Routine Reboot" -ErrorAction SilentlyContinue) {
    Unregister-ScheduledTask -TaskPath "\" -TaskName "Routine Reboot" -Confirm:$false
}

### C O N V E R T   U P T I M E   T O   D A Y S ###
$LastBootUpTime = (Get-CimInstance -ClassName Win32_OperatingSystem).LastBootUpTime

if ($LastBootUpTime -isnot [datetime]) {
    $LastBootUpTime = [Management.ManagementDateTimeConverter]::ToDateTime($LastBootUpTime)
}

$Uptime = (Get-Date) - $LastBootUpTime
$UptimeDays = $Uptime.Days

### U P D A T E   E N D P O I N T   M O N I T E R   U D F ###
if ( $UptimeDays -gt 5) {
    schtasks.exe --% /Create /SC ONCE /TN "Routine Reboot" /TR "shutdown /r /f /t 0" /ST 23:30 /F
    if (-not($?)) {
        Write-Host '<-Start Result->'
        Write-Host 'STATUS=COMP ERROR'
        Write-Host '<-End Result->'
        #exit 1      # Raise ticket with NOC that the task failed to register.
    } else {
        Write-Host '<-Start Result->'
        Write-Host 'STATUS=EXCEEDED'
        Write-Host '<-End Result->'
        #exit 0
    }
} else {
    Write-Host '<-Start Result->'
    Write-Host 'STATUS=OK' 
    Write-Host '<-End Result->'
    #exit 0
}

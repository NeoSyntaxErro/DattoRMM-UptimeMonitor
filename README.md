
# Endpoint Uptime RMM Monitoring Component

**Scripted by: Steffen Teall (neosyntaxerro)**

## Overview

This PowerShell script is designed to run once daily as an RMM (Remote Monitoring and Management) monitoring component. It evaluates the uptime of an endpoint and, if the uptime exceeds five days, schedules a reboot during off-hours.

> ✅ This component **does not** require an associated remediation script.

## Key Features

- **Automatic Task Cleanup:** Removes any existing "Routine Reboot" scheduled task to prevent duplicates.
- **Uptime Monitoring:** Calculates the system's current uptime based on the last boot time.
- **Scheduled Reboot:** If uptime exceeds five days, it schedules a reboot at 2:30 AM using Task Scheduler.
- **Error Handling:** If the task fails to register, the script exits with a non-zero code to raise an alert.
- **Flexible Deployment** Built originally for Datto RMM but can be easily re-used and repurposed.

## Script Logic

1. **Task Cleanup**
   - Checks for an existing task named `"Routine Reboot"`.
   - If found, it deletes the task.

2. **Uptime Calculation**
   - Retrieves the last boot time using `Win32_OperatingSystem`.
   - Converts it to a DateTime object if necessary.
   - Calculates the total uptime in days.

3. **Reboot Scheduling**
   - If uptime exceeds **5 days**, it attempts to schedule a reboot at **23:30 PM** using `schtasks`.
   - If task registration fails, it outputs a status of `COMP ERROR` and exits with `1`.
   - If successful, it outputs `STATUS=EXCEEDED` and exits with `0`.

4. **Normal Operation**
   - If uptime is **5 days or less**, the script outputs `STATUS=OK` and exits with `0`.

## Example Output

```
<-Start Result->
STATUS=EXCEEDED
<-End Result->
```

## Usage

Deploy this script as a monitoring-only component in your RMM solution to enforce regular reboots of Windows endpoints without user intervention. It ensures minimal impact on productivity by rebooting during non-working hours.

---

For feedback or improvements, feel free to fork or open a pull request.

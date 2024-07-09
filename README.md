# Monitor-DomainAdminLogonAttempts.ps1

## Overview

This PowerShell script is designed to monitor and report on successful logon attempts by domain admin users within a specified timeframe (defaulting to the last 10 days). The script retrieves security logs from the Windows Event Log, filters for successful logon events (Event ID 4624), and extracts relevant information such as the timestamp, username, logon type, and computer name.

## Features

- **Time Frame Specification:** Defines a start date, defaulting to 10 days prior to the current date, allowing it to focus on recent logon attempts.
- **Event Filtering:** Filters the security logs to capture only successful logon events (Event ID 4624).
- **Information Extraction:** Extracts critical information from the log events, including the time of creation, username, logon type, and computer name.
- **System Account Exclusion:** Filters out system accounts and anonymous logon attempts to focus on actual user activity.
- **Domain Admin Verification:** Includes a function to verify if a user is a domain admin by checking their membership in the 'Domain Admins' group.
- **Domain Admin Access Logs:** Filters the logon attempts to identify and isolate those made by domain admin users.
- **Unique User Grouping:** Groups the domain admin logon attempts by username to provide a unique list of domain admin users who accessed the server, along with the count of their logon attempts.
- **Output Formatting:** Outputs the results in a neatly formatted table for easy review and analysis.

## Prerequisites

- **PowerShell** installed and configured on the system.
- **Administrative permissions** to access and read Windows Event Logs and Active Directory information.

## Usage

1. **Download and Save Script:**
   Save the script as `Monitor-DomainAdminLogonAttempts.ps1`.

2. **Edit the Script (if necessary):**
   Modify any variables or settings within the script as needed to fit your environment.

3. **Run the Script:**
   Open PowerShell with administrative privileges and run the script:

# Script Breakdown

```powershell
$events = Get-WinEvent -FilterHashtable @{LogName='Security'; Id=$logonEventID; StartTime=$startDate} -MaxEvents 10000

# Define the start date (10 days ago)
$startDate = (Get-Date).AddDays(-10)

# Define the Event ID for successful logon attempts
$logonEventID = 4624

# Get the security logs for the specified event ID and time frame
$events = Get-WinEvent -FilterHashtable @{LogName='Security'; Id=$logonEventID; StartTime=$startDate} -MaxEvents 10000

# Extract relevant information
$userAccessLogs = $events | Select-Object @{Name='TimeCreated'; Expression={$_.TimeCreated}},
                                      @{Name='UserName'; Expression={($_.Properties[5].Value)}},
                                      @{Name='LogonType'; Expression={($_.Properties[8].Value)}},
                                      @{Name='ComputerName'; Expression={($_.MachineName)}}

# Filter out system accounts and null values
$userAccessLogs = $userAccessLogs | Where-Object { $_.UserName -ne '' -and $_.UserName -notlike 'NT AUTHORITY*' -and $_.UserName -notlike 'ANONYMOUS LOGON' }

# Function to check if a user is a domain admin
function Is-DomainAdmin($username) {
    $domainAdminsGroup = [ADSI]"LDAP://CN=Domain Admins,CN=Users,DC=domain,DC=com"
    $domainAdminsGroupMembers = $domainAdminsGroup.psbase.Invoke("Members") | ForEach-Object { $_.GetType().InvokeMember("SamAccountName", 'GetProperty', $null, $_, $null) }
    return $domainAdminsGroupMembers -contains $username
}

# Check each user and filter for domain admins
$domainAdminAccessLogs = $userAccessLogs | Where-Object { Is-DomainAdmin($_.UserName) }

# Group and display unique domain admin users who accessed the server
$uniqueDomainAdminAccessLogs = $domainAdminAccessLogs | Group-Object UserName | Select-Object Name, Count

# Output the results
$uniqueDomainAdminAccessLogs | Format-Table -AutoSize

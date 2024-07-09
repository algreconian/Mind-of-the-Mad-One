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

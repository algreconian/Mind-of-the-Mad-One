# Ensure the script is run with administrative permissions and has the required Exchange management role
# Assign the necessary permissions
New-ManagementRoleAssignment –Role "Mailbox Import Export" –User AvanHeerden@Harmony.co.za

# Define the export path and mailbox
$ExportPath = "\\host\share"
$Mailbox = "specify username"
$PstFilePath = "$ExportPath\$($Mailbox -replace '@', '_')_Calendar.pst"

# Ensure the export path exists
if (-not (Test-Path -Path $ExportPath)) {
    New-Item -ItemType Directory -Path $ExportPath
}

# Corrected IncludeFolders path with escaped backslashes
$CalendarFolderPath = "Top of Information Store\\Calendar"

# Create the export request with the correct path format
New-MailboxExportRequest -Mailbox $Mailbox -IncludeFolders $CalendarFolderPath -FilePath $PstFilePath

# Monitor the export request
Start-Sleep -Seconds 10  # Wait for a short period before checking the status

# Fetching export request status and output the results
Get-MailboxExportRequest -Mailbox $Mailbox | Get-MailboxExportRequestStatistics

# Optional: Continuously monitor the export status until it completes
do {
    $status = Get-MailboxExportRequest -Mailbox $Mailbox | Get-MailboxExportRequestStatistics
    Write-Output $status.Status
    Start-Sleep -Seconds 10  # Adjust the interval as necessary
} while ($status.Status -ne "Completed" -and $status.Status -ne "Failed")

if ($status.Status -eq "Completed") {
    Write-Output "Mailbox export completed successfully."
} else {
    Write-Output "Mailbox export failed."
}

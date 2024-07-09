Export-MailboxCalendarToPST.ps1

Overview
This PowerShell script is designed to export the calendar of a specified Exchange mailbox to a PST file. The script assigns the necessary permissions, verifies the existence of the export path, initiates the export request, and monitors the status of the export process.

Features
Permission Assignment: Ensures the script runs with the required administrative permissions and assigns the "Mailbox Import Export" role to the specified user.
Export Path Verification: Checks if the specified export path exists and creates it if necessary.
Calendar Export: Defines the mailbox and export path, constructs the file path for the PST file, and initiates the export request for the calendar folder.
Status Monitoring: Monitors the status of the mailbox export request, providing real-time updates until the export process is completed or fails.
Output and Feedback: Outputs the final status of the export process, indicating whether it was successful or not.

Prerequisites
PowerShell with administrative permissions on the Exchange server.
Exchange management tools installed and configured.
Appropriate permissions to assign management roles and export mailbox data.

Usage
Download and Save Script:
Save the script as Export-MailboxCalendarToPST.ps1.

Edit the Script:
Modify the following variables in the script as needed:
$ExportPath - The path where the PST file will be saved.
$Mailbox - The email address of the mailbox to be exported.

# Script logging 101 

# Define log file with date-based rotation
$logFile = "C:\Logs\script_$(Get-Date -Format 'yyyy-MM-dd_HH-mm-ss').log"

# Start PowerShell logging
Start-Transcript -Path $logFile -Append

# Function for logging messages
function Write-Log {
    param ($message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "$timestamp - $message"
    Write-Output $logMessage | Tee-Object -FilePath $logFile -Append
}

# Start logging
Write-Log "Script started."

# Run a PowerShell command and log output
$diskSpace = Get-PSDrive C
Write-Log "Available space on C: $($diskSpace.Free / 1GB) GB"

# Run external command (e.g., robocopy) and capture output
Write-Log "Starting backup..."
robocopy "C:\Source" "D:\Backup" /E /MIR | Tee-Object -FilePath $logFile -Append
Write-Log "Backup completed."

# Stop transcript logging
Stop-Transcript


# E-mail alerting

$to = "your@email.com"
$from = "backup@email.com"
$smtpServer = "smtp.yourmailserver.com"
$subject = "Backup Report"
$body = "Backup completed successfully at $(Get-Date)."
$logFile = "C:\Logs\backup.log"

Send-MailMessage -To $to -From $from -Subject $subject -Body $body -SmtpServer $smtpServer -Attachments $logFile

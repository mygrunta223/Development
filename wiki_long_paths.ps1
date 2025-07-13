# Set the paths
# This script identifies long paths in a specified source directory using robocopy.
# Ensure you have the necessary permissions to run this script.
# Set the source directory

$target = "N:\backups\cloud_offline\wiki_full_backups"

# Create target directory if it doesn't exist
if (-not (Test-Path -Path $target)) {
    New-Item -ItemType Directory -Path $target | Out-Null
}

# Use robocopy to identify long paths
robocopy $target /L /MAXLAD:260 /E /LOG:"C:\SWORD_LOGS\LongPaths.txt"


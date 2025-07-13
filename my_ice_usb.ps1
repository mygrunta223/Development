# Some development notes ;
# Needed ;
# * Logging (nice to have BUT this is going to be a manually executed (and monitored in person) process)
# * Flags to check and flag to update
# * DO differences exist? 
# * messenging (ntfy or Gotfy)?? Necessary? Really

# CONFIGURATION
$usbLabel = "HUSKY"
$sourceFiles = @(
    "C:\Users\Declan\Documents\Passwords\Passwords.kdbx",
    "C:\Users\Declan\Documents\Passwords\TiddlyWiki.html",
    "C:\Users\Declan\Documents\important-stuff\"
)

# Find USB by volume label
# Get the drive letter of the USB device
#$usbDrive = (Get-WmiObject -Class Win32_Volume | Where-Object { $_.DriveLetter -and $_.Label -eq "$usbLable" }).DriveLetter
$usbDrive = (Get-WmiObject -Class Win32_Volume | Where-Object { $_.DriveLetter -and $_.Label -eq "HUSKY" }).DriveLetter
# Check if the USB drive is found
if (-not $usbDrive) {
    Write-Host "USB drive with label '$usbLabel' not found. Please check the connection."
    exit
}

# Display the USB drive found
Write-Host "USB drive found: $usbDrive"

$targetPath = "$($usbDrive.DriveLetter)\ICE_Backup"
New-Item -ItemType Directory -Path $targetPath -Force | Out-Null
# Check if the target path exists, if not, create it
if (-not (Test-Path -Path $targetPath)) {
    New-Item -Path $targetPath -ItemType Directory
    Write-Host "Created directory: $targetPath"
} else {
    Write-Host "Directory already exists: $targetPath"
}
# Display the target path
Write-Host "Target path for backup: $targetPath"

# Ensure the source files exist before copying
if (-not (Test-Path -Path $sourceFiles[0])) {
    Write-Host "Source files not found. Please check the paths."
    exit
}   

# Display the source files to be copied
Write-Host "Source files to be copied:"
foreach ($file in $sourceFiles) {
    Write-Host "- $file"
}

# Copy files
foreach ($file in $sourceFiles) {
    $dest = Join-Path $targetPath (Split-Path $file -Leaf)
    if (Test-Path $file) {
        Write-Host "Copying $file to $dest"
        # Copy-Item -Path $file -Destination $dest -Recurse -Force
    } else {
        Write-Host "File not found: $file"
    }
}

Write-Host "Backup complete. Your ICE USB is now updated."
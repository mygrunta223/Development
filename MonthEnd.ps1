# Author: dhjac
# Date: 2023-10-01
# Description: MonthEnd.ps1
# Requires: Version 5.1
# This script performs a month-end backup by copying files from a specified source directory and an Oasis folder to external USB
# storage. It creates a new folder for the previous month on the USB drive if it doesn't already exist.
# Ensure the script runs with appropriate permissions   
# and that the USB drive is connected and labeled as "USB". 

# Set the source directory for the files to be copied
$sourceDirectory = "C:\Users\dhjac\OneDrive\Documents\Development\testing\SourceDIR"  # Modify this path as needed

# Check if the source directory exists
if (-not (Test-Path -Path $sourceDirectory)) {
    Write-Host "Source directory not found: $sourceDirectory. Please check the path."
    exit
}

# Set the path to the Oasis folder on the local drive
$oasisFolder = "N:\temp\oasis"  # Modify this path as needed

# Check if the Oasis folder exists on the local drive
if (-not (Test-Path -Path $oasisFolder)) {
    Write-Host "Oasis folder not found at $oasisFolder. Please check the path."
    exit
}

# Get the drive letter of the USB device
$usbDrive = (Get-WmiObject -Class Win32_Volume | Where-Object { $_.DriveLetter -and $_.Label -eq "HUSKY" }).DriveLetter

# Check if the USB drive is found
if (-not $usbDrive) {
    Write-Host "USB drive not found. Please check the connection."
    exit
}

Write-host "USB drive found: $usbDrive"

# Get the current date, subtract one month to get the previous month for which we are running the month end
$previousMonth = (Get-Date).AddMonths(-1).ToString("MMMM")

# Create the previous month folder on the USB device
$usbMonthFolder = "${usbDrive}\TheHereAndNow\2025\$previousMonth"

Write-Host "Creating folder for previous month: $usbMonthFolder"

# Check if the USB month folder already exists, if not, create it
if (-not (Test-Path -Path $usbMonthFolder)) {
    New-Item -Path $usbMonthFolder -ItemType Directory
    Write-Host "Created new folder: $usbMonthFolder"
}
else {
    Write-Host "Looks like we've already created a $previousMonth directory on the USB drive."
    prompt "Do you want to continue? (Y/N)" -default "N"
    $response = Read-Host
    if ($response -ne "Y") {
        Write-Host "Exiting script as per user request."
        exit
    }   
}

# Copy all files from the source directory to the USB drive
Write-Host "Copying files from $sourceDirectory to $usbMonthFolder"
Copy-Item -Path "$sourceDirectory\*" -Destination "$usbMonthFolder" -Recurse -Force

# Copy files from the Oasis folder to the new $month folder on the USB drive
Write-Host "Copying files from $oasisFolder to $usbMonthFolder"
Copy-Item -Path "$oasisFolder\*" -Destination $usbMonthFolder -Recurse -Force

Write-Host "Month-end backup for $previousMonth completed successfully."
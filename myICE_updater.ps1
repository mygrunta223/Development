# Author: dhjac
# Date: 2025-07-11
# myICE_updater.ps1
# Description: This script updates the myICE.html file on the HUSKY USB drive and copies the KeePass database to the same drive.
# It allows for updating specific fields in the HTML file and optionally creating a backup.
# Usage: myICE_updater.ps1 -WikiPath "E:\ICE.html" -KeepassSourcePath "C:\Users\Me\Documents\KeePass\MyDatabase.kdbx" -MasterPassword "your_password" -ContactTelephone "123-456-7890" -Backup

param (
    [string]$WikiPath = "E:\ICE.html",          # Path on HUSKY
    [string]$KeepassSourcePath = "C:\Users\dhjac\OneDrive\Documents\Development\Scripts\myTestDatabase.kdbx",
    [string]$MasterPassword,
    [string]$ContactTelephone,
    [switch]$Backup
)

# Define HUSKY drive letter, e.g. E:
$HuskyLabel = "HUSKY"
$HuskyDrive = (Get-WmiObject Win32_LogicalDisk | Where-Object { $_.VolumeName -eq $HuskyLabel }).DeviceID

# Sanity check for HUSKY
if (-not $HuskyDrive) {
    Write-Error "HUSKY drive not found! Please attach the USB drive labeled 'HUSKY'."
    exit 1
}

# ICE.html path on HUSKY
$WikiPath = Join-Path $HuskyDrive "myICE.html"
$KeepassDestPath = Join-Path $HuskyDrive "myTestDatabase.kdbx"

# Sanity check for ICE.html
if (-not (Test-Path $WikiPath)) {
    Write-Error "myICE.html not found on HUSKY drive!"
    exit 1
}

# Sanity check for KeePass DB
if (-not (Test-Path $KeepassSourcePath)) {
    Write-Host "KeePass database not found at $KeepassSourcePath!"
    exit 1
}

# Update ICE.html as before
function Update-TiddlerText {
    param(
        [string]$Html,
        [string]$TiddlerTitle,
        [string]$NewText
    )
    $escapedTitle = [regex]::Escape($TiddlerTitle)
    $pattern = "(?s)(<div[^>]*data-title=""$escapedTitle""[^>]*>)(.*?)(</div>)"
    $replacement = "`$1$NewText`$3"
    return [regex]::Replace($Html, $pattern, $replacement)
}

if ($Backup) {
    $backupPath = "$WikiPath.bak"
    Copy-Item $WikiPath $backupPath -Force
    Write-Host "Backup created at $backupPath"
}

$html = Get-Content $WikiPath -Raw

if ($MasterPassword) {
    $html = Update-TiddlerText -Html $html -TiddlerTitle "MasterPassword" -NewText $MasterPassword
    Write-Host "Updated Master Password"
}
if ($ContactTelephone) {
    $html = Update-TiddlerText -Html $html -TiddlerTitle "ContactTelephone" -NewText $ContactTelephone
    Write-Host "Updated Contact Telephone"
}

Set-Content $WikiPath $html
Write-Host "TiddlyWiki updated successfully."

# Copy KeePass DB to HUSKY
Copy-Item $KeepassSourcePath $KeepassDestPath -Force
Write-Host "KeePass database copied to HUSKY."
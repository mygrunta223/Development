# ICE USB Backup Script
# Declan's Digital Go Bag

# Prompt for login info
$AdminLogin = Read-Host "Enter admin login name"
$MasterPassword = Read-Host "Enter master password"

# Paths
$tiddlyPath = "C:\Users\dhjac\OneDrive\Documents\myToolBox\Scripts\development\empty.html"
$kdbxPath   = "C:\Users\dhjac\OneDrive\Documents\myToolBox\Scripts\development\myTestDatabase.kdbx"
$extraFolder = "C:\Users\dhjac\OneDrive\Documents\myToolBox\Scripts\development\important-stuff"

# USB detection
$usbLabel = "ICE_USB"
$usbDrive = Get-Volume | Where-Object { $_.FileSystemLabel -eq $usbLabel }

if (-not $usbDrive) {
    Write-Host "`nUSB drive with label '$usbLabel' not found. Plug it in and try again." -ForegroundColor Red
    exit
}

$targetPath = "$($usbDrive.DriveLetter):\ICE_Backup"
New-Item -ItemType Directory -Path $targetPath -Force | Out-Null

# Backup TiddlyWiki before editing
$tiddlyBackup = "$tiddlyPath.bak"
Copy-Item $tiddlyPath $tiddlyBackup -Force

# Load and update TiddlyWiki HTML
$html = Get-Content $tiddlyPath -Raw

$newCredentials = @"
<!--START_CREDENTIALS-->
<b>Admin Login:</b> $AdminLogin<br>
<b>Master Password:</b> $MasterPassword
<!--END_CREDENTIALS-->
"@

$html = [regex]::Replace(
    $html,
    '<!--START_CREDENTIALS-->.*?<!--END_CREDENTIALS-->',
    [System.Text.RegularExpressions.Regex]::Escape($newCredentials),
    [System.Text.RegularExpressions.RegexOptions]::Singleline
)

Set-Content -Path $tiddlyPath -Value $html

# Copy files to ICE USB
$filesToCopy = @($tiddlyPath, $kdbxPath)

foreach ($file in $filesToCopy) {
    $dest = Join-Path $targetPath (Split-Path $file -Leaf)
    Write-Host "Copying $file → $dest"
    Copy-Item -Path $file -Destination $dest -Force
}

# Copy extra folder
if (Test-Path $extraFolder) {
    Write-Host "Copying $extraFolder → $targetPath\important-stuff"
    Copy-Item -Path $extraFolder -Destination "$targetPath\" -Recurse -Force
}

Write-Host "`n ICE Backup complete!" -ForegroundColor Green

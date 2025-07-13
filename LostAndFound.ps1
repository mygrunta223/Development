# Set source and target directories
$sourceDir = "C:\Users\dhjac\OneDrive\Documents\Development\testing\SourceDIR"
$targetDir = "C:\Users\dhjac\OneDrive\Documents\Development\testing\DestDIR"
$foundDir = Join-Path -Path $sourceDir -ChildPath "FOUND"

# Create FOUND directory if it doesn't exist
if (-not (Test-Path $foundDir)) {
    New-Item -ItemType Directory -Path $foundDir | Out-Null
}

# Read the list of files to check
Get-Content -Path "C:\filelist.txt" | ForEach-Object {
    $filename = $_.Trim()
    
    # Construct full paths
    $sourceFile = Join-Path -Path $sourceDir -ChildPath $filename
    $targetFile = Join-Path -Path $targetDir -ChildPath $filename
    
    # Check if source file exists
    if (Test-Path $sourceFile) {
        # Check if file exists in target location
        if (Test-Path $targetFile) {
            try {
                # Move file to FOUND directory
                Move-Item -Path $sourceFile -Destination $foundDir -Force
                Write-Host "Moved $filename to FOUND directory" -ForegroundColor Green
            }
            catch {
                Write-Host "Error moving $filename: $_" -ForegroundColor Red
            }
        }
        else {
            Write-Host "File $filename exists in source but not in target location" -ForegroundColor Yellow
        }
    }
    else {
        Write-Host "File $filename not found in source location" -ForegroundColor Red
    }
}
# Define variables
$usbDriveLetter = "H:"
$usbDriveLabel = "MERCURY"
$sourceDir = "N:\data\media\games\new"
$destDir = "$usbDriveLetter\data\media\games\installers\new"

# Check if the USB drive exists and has the correct label
$drive = Get-Volume -DriveLetter $usbDriveLetter.TrimEnd(':') -ErrorAction SilentlyContinue
if ($drive -and $drive.FileSystemLabel -eq $usbDriveLabel) {

    # Ensure destination directory exists
    if (-not (Test-Path $destDir)) {
        New-Item -Path $destDir -ItemType Directory | Out-Null
    }

    # Do some sanity checking
    # Calculate total size to move
    $sourceDirs = Get-ChildItem -Path "N:\data\media\games" -Directory | Where-Object { $_.Name -notin @("ARCHIVED", "UPDATES") }
    $totalSize = ($sourceDirs | Get-ChildItem -Recurse | Measure-Object -Property Length -Sum).Sum

    # Convert to GB
    $totalSizeGB = [math]::Round($totalSize / 1GB, 2)

    # Check free space on destination
    $destDrive = Get-PSDrive -Name H
    $freeSpaceGB = [math]::Round($destDrive.Free / 1GB, 2)

    # Check if enough space
    if ($freeSpaceGB -lt $totalSizeGB) {
        Write-Error "Not enough space on destination drive. $freeSpaceGB GB available, $totalSizeGB GB required."
    exit
    }

    # Warn if threshold exceeded
    if ($totalSizeGB -gt 10) {
        Write-Warning "You are about to move $totalSizeGB GB. Continue? (Y/N)"
        $response = Read-Host
        if ($response -ne 'Y') { exit }
    }
    Write-Host "Moving $totalSizeGB GB of data to $destDir"
   
    # Get directories in the source directory
    $dirs = Get-ChildItem -Path $sourceDir -Directory
    foreach ($dir in $dirs) {
        $sourcePath = $dir.FullName
        $destPath = Join-Path $destDir $dir.Name
        
        # Uncomment the following lines to check permissions
        # This is optional and can be used for debugging purposes
        #$acl = Get-Acl $dir.FullName
        #Write-Output "Permissions for $($dir.FullName):" $acl.Access | Format-Table IdentityReference, FileSystemRights, AccessControlType

        # Exclude certain directories from being moved
        $excludedDirs = @("UPDATES", "ARCHIVED") # Replace with actual directory names to exclude

        if ($excludedDirs -contains $dir.Name) {
            Write-Host "Skipping excluded directory: $($dir.Name)"
            continue
        }

        # Create the directory if it doesn't already exist at the destination
        if (-not (Test-Path $destPath)) {
           # Create the destination directory
            Write-Host "Creating destination directory: $destPath"      
            New-Item -Path $destPath -ItemType Directory | Out-Null
        }
        else {
            Write-Host "Destination directory already exists: $destPath"
        }      
        
        # Move the directory
         Write-Host "Moving $sourcePath to $destPath"    
        # Use -Recurse to move all contents and -Force to overwrite if necessary
        # Use -PassThru to return the moved item
        # Move-Item -Path $sourcePath -Destination $destPath -Recurse -Force -PassThru
        # Use Robocopy with verbose output and progress
            $robocopyCmd = @(       
                "robocopy"
                "$sourcePath"
                "$destPath"
                "/mov"                    # Move files (instead of copy)
                "/e"                      # Copy subdirectories, including empty ones
                "/mt:8"                   # Use 8 threads for better performance
                "/w:1"                    # Wait 1 second between retries
                "/r:1"                    # Retry once if failed
                "/v"                      # Verbose output
                "/eta"                    # Show estimated time to completion
                "/fp"                     # Include full path in log
                "/bytes"                  # Show sizes in bytes
                "/log+:move_torrents.log" # Append output to log file
                "/tee"                    # Output to console and log file
            )
            # Execute the robocopy command
            Write-Host "Executing: $($robocopyCmd -join ' ')"
            #Start-Process -FilePath "robocopy" -ArgumentList $robocopyCmd -NoNewWindow -Wait
            
            if ($LASTEXITCODE -eq 0) {
                Write-Host "Successfully moved $sourcePath to $destPath" -ForegroundColor Green
            } elseif ($LASTEXITCODE -eq 1) {
                Write-Host "No files were copied, but no errors occurred." -ForegroundColor Yellow
            } else {
                Write-Error "Robocopy failed with exit code $LASTEXITCODE"
            }
        } else {
            Write-Host "Destination directory already exists: $destPath"
        }
} else {
    Write-Host "USB drive $usbDriveLetter with label '$usbDriveLabel' not found."
}
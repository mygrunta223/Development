# Set your variables
$HOME_DIR = "N:\data\media\games\new"
$DEST_DIR = "C:\Users\dhjac\Downloads"
$NUM_TO_COPY = 1  # Change this to however many directories you want to copy

# Get the list of directories in HOME_DIR
$dirs = Get-ChildItem -Path $HOME_DIR -Directory | Select-Object -First $NUM_TO_COPY

# Loop through and copy using ROBOCOPY
# Ensure the destination directory exists
if (-not (Test-Path -Path $DEST_DIR)) {
    New-Item -ItemType Directory -Path $DEST_DIR -Force | Out-Null
    Write-Host "Created destination directory: $DEST_DIR"
}

foreach ($dir in $dirs) {
    try {

    # Prepare source and destination paths
    $sourcePath = $dir.FullName
    $destPath = Join-Path $DEST_DIR $dir.Name

    Write-Output "Copying: $sourcePath to ${destPath}"

  # Create the Robocopy command array
    $robocopyCmd = @(
        "robocopy"
        $sourcePath
        $destPath
        "/mov"                    # Move files
        "/e"                      # Copy subdirectories, including empty ones
        "/mt:8"                   # Use 8 threads for better performance
        "/w:1"                    # Wait 1 second between retries
        "/r:1"                    # Retry once if failed
        "/v"                      # Verbose output
        "/eta"                    # Show estimated time to completion
        "/fp"                     # Include full path in log
        "/bytes"                  # Show sizes in bytes
    )

    # Output the command for testing
    Write-Host "Test command (copy and run in terminal):"
    Write-Host ($robocopyCmd -join ' ')
    
    # Exit the script since we're just testing
    # exit
    
    } catch {
        # Log detailed error information
        Write-Error "Failed to prepare command. Error: $_"
        Write-Debug "Source path exists: $(Test-Path $sourcePath)"
        Write-Debug "Destination directory exists: $(Test-Path $DEST_DIR)"
        Write-Debug "Source item type: $($dir.GetType().Name)"
        Write-Debug "Source item length: $(if ($dir.PSIsContainer) { "N/A" } else { $dir.Length })"
    }
}
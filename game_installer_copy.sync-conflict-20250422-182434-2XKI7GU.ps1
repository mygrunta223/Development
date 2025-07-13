# Set your variables
$HOME_DIR = "N:\data\media\games"
$DEST_DIR = "J:\Games"
$NUM_TO_COPY = 15  # Change this to however many directories you want to copy

# Get the list of directories in HOME_DIR
$dirs = Get-ChildItem -Path $HOME_DIR -Directory | Select-Object -First $NUM_TO_COPY

# Loop through and copy using ROBOCOPY
foreach ($dir in $dirs) {
    $sourcePath = $dir.FullName
    $destPath = Join-Path $DEST_DIR $dir.Name

    Write-Output "Copying: $sourcePath to ${destPath}"
    # ROBOCOPY command to copy directory
    
    robocopy $sourcePath $destPath /E /Z /MT:4 /W:1 /R:1 /MOV
    
    # /E - Copy subdirectories including empty ones
    # /Z - Restartable mode
    # /MT:4 - Multithreaded (adjust number of threads as needed)
}

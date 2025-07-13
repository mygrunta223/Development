# Set your variables
$HOME_DIR = "C:\Users\dhjac\OneDrive\Documents\myToolBox\Scripts\testing\SourceDIR"
$DEST_DIR = "C:\Users\dhjac\OneDrive\Documents\myToolBox\Scripts\testing\DestDIR"
$NUM_TO_COPY = 1  # Change this to however many directories you want to copy

# Get the list of directories in HOME_DIR
$dirs = Get-ChildItem -Path $HOME_DIR -Directory | Select-Object -First $NUM_TO_COPY

# Some sanity checking

if ((Test-Path $HOME_DIR) -and (Test-Path $DEST_DIR)) {
    Write-Host "The source directory exists."
} else {
    Write-Host "One of the directories specified doesn't exist. Please check and rerun the script"
}

# Loop through and copy using ROBOCOPY
foreach ($dir in $dirs) {
    $sourcePath = $dir.FullName
    $destPath = Join-Path $DEST_DIR $dir.Name

    Write-Output "Copying: $sourcePath to ${destPath}"
    # ROBOCOPY command to copy directory
    
    robocopy $sourcePath $destPath /E /Z /MT:4 /W:1 /R:1 /MOV /L
    $exitCode = $LASTEXITCODE

    if ($exitCode -lt 8) {

        Write-Host "Here. Destination path is :  '$destPath'"      

        # Escape the crazy square brackets in the directory path
        $sanitizedDirectory = $destPath -replace '(\[|\])', '``$&'

        # Test if the sanitized path exists
        Test-Path -Path $sanitizedDirectory

        if (Test-Path $sanitizedDirectory) {
            Write-Host "Doing some house keeping!!."    
            
            
            
            Write-Output "Here" $sourcePath -replace '(\[|\])', '``$&'

            $sourceItems = Get-ChildItem -Path $sourcePath -Recurse
            Write-Output $sourceItems.Count

            Write-Output "And here" $sanitizedDirectory
            $destItems = Get-ChildItem -Path $sanitizedDirectory -Recurse
            Write-Output $destItems.Count
            # Check if directories contain items

            if ($sourceItems.Count -gt 0 -and $destItems.Count -gt 0) {

                Write-Output "The directories are populated"

                # Check for differences

                $differences = Compare-Object -ReferenceObject $sourceItems -DifferenceObject $destItems
            
                Write-Output "DIFFERENCES" $differences

                    if ($differences.Count -eq 0) {
                        Write-Output "The directories are identical."
                    } else {
                        Write-Output "The directories are not identical."
                        $differences
                    }
            } else {
                Write-Output "Something bad has happened"
            } 
        }
    }
}            

  #  Remove-Item $sourcePath -Recurse -Force



#$differences = Compare-Object -ReferenceObject (Get-ChildItem -Path $destPath -Recurse) -DifferenceObject (Get-ChildItem -Path $sourcePath -Recurse)
      #      $differences

    #        if ($differences.Count -eq 0) {
     #           Write-Output "The directories are identical."
   #         } else {
 #               Write-Output "The directories are not identical."
#                $differences
  #          }
                # Try to remove the source directory after the move
               # if (Test-Path $sourcePath) {
                  #       Remove-Item $sourcePath -Recurse -Force -ErrorAction Stop
                #       Write-Host "Cleaned up source directory: $sourcePath"
                #} else {
                 #       Write-Warning "Could not delete $sourcePath — $_"
                #}   
#             } else {
 #               # Write-Host "Robocopy failed with exit code $exitCode — skipping cleanup." -ForegroundColor Red
  #              Write-Host "No cleanup done to keep original files intact."        

  
    # /E - Copy subdirectories including empty ones
    # /Z - Restartable mode
    # /MT:4 - Multithreaded (adjust number of threads as needed)

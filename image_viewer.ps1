# Set delay duration in milliseconds
$delayMs = 5000  # 5 seconds

# Get all image files in current directory
$imageFiles = Get-ChildItem .\Images\*.jpg, .\Images\*.jpeg, .\Images\*.png, .\Images\*.gif, .\Images\*.bmp

if ($imageFiles.Count -eq 0) {
    Write-Host "No images found in current directory!"
    exit
}

# Process each image
foreach ($index in 0..($imageFiles.Count-1)) {
    $file = $imageFiles[$index]
    Write-Progress -Activity "Image Slideshow" -Status "$($index+1)/$($imageFiles.Count)" -PercentComplete (($index/$imageFiles.Count)*100)
    
    # Open image
    Start-Process -FilePath $file.FullName
    
    # Wait for specified duration
    Start-Sleep -Milliseconds $delayMs
    
    # Close the most recently opened window
    Get-Process | Where-Object {$_.MainWindowTitle -ne ""} | Sort-Object Id -Descending | Select-Object -First 1 | Stop-Process -Force
}
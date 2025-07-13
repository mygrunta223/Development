# Set your variables
$HOME_DIR = "C:\Users\dhjac\OneDrive\Documents\myToolBox\Scripts\testing\SourceDIR"
$DEST_DIR = "C:\Users\dhjac\OneDrive\Documents\myToolBox\Scripts\testing\DestDIR"
$NUM_TO_COPY = 1  # Change this to however many directories you want to copy

# Function to sanitize a path
function Sanitize-Path {
    param([string]$path)

    if ([string]::IsNullOrWhiteSpace($path)) {
        throw "Path is null or empty."
    }

    $cleanPath = $path.Trim()

    # Remove trailing backslashes (but leave root drives like C:\ alone)
    if ($cleanPath.Length -gt 3 -and $cleanPath.EndsWith("\")) {
        $cleanPath = $cleanPath.TrimEnd('\')
    }

    # Allow square brackets, block only true invalid characters
    if ($cleanPath -match '[<>:"/\\|?*]') {
        throw "Path contains invalid characters: $cleanPath"
    }

    return $cleanPath
}

# Example usage:
try {
    $sourcePath = Sanitize-Path $sourcePath
    $destPath = Sanitize-Path $destPath
    Write-Host "Paths sanitized successfully."
    Write-Host "Source: '$sourcePath'"
    Write-Host "Destination: '$destPath'"
} catch {
    Write-Error "Path sanitization failed: $_"
    exit 1
}

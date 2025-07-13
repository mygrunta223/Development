# Set your variables
$rootPath = ".\"

# Now includes a space character at the start of the class
#$invalidCharsPattern = '[ <>:"/\\|?*]'
#$brandingPattern     = '\[.*?\]'

# Regex patterns
$invalidCharsPattern = '[\s<>:"/\\|?*]'    # ← now includes whitespace (spaces/tabs)
$brandingPattern     = '\[.*?\]'

function Set-SafeName {
    param ([string]$name)

    # 1) Strip out any branding tags
    $clean = $name -replace $brandingPattern, ''

    # 2) Replace spaces and all other invalid chars with underscores
    $clean = $clean -replace $invalidCharsPattern, '_'

    # 3) Collapse multiple underscores into one
    $clean = $clean -replace '_{2,}', '_'

    # 4) Trim leading/trailing underscores or spaces
    $clean = $clean.Trim('_',' ')

    return $clean
}

# Grab root + subdirectories
$allDirs = @(
    Get-ChildItem -Path $rootPath
)

foreach ($dirInfo in $allDirs) {

    $orig = $dirInfo.Name
    $parent = $dirInfo.Parent.FullName
    $new = Set-SafeName $orig
    

    if ($orig -ne $new) {
        $dest = Join-Path $parent $new
 
        try {
            Rename-Item -Path $dirInfo.FullName -NewName $dest -ErrorAction Stop
            Write-Host "Renamed $orig $new"
        } catch {
            Write-Warning "Failed to rename $orig $_"
        }
    } else {
        Write-Host "Already clean: $orig" 
    }  
}
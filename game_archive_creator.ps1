# Description: This script creates dummy files for games listed in a text file.
# The text file should contain one game name per line. The script will create a dummy File
# for each game in the specified output directory.
# This is useful for archiving of games but retaining a record of them without needing the actual game files.

# Set the input and output directories
$inputFile = "N:\data\media\games\Archived\ladybird_game_list.txt"

# Ensure the input file exists
if (-not (Test-Path $inputFile)) {
    Write-Host "Input file not found: $inputFile"
    exit
}
$outputDir = "N:\data\media\games\Archived"

# Read the games list and create dummy files
Get-Content -Path $inputFile | ForEach-Object {
    $gameName = $_
    $filePath = Join-Path -Path $outputDir -ChildPath "$gameName.txt"
    # Check if the file already exists
    if (Test-Path $filePath) {
        Write-Host "File already exists: $filePath"
        return
    }        
    # Create a dummy file with some content
    $content = "This is a dummy file for the game: $gameName"   
    New-Item -ItemType File -Path $filePath -Force | Out-Null
    Write-Host "Created file: $filePath"
}   
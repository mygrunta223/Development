# Only delete source if not dry run and exit code < 8
#if (-not $DryRun -and $exitCode -lt 8) {
 #   if (Test-Path $sourcePath) {
  #      try {
   #        # Remove-Item $sourcePath -Recurse -Force -ErrorAction Stop
    #        Write-Host "`nSource directory removed: $sourcePath" -ForegroundColor Green
     #   } catch {
      #      Write-Warning "Could not delete $sourcePath — $_"
       # }
   # }
#}
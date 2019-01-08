. ($RMLConfig["commondir"] + "\source.ps1")
Compress-Archive $dir\* $rc["outFile"] -Force

if (-not $NoRemove) {
    Remove-Item $dir -Recurse
} else {
    Write-Host "File preserved at $dir"
}


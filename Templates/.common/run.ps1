. ($RMLConfig["commondir"] + "\source.ps1")
pushd $dir
$proc =      Start-Process "Game.exe" -WindowStyle Hidden -PassThru
$proc.id | Out-File "pid" 
Wait-Process -id $proc.id
popd

if (-not $NoRemove) {
    Remove-Item $dir -Recurse
} else {
    Write-Host "File preserved at $dir"
}


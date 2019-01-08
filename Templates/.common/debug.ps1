. ($RMLConfig["commondir"] + "\source.ps1")

$ruby = $rc["ruby"]
$f2s  = $rc["f2s"]
Copy-Item ($rc["RML.ruby"] + "\Debug\*") "$dir" -Recurse -Force
Start-Process $ruby -ArgumentList $f2s, "$dir/client.rb", "$dir/Data/DebugClient.$suf","Data/Scripts.$suf" -Wait -WindowStyle Hidden
inimodify "$dir/Game.ini" "Scripts" "Data/DebugClient.$suf"
pushd $dir
Start-Process "cmd" -ArgumentList /c, "$ruby server.rb" -Wait
popd

if (-not $NoRemove) {
    Remove-Item $dir -Recurse
} else {
    Write-Host "File preserved at $dir"
}


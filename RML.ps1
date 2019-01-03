param (
    [string]$code,
    [string]$file,
    [string]$gen,
    [string[]]$arglist, 
    [switch] $run,
    [switch] $debug
)

$ruby = "RM3/ruby/bin/ruby.exe"
$f2s  = "RML/file2script.rb"
$suffix = @{
    RMXP  = "rxdata";
    RMVX  = "rvdata";
    RMVXA = "rvdata2";
}

if ($gen -eq $null) {
    $gen = "RMVXA"
}
if ($gen -notin @('RMXP','RMVX','RMVXA')) {
    Write-Error "-Gen must be one of RMXP,RMVX,RMVXA"
    exit
}

$dir = "runid_" + [guid]::NewGuid()
copy-item "RM3/System-$gen" $dir -Recurse
if ($file) { 
    copy $file $dir/main.rb
} else {
    if ($code) {
        $code | Out-File -Encoding utf8 $dir/main.rb
    } else {
        Write-Host "Error"
    }
}
$suf = $suffix[$gen]
&$ruby $f2s "$dir/main.rb" "$dir/Data/Scripts.$suf"
"Game.exe " + [System.String]::Join(" ", $arglist) | Out-File -Encoding Ascii "$dir/run.cmd"
pushd $dir
Start-Process "run.cmd" -Wait -WindowStyle Hidden
popd
Remove-Item $dir -Recurse

param (
    [string]   $Code,
    [string]   $File,
    [string]   $FromDir,
    [string]   $ZipFile,
    [string]   $Gen,
    [string[]] $Arglist, 
    [string]   $Title,
    [string]   $Pack,
    [switch]   $NoCopy,
    [switch]   $NoRemove,
    [switch]   $Debug,
    [switch]   $Clean
)

if ($Clean){
    foreach ($a in Get-Item "runid_*") {
        $pids = Get-Content "$a/pid" -erroraction 'silentlycontinue'
        foreach ($onepid in $pids) {
            Stop-Process -id $onepid -erroraction 'silentlycontinue'
        }
        Remove-Item $a -fo -r -erroraction 'silentlycontinue'
    }
    exit
} 
        
function inimodify($filename, $a, $b) {
    $content = Get-Content $filename
    $out = @()
    foreach($line in $content) {
        $outline = $line
        if ($line[0] -ne "[") {
            $name, $value = $line.Split("=")
            if ($name -eq $a) {
                $outline = $a + "=" + $b
            }
        }
        $out += $outline
    }
    Set-Content $filename $out
}


$ruby = (Get-Item "RM3/ruby/bin/ruby.exe").FullName
$f2s  = (Get-Item "RML/file2script.rb").FullName
$suffix = @{
    RMXP  = "rxdata";
    RMVX  = "rvdata";
    RMVXA = "rvdata2";
    RGD   = "rvdata2";
}

if ($gen -eq $null -or $gen -eq "") {
    $gen = "RMVXA"
}
if ($gen -notin $suffix.Keys) {
    Write-Error ("-Gen must be one of " + [System.String]::Join(" ", $suffix.Keys.Where({$true})))
    exit
}

$dir = "runid_" + [guid]::NewGuid()
if (-not $NoCopy) {
    copy-item "RM3/System-$gen" $dir -Recurse
} else {
    if (Test-Path $dir) {
        Remove-Item $dir
    }
    if (-not (Test-Path $dir)) {
        $null = mkdir $dir
    }
}
$suf = $suffix[$gen]
if ($file) { 
    $suf = $suffix[$gen]
    &$ruby $f2s "$dir/main.rb" "$dir/Data/Scripts.$suf"
} else {
    if ($code) {
        $code | Out-File -Encoding utf8 $dir/main.rb
        $suf = $suffix[$gen]
        Start-Process $ruby -ArgumentList $f2s, "$dir/main.rb", "$dir/Data/Scripts.$suf" -Wait -WindowStyle Hidden
    } else {
        if ($FromDir) {
            copy-item $FromDir\* $dir -Force -Recurse
        } else {
            if ($ZipFile) {
                Expand-Archive $ZipFile $dir -Force 
            } else {
                
            }
        }
    }
}

if ($arglist -eq $null) {
    $arglist = @()
}
if ($title) {
    inimodify "$dir/Game.ini" "Title" $title
}
#"Game.exe " + [System.String]::Join(" ", $arglist) | Out-File -Encoding Ascii "$dir/run.cmd"
if ($debug) {
        Copy-Item "RML\debug\*" "$dir"
        Start-Process $ruby -ArgumentList $f2s, "$dir/client.rb", "$dir/Data/DebugClient.$suf","Data/Scripts.$suf" -Wait -WindowStyle Hidden
        inimodify "$dir/Game.ini" "Scripts" "Data/DebugClient.$suf"
        pushd $dir
        Start-Process "cmd" -ArgumentList /c, "$ruby server.rb" -Wait
        popd
} else {
    if ($Pack) {
        Compress-Archive $dir\* $Pack -Force
    } else {
            pushd $dir
            $proc =      Start-Process "Game.exe" -WindowStyle Hidden -PassThru
            $proc.id | Out-File "pid" 
            Wait-Process -id $proc.id
            popd
        
    }
}


if (-not $NoRemove) {
    Remove-Item $dir -Recurse
} else {
    Write-Host "File preserved at $dir"
}

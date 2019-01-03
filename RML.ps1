param (
    [string]$Code,
    [string]$File,
    [string]$FromDir,
    [string]$ZipFile,
    [string]$Gen,
    [string[]]$Arglist, 
    [string] $Title,
    [string] $Command,
    [string] $OutFile,
    [switch] $NoCopy
)

$ini = Add-Type -memberDefinition @"
[DllImport("Kernel32")]
public static extern long WritePrivateProfileString (
string section ,
string key , 
string val , 
string filePath );
"@ -passthru -name MyPrivateProfileString

$ruby = "RM3/ruby/bin/ruby.exe"
$f2s  = "RML/file2script.rb"
$suffix = @{
    RMXP  = "rxdata";
    RMVX  = "rvdata";
    RMVXA = "rvdata2";
    RMVA  = "rvdata2"
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
if ($file) { 
    copy $file $dir/main.rb
    $suf = $suffix[$gen]
    &$ruby $f2s "$dir/main.rb" "$dir/Data/Scripts.$suf"
} else {
    if ($code) {
        $code | Out-File -Encoding utf8 $dir/main.rb
        $suf = $suffix[$gen]
        &$ruby $f2s "$dir/main.rb" "$dir/Data/Scripts.$suf"
    } else {
        if ($FromDir) {
            copy-item $FromDir\* $dir -Force -Recurse
        } else {
            if ($ZipFile) {
                Expand-Archive $ZipFile $dir -Force 
            } else {
                Write-Error "No -Code or -File present"
                exit
            }
        }
    }
}

if ($arglist -eq $null) {
    $arglist = @()
}
if ($title) {
    $null = $ini::WritePrivateProfileString("Game", "Title", $title, "$dir/Game.ini")
}
"Game.exe " + [System.String]::Join(" ", $arglist) | Out-File -Encoding Ascii "$dir/run.cmd"
if (-not $command) {
    $command = "run"
}

if ($command -eq "run") {
    pushd $dir
    Start-Process "run.cmd" -Wait -WindowStyle Hidden
    popd
}

if ($command -eq "pack") {
    Compress-Archive $dir\* $OutFile -Force
}
Remove-Item $dir -Recurse
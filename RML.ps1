param (
    [string]$Code,
    [string]$File,
    [string]$FromDir,
    [string]$ZipFile,
    [string]$Gen,
    [string[]]$Arglist, 
    [string] $Title,
    [string] $Pack,
    [switch] $NoCopy,
    [switch] $NoRemove,
    [switch] $Debug,
    [switch] $Clean
)

if ($Clean){
    Remove-Item runid_* -Force -Recurse
    exit
} 
        

$ini = Add-Type -memberDefinition @"
[DllImport("Kernel32")]
public static extern long WritePrivateProfileString (
string section ,
string key , 
string val , 
string filePath );
"@ -passthru -name MyPrivateProfileString

$ruby = (Get-Item "RM3/ruby/bin/ruby.exe").FullName
$f2s  = (Get-Item "RML/file2script.rb").FullName
$suffix = @{
    RMXP  = "rxdata";
    RMVX  = "rvdata";
    RMVXA = "rvdata2";
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
        Start-Process $ruby -ArgumentList $f2s, "$dir/main.rb", "$dir/Data/Scripts.$suf" -Wait -WindowStyle Hidden
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

if ($debug) {
        Copy-Item "RML\debug\*" "$dir"
        Start-Process $ruby -ArgumentList $f2s, "$dir/client.rb", "$dir/Data/DebugClient.$suf","Data/Scripts.$suf" -Wait -WindowStyle Hidden
        $null = $ini::WritePrivateProfileString("Game", "Scripts", "Data/DebugClient.$suf", "$dir/Game.ini")
        pushd $dir
        Start-Process "cmd" -ArgumentList /c, "$ruby server.rb" -Wait
        popd
} else {
    if ($Pack) {
        Compress-Archive $dir\* $Pack -Force
    } else {
            pushd $dir
            Start-Process "run.cmd" -Wait -WindowStyle Hidden
            popd
        
    }
}


if (-not $NoRemove) {
    Remove-Item $dir -Recurse
} else {
    Write-Host "File preserved at $dir"
}

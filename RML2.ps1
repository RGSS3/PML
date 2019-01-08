param (
    [parameter(
        Mandatory = $true,
        Position = 0
    )]
    [string]   $Command,
    [string]   $Gen,
    [string]   $Code,
    [string]   $File,
    [string]   $fromDir,
    [string]   $zipFile,
    [switch]   $empty,
    [string]   $NoCopy,
    [switch]   $NoRemove,
    [string[]]   $ArgList,
    [string]  $outFile,
    [string]   $Title
)

if ($Command -ieq "cleanall"){
    foreach ($a in Get-Item "runid_*") {
        $pids = Get-Content "$a/pid" -erroraction 'silentlycontinue'
        foreach ($onepid in $pids) {
            Stop-Process -id $onepid -erroraction 'silentlycontinue'
        }
        Remove-Item $a -fo -r -erroraction 'silentlycontinue'
    }
    exit
}

if (-not (Test-Path "Templates/$gen")) {
    Write-Error "template ``$gen`` not found."   
    exit
}

if (-not $gen) {
    $gen = "RMVXA"
}

$rc = $RMLConfig = @{}


$ruby = (Get-Item "RM3/ruby/bin/ruby.exe").FullName
$f2s  = (Get-Item "RML/file2script.rb").FullName

$rc["ruby"] = $ruby
$rc["f2s"]  = $f2s
$dir = "runid_" + [guid]::NewGuid()

if (-not (Test-Path $dir)) {
    mkdir $dir | Out-Null
    mkdir "$dir\.rml" | Out-Null
}


$dir = (Get-Item $dir).FullName
$rc["dir"] = $dir
$rc["template"] = (Get-Item "Templates").FullName
$rc["tpldir"] = $rc["template"] + "\" + $gen
$rc["commondir"] = $rc["template"] + "\.common"
$rc["tplrml"] = $rc["tpldir"] + "\.rml"
$rc["command"]  = $Command
$rc["gen"]  = $gen
$rc["gendir"] = $dir + "\.rml"
$rc["gencmd"] = $rc["gendir"] + "\" + $rc["command"] + ".ps1"
$rc["code"]  = $code
$rc["file"]  = $file
$rc["fromDir"] = $FromDir
$rc["zipFile"] = $ZipFile
$rc["argList"] = $ArgList
$rc["title"]   = $Title
$rc["NoRemove"] = $NoRemove
$rc["empty"]    = $Empty
$rc["outFile"]  = $OutFile
$rc["RML.ruby"] = (Get-Item "RML").FullName
if ($NoCopy) {
    Copy-Item ($rc["tplrml"] + "\*") $rc["gendir"] -Force -Recurse
} else {
    Copy-Item ($rc["tpldir"] + "\*") $rc["dir"] -Force -Recurse
}
. $rc["gencmd"]
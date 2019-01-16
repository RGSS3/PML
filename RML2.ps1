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


$dir = "runid_" + [guid]::NewGuid()

if (-not (Test-Path $dir)) {
    mkdir $dir | Out-Null
    mkdir "$dir\.rml" | Out-Null
}

$dir = (Get-Item $dir).FullName
$rc = $RMLConfig = & "./config.ps1" $gen $dir $command
if ($NoCopy) {
    Copy-Item ($rc["tplrml"] + "\*") $rc["gendir"] -Force -Recurse
} else {
    Copy-Item ($rc["tpldir"] + "\*") $rc["dir"] -Force -Recurse
}
if (-not (Test-Path $rc["gencmd"])) {
    Write-Error "Can't find command for: $gen.$command"
    ri $dir -Force -Recurse
    exit
}

. $rc["gencmd"]
function rmlhome {
    $PSScriptRoot | Split-Path -Parent 
}

function runconfig {
    param (
        [string]$gen,
        [string]$dir,
        [string]$command
    )
    $config =  (rmlhome) + "\config.ps1"
    write-host $config
    $dir = (Get-Item $dir).FullName
    $rc = $RMLConfig = & $config $gen $dir $command
    . $rc["gencmd"]
}


function rmlcommon {
    (Get-Item (rmlhome) + "\Templates\.common").FullName
}
function rmk {
    param (
        [string] $command
    )

    if ($command -eq "new") {
        return rmknew @args
    }
}

function rmknew {
    param(
        [parameter(
            Mandatory = $true,
            Position = 0
        )]
        [string] $Gen,
        [parameter(
            Mandatory = $true,
            Position = 1
        )]
        [string] $Dir
    )

    $source = (rmlhome) + "\Templates\$Gen"
    if (-not (Test-Path $source)) {
        Write-Error "Genre $Gen not found"
        exit
    }
    if (Test-Path $dir) {
        Write-Error "Target $Dir already exists"
        exit
    }
    Copy-Item $source $dir -Force -Recurse
}
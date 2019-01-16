param (
    [string]$Gen,
    [string]$Dir,
    [string]$Command
)

$rmlhome = ($MyInvocation.MyCommand.Path | Split-Path -Parent) + "\"
$rc = $RMLConfig = @{}
$ruby = (Get-Item ($rmlhome + "/RM3/ruby/bin/ruby.exe")).FullName
$f2s  = (Get-Item ($rmlhome + "/RML/file2script.rb")).FullName
$rc["ruby"] = $ruby
$rc["f2s"]  = $f2s
$rc["dir"] = $dir
$rc["template"] = (Get-Item ($rmlhome + "Templates")).FullName
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
$rc["RML.ruby"] = (Get-Item ($rmlhome + "RML")).FullName
$rc

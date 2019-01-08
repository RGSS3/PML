$path = Split-Path -Parent $MyInvocation.MyCommand.Definition
$xml = [xml](Get-Content ($path + "\" + "config.xml"))
$suf = $xml.suffix
. ($rc["commondir"] + "\debug.ps1")
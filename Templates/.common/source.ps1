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

$ruby = $rc["ruby"]
$f2s  = $rc["f2s"]
$file = $rc["file"]
$code = $rc["code"]
$fromDir = $rc["fromDir"]
$zipFile = $rc["file"]
$arglist = $rc["argList"]
$title = $rc["title"]
$noremove = $rc["NoRemove"]
$empty = $rc["empty"]

while (1) {
    if ($file) {
        Copy-Item $file "$dir/main.rb"
        &$ruby $f2s "$dir/main.rb" "$dir/Data/Scripts.$suf"
        break
    }

    if ($code) {
        $code | Out-File -Encoding utf8 $dir/main.rb
        Start-Process $ruby -ArgumentList $f2s, "$dir/main.rb", "$dir/Data/Scripts.$suf" -Wait -WindowStyle Hidden
        break
    }

    if ($fromDir) {
        copy-item $FromDir\* $dir -Force -Recurse
        break
    }

    if ($zipFile) {
        Expand-Archive $ZipFile $dir -Force 
        break
    }

    if ($empty) {
        break
    }

    Write-Host "No source present, exit"
    exit
}

if ($arglist -eq $null) {
    $arglist = @()
}
if ($title) {
    inimodify "$dir/Game.ini" "Title" $title
}
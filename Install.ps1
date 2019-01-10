[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$rm3  =  "https://github.com/RGSS3/RML-RM3/archive/v1.2.zip"
ri RM3 -fo -r
Invoke-Webrequest $rm3 -OutFile tmp/RM3.zip
Expand-Archive tmp\RM3.zip . -Force
Move-Item RML-RM3-1.2 RM3

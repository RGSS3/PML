[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$rm3  =  "https://github.com/RGSS3/RM3/releases/download/v1.1/RM3-1.1.zip"

mkdir RM3
Invoke-Webrequest $rm3 -OutFile RM3\RM3.zip
Expand-Archive RM3\RM3.zip .

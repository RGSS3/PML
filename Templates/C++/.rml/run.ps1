$code = $rc["code"]
$file = "
#include <bits/stdc++.h>
#include <windows.h>
using namespace std;
int main(){
    $code;
}
"

pushd $dir
$file | Out-File "main.cpp"  -Encoding utf8 
$a = Start-Process "g++.exe" -ArgumentList "main.cpp","-o","main.exe" -passthru -WindowStyle Hidden
$a.id | Out-File "pid"
Wait-Process -id $a.id
$b = Start-Process ".\main.exe" -passthru -NoNewWindow
$b.id | Out-File -Append "pid"
Wait-Process -id $b.id
popd
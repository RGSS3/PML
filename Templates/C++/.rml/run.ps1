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
g++ main.cpp -o main.exe
.\main.exe
popd
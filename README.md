# PML

## Synopsis
run `Install.ps1` first
```powershell
PS E:\fun\PML> ./rml -ZipFile a.zip -NoCopy
PS E:\fun\PML> ./rml -FromDir 'C:\Users\seiran\Documents\RPGXP\Project11'
PS E:\fun\PML> ./rml -Code 'msgbox "Hello world"'
PS E:\fun\PML> ./rml -File 'Sample\first.rb' -Gen RMVX  


# clean all workspaces, i.e. will clean the runid_* folder
PS E:\fun\PML> ./rml -Clean 
...
PS E:\fun\PML> ./rml -File 'Sample\first.rb' -Gen RMVB
E:\fun\PML\RML.ps1 : -Gen must be one of RMVA RMXP RMVXA RMVX
```

## Debug Mode
```powershell
PS E:\fun\PML> ./rml -Code 'Graphics.update while 1' -Debug -Gen RMXP
```

in the open window of irb:
```irb
irb(main):001:0> debug_eval "print 3 + 5"
=> nil
```
will call the game to print(messagebox) a value 8

```irb
irb(main):001:0> debug_eval "Debug.report 3 + 5"
=> nil
```
will call the game to report a value 8 to the console of irb



## LICENSE
GPL v3

# PML v2.0

## Synopsis
run `Install.ps1` first
```powershell
PS E:\fun\PML> ./rml2 run -ZipFile a.zip -NoCopy
PS E:\fun\PML> ./rml2 run -FromDir 'C:\Users\seiran\Documents\RPGXP\Project11'
PS E:\fun\PML> ./rml2 run -Code 'msgbox "Hello world"'
PS E:\fun\PML> ./rml2 run -File 'Sample\first.rb' -Gen RMVX  


# clean all workspaces, i.e. will clean the runid_* folder
PS E:\fun\PML> ./rml2 cleanall
...
PS E:\fun\PML> ./rml2 run -File 'Sample\first.rb' -Gen RMVB
```

## Debug Mode
```powershell
PS E:\fun\PML> ./rml2 debug -Code 'Graphics.update while 1' -Gen RMXP
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

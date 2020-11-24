# cgo crash debuging

Author: [songtianyi](http://songtianyi.info) create@2020-11-17

### ulimit setting

``` 

ulimit -c unlimited
```

### generate core dump

``` 

GOTRACEBACK=crash ./your-binary
```

### gdb

``` 

gdb ./your-binary core.xxx
```

``` 

bt full
```

``` 

where
```

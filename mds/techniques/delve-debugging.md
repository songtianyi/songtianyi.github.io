# 用delve调试go程序

#### debug daemon process on macOS

```
dlv attach $pid $executable [flags]
```

eg.

```
dh 10270 ./ekanited
```

#### debug from main file with args on macOS

```
dlv debug . -- -a v1 -b v2 -c v3
```

eg.

```
sudo dlv debug . -- -datadir ~/trash/ekanited -udp 192.168.1.40:5514 -tcp 192.168.1.40:5514
```



#### debug session commands

###### funcs

用 `funcs`加包名列出需要debug的包内的函数，便于设置断点

```
funcs $packageName
```

###### break

用上述示例中的输出来打断点

```
break github.com/ekanite/ekanite/input.(*TCPCollector).handleConnection:1
```

注意：断点行号是按照该函数的起始行来偏移的，而不是文件

###### continue

运行，直到遇到断点或程序终止



#### QA

###### Command failed: could not find symbol value for xxx

```
#编译的时候去掉优化
go build -gcflags='-N -l' .
```


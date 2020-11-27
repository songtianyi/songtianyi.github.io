# firewall nat policy verification method

### 网络环境

本地网段: 192.168.1.0/24

NAT地址网段: 172.19.1.0/24

### checkpoint

本地路由

```
sudo route -n add  -net 5.5.5.0 -netmask 255.255.255.0 192.168.1.157
```

接口配置: 192.168.1.157/24, 5.5.5.2/2

##### SNAT验证

```
#本地
telnet 5.5.5.123 80
[vs_0][fw_1] eth0:i0 (Stateless verifications (in))[64]: 192.168.1.14 -> 5.5.5.123 (TCP) len=64 id=25348
TCP: 54816 -> 80 .S.... seq=04a5a3d4 ack=00000000
[vs_0][fw_1] eth0:i1 (fw multik misc proto forwarding)[64]: 192.168.1.14 -> 5.5.5.123 (TCP) len=64 id=25348
TCP: 54816 -> 80 .S.... seq=04a5a3d4 ack=00000000
[vs_0][fw_1] eth0:i2 (fw VM inbound )[64]: 192.168.1.14 -> 5.5.5.123 (TCP) len=64 id=25348
TCP: 54816 -> 80 .S.... seq=04a5a3d4 ack=00000000


# 添加策略
192.168.1.14 5.5.5.123 tcp any any permit

# 添加NAT策略
src 192.168.1.14 translated_src 172.19.1.14 


```

##### DNAT

##### Static NAT

### juniper ssg

```
Debug flow basic
Shows the flow of traffic through the firewall, allowing for troubleshooting route selection, policy selection, any address translation and whether the packet is recieved or dropped by the firewall.

    1)   get ffilter - see if an filters have been set already, if they have you use 'unset ffilter' to remove, repeat the steps until you remove all the filters
    2)   set ffilter src-ip 10.1.1.5 dst-ip 1.1.70.250 - allows you to limit the traffic that you capture using src-ip, src-port, dst-ip, dst-port & etc... Recommeded as debug flow basic can be intensive on the firewall especially if it is under heavy load.
    3)   debug flow basic - turns on flow debuging with a level of basic logging
    4)   clear db - make sure there is nothing in the debug buffer from previous debugs
    5)   Begin the test, do a ping or try to access the resource that you are having problems with.
    6)   undebug all or press Esc key - turns off debug
    7)   get db str - reads the debug buffer and outputs.
    8)   unset ffilter - remove ffilters when finished
    9)   clear db - make sure there is nothing in the debug buffer from previous debugs
```


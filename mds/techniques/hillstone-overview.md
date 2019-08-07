# Hillstone防火墙概览

> 除了带 > 号的命令，其他命令都是在configure模式下执行的

##### user guide

https://kb.hillstonenet.com/en/wp-content/uploads/2015/06/StoneOS_CLI_User_Guide_5.5R1.pdf

##### 取消输出分页

```
terminal length 0
```

##### 进入配置模式

```
# configure
```

##### 提交配置

```
save
\n
\n
```

##### 获取running配置

```
show configuration xml
```

##### 获取预定义对象

```
show service predefined
show servgroup predefined
```

##### hostname

```
TODO
```

```
hostname hillstone
```

##### interface

```
show configuration interface
```

```
interface ethernet0/1
  zone  "untrust"
  ip address 192.168.64.225 255.255.255.224
exit
```

##### static route 

```
show ip route
```

```
hostname(config)# ip vrouter trust-vr
hostname(config-vrouter)# ip route source 0.0.0.0/0 202.10.10.2
(the traffic from this segment goes to Telecom by default)
hostname(config-vrouter)# ip route source 202.10.2.1/24
202.10.11.2 (the traffic from this segment goes to Netcom by default)
hostname(config-vrouter)# ip route source 202.10.3.1/24
202.10.11.2 (the traffic from this segment goes to Netcom by default)

302
hostname(config-vrouter)# ip route source 202.10.4.1/24
202.10.11.2 (the traffic from this segment goes to Netcom by default)
hostname(config-vrouter)# ip route source 202.10.5.1/24
202.10.11.2 (the traffic from this segment goes to Netcom by default)
```

##### Logging

```
show logging syslog
```

```
logging configuration to syslog
logging configuration on
# TODO
```

##### address

>  exclude怎么表达？
>

```
show address
```

```
set address adsf fqdn asdf.asdf.asdf
set address ip-net ip-netmask 192.168.2.0/24
set address ip-range description "asdf adsf" ip-range 192.168.1.100-192.168.1.101
```

##### address group

```
show address-group
```

```
address test
  description test
  ip 192.168.3.0/24
  exclude ip 192.168.1.1 255.255.255.255
  exit
```

##### service

> 先确认下running config里有没有predefined service

```
show service
```

```
service myServ
    description "this is for my test"
    tcp dst-port 2211
    tcp dst-port 255 500
    udp dst-port 5566 src-port 2288
    icmp type 8 code 2 
    protocol 2
```

```
set service udp- protocol udp port 123
```

##### service-group

```
show servgroup
```

```
servgroup sgtest1
    service hehe
    service myServ
    exit
```

##### zone

> zone和interface的绑定关系是在interface的配置里

```
show zone
```

```
zone test-default-l3
    description test
    exit
    
```

```
zone test-l2 l2
    description test
    exit
```

##### policy

> 

```
show policy
```

```
policy-global
    move 300 after 1
    exit
```

```
policy-global
    move 300 before 1
    exit
```

```
policy-global
    rule from abc to any service DNS permit
    exit
```

```
policy-global
   rule from any to any from-zone trust to-zone untrust application BGP permit
   exit
```

##### policy group

> You can organize some policy rules together to form a policy group, and configure the
> policy group directly.

```
show policy-group
```

```
policy-group
    rule 1
    description test
    exit
```

##### scheduler

> 可以为数组，和目前模型不一致!!!!!!!!

```
show schedule
```

```
schedule test
    absolute start 07/05/2018 09:00 end 08/05/2019 06:00
    exit
```

```
scheduler test1
    periodic daily 16:00 to 20:00
    exit
```

##### NAT

> examples:
>
> 

```
show snat
```

```
# SNAT
ip vrouter trust-vr
    snatrule from asdf to abc  service Any  trans-to 1.1.1.0/24 mode dynamicport
    exit
```

```
show dnat
```

```
# DNAT
ip vrouter trust-vr
    dnatrule from any to outSideAdd service any trans-to virtualAdd
    exit
```

```
show bnat
```

```
ip vrouter trust-vr
  bnatrule virtual address-book virtualAdd real address-book outSideAdd
  exit
```

##### 透明模式

> To build the transparent application mode, you must create some L2 zones, bind
> interfaces to the L2 zones and then bind the L2 zones to the VSwitch. If necessary,
> you can create multiple VSwitches. The transparent mode takes the following
> advantages:
> ♦ Do not have to change the IP addresses of the protected network.
> ♦ No NAT rules are needed.
>
> 需要注意的是，hillstone可以混用两个mode

##### Errors

```
                  ^-----incomplete command
```

```
         ^-----unrecognized keyword asdf
```

```
Error: syslog server table is full
```

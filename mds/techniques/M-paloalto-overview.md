# PA防火墙概览

> 除了带 > 号的命令，其他命令都是在configure模式下执行的

##### cheat sheet

https://www.paloaltonetworks.com/content/dam/pan/en_US/assets/pdf/framemaker/71/pan-os/cli-gsg/section_3.pdf

##### 设置配置格式

用于测试的PA虚拟机上，json格式存在bug，所以用xml格式解析

```
admin@PA-VM> set cli config-output-format
  default   default
  json      json
  set       set
  xml       xml
```

##### 取消输出分页

```
> set cli pager off
```

##### 进入配置模式

```
> configure
```

##### 提交配置

```
commit
```

##### 获取running配置

```
show
```

##### 获取预定义对象

```
admin@PA-VM# show predefined
  application              application
  application-container    application-container
  application-filter       application-filter
  application-group        application-group
  application-type         application-type
  default-security-rules   default-security-rules
  private-application      private-application
  profile-group            profile-group
  profiles                 profiles
  region                   region
  reports                  reports
  service                  service
  service-group            service-group
  sig-default              sig-default
  signature                signature
  threats                  threats
  url-categories           url-categories
  user-id-collector        user-id-collector
  |                        Pipe through a command
  <Enter>                  Finish input
```

##### hostname

```
show deviceconfig system
```

```
set deviceconfig system hostname PA-VM
```

##### interface

```
show network interface
```

```
set network interface ethernet ethernet1/1 comment "try" layer3 ip 192.168.2.0/24
```

##### static route

```
show network virtual-router default routing-table ip static-route
```

```
set network virtual-router default routing-table ip static-route asdf destination 10.1.1.0/24 nexthop ip-address 10.1.1.254
```

##### Logging

```
show shared log-settings
```

```
set shared log-settings syslog asdf server asdf format IETF server 192.168.1.99 port 5514 transport TCP
set shared log-settings system informational
```

##### address

>  tag暂时不考虑
>
>  description 必须在 type前面定义

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
set address-group addrg dynamic filter xx
set address-group addrgs static addrg
set address-group addrset description asdf static [ ip-net ip-range ]
```

##### service

```
show service
```

```
set service asdf protocol tcp port 1-234 source-port 1032
# port应该是目的端口
```

```
set service udp- protocol udp port 123
```

##### service-group

```
show service-group
```

```
set service-group srvg members [ asdf service-http ]
```

##### zone

> zone和interface是1:1的关系

```
show zone
```

```
set zone asdf network layer2 [ ]
```

```
set zone l3 network layer3 ethernet1/1
```

```
# 多行命令
set zone l31 user-acl include-list addrg
set zone l31 network layer3 loopback
```

```
1. NAP device mode设置为zone，不可修改
2. 如果地址匹配到了zone，下发时使用zone，如果没有匹配到，使用any
```



##### policy

> In earlier releases of PAN-OS prior to 6.1 there is no classification called "RULE TYPE" in the security policy.This is new feature incorporated in the 6.1 version of PAN-OS

| **Rule Type** | **Description**                          |
| ------------- | ---------------------------------------- |
| **Universal** | By default, all the traffic destined between two zones, regardless of being from the same zone or different zone, this applies the rule to all matching interzone and intrazone traffic in the specified source and destination zones.For example, if creating a universal role with source zones A and B and destination zones A and B, the rule would apply to all traffic within zone A, all traffic within zone B, and all traffic from zone A to zone B and all traffic from zone B to zone A. |
| **Intrazone** | A security policy allowing traffic between the same zone, this applies the rule to all matching traffic within the specified source zones (cannot specify a destination zone for intrazone rules).For example, if setting the source zone to A and B, the rule would apply to all traffic within zone A and all traffic within zone B, but not to traffic between zones A and B. |
| **Interzone** | A security policy allowing traffic between two different zones. However, the traffic between the same zone will not be allowed when created with this type, this applies the rule to all matching traffic between the specified source and destination zones.For example, if setting the source zone to A, B, and C and the destination zone to A and B, the rule would apply to traffic from zone A to zone B, from zone B to zone A, from zone C to zone A, and from zone C to zone B, but not traffic within zones A, B, or C. |

```
Universal policies are just a way to carry through the pre-6.x behaviour (I think this was a 6.0 feature). It basically means the policy rule will match any flow which has any of the source zones AND any of the destination zones, regardless of whether the source and destination zones are the same, or not.

Most policies are intended as interzone rules, eg. inside to outside. If you create a universal rule with src: inside and dst: outside, a universal rule and an interzone rule will behave in the same way.

Alternatively, if you create a rule with src: inside, outside and dst: outside, each rule type would match differently. Intra would match outside>outside flows only; Inter would match inside>outside flows only; Universal would match both.

I normally just use universal rules except in the very specific circumstances where it creates a more concise rulebase to use one of the other types.
```



```
show rulebase security
```

```
set rulebase security rules zonep rule-type interzone from l3 to l31 source any destination 192.168.1.1-192.168.1.2 description asf service empty
```

##### scheduler

> 可以为数组，和目前模型不一致!!!!!!!!

```
show schedule
```

```
set schedule test recurring weekly friday [ 10:00-23:59 11:00-12:00 ]
set schedule test recurring weekly friday 10:00-23:59
set schedule non-re non-recurring 2006/08/01@10:00-2007/12/31@23:59
set schedule non-re non-recurring [ 2006/08/01@10:00-2007/12/31@23:59 2006/08/01@10:00-2007/12/31@23:59 ]
```

##### NAT

> examples:
>
> https://www.paloaltonetworks.com/documentation/71/pan-os/pan-os/networking/nat-configuration-examples

```
show rulebase nat rules
```

```
set rulebase nat rules adsf nat-type ipv4 description asdf from any to l3 service service-http source addrset to-interface ethernet1/1 source-translation static-ip translated-address ip-range bi-directional yess
```

##### 透明模式

PA的透明模式叫virtual-wire或者v-wire，可以通过接口的配置来确定

```
set network interface ethernet ethernet1/10 virtual-wire
```

##### Errors

```
192.168.1.100-192.168.1.80 is not a valid IPv4/v6 ip address range (e.g. 10.1.1.1-10.1.1.9 )

Invalid syntax.
[edit]
```

```

Server error :  -> static '[ip-net]' is not a valid reference
 -> static is invalid
[edit]
```

```


.
Validation Error:
service -> udp-  is missing 'protocol'
service is invalid
[edit]
```

##### User-ID



##### 版本差异

> 命令set service-group srvg members [ asdf service-http ]，相比pa6.0多了个关键字members

> 从pa6.1起，Policy新增Rule Type字段，取值<universal | intrazone | interzone>

> 命令set shared log-settings syslog asdf server asdf format IETF server 192.168.1.99 port 5514 transport TCP，相比pa6.0  syslog 下的server里多了 format和 transport字段，其取值如下
>
>  format ：<BSD | IETF>  ；transport ： <SSL | TCP | UDP>

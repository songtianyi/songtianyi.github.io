#Fortinet概览

### 前言

主要介绍fortinet各类对象的获取和下发命令。

### Full-configuration

```
show full-configuration
```

### Output settings

```
config system console
    set output standard
end
```

### Hostname

###### GET

```
show system global
```

###### SET

```
config system global
    set hostname "fortigate-test-KVM-64"
end
```

### Interface

###### GET

```
show system interface
```

###### SET

```
config system interface
    edit "port1"
        set vdom "root"
        set ip 192.168.1.59 255.255.255.0
        set allowaccess ping https ssh
        set type physical
        set snmp-index 1
    next
    edit "port2"
        set vdom "root"
        set type physical
        set snmp-index 2
    next
    edit "port3"
        set vdom "root"
        set type physical
        set snmp-index 3
    next
    edit "ssl.root"
        set vdom "root"
        set type tunnel
        set alias "SSL VPN interface"
        set snmp-index 4
    next
end
```

### Static route

###### GET

```
show router static
```

###### SET

```
config router static
    edit 1
        set status disable
        set dst 192.168.1.0 255.255.255.0
        set distance 1
        set weight 1
        set priority 1
        set device "port1"
        set comment "for test"
    next
end
```

### Logging

###### GET

```
show log setting
show log syslogd filter
show log syslogd setting
show log syslogd2 filter
show log syslogd2 setting
show log syslogd3 filter
show log syslogd3 setting
show log syslogd4 filter
show log syslogd4 setting
```

###### SET

```
config log syslogd$i filter
    set severity notification
end
```

```
config log syslogd setting
    set status enable
    set server "192.168.1.99"
    set port 5524
end
```

### Address

###### GET

```
show firewall address
```

###### SET

```
config firewall address
    edit "SSLVPN_TUNNEL_ADDR1"
        set uuid 05312aba-a6e0-51e8-1bde-9688c3b0e5eb
        set type iprange
        set associated-interface "ssl.root"
        set start-ip 10.212.134.200
        set end-ip 10.212.134.210
    next
    edit "all"
        set uuid 0532be84-a6e0-51e8-35fa-93ef6072f3cf
    next
    edit "none"
        set uuid 0532c4ec-a6e0-51e8-c50f-c4766862a4cd
        set subnet 0.0.0.0 255.255.255.255
    next
    edit "adobe"
        set uuid 0532ca14-a6e0-51e8-db9c-f30212ade1cb
        set type wildcard-fqdn
        set wildcard-fqdn "*.adobe.com"
    next
    edit "auth.gfx.ms"
        set uuid 0532e508-a6e0-51e8-937f-8621a4bc9e93
        set type fqdn
        set fqdn "auth.gfx.ms"
    next
    edit "fortinet"
        set uuid 053303ee-a6e0-51e8-302a-fc2d58779918
        set subnet 192.168.1.0 255.255.255.0
    next
```

### AddressGroup

###### GET

```
show firewall addrgrp
```

###### SET

```
config firewall addrgrp
    edit "demogrp"
        set uuid 45d60b34-a74f-51e8-d19c-4ce54a196ef8
        set member "skype" "citrix"
        set comment "demo grp"
    next
end
```

```
config firewall addrgrp
	edit "demogrp"
	append member "fortinet"
end
```

### Service

 ###### GET

```
show firewall service custom
```

###### SET

```
config firewall service custom
	edit "demosrv"
        set comment "asdf"
        set iprange 192.168.1.1
        set tcp-portrange 10-20:200-300
    next
    edit "tcp"
        set comment "tcp service"
        set tcp-portrange 10-20:23-45
    next
    edit "udp"
        set udp-portrange 10-20:45-1213
    next
    edit "ip"
        set protocol IP
        set protocol-number 45
    next
    edit "multi-protocol"
        set protocol ICMP
        unset icmptype
    next
    edit "icmp"
        set protocol ICMP
        set icmptype 8
        set icmpcode 0
    next
    edit "icmp6"
        set protocol ICMP6
        set icmptype 80
        set icmpcode 90
    next
end
```

### ServiceGroup

###### GET

```
show firewall service group
```

###### SET

```
config firewall service group
    edit "Email Access"
        set member "DNS" "IMAP" "IMAPS" "POP3" "POP3S" "SMTP" "SMTPS"
    next
    edit "Web Access"
        set member "DNS" "HTTP" "HTTPS"
    next
    edit "Windows AD"
        set member "DCE-RPC" "DNS" "KERBEROS" "LDAP" "LDAP_UDP" "SAMBA" "SMB"
    next
    edit "Exchange Server"
        set member "DCE-RPC" "DNS" "HTTPS"
    next
end
```

### Policy

###### GET

```
show firewall policy
```

###### SET

```
config firewall policy
    edit 1
        set name "demo-policy-1"
        set uuid c6b95774-a781-51e8-012c-cba800a0634f
        set srcintf "any"
        set dstintf "port1"
        set srcaddr "fortinet" "google-play"
        set dstaddr "all"
        set action accept
        set schedule "always"
        set service "tcp" "udp"
        set logtraffic disable
        set devices "ip-phone"
        set comments "demo"
    next
end
```

### Interface policy

可以对接口定义policy，相当于从该接口进来或者出去的流量都会应用这个策略。

### Scheduler

###### GET

```
show firewall schedule group
```

```
show firewall schedule onetime
```

```
show firewall schedule recurring
```

###### SET

```
config firewall schedule group
    edit "demo"
        set member "always" "none"
    next
end
```

```
config firewall schedule onetime
    edit "onetime-demo"
        set start 12:00 2001/12/01
        set end 00:00 2050/12/30
    next
end
```

```
config firewall schedule recurring
    edit "always"
        set day sunday monday tuesday wednesday thursday friday saturday
    next
    edit "none"
    next
    edit "recurring"
        set start 13:00
        set end 14:00
    next
end
```

###### Weekday

```
sunday       Sunday.
monday       Monday.
tuesday      Tuesday.
wednesday    Wednesday.
thursday     Thursday.
friday       Friday.
saturday     Saturday.
none         None.
```

### NAT

##### SNAT(Dynamic PAT)

###### GET

```
show firewall ippool
```

###### SET

```
config firewall ippool
    edit "inner2outer"
        set type overload
        set startip 122.1.1.1
        set endip 122.1.1.1
        set arp-reply enable
        set arp-intf "port2"
        set comments "hhhaaaa"
end
```

##### DNAT/STATIC

###### GET

```
show firewall vip
```

###### SET

```
-----DNAT-----
config firewall vip
    edit v1
        set comment "dnat"
        set src-filter 102.1.1.1 105.1.1.0/24 106.1.1.1-106.1.1.2
        set extip 155.1.1.1
        set mappedip 192.168.182.78
        set extintf port2
        set arp-reply enable
        set portforward enable
        set protocol tcp
        set extport 80-80
        set mappedport 90-90
        set portmapping-type 1-to-1
end
-----STATIC-----
config firewall vip
    edit v2
        set comment "static"
        set type static-nat
        set src-filter 102.1.1.1 105.1.1.0/24 106.1.1.1-106.1.1.2
        set extip 155.1.1.22
        set mappedip 192.168.182.79
        set extintf port2
        set arp-reply enable
        set portforward enable
        set protocol tcp
        set extport 80-80
        set mappedport 90-90
        set portmapping-type 1-to-1
end
```




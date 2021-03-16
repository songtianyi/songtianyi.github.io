# DPTech-FW1000 概览

### 前言

主要介绍迪普防火墙各类对象的获取和下发命令。

### 综合

``` 

show version
通过 radius 来控制账户权限
HA: 静默单活，配同个 ip，不做 vip
````

### Full-configuration

``` 

show running-config
```

### Output settings

``` 

terminal line 0
```

### Hostname

###### GET

``` 

```

###### SET

``` 

hostname xxx
no hostname
```

### Interface

###### GET

``` 

show interface
```

###### SET

``` 

```

### Static route

###### GET

``` 

show ip route static
```

###### SET

``` 

```

### Logging

###### GET

``` 

```

###### SET

``` 

```

``` 

```

### Address

###### GET

``` 

show address-object *
```

###### SET

``` 

```

### AddressGroup

###### GET

``` 

show address-group *
```

###### SET

``` 

```

``` 

```

### Service

 ###### GET

``` 

show predefined-service *
show service-object *
```

###### SET

``` 

```

### ServiceGroup

###### GET

``` 

show service-group *
```

###### SET

``` 

```

### Policy

###### GET

``` 

show running-config | inc security-policy
show security-policy *
show security-policy id $id
show security-policy name $name
```

###### SET

``` 

```

### Scheduler

###### GET

``` 

show time-object *
```

``` 

```

###### SET

``` 

```

``` 

```

``` 

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

##### SNAT

###### GET

``` 

show nat source-nat *
```

###### SET

``` 

```

##### DNAT

###### GET

``` 

show nat destination-nat *
```

###### SET

``` 

```

##### Static NAT

###### GET

``` 

show nat static *
```

###### SET

`

``` 

````

##### Zone

``` shell
show security-zone *
```

``` 

1. NAP device mode 设置为 zone，不可修改
2. 如果地址匹配到 zone，下发 zone，如果未匹配到 zone，下发 port(interface)

```

### Errors

``` 

% Unknown command.
```

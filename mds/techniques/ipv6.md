# IPv6

作者: [songtianyi](www.songtianyi.info) 2020-06-17

> 图片来自网络

为什么会有ipv6等基本信息就不提了，网上资料很多。相对IPV4，v6地址数量更多(8 * 4 --> 16 * 8)，协议格式也做了简化。

![image](https://songtianyi-blog.oss-cn-shenzhen.aliyuncs.com/ipv6-format.jpg)

- IPv6报文头部是定长（固定为40字节），IPv4报文头部是变长的。意味着，处理v6数据包的效率会高很多
- IPv6中Hop Limit字段含义类似IPv4的TTL；
- IPv6中的Traffic Class字段含义类似IPv4中的TOS（Type Of Service）
- IPv6的报文头部取消了校验和字段：取消这个字段也是对IPv4协议的一个改进。当IPv4报文在网路间传输，每经过一个路由器转发就要修改TTL字段，就需要重新计算校验和，而由于数据链路层L2和传输层L4的校验已经足够强壮，因此IPv6取消这个字段会提高路由器的转发效率。值得一提的是，在IPv6协议下，传输层协议UDP、TCP是强制需要进行校验和的（IPv4是可选的）
- IPv6报文头部中的Next Header字段表示“承载上一层的协议类型”或者“扩展头部类型”

IPv6地址使用128比特进行标识，每16个比特划分为一段，使用16进制数字表示，共8段，并且使用冒号隔开。如2001:0000:130F:120E:02C0:06E0:175A:180B。但有时候书写起来比较麻烦，所以有了IPv6的压缩格式，每段前面的0都可以省略，比如前面的IPv6地址，可以表示为2001:0000:130F:120E:2C0:6E0:175A:180B。如果IPv6的地址中包含的连续两个或多个均为0的段，可以用双冒号“::”来代替。比如2001:0000:0000:120E:02C0:06E0:175A:180B，可以压缩为2001::120E:02C0:06E0:175A:180B。但是我们同时规定，一个IPv6的地址中只能使用一次双冒号，因为如果使用多次，恢复成128位完整的格式的时候，会无法确定知道每段的0的个数，两个常用地址的v6压缩格式

```
0.0.0.0 --> ::/128
127.0.0.1 --> ::1/128
```

ipv4地址分为网络号和主机号，v6分为网络前缀和接口标识，其实是对应的，但ipv6没有子网掩码一说。接口标识可以手工配置，就像我们给主机分配ip地址一样，或者系统通过软件自动生成，或者根据IEEE EUI-64规范自动生成。IEEE EUI-64规范是根据接口的MAC地址生成IPv6的接口标识。网络前缀地址由管理机构定义和分配。

##### [IPv6地址](https://www.ripe.net/manage-ips-and-asns/ipv6/ipv6-address-types/ipv6_reference_card_July2015.pdf)分三种类型：

- 单播，对应于IPv4的普通公网和私网地址；

- 组播(multicast)，对应于IPv4的组播（多播）地址；ff00::/8 -- 224.0.0.0/4

  ![image](https://forum.huawei.com/huaweiconnect/data/attachment/forum/201710/27/20171027141557272.jpg)

  > FF01::1节点本地范围所有节点组播地址
  >
  > FF01::2节点本地范围所有路由器组播地址
  >
  > FF02::1链路本地范围所有节点组播地址
  >
  > FF02::2链路本地范围所有路由器组播地址
  >
  > ……
  
- 任播(anycast)，IPv6新增的地址概念类型。

地址辅助工具

* https://tool.oschina.net/hexconvert
* https://jennieji.github.io/subipv6/

相比[v4](https://www.cnblogs.com/rogerroddick/archive/2009/08/31/1557228.html) , v6没有广播(broadcast)的概念，用组播实现广播的功能。v6新增了[任播地址](https://blog.csdn.net/weixin_30340745/article/details/98768164)

>
任播技术是一种新的网络应用，它能够支持把同样的地址可以分配给多个节点去提供特定服务的以服务导向的地址，而带有任播目的地地址的数据报能够使用相同的任播地址并被传给众多节点中的任意一个。因特网研究任务组（IRTF）在1993年到RFC 1546中已经定义了任播技术的作用：“主机向一个任播地址发送数据报，网络负责尽力将数据报传递到至少一个，最好也是一个，按任播地址接收数据的服务器上。"采用任播机制的初衷是彻底去简化在互联网中寻找合适服务器的任务；任播通信的基本概念是从物理主机设备中分离出的逻辑服务标识符，任播地址可以根据服务类型来分配，使得网络服务担当一个逻辑主机的角色。

##### ipv6单播地址又分为以下几种

* 全球单播地址(Global Unicast Address), 前缀2000::/3，**2000::到 3FFF:FFFF:….FFFF**, 前三个bit是001，相当于IPv4的公网地址（IPv6的诞生根本上就是为了解决IPv4公网地址耗尽的问题）。这种地址在全球的路由器间可以路由。

  **一般从运营商处申请到的IPv6地址空间为/48，再由自己根据需要进一步规划：如下图，分配给终端的IPv6地址可能是这样的结构：**

  ![image](https://forum.huawei.com/huaweiconnect/data/attachment/forum/201708/04/20170804092221419001.jpg)



  > 为支持新型基础设施建设,加快推进我国IPv6规模部署,鼓励广大互联网服务提供商和相关企事业单位申请并使用IPv6地址,中国互联网络信息中心(CNNIC)将于5月1日起,实行新规加大IPv6地址申请支持力度。(一)大幅降低新用户办理IPv6地址年费。支持IPv6地址独立开户,将每一级别地址量年费降为当前年费的50%。(二)加快IPv6地址申请办理进度。对于默认/32地址空间的IPv6地址申请,随时申请随时办理。(三)加大对IPv6规划指导和培训力度。对于有较大块IPv6地址申请需求的单位进行免费规划指导。优先向新申请IPv6地址的单位提供IPv6培训。
  >
  >  目前全球IPv4地址几近消耗殆尽,必须大力推广IPv6以满足国家“新基建”对IP地址的需求。作为国家的互联网络信息中心,CNNIC将进一步在地址分配、技术标准研发、国内外技术培训与交流方面加大对IPv6的支持力度。
  >
  >  CNNIC IP地址分配联盟: CNNIC是亚太互联网络信息中心(APNIC)认定的中国大陆地区唯一的国家互联网注册机构(NIR),于1997年成立了以CNNIC为召集单位的CNNIC IP地址分配联盟,帮助中国大陆地区的相关单位和组织从APNIC申请IP地址、AS号码互联网资源。


* 链路本地地址（Link-Local Addresses）, 前缀FE80::/10，前10个bit是1111 1110 10, 对应v4的169.254.0.0/16。顾名思义，此类地址用于同一链路上节点间的通信，主要用于自动配置地址和邻居节点发现。Windows和Linux开启IPv6后，默认给网卡接口自动配置一个链路本地地址。也就是说，一个接口一定有一个链路本地地址。每个接口可以配置1个以上的单播地址，例如一个接口可以配置一个链路本地地址，同时也可以配置一个全球单播地址。链路本地地址是一类非常重要的地址，它的有效范围仅仅在所处链路上.以FE80::/10为前缀，11-64位为0，外加一个64bits的接口标识（一般是EUI-64）

  ![image](https://forum.huawei.com/huaweiconnect/data/attachment/forum/201708/04/20170804093243395001.jpg)

* 唯一本地地址（Unique Local Addresses (ULAs)), 前缀FC00::/7，前7个bit为1111110，相当于IPv4的私网地址（10.0.0.0/8、172.16.0.0/12、192.168.0.0/16），在RFC4193中新定义的一种解决私网需求的单播地址类型，用来代替废弃使用的站点本地地址。仅能够在本地网络使用，在IPv6 Internet上不可被路由.ULA拥有固定前缀FC00::/7，分为两块：FC00::/8暂未定义，FD00::/8定义如下：

  ![image](https://forum.huawei.com/huaweiconnect/data/attachment/forum/201708/04/20170804092400293001.jpg)

> 既然IPv6的地址空间那么大，可以为每一个网络节点分配公网IPv6的节点，那为什么IPv6还需要支持私网？在IPv4中，利用NAT技术，私网内的网络节点可以使用统一的公网出口访问互联网资源，大大节省了IPv4公网地址的消耗（IPv6推进缓慢的原因之一）。另一方面，由于默认情况下私网内节点与外界通信的发起是单向的，网络访问仅仅能从私网内发起，外部发起的请求会被统一网关或者防火墙阻隔掉，这样的网络架构很好的保护了私网内的节点安全性和私密性。可以设想一下，如果企业内部每台办公电脑都配置了IPv6的公网地址上网，是多么可怕的事情，每台办公电脑都会面临被黑客入侵的威胁，肉鸡将会泛滥。
因此，在安全性和私密性要求下，IPv6中同样需要支持私网，并且也需要支持NAT。在Linux内核3.7版本开始加入对IPv6 NAT的支持，实现的方式和IPv4下的差别不大。

* 特殊地址

  * 回环地址(Loopback)，0:0:0:0:0:0:0:1或::1/128，等同于IPv4的127.0.0.1
  * 未指定地址(Unspecified), ::/128, 等同于ipv4的 0.0.0.0

* 站点本地地址(Site-local address)，以前是用来部署私网的，但RFC3879中已经不建议使用这类地址，建议使用唯一本地地址。大家知道有这么一回事就可以了。

* IPv4兼容地址，0:0:0:0:0:0:w.x.y.z或::w.x.y.z（其中w.x.y.z是点分十进制的IPv4地址）。但在RFC4291中已经不推荐使用这类地址，大家知道有这么一回事就可以了。

* IPv4映射地址(IPv4-Mapped)，0:0:0:0:0:FFFF:w.x.y.z或::FFFF:w.x.y.z（其中w.x.y.z是点分十进制的IPv4地址），以IPv6的形式表示IPv4地址。主要用于某些场景下IPv6节点与IPv4节点通信，Linux内核对这类地址有很好地支持。
* 还有一些其他地址就不一一列举了，可以查看[文档](https://www.ripe.net/manage-ips-and-asns/ipv6/ipv6-address-types/ipv6_reference_card_July2015.pdf)

  

##### IPv6地址配置

IPv6一个比IPv4更厉害的方面，就是可以自动配置地址，甚至这个配置过程不需要DHCPv6（在IPv4中是DHCPv4）这样的地址配置协议。最典型的例子就是，只要开启了IPv6协议栈的操作系统，每个接口就能自动配置了链路本地地址，这个是和IPv4最重要的区别之一。

IPv6的地址配置有以下几种：

- 只要开启了IPv6协议栈，接口自动分配链路本地地址；
- 无状态自动配置地址（[RFC2462](https://tools.ietf.org/html/rfc2462)）
- 有状态自动配置地址，例如DHCPv6
- 手动配置

##### 寻址
在ipv4的体系中，通过arp协议去发现mac地址，而ipv6是通过ND协议，其中，NS（Neighbor Solicitation）报文对应arp请求报文，NA(Neighbor Advertisement)报文对应arp应答报文

##### 域名解析

由于IPv6的地址扩展为128位，比IPv4更难书写和记忆，因此IPv6下的DNS变得尤为重要。IPv6的的DNS资源记录类型为AAAA（又称作4A），用于解析指向IPv6地址的完全有效域名。

下面是一个示例：
Hostipv6.example.wechat.com IN AAAA 2001:db8:1::1

IPv6下的域名解析可以认为是IPv4的扩展，详细可以查看[RFC3596](https://tools.ietf.org/html/rfc3596).


##### 路由

ipv4除了静态路由，还可以通过ICMP路由器请求报文和ICMP路由器通告报文来获取路由信息，同样的，ipv6通过路由器请求报文（Router Solicitation）和路由器通告（Router Advertisement）来获取路由信息。

##### NAT

[为什么ipv6保留了NAT？](https://help.fortinet.com/fos50hlp/54/Content/FortiOS/fortigate-firewall-52/Concepts/NAT 66.htm)

NAT-PT（Network Address Translation - Protocol Translation）技术，用于v4和v6的地址映射, 以下是静态NAT-PT示例
```
ipv6 nat v6v4 source 3001:11:0:1::1 150.11.3.1
ipv6 nat v4v6 source 192.168.30.9 2000::960B:202
```
###### 动态NAT-PT

在动态NAT-PT中，NAT-PT网关向IPv6网络通告一个96位的地址前缀，并结合主机32位IPv4地址作为对IPv4网络中主机的标识。从IPv6网络中的主机向IPv4网络发送的报文，其目的地址前缀与NAT-PT发布的地址前缀相同，这些报文都被路由到NAT-PT网关，由NAT-PT网关对报文头进行修改，取出其中的IPv4地址信息，替换目的地址。同时，NAT-PT网关定义了IPv4地址池，它从地址池中取出一个地址来替换IPv6报文的源地址，从而完成从IPv6地址到IPv4地址的转换。
动态NAT-PT改进了静态NAT-PT配置复杂、消耗大量IPv4地址池的缺点。由于它采用上层协议映射方法，故只需用很少的IPv4地址就可以支持大量的IPv6到IPv4的转换。但是，动态NAT-PT只能由IPv6一侧首先发起连接，路由器把IPv6地址转换为IPv4地址后，IPv4主机才知道使用哪一个IPv4地址来标识IPv6主机。若从IPv4端首先发起连接，IPv4主机并不知道IPv6主机的IPv4地址，因为这个地址是NAT-PT网关从地址池中随机选择的，连接将无法进行。


>NAT-PT has been deemed deprecated by IETF because of its tight coupling with Domain Name System (DNS) and its general limitations in translation, and it has proven as technology to be too complex to maintain scalable translational services. With the deprecation of NAT-PT and the increasing IPv6 transition among users has led to the introduction of NAT64. Refer to these documents for more information on NAT64:
>
>* NAT64 Technology: Connecting IPv6 and IPv4 Networks
>* NAT64-Stateless versus Stateful
>* IPv6 Stateful NAT64 Configuration Example

![image](https://www.cisco.com/c/dam/en/us/products/collateral/ios-nx-os-software/enterprise-ipv6-solution/white_paper_c11-676278.doc/_jcr_content/renditions/white_paper_c11-676278-02.jpg)

##### 静态路由
```
ipv6 route ::/0 2001:DB8:3002::10
```

##### 总结下相对于IPV4的变化

1. ip报文格式
2. ip表达格式
3. 地址(接口)配置方式，DHCPv4 --> DHCPv6
4. ICMP版本变化,  ICMPv4 --> ICMPv6
5. 过渡技术，如nat64

ipv6的普及率目前仍然比较低，虽然上游（操作系统，电信商，电信设备等）都已经支持ipv6，各大网站的主站（bat等等）也已支持，但终端用户仍然基本都是用ipv4，目前是被政策推着向前的状态。

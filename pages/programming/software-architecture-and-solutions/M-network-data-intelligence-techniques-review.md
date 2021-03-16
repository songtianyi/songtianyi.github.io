# 网络数据智能平台-技术要点

作者: [songtianyi](http://songtianyi.info) 2020-06-30

> 部分图片来自网络

### 需求背景

金融行业面对越来越多的业务系统，在数据的再利用和安全方面面对越来越大的挑战。网络数据智能平台，通过在边界设备采集流量，避免侵入业务系统，之后对数据包重组并解码成业务数据，从而完成数据的收集，分析，加工和利用。

例如，在业务监控方面，传统的方式是在各个业务做代码埋点，收集数据并上报给监控平台，监控平台再通过接口提供给其它应用。做埋点是很繁琐的，相当于把同样的工作交给了每个研发人员，很容易出现遗漏的情况。而且从管理者的角度讲，这种方式不好推行，尤其是在监控/安全这种付出了不一定能看到收益的地方。

在安全方面，必须尽早发现，及时封堵，因此将分析软件放在出入口是更合适的，尽可能在实际产生破坏之前发现并制止。

网络数据智能平台建设是数据再利用的第一道关，也是安全屏障的第一道关。

### 数据抓取

面对复杂的业务系统，装 agent 的方式，维护成本会很高，在分布式应用里这点体现的比较明显。好处是性能有保证，而且，在末端抓的话，不需要再对流量分类，Netis 开源了一个[agent](https://github.com/Netis/packet-agent)，在没有 TAP/SPAN 的时候使用。

另外，可以通过 TAP/SPAN 设备在流量出入口镜像流量，之后导向流量分析器所在的系统，通过 libpcap 抓取。

SPAN(**Switch Port Analyzer**)采用交换机端口镜像的方式镜像流量，将一个或多个端口的数据包复制到一个指定的端口，会损耗交换机的性能，而且可能会丢包，所以一般在金融行业也不会采用。

![image](https://songtianyi-blog.oss-cn-shenzhen.aliyuncs.com/TAP-v-SPAN-Diagram-SPAN.png)

TAP(**Test Access Point**)也叫分路器，在线路中接入 TAP 设备，TAP 设备复制流量并导向分析器接入的端口。好处是对交换机无影响，不会丢包，无延迟，但额外的 TAP 设备自然需要额外的花费，

![image](https://songtianyi-blog.oss-cn-shenzhen.aliyuncs.com/TAP-v-SPAN-Diagram-TAP.png)

常用的抓包软件，如 wireshark，tcpdump 等，底层都是 libpcap。demo 程序使用 Go 语言开发，所以用的 gopacket，gopacket 也是基于 libpcap，用 cgo 桥接，性能会有损耗，跨平台编译也非常麻烦。

libpcap 会在链路层加一个旁路，从设备驱动程序中复制数据包，经过 BPF(BSD Packet Filter)过滤，之后送入内核缓冲，最后进入用户层缓冲区。

![image](https://songtianyi-blog.oss-cn-shenzhen.aliyuncs.com/libpcap-packet-flow.png)

> BPF 是一个内核模块

### 会话重组

从上面的图中可以看到，libpcap 的拿到的数据是没有经过协议栈的，所以需要上层软件自己去组装和解码，根据需求去模拟协议栈的部分或全部。因此，我们要了解协议栈是怎么工作的，以基于 TCP 的 c/s 模型为例：

![image](https://songtianyi-blog.oss-cn-shenzhen.aliyuncs.com/tcp-ip-stack.gif)



> We say `TCP segment` is the protocol data unit which consists a TCP header and an application data piece (packet) which comes from the (upper) Application Layer. Transport layer data is generally named as `segment` and network layer data unit is named as `datagram` but when we use UDP as transport layer protocol we don't say `UDP segment`, instead, we say `UDP datagram`. I think this is because we do not segmentate UDP data unit (segmentation is made in transport layer when we use TCP).

![image](https://songtianyi-blog.oss-cn-shenzhen.aliyuncs.com/tcp-ip-data-encapsulation.jpg)

从上面两张图，我们可以清晰地看到应用层的数据是怎么被封包和解包的。需要补充的是，如果是 TCP 协议，应用层的数据会被分片，并被加上 TCP header，变成 TCP segment。segment 的大小由 MSS(maximum segment size)来控制, 一般比 MTU 小，避免 IP 分片(fragmentation).

到了网络层，IP 协议会对根据 MTU 和 TCP segment 的大小来分片，分片后加上 IP header，变成 IP datagram。在整个传输过程中，IP 包可能会被多次分片。所以，为了避免分片，MSS 应设置为整个链路中的最小的 MTU 值。下图是 IP 报文多次分片的过程。

![image](https://songtianyi-blog.oss-cn-shenzhen.aliyuncs.com/1280px-IP_Fragmentation_example_-_en.png)

IP 报文在到达链路层之后，被加上了链路层的 header（主要是源 MAC 地址和目的 MAC 地址），变成以太网帧，即 Ethernet frame.

![image](https://songtianyi-blog.oss-cn-shenzhen.aliyuncs.com/802.3-ethernet-frame.jpg)

libpcap 捕捉到的即是以太网帧，我们按照协议栈将以太网帧逐层解码, 根据需求去提取数据。

拿到了每一层的数据，会话重组就很简单了，通过 ip+port 即可确定一个会话。主要的工作量在于保证数据包的顺序。另外取决于我们的需要，比如需要模拟应用层的会话过程，则相对繁琐一些，既要扮演 client，又要扮演 server。

### 协议识别

通信的双方是知道应用层的通信协议的，但是对于普适的流量分析软件，拿到的是应用层以下的数据包，是不知道应用层协议的, 不知道协议，就无从解码。识别协议，有以下几种方式:

1. 录入 ip/port 和应用协议的映射关系，对于存量和新增的业务都要录入
2. 通过[nDPI](https://github.com/ntop/nDPI/wiki/Supported-Protocols)(深度包检测）来判断常用的应用层协议，比如 http/tls/ftp 等等, 目前标准的应用层协议基本都支持，ip 层的协议如 ICMP/ICMPv6 也支持, 常用的软件如 QQ/Wechat/Zoom 也支持。DPI 软件一般是通过分析会话的第一个包的部分字节来确定协议。类似的有[libprotoident](https://github.com/wanduow/libprotoident/wiki/SupportedProtocols).
3. 通过机器学习训练识别模型，然后用模型来推断协议

结合以上几种形式，基本解决协议识别的问题。

### 协议解析

##### 明文

识别协议之后，如果是标准的应用协议，自然能够根据标准对其解码，做统计也好，拿关键信息也好，方案是明确的，主要的工作量在于了解协议格式，会话过程，编写解码逻辑。

对于非标准的协议，需要咨询协议的制定者，了解编解码方式，如果不能透露，可以直接按照其使用的字符编码打印出来观察，是否有分析软件需要的关键信息。

##### 加密数据

对于加密数据，如果是标准的 TLS 加密，需要拿到客户使用的证书的私钥才能解码，因为 TLS 的会话过程中，生成对称密码的关键信息是用公钥加密过的，只能私钥来解。所以，这个问题主要依赖客户，如果能拿到私钥，我们只需要模拟整个 TLS 握手过程即可解密。

如果是非标准的加密，就需要了解具体的加密方式, 还是得依赖客户。

##### 金融证券协议

国内的金融证券协议是从国际标准演化而来，具体的实现又和交易所，各个银行等强相关，所以比较复杂。打个比方，标准只规定使用 k=v 结构来组织数据，交易所实现的时候，k 的定义可能是五花八门的，但对于分析软件来说，k 是很关键的，否则没有解码的必要。

![image](http://assets.processon.com/chart_image/5eeb42cd6376891e81d65470.png)

### 性能

性能会是一个潜在的比较大的问题，因为数据量实在太大。对于大厂商，他们可能会用专门的硬件和系统来跑分析软件，目前我们只能用标准系统来跑，但也有可以优化的点。

首先是语言和框架的选用，除了 demo 使用的 gopacket，还有基于 C++开发的[PcapPlusPlus](https://github.com/seladb/PcapPlusPlus), 相比 cgo 性能自然好很多，但是 C++的开发成本应该高一些。

##### DPDK

Data Plane Development Kit (DPDK) 通过绕过内核(kernel bypass)来加快处理数据的速度，运行在用户态，提供驱动和数据处理的函数。由于绕过了内核，所以减少了中断和数据拷贝次数，同时不影响原本的架构。缺点是没有实现网络协议栈，但 DPDK 支持内核重入，即把数据重新塞进内核协议栈，而且也有 ip 包重组的库。

##### PF_RING

PF_RING 由内核模块和用户态框架组成，能够增加包处理的速度，libpcap 已经支持。

![image](https://songtianyi-blog.oss-cn-shenzhen.aliyuncs.com/pf_ring_and_legacy_architecture.jpg)

### 存储

由于流量巨大，全量存储的方式性价比较低，需要根据具体的业务场景来权衡。

在数据统计，监控的场景，我们只需存储计算后的数据，如流量计数，这类数据可以存入时序数据库。

对于安全相关的近期数据，我们可以存入 Elasticsearch，过时的数据可以存入 HBase 等。可以只选取数据包里的五元组作为元数据来存储，而不必存储整个数据包。

### 架构

![image](https://songtianyi-blog.oss-cn-shenzhen.aliyuncs.com/network-data-intelligence-archi.png)




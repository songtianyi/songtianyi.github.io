# 解码 TLS

作者: [songtianyi](http://songtianyi.info) 2020-06-11

> 本文前三小节会介绍 TLS 相关的基础知识，只对解密部分感兴趣的可直接跳到 TLS 握手这一节
>
> 部分图片来自网络

### TLS

TLS(Transport Layer Security)协议是为了安全而生的，它的前身是 SSL(Secure Sockets Layer)，能够为 TCP, HTTP 等协议提供安全性。

![image](https://songtianyi-blog.oss-cn-shenzhen.aliyuncs.com/WeChat1c21580295a2493c238e262635eb00e7.png)

如果不使用安全协议，会产生哪些安全问题？

* 我们在开发服务的时候，如果不考虑安全，基本都是使用 http/tcp 协议，为了方便，直接使用明文传输，数据在传输过程如果被嗅探，那么我们的隐私就全都暴露给了别人，形同裸奔。
* 明文传输也会暴露自己的交互接口，伪造客户端或服务端程序会变得很容易
* 数据在传输过程中可能会被劫持和篡改
* 一种方案是使用对称加密，通信双方用同样的密钥对数据加解密，但仍然存在密钥泄漏的可能。如果所有的连接都使用相同的密钥，泄漏之后造成的危害极大，如果使用不同的密钥，那么协商密钥的过程也会被嗅探。

上述问题总结为

* 数据会泄漏
* 数据会被篡改
* 可伪造数据

实践证明，TLS 很好地解决了这些问题

* 用证书(public key certificate)机制做身份验证，防伪造
* 借助非对称加密协商密钥，对应用数据进行对称加密，防泄漏，防篡改

### 公钥证书

了解非对称加密 <sub>[2]</sub>特点的人应该知道，用公钥对数据加密后，只能用私钥解密，相应的，用私钥加密数据后，只能用公钥解密，这个特性是证书的基础。简单来说，假如 A 访问 B，B 用自己的私钥将信息加密后，传输给 A，同时把 B 的公钥告诉 A，A 用收到的公钥对加密数据解密，如果能够解密，说明 A 收到的数据确实是 B 发送的。问题在于，A 怎么知道自己得到的加密数据和公钥确实是 B 的呢，似乎我们掉进了一个鸡生蛋蛋生鸡的循环里。比如，我们访问 zhihu.com，怎么知道我们收到的公钥确实是知乎的呢？那是否，知乎需要通过可信渠道将公钥派发给我们？如果通过网络派发，我们又回到了安全问题的循环里，如果通过传统媒介，比如报纸，电视等，很明显这类方式是没办法轻松完成数以亿计的公钥派发的，于是有了根证书的概念。公钥存在证书里，通过网络派发，根证书就是初始的“可信渠道”。

根证书是世界公认的可信机构自己给自己签名的证书，前面列举的 A/B 通信的例子就是自签名的案例，问题是，如果每个人都可以自签名，那么证书就没有可信度了，相当于谁都可以说自己是 zhihu.com，该信谁？信认可以派生，对于证书的信任派生是以可信机构的自签名证书为根，逐级进行的。

我们打开 zhihu.com, 找到其证书, 可以很清晰的看到，可信机构**DigiCert Inc**自签名了一个全球有效的根证书 **DigiCert Global Root CA**，并用自己的私钥给分支机构签发证书，再由分支机构用自己的私钥向外签发证书，完成整个信任派生的过程。

![image](https://songtianyi-blog.oss-cn-shenzhen.aliyuncs.com/zhihu-cert-root.jpg)

![image](https://songtianyi-blog.oss-cn-shenzhen.aliyuncs.com/zhihu-cert-zhongji.jpg)

![image](https://songtianyi-blog.oss-cn-shenzhen.aliyuncs.com/zhihu-cert.jpg)

我们的操作系统内置了可信任的根证书，那么由可信任的根证书签发的整个证书链都是可信的。

![image](https://songtianyi-blog.oss-cn-shenzhen.aliyuncs.com/digicert-in-system.jpg)

根证书的重要性不言而喻，需要审计后才能加入到可信列表中，这里不展开讲。曾经的 12306 使用的是自己内部(SRCA)签名的证书，SRCA 不在操作系统如 widnows 的可信列表中，所以大家在使用的时候会遇到安全方面的提示，现在 12306 也使用国际机构签发的证书了。

##### 双向身份验证

A 访问 B 的场景中，只需要 B 提供证书，保证 B 的身份的真实性。比如我们访问知乎，只需要用户名和密码即可，至于是我们本人在访问，还是本人的亲人朋友在访问，知乎并不关心。但对于网上银行交易来说，银行（此时扮演 B）必须确保 A 的身份的真实性，所以在银行开卡的时候，通常会发一个 U 盾（USBKey），U 盾里存放着 A 的数字证书和他的私钥，在交易时，银行会验证这些信息，确保使用者是其本人。

### x.509

x.509<sub>[3]</sub>是公钥证书遵循的一种标准格式，我们称使用 x.509 规范的公钥证书为 x.509 证书，它的应用场景不止于 TLS，还包括

* 邮件加密
* 代码/应用程序签名
* 电子文档签名
* 客户端认证
* 电子身份签名

x.509 包含哪些内容？回顾一下前面的内容

> 简单来说，假如 A 访问 B，B 用自己的私钥将自己的信息加密后，传输给 A，同时把 B 的公钥告诉 A，A 用收到的公钥后对加密数据解密，如果能够解密，说明 A 收到的数据确实是 B 发送的

这是一个基本的通信场景，证书解决的是把 B 的公钥告诉 A 时的安全问题，所以证书需要包含 B 的公钥。为了表明身份信息，至少会包含签发的对象（这里是 B）以及签发者。为了方便管理证书，会给它分配一个序列号，同时还有 x.509 规范的版本信息，证书的有效期，签名算法等等，这些属于证书的数据域，我们先对证书的数据域进行 hash，然后签发者用自己的私钥对 hash 值加密，得到一个签名，并放进证书。以上，我们得知，一个完整的证书至少包含以下内容

* 签发的对象
* 签发者
* 签发的对象的公钥
* x.509 版本
* 签名算法
* 证书有效期
* 证书数据签名

A 在收到此证书后，使用签发者的公钥（签发者的公钥是内置在系统内的证书包含的，以此类推）解密签名，得到数据域的 hash 值，使用同样的 hash 算法对数据域 hash，对比两个 hash 值，来验证 A 收到的 B 的证书的可靠性。

> 注意，实际上我们并不会直接用 RSA 对需要传输的数据进行加解密，因为效率不高。通常，对于防篡改的场景，我们对数据先做 hash，然后对 hash 值做 RSA 加密

我们可以借助 openssl 命令打开一个证书看看，里面具体有哪些内容

```

# 先生成自签名的证书
openssl req -x509 -nodes -newkey rsa:2048 -keyout server.key -out server.crt -days 3650
# 查看证书文本
openssl x509 -in server.crt -text
```

这是一个自签名的证书，所以 Issuer(签发者）和 Subject（签发的对象）是相同的。

![image](https://songtianyi-blog.oss-cn-shenzhen.aliyuncs.com/self-signed-certificate-example.jpg "本地自签名例子")

### TLS 握手

前面提到，公钥证书是 TLS 加密机制的一部分，那它们具体是怎么联系在一起的？我们来推测一下，还是以 A 访问 B 为例。

1. 首先，TLS 协议是在传输层之上的，所以需要先建立 TCP 连接
2. B 需要把自己的公钥证书发送给 A，A 根据证书链去验证 B 的真实性
3. 由于安全的需要，A/B 之间的应用数据是需要加密后传输的，但我们不直接使用 RSA 对应用数据加解密，因为效率低，所以需要协商一个对称加密算法和密码，这些少量的协商时的内容在传输过程中可以使用 RSA 来加密
4. 使用协商好的算法和密码，对应用数据加密，然后传输，对方在收到数据后用协商好的算法和密码解密

实际过程复杂很多，除了加密算法还会协商压缩算法。TLS 协议包含握手协议和记录(record)协议。记录协议会对数据分片压缩，再用协商的对称密钥加密。TLS 协议的构成如下:

![image](https://songtianyi-blog.oss-cn-shenzhen.aliyuncs.com/tls-proto.png)

我们来抓包看下具体的握手过程。在此之前需要先生成自签名的证书，然后编写 client 端和 server 端的代码, 见 Github [tls-example]( https://github.com/songtianyi/tls-example) <sub>[4]</sub>

编译并运行样例程序，并使用 wireshark 抓包，截图如下

![image](https://songtianyi-blog.oss-cn-shenzhen.aliyuncs.com/tls-handshake.jpg)

从图中，可以清楚地看到

1. 在建立 TLS 连接之前先建立了 TCP 连接
2. tls 握手开始，先发送 client hello 消息，告诉 server 端自己的 tls 版本，支持的加密算法，压缩算法等等，另外生成随机字符串 Random，我们记它为 client random

![image](https://songtianyi-blog.oss-cn-shenzhen.aliyuncs.com/client-hello.jpg)

3. server 端收到 client hello 后，发送了三种类型的消息给 client 端

   - Server Hello: 发送选择的加密算法，压缩算法等，生成 Random 字符串，我们记它为 server random
   - Certificate: 发送 server 端的证书
   - Server Hello Done: 结束标记

![image](https://songtianyi-blog.oss-cn-shenzhen.aliyuncs.com/server-handshake.jpg)

4. client 收到证书后进行验证
5. client 根据协商的算法生成 PreMaster-Secret, 然后使用收到的证书里的公钥加密，发送加密后的 PreMaster Secret, 结束握手
6. server 收到加密后的 PreMaster Secret，并使用自己的私钥解密, 然后结束握手

至此，client 和 server 都可以根据 client random, server random 和 PreMaster secret 来生成加密密钥

```

key = GenerateKey(client_random, server_random, pre_master_secret)
```

之后发送的数据会使用这个 key 来加密，key 是我们解密 TLS 数据包的关键。

综上，tls 握手的流程总结如下：

<img src="https://songtianyi-blog.oss-cn-shenzhen.aliyuncs.com/tls-handshake-process.png" width="50%">

### 解码

在我们使用 wireshark 抓包的时候，纵观整个流程，只有 PreMaster-Secret 是加密的，其他的握手数据是明文，所以，PreMaster-Secret 是解码的关键。为此，wireshark 给我们提供了两种方案。

##### 通过 RSA 私钥

有了 PreMaster-Secret, 我们就能生成密钥，使用密钥来解码数据。而 Secret 是使用 server 端的公钥加密的，只能使用 server 端的私钥解密，因此，我们有了私钥，自然可以对抓到的 Secret 解密，然后生成密钥。具体的操作步骤可以参考 <sub>[1]</sub>

![image](https://songtianyi-blog.oss-cn-shenzhen.aliyuncs.com/wireshark-rsa-list.jpg)

##### 通过 ssl_key_log

client 和 server 作为通信的双方，也是能够知道加密密钥的，所以很多语言包，为了 debug tls，会提供输出 PreMaster-Secret 的接口，比如 Go 语言提供了 KeyLogWriter:

```go
// write per-session secrets
w, err := os.OpenFile("sslkeylog", os.O_WRONLY|os.O_CREATE|os.O_APPEND, 0600)
if err != nil {
	log.Fatal(err)
}

config = tls.Config{
	KeyLogWriter:       w, // writer
}
```

把写到文件的 secret 交给 wireshark 就可以解包了，具体操作步骤参考 <sub>[1]</sub>

![image](https://songtianyi-blog.oss-cn-shenzhen.aliyuncs.com/wireshark-ssl-keylog.jpg)

本地测试结果截图如下:

![image](https://songtianyi-blog.oss-cn-shenzhen.aliyuncs.com/tls-send-demo.jpg)

除了使用 wireshark，我们也可以自己写代码来抓数据包，然后使用相同的方式解码。

### 参考资料

* [1] wireshark TLS 〔DB/OL〕[https://wiki.wireshark.org/TLS](https://wiki.wireshark.org/TLS)
* [2] [RSA 加密算法的探究与实现 〔DB/OL〕](../../blockchain/rsa.html)
* [3] What Is an X.509 Certificate? 〔DB/OL〕[https://www.ssl.com/faqs/what-is-an-x-509-certificate/](https://www.ssl.com/faqs/what-is-an-x-509-certificate/)
* [4] tls-example 〔DB/OL〕[https://github.com/songtianyi/tls-example](https://github.com/songtianyi/tls-example)

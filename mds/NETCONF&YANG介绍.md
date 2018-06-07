# 背景
随着互联网的发展，网络日趋复杂且规模庞大。网络的稳定性／可预测的故障恢复时间如何保障？大量的新设备和服务如何安全快速地融入老的系统？不同的厂商接口如何统一管理？这些问题需要大量的优秀工程师去处理，但另一个事实是，相当一部分的网络故障是由人为操作不当引起的。通过自动化网络管理去减轻工程师的运维负担是大势所趋。在2002年IAB（Internet Architecture Board ）就网络管理所面临的问题作了讨论（[RFC3535](https://tools.ietf.org/pdf/rfc3535.pdf))，确定了四个解决问题的关键方向，支持事物／可回滚／实现成本低／配置可存储和恢复。随即NETCONF工作小组成立，基于这几个方向制定了NETCONF标准([RFC6241](https://tools.ietf.org/pdf/rfc6241.pdf)). NETCONF协议包含四层，数据层/操作层/调用层/传输层, 但是缺少一种定义数据模型的方式，2008年NETMOD工作组成立，2009年NETMOD发布了YANG（[RFC7950](https://tools.ietf.org/pdf/rfc7950.pdf)）, 一种为NETCONF定义数据模型的标准语言。
# NECONF
#### 术语
* datastore 网络设备上配置的存储和分类方式，分为三种，startup/candidate/running
  * startup 设备启动时使用的配置
  * candidate 可供修改但不会立即生效的配置，可以通过commit操作提交，成为running配置，不是所有的设备都有candidate配置
  * running 设备当前使用的配置
* capabilities NETCONF server端向client端暴露自己所支持的功能，NETCONF协议制定了一些基本功能，以urn开头
```
urn:ietf:params:netconf:capability:{name}:1.x
```

#### 工作机制
NETCONF是C/S架构的模式，Client和Server通过RPC以xml形式交换数据。Client端作为网络管理服务的一部分，可以是脚本，也可以是应用等。Server端一般是网络设备。

![NETCONF架构](http://upload-images.jianshu.io/upload_images/7361-52d2639e88f4f936.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
#### 四个层次
NETCONF包含了四个层次，数据层／操作层／RPC/传输层, 对于普通用户，只需关注数据层和操作层即可。

![NETCONF的四个层次](http://upload-images.jianshu.io/upload_images/7361-74efe21cac088804.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

###### Content
设备模型数据，YANG数据建模语言正是用来描述这些模型数据的。
###### Operations
操作层定义了一系列用于网络设备管理的操作。

![NETCONF operations 列表](http://upload-images.jianshu.io/upload_images/7361-158b4b7be41227d6.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
###### RPC
定义了一种独立于协议之上( transport-protocol-independent)的数据组织和传输方式。
###### Transport Protocol
定义了数据的传输方式， NETCONF并没有指定协议实现者在C/S之间使用什么传输协议，只是规定了一些传输协议必须满足的要求，比如面向连接／支持kee-alive等，具体的参见[RFC6241](https://tools.ietf.org/pdf/rfc6241.pdf).
#### 实际环境中的使用
我们使用juniper的vsrx来做NETCONF的使用示例。
###### vsrx安装
1. 下载[vsrx](http://www.juniper.net/support/downloads/?p=vsrx)
2. 使用vmware等虚拟化软件安装并启动vsrx
3. 配置vsrx
 3.1 通过缺省用户名和密码登录(root/空)
 3.2 进入操作模式
```
cli
```
 3.3 进入配置模式
```
configure
```
3.4 设置密码
```
set system root-authentication plain-text-password
```
3.5 设置远程登录管理用户
```
set system login user remote class super-user authentication plain-text-password
```
3.6 设置网络
```
set interfaces fxp0 unit 0 family inet address 172.16.240.189/24
```
3.7 设置netconf ssh port
```
set system services  netconf ssh port 830
```
3.8 提交配置
```
commit check
commit
```

###### NETCONF clients
client列表
 * [go-netconf](https://github.com/Juniper/go-netconf) 
 * [ncclient](https://github.com/ncclient/ncclient)
 * [netconf-java](https://github.com/Juniper/netconf-java)
 * [JNC](https://github.com/tail-f-systems/JNC)

###### 创建一个session
连接完成后，server端会返回自己的capabilities
```
package main

import (
	"fmt"
	"golang.org/x/crypto/ssh"
	"log"
	"github.com/Juniper/go-netconf/netconf"
)

func main() {
	sshConfig := &ssh.ClientConfig{
		User: "root",
		Auth: []ssh.AuthMethod{ssh.Password("r00ttest")},
		HostKeyCallback: ssh.InsecureIgnoreHostKey(),
	}

	s, err := netconf.DialSSH("172.16.240.189", sshConfig)

	if err != nil {
		log.Fatal(err)
	}

	defer s.Close()

	fmt.Println(s.ServerCapabilities)
	fmt.Println(s.SessionID)
}
```
###### 获取running配置
你会看到running的所有配置
```
package main

import (
	"fmt"
	"golang.org/x/crypto/ssh"
	"log"

	"github.com/Juniper/go-netconf/netconf"
)

func main() {
	sshConfig := &ssh.ClientConfig{
		User: "root",
		Auth: []ssh.AuthMethod{ssh.Password("r00ttest")},
		HostKeyCallback: ssh.InsecureIgnoreHostKey(),
	}

	s, err := netconf.DialSSH("172.16.240.189", sshConfig)

	if err != nil {
		log.Fatal(err)
	}

	defer s.Close()

	fmt.Println(s.ServerCapabilities)
	fmt.Println(s.SessionID)

	// Sends raw XML
	reply, err := s.Exec(netconf.RawMethod("<get-config><source><running/></source></get-config>"))
	if err != nil {
		panic(err)
	}
	fmt.Printf("Reply: %+v", reply)
}
```
###### 修改配置并提交
包括错误回滚
```
package main

import (
	"fmt"
	"golang.org/x/crypto/ssh"
	"log"

	"github.com/Juniper/go-netconf/netconf"
)

func doRpc(s *netconf.Session, xml string) {
	reply, err := s.Exec(netconf.RawMethod(xml))
	if err != nil {
		panic(err)
	}
	fmt.Printf("Reply: %+v", reply)
}

func main() {
	sshConfig := &ssh.ClientConfig{
		User: "root",
		Auth: []ssh.AuthMethod{ssh.Password("r00ttest")},
		HostKeyCallback: ssh.InsecureIgnoreHostKey(),
	}

	s, err := netconf.DialSSH("172.16.240.189", sshConfig)

	if err != nil {
		log.Fatal(err)
	}

	defer s.Close()

	fmt.Println(s.ServerCapabilities)
	fmt.Println(s.SessionID)
	//xml := "<rpc>"
	xml := ""
	xml += "<edit-config>"
	xml += "  <target><candidate/></target>"
	xml += "  <error-option>stop-on-error</error-option>"
	xml += "		<config>"
	xml += "		<configuration>"
	xml += "			<interface>"
	xml += "				<name>fxp0</name>"
	xml += "			<unit>"
	xml += "				<name>0</name>"
	xml += "				<family>"
	xml += "					<inet>"
	xml += "						<address>172.16.240.189/24</address>"
	xml += "					</inet>"
	xml += "				</family>"
	xml += "			</unit>"
	xml += "			</interface>"
	xml += "		</configuration>"
	xml += "		</config>"
	xml += "</edit-config>"
	//xml += "</rpc>

	// Sends raw XML
	doRpc(s, xml)
	xml = "<rpc><commit></commit></rpc>"
	doRpc(s, xml)
}
```
#### Distributied transactions
当有多个设备需要修改配置时，为了保证操作的原子性，我们可以先锁定所有设备的配置，修改完成后，利用confirmed-commit特性，check完之后再确认提交。

![distributed transactions](http://upload-images.jianshu.io/upload_images/7361-0443c85b8bb0995e.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


## YANG
YANG是为NETCONF而生的数据建模语言, 应用在NETCONF的content层和operation层。YANG用层级的方式描述NETCONF的配置和状态数据,RPC及通知，覆盖了NETCONF C/S的整个生命周期。YANG模型可以转换成JSON和XML。
#### statements
YANG定义了一系列的模型描述关键字。

![statements](http://upload-images.jianshu.io/upload_images/7361-6467b5684e7fb270.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

#### types
YANG定义了一系列的基础类型，同时可以用typedef描述自定义的类型, 一些通用的扩充类型可以参见[RFC6021](https://tools.ietf.org/pdf/rfc6021.pdf)

![基础类型](http://upload-images.jianshu.io/upload_images/7361-2d2937d611ec320d.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

#### 使用YANG来描述一个DHCP配置
###### DHCP配置
```
# Sample configuration file for ISC dhcpd

default-lease-time 600;
max-lease-time 7200;

subnet 10.254.239.0 netmask 255.255.255.224 {
  range dynamic-bootp 10.254.239.10 10.254.239.20;
  option routers rtr-239-0-1.example.org, rtr-239-0-2.example.org;
  max-lease-time 1200;
}

shared-network 224-29 {
  subnet 10.17.224.0 netmask 255.255.255.0 {
    range 10.17.224.10 10.17.224.250;
    option routers rtr-224.example.org;
  }
  subnet 10.0.29.0 netmask 255.255.255.0 {
    range 10.0.29.10 10.0.29.230;
    option routers rtr-29.example.org;
  }
}
```
###### YANG模型
```
module dhcp { // dhcp module
	namespace "songtianyi:yang:dhcp";
	prefix dhcp;
	import ietf-yang-types { // 导入自定义类型
		prefix yang;
	}
	import ietf-inet-types {
		prefix inet;
	}

	organization "TIANYUAN CLOUD TECH";
	description "Partial data model for DHCP, based on the config of the ISC DHCP reference implementation.";

	container dhcp { // 根结点
		description "configuration and operational parameters for a DHCP server.";

		leaf max-lease-time { // 描述最大租赁期
			type uint32;
			units seconds;	// 定义单位
			default 7200;	// 最大租赁期默认值
		}

		leaf default-lease-time {
			type uint32;
			units seconds;
			must 'current() <= ../max-lease-time' { // 约束,  default-lease-time必须小于等于 max-lease-time
				error-message "The default-lease-time must less or equal max-lease-time";
			}
			default 600; // 如果默认值大于 max-lease-time也会报错
		}

		uses subnet-list;	// 引用grouping描述

		container shared-networks {
			list shared-network {
				key name;
				leaf name {
					type string;
				}

				uses subnet-list;
			}
		}
	}

	grouping subnet-list {
		description "A reusable list of subnets";

		list subnet {
			key net;
			leaf net {
				type inet:ip-prefix;
			}
			container range {
				presence "enables dynamic address assignment"; // presence表明，range作为子节点存在，即使range没有定义子节点
				leaf dynamic-bootp {
					type empty;
					description "Allows BOOTP clients to get addresses in this range";
				}

				leaf low {
					type inet:ip-address;
					mandatory true;
				}

				leaf high {
					type inet:ip-address;
					mandatory true;
				}
			}

			container dhcp-options {
				description "Options in the DHCP protocol";

				leaf-list router {
					type inet:ip-address;
					ordered-by user;
				}

				leaf domain-name {
					type inet:domain-name;

				}

				leaf max-lease-time {
					type uint32;
					units seconds;
					default 1200;
				}
			}
		}
	}
}
```
#### YANG tools
* [pyang](https://github.com/mbj4668/pyang)
* [libyang](https://github.com/CESNET/libyang)
* [goyang](https://github.com/openconfig/goyang)

## NETCONF&YANG
前边分别介绍了NETCONF和YANG, 那么它们是如何结合起来的呢？
```
<dhcp xmlns="http://yang-central.org/ns/example/dhcp" xmlns:nc="urn:ietf:params:xml:ns:netconf:base:1.0">
	<default-lease-time nc:operation="merge">10800</default-lease-time>
</dhcp>
```
在netconf client发送xml给netconf server的时候将YANG模型加入xml即可，server会根据模型来检验xml里的配置数据，因此default-lease-time的10800配置会返回rpc-error。需要注意的是，这些特性依赖于netconf server的具体实现，因此需要通过server端返回的capbilities来检查是否支持该特性。

## NSO
在网络设备管理方面起步早且做的好的，应当是tail -F systems, 该公司的NSO(Network Service Orchestrator)产品已被cisco收购。
#### NSO架构

![NSO Logical Architecture](http://upload-images.jianshu.io/upload_images/7361-47073a0ce292334e.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
#### Web User Interface
参见视频[]
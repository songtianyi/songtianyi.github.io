# 编程核心概念

作者: [songtianyi](http://songtianyi.info) create@2020-11-08

计算机技术非常庞大，而且仍在快速更新，面对越来越多的新技术，我们似乎跟不上了。如何面对新技术，如果面对换工作时的技术迁移，是必须要考虑的。
优秀的程序员不会被技术迭代淘汰掉，也不惧怕切入新的技术领域。掌握一些核心的概念，可迁移的能力，是我们从容应对的底气。之后要介绍的内容，正是基于此而产生的，我个人认为比较重要的一些核心概念。这些概念虽然简单，但需要我们时常放在心上。

除了讲述基本概念，每个概念会附带一些技术名词，方便进一步学习。

### **protocol**

协议，或者说约定，是我们构建任何系统的基础，我们制定标准，在标准的指导下通力合作，构建出一个个庞杂的系统。比如网络协议 tcp/ip，编码标准，编程语言，甚至我们平时说的普通话，都可以算作是协议。协议本身是很简单的，都是规定死的东西，重要的是协议为什么是这样设计的, 所以它的发展历程很重要。
我们在学tcp/ip 的时候，如果一开始就扎进协议的细节里，会学的很痛苦，协议本身是很枯燥的，而且庞杂，好比我们学英语的时候去死背英语单词。正确的学习方式是，从简单的协议开始，理解协议本身，建立“每一个设计细节背后，都有一个精妙的设计初衷”这种观念，比如tcp/ip协议栈的层级结构，它在一开始就是这样的嘛，这样一个复杂的东西，是怎么一步步变成现在这个样子的，然后再一点点地去了解协议细节，以及背后的设计初衷。精密的事物，都有精妙的设计哲学在里面，重要的是，我们能感知这种哲学，感受设计者的思想，这才是最有意思的事情。

programming-languages/network-protocols/RFCs/encoding-decoding-protocols

### **encoding/decoding**

编码与解码无处不在，在我的概念里，编码/解码是协议的实现，比如utf-8的编解码实现了utf-8这个标准。
编解码处理的是数据，而且一般成对出现，是可逆的，比如软件工程里的逆向工程；但有的是不可逆的，比如有损压缩，你需要借助一些插值算法，才能把数据补回去，补回去的数据也并非原数据；再比如hash，只有编码过程，没有解码过程。

之前面试的时候，有面试者说SHA1 hash是加密算法，虽然加密算法也是encoding的过程，但区别是，加密必然伴随着解密，即decoding，所以hash只能算编码算法。这里贴一段英文的解释<sup>[1]</sup>，因为大部分中文教程里，都有 ~~`md5是加密算法`~~ 这样的错误描述，导致很多人对此深信不疑。

``` 

By definition, a hash function is not encryption.

> Encryption is the process of encoding messages (or information) in such a way that eavesdroppers cannot read it, but that authorized parties can.

and

> Hash function is an algorithm that takes an arbitrary block of data and returns a fixed-size bit string, the cryptographic hash value, such that any change to the data will (with very high probability) change the hash value.

Encryption provides confidentiality while hash functions provide integrity.

Hash functions are used alongside encryption for their integrity capabilities.
```

我们在阅读或者debug代码的时候，多去寻找编解码的函数，如此，数据的边界，流向，变化过程会比较清晰，便于我们快速定位出错的位置。
举个乱码的例子，很多人都遇到过乱码，有些情况比较简单，有些则看起来复杂。比如，同样的代码，在虚拟机上的输出是乱码，在本地PC上的输出却是正常的。如果我们只关注到代码是一样的，你会觉得这问题出的很是莫名其妙对不对，但如果你注意到，我们从程序里输出到terminal的内容，是会被terminal解码的，这时你应该会想到，是不是本地 terminal 设置的编码和远程虚拟机 terminal 设置的编码不一致导致了这种差异。

ffmpeg/open-ssl/compiler-decompiler/compression-decompression

### **binary**

二进制是我们在计算机人门时最先接触到的概念，虽然我们熟知二进制是信息最基础的表现形式，但我们并不一定时常能以这样的认知去看待事物。
以编程语言里的类型来举例，在我们的认知里，类型通常是不能随意转换的，你会遇到各种编译错误，对不对？但实际上是可以的。所谓类型，只是编译器用来约束变量边界的规范，任何类型，其本质都是二进制，我们可以用 `int32` 来存储1-4个 `char` ，也可以用一个 `double` 来存储1-4个 `int32` , 还可以用 `short` 来存储 `float` 以降低 `float` 的精度，从而达到降低存储空间的目的等等。二进制级别的运算是很有意思的，可以借助指针让我们直接操作内存，在性能和存储空间方面做更深入的优化，也可以做一些精妙的hack。但并不是所有语言都提供这种自由。

```c++
// c++
// 32bit float 降精度，用16bit short 存，节省存储空间
void FPC::__32To16(const float x, unsigned short &res)
{

    //little endian
    assert(GABS(x)  < 1.0f);
    int  nTmp = static_cast<int>(x*32768);
    nTmp += 32768;
	res = nTmp & 65535;

}
```

binary-arithmetic/pointer

### **input/output**

i/o 无处不在，但我们不一定会特别注意到它。比如磁盘io，键盘(input)+显示器(output)，网络io等。io一般发生在软件与软件或者软件与硬件的边界处，对我们理解软件／系统架构至关重要，自己做架构设计时候也要时常注意io的边界。

network-io/disk-io/functions-input-output

### **emulation**

"一切能用硬件实现的东西，都可以用软件来模拟“。这是一位学长教给我的至今印象很深的一句话。就像摩尔定律一样，这句话相当于一种论断，预言，它能带给你信心，也会促使你去寻找反例。我们可以用软件构建出一个和现实世界一模一样的虚拟世界: 仿真系统，虚拟化，自动化系统等等。

除了使用软件模拟现实世界这方面，模拟的概念也时常出现在使用软件模拟软件方面。比如，模拟浏览器访问网站；模拟软件系统中的某个组件，用来测试系统中的其他组件或者伪装身份等等。

qemu/automation-system/simulation-system/games/man-in-the-middle-attack/mock

### **data-structure and algorithm**

程序设计 = 数据结构 + 算法， 在C语言的第一堂课里，老师应该会给你们讲这个公式，它们的重要性不言而喻。数据结构用来组织数据，堆栈，数组，链表，图，树等等，我们需要掌握很多种数据结构，并关注它们的使用场景。算法和数据结构是相辅相成的，合在一起构成解决问题的方案，也可以认为是解耦的，同一个算法可以使用不同的数据结构来实现。

从我个人理解的角度以及实用的角度讲，数据结构要比算法重要的多，首先数据结构是我们解决问题的第一步，即如何表达数据，表达数据不是单纯地存取它，而是发掘数据的内在结构，以一种较贴切的数据结构去表达数据的特性，当我们很好的完成第一步，接下来就能比较容易地去套用成熟算法了。

heap/stack/queue/linked-list/array/tree/graph/sort/search/indexing

### **time-sharing and asynchronous**

我们熟知的操作系统都属于分时操作系统，这种分时机制可以让多个进程"同时"跑，cpu资源按时间分片，分配给不同的进程，以达到多任务的效果, 它是并发的基础。而我们熟知的异步, 和并发的概念是不同的，异步是一种编程模型，你可以开一个子进程去执行长操作（比如磁盘io），而不用阻塞长操作之后的逻辑。

### **lock**

对于cpu资源，操作系统会把它按时间分片，然后分配给所有线程，不存在竞争，因为时间是不可能重叠的，不可复用的，但像内存，文件这类资源，是没办法按时间分片的，在并发的时候就有可能产生数据竞争（data race）。

![image](https://songtianyi-blog.oss-cn-shenzhen.aliyuncs.com/data-race.png)

如图所示，P1, P2相当于"同时"在访问这个内存块，因为P1的读还未结束，P2就开始修改它了。因此，我们需要对资源加锁，保证P1在完成读之前，P2是是不能写的。

真正的并行需要增加多个'时间线', 即多核, 每个核是独立的时间线。但多核也会让内存等不能按时间分片的资源更容易产生竞争, 处理起来也更复杂。在多核的情况下，我们可以对内存这类资源分片来减少共享数据，比如找数组的最大值，先将数组分成多份，然后合并结果。

spinlock/semaphore/mutex/concurrency/parallel/shared lock/exclusive lock

### **centralized/decentralized and distributed system**

我们经常会听到分布式架构, 但分布式（distribution）和去中心化（decentralize，也可以称非集中式）不是一个概念。分布式是指整个系统被分散到不同的位置，用来提升性能或者提高可靠性（比如git），而去中心化是指的是不存在一个单一的管理实体去管理整个系统，去中心化依赖多个相互独立的管理实体共同管理整个系统。SDN是中心化（也称集中式）的，区块链是去中心化的，也是分布式的。

CAP/BASE/Paxos/Raft/ZAB/Gossip/distributed-lock/distributed-id

### **cache and buffer**

之所以将 cache 作为核心概念，一是，它很重要，无处不在，二是，我不能很快地在现实世界中找到同样的案例，因此没把它归类到 `emulation` 里。

我们通常接触到的 cache 是我们的内存，它的读写速度比磁盘快很多，但也很贵，存储容量有限。cache 就是在容量和性能之间做的一个较好的权衡，用较小的代价，换取可观的性能收益。它的理论基础可以认为是:

* 时间局部性：如果某个数据被访问，那么在不久的将来它很可能被再次访问
* 空间局部性：如果某个数据被访问，那么与它相邻的数据很快也可能被访问

此为局部性原理。

在此类有性能差的软硬件之间，就可以设置 cache 层，来达到一个不错的效果。比如:

*CPU cache*
CPU 的性能相对主存要快很多，如果 CPU 直接访问主存，那么会浪费掉 CPU 的性能，而 CPU 所使用的 cache （Static RAM）是比主存(main memory) 快的多的硬件(Dynamic RAM), 而且有多级的 cache。当然，这种高速 cache 的容量是很小很小的，如果 miss ，cpu 会直接访问主存。
*GPU cache*
和 CPU cache 的架构类似，但是是针对3维数据，纹理数据做了优化的。
*Dsik cache*
磁盘也有 cache ，也是为了弥补内存和磁盘之间性能差距的，能够大幅提高磁盘的读写速度。

buffer 又是是什么？和 cache 有什么区别？ 

从字面上理解，buffer 是缓冲，而 cache 是缓存。cache 一般用来提高 io 速度，而 buffer 一般用来提高 io 吞吐效率。buffer 一般是用来提高写效率，cache 一般用来提高读效率。之所以放在一起，是因为它们的功能是一样的，都是为了弥补性能鸿沟。

> Disk cache 有时候也被称为 disk buffer, 可见它们之间的渊源。

当一些数据不能马上被拿走或消费掉的时候，就需要用 buffer，比如消息队列，它可以提高业务处理不过来的时候的响应速度，再比如 tcp 连接的 buffer，传输过来的数据会先被放进 buffer，这样传输就不用受限于业务程序的处理效率。 再如，数据库里使用的 WAL 技术，也可以认为是一种基于文件的 buffer, 提供持久性的同时，用顺序 io 代替随机 io 以提高写入速度。

### **参考资料**

* [1] [is-sha-1-encryption](https://security.stackexchange.com/questions/29482/is-sha-1-encryption)
* [2] [局部性原理——各类优化的基石](https://www.cnblogs.com/xindoo/p/11303906.html)
* [3] [Types of locality](https://en.wikipedia.org/wiki/Locality_of_reference#Types_of_locality)

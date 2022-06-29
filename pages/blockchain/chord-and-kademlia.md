# Chord 和 Kademia 算法

作者: songtianyi create@2022-06-29

## 背景

在整个去中心化生态里里，P2P(Peer-to-Peer) 都是非常重要且必要的技术，它的特点是，每个节点是等价的，既可以作为 client, 又可以作为 server. 在 C/S 的架构中，client 要连接 server 需要知道 server 的地址，P2P 网络中的节点之间也不例外，我们可以在每个节点中保存所有其它节点的地址信息，并访问。但问题是，如果网络中的节点数量非常庞大，达到百万级别，这样的方式对于内存和存储的消耗就非常大了。本文要讲的内容，Chord 和 Kdemia 算法，就是来解决这个问题的，即，解决节点间如何高效地找到彼此的问题。

## 抽象化

我在 [《编程核心概念》](../programming/software-engineering/M-core-concepts-in-programming.html) 中的数据结构和算法小节中有强调过，数据结构作为解决问题的第一关，其实比算法要更重要。对于这个问题，也不例外。我们首先要做的事情是，将离散的节点变的有规律一些，且不改变它的特质。
如下图，这些节点的组织方式不便于我们思考。

<img src="https://songtianyi-blog.oss-cn-shenzhen.aliyuncs.com/A-simplified-IPFS-network-and-its-components-A-user-adds-data-to-the-network-and-its.png" width="30%">

我们可以尝试把它抽象成一个环状的结构, 如下:

<img src="https://songtianyi-blog.oss-cn-shenzhen.aliyuncs.com/peer-ring.png" width="30%">

这个环状结构和这些节点的实际网络拓扑并不是对应的，它们之间的真实物理距离也并非像图中所示那样等分的。
如果每个节点保存其相邻节点（如下图所示），我们能很快找到附近的节点，但当节点数比较庞大的时候，并不高效，复杂度为 ***O(N)***

<img src="https://songtianyi-blog.oss-cn-shenzhen.aliyuncs.com/peer-ring-basic-query.jpg" width="30%">

那如果跳着查呢？节点 0 保存了节点 8 的信息，这样节点 8 周围的节点也能较快被找到。

<img src="https://songtianyi-blog.oss-cn-shenzhen.aliyuncs.com/basic-query-with-jump.jpg" width="30%">

## Chord

在 [《算法优化之时空交换》](../programming/data-structure-and-algorithms/M-time-space-trade-off.html) 一文中有强调，算法优化的思路就是用空间和时间相互转换，找到一个平衡点。在上图中，我们多保存了一个节点的信息，查找效率可以认为提升了1倍，变为 ***O(N/2)***, 那么保存越多的节点信息，查找效率越高，但在本文开头，我们也强调了，不可能保存所有的信息(保存所有节点信息的查找复杂度为 ***O(1)***).

Chord 算法的做法是，每个节点保存最多 m = ***Ceil(log<sub>2</sub>N)*** 个节点的信息，***N*** 为节点数。假设当前节点为 0, 它所保存的节点(称之为 *successor*)为 1, 2, 4, 8. 如下图所示:

<img src="https://songtianyi-blog.oss-cn-shenzhen.aliyuncs.com/node-zero-successors.jpg" width="30%">

设当前节点为 ***n***, 其第 i (m >= i >= 1) successor 为 ***(n + 2<sup>i-1</sup>) mod 2<sup>m</sup>***

以 N 为 16 为例，按照上述方法构造出来的图应该如下:

<img src="https://songtianyi-blog.oss-cn-shenzhen.aliyuncs.com/Chord_network.png">

其中的一个节点的连接情况用粗线标记出来了。
保存 *successor* 的结构称为 *finger table*. Chord 算法的查找复杂度为 ***log<sub>2</sub>N)***

search(n, id)
 if id ∈

##

## 参考资料

* [Chord (peer-to-peer)](https://en.wikipedia.org/wiki/Chord_(peer-to-peer))

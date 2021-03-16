# 如何评估一个 github 项目的价值

作者: [songtianyi](http://songtianyi.info) 2018-10-22

### 前言

一直觉得 github 的社交价值有待挖掘，想了下，可以做一个发现周围技术牛人的小程序，具体怎么做，这里先不说。如果去实现它，要解决的问题之一就是怎么评价 github 项目的价值。

##### 要素的选取

对比的要素 github 已经都标出来了，star, fork, watch.  比如目前比较热的深度学习框架 Tensorflow，它的要素值为(112564, 68801, 8471), 

##### 确定参考项目

另外，我们需要一个或者多个项目作为参考值。 不同的项目所对应的参考项目应该是不一样的，拿一个爬虫项目和 Tensorflow 对比没有意义, 而且冷门领域的 star 数会小几个数量级。所以，需要分类选取多个参考项目，简单点，我们把 star 排名前 N 的项目都找出来，作为参考项目，这些项目应该已经涵盖到了技术的方方面面了。在计算分数的时候，根据编程语言，标签(topics)找到匹配的参考项目进行计算。匹配的原则是，任意一个元素匹配即可，比如 A 项目的分类属性值为(go, wechat, bot), B 项目的分类属性值为(ruby, wechat, tool), 其中 wechat 是匹配的，那么 B 可以作为 A 的参考项目，这样更容易将项目的价值凸显出来。

##### 计算

最简单的计算方式是 star + fork + watch，然后计算和参考项目的差值并计算比例即可，但从某个角度来说，star, fork, watch 是三个不同的度量，好比单位不同(你不能直接将单位为米的 star 和单位为厘米的 fork 相加)，此外，star, fork, watch 它们的在计算时的权重也应有所差异，watch 的权重应该最高，其次是 fork。我们可以估算一个权重 `star=5*fork=10*watch` 。我们可以把它们看成三维空间的 x, y, z 轴上的值，如果有多个参考对象，先使用欧式距离分别计算它们和当前项目的距离，设参考项目 j 的要素值为(star<sub>j</sub>, fork <sub>j</sub>, watch<sub>j</sub>), 则有:

![image](https://songtianyi-blog.oss-cn-shenzhen.aliyuncs.com/weight-euclidean-dist-between-i-j.png)

由于有多个参考项目，我们取 d 最小的 j, 其到零点的距离为:

![image](https://songtianyi-blog.oss-cn-shenzhen.aliyuncs.com/euclidean_dist_with_zero_right.png)

同样地，计算出当前项目 i 到零点的距离 d<sub>i</sub>, 那么项目 i 的打分为为:

![image](https://songtianyi-blog.oss-cn-shenzhen.aliyuncs.com/di-multi-100-divide-dj.png)

PS. 写着写着发现自己在扯淡，充个数吧。

### 参考资料

1. [Euclidean Distance](http://www.pbarrett.net/techpapers/euclid.pdf)

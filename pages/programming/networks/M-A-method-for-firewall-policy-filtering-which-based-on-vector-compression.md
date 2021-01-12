# 基于向量压缩的防火墙策略过滤方法

作者: songtianyi@sky-cloud.net

## 背景

防火墙策略管理里有合规管理的需求，即，要开通的需求是否满足一定的规范，比如，通常不允许开放的端口范围过大。所以，我们需要一些检查手段，来防止这类策略的开通。

1. 在需求输入阶段，检查输入的需求是否满足规范<sub>场景1</sub>
2. 在策略下发后的阶段，检查已经下发的策略是否满足规范<sub>场景2</sub>

对于第 1 种情况，假设规范的数量为 X, 那么时间复杂度为 O(X)。在规范数量较少的时候，这个性能是可以接受的，但当 X > 100 基本上就很慢了。

``` 

INPUT: A, X_array, X
BEGIN:
    
    for(i = 0; i < X;i++) {
        if(A include X_array[i]) {
            return true
        }
    }
    return false
END
```

对于第二种情况，假设规范的数量为 X, 所有墙上的策略的总数量为 Y, 那么时间复杂度为 O(XY)。我们按照每台墙 10000 条策略算，墙的数量为 30 台, 那么这个性能很明显是不能接受的

``` 

INPUT: A, Y_array, Y, X_array, X
BEGIN:
    for(i = 0; i < X;i++) {
        for(j = 0;j < Y;j++) {
            if(Y_array[j] include X_array[i]) {
                APPEND (Y_array[j], X_array[i]) to res
            }
        }
    }
    return res
END
```

## 向量压缩

防火墙策略是一个五元组, (src_addr, dst_addr, src_port, dst_port, protocol), 策略之间的比较不是像数字一样是或大或小或等于的关系，而是或包含或被包含或相等的关系。场景1和场景2本质上都是对策略的包含关系的检查。
对于场景1，如果需求 A, 包含任意一条规则 X<sub>i</sub> ，那么认为 A 是不符合规范的。对于场景2，如果已有策略 A，包含任意一条规则X<sub>i</sub> ，那么 A 是不符合规范的。

![image](https://songtianyi-blog.oss-cn-shenzhen.aliyuncs.com/A-method-for-firewall-policy-filtering-which-based-on-vector-compression-include.png)

> 需要注意的是，实际情况，我们可能在定义规则的时候指定计算关系，并不一定是 A 包含 X<sub>i</sub>, 而是 A.src_addr 包含 X<sub>i</sub>.src_addr 且 A.dst_addr 被 X<sub>i</sub>.src_addr 包含，等等。

五元组中的 ip 和端口都属于范围类型，(192.168.1.1~192.168.1.20, 192.168.34.0/24, null, 80-90, tcp), 不能直接套用常规的索引数据结构, 而且存在多个地址的情况，会更复杂，([192.168.1.1~192.168.1.20, 192.168.2.0/24], [192.168.34.0/24, 192.122.1.1], null, [80-90, 1000], tcp). 

向量压缩指的是将范围 A->B 这个向量，看作是一个点 即, B-A+1, 向量的长度。进行这样的压缩后，可以用向量的大小关系代替向量的包含关系，因为如果策略 A 包含策略 B, 那么必然有:

``` 

Compress(A.src_addr) > Compress(B.src_addr)
```

同理, 如果策略 A 等于策略 B, 那么必然存在:

``` 

Compress(A.src_addr) == Compress(B.dst_addr)
```

如此以来，我们可以先用压缩后的策略来进行比对筛选，对筛选之后策略再进行更精确的比较。

进行向量压缩后就可以顺利降维了，因为如果策略 A 包含策略 B, 那么必然有:

``` 

Compress(A.src_addr) + Compress(A.dst_addr) + Compress(Asrc_port) + Compress(A.dst_port) > Compress(B.src_addr)+ Compress(B.dst_addr) + Compress(B.src_port) + Compress(B.dst_port)  
```

简写为:

``` 

Compress(A) > Compress(B)
```

以此类推。然后，得到基于向量压缩后的伪代码:

``` 

INPUT: policy A, X_array, X
BEGIN:

    for(int i  = 0;i < X;i++) {
        avl_insert((compress(X_array[i]), i))
    }
    available = avl_search(compress(A))
    for(int i = 0;i < available.size();i++) {
        if(A include X_array[available[i].index]) {
            return true
        }
    }
    return false
```

当筛选后的策略数, 即 `available.size()` 远比 X 小的时候，这个方法会比较有效. 所以关键要看压缩后的策略的每个维度的数字的分布情况。压缩后的数字非重复值越多，说明越平均，效果越好。

![image](https://songtianyi-blog.oss-cn-shenzhen.aliyuncs.com/A-method-for-firewall-policy-filtering-which-based-on-vector-compression-compressed-distribution.png)

如上图，第一种情况的效果会变差，因为压缩后的数值集中在一个区域，无法起到较强的过滤效果，第二种情况的效果最好，压缩后的数值均匀分布，每个值对应的压缩前的策略数较少，过滤效果强。

## 策略比对算法

在对策略进行向量压缩后，可以先对压缩后的数字建立树形索引，可以使用 AVL 或者 红黑树。然后将输入的待对比策略压缩后，查询树形索引，得到过滤后的策略列表的下标值。遍历过滤后的策略列表，进行精准比对。

## 测试验证

### 实施前的性能指标

* 不断增加 X, 一直增加到 100, 计算每条规则所需要的时间消耗
* 准备 N 台墙, 每台墙上的策略数增加到 M, 直到 N*M > 100000, 记录场景2的时间消耗

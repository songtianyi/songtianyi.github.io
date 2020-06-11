# 二元决策图

作者: [songtianyi](http://songtianyi.info) 2018-09-25

### 前言

这两天在看防火墙策略相关的论文，多篇论文中都反复提到了二元决策图(binary decision diagram，BDD)，一种用于表示防火墙策略的数据结构, 也称为二元判定图。二叉决策树我们听的多了，二元决策图我还是第一回看到，写篇文章记录一下。为了方便叙述，下文中的二元决策图均用BDD来代替。

### 二叉决策树

在学习BDD之前，我们先回顾一下二叉决策树(BDT)的内容，我想它们之间一定有一些共性。二叉决策树的主要应用是分类，通过度量一系列的属性，将输入分成两类甚至多类。用一个通俗的择偶过程来举例一个简单的二叉决策树的构造:

![image](https://songtianyi-blog.oss-cn-shenzhen.aliyuncs.com/binary-decision-tree.jpeg)

在上图中，我们通过年龄，性格和身材将择偶对象简单分成了两类，接受和拒绝。年龄，性格和身材我们都将其看成是离散的整形值，然后划分成两个集合，比如把年龄分成[23,28], [1,22] ∪ [29,+∞)，决策结果分别对应于接受和拒绝，决策的过程由决策函数来完成, 比如对于年龄的决策:

```go
func f(age int) bool {
    return age >= 23 && age <= 28
}
```

以此类推，遍历整棵树完成所有决策过程。看到这里大家应该会有这样的疑问: 为什么先判断的是年龄，而不是性格或者身材呢? 这个决策顺序的确是很有讲究的，顺序不同，整个决策过程所需的计算次数也不同，从经验上讲，年龄的判断是最简单的，假设输入的对象的随机抽样出来的，按照现在的人口年龄比例，属于[23,28]集合的对象远比属于[1,22] ∪ [29,+∞)集合的少，这样通过年龄可以过滤掉大部分对象。但实际的案例并不会像这个例子这么简单，单凭经验是无法构造出一个复杂度较低的决策树的。

##### ID3算法

即第三代迭代二叉树算法，是一种二叉树构造算法，用于解决如何构造最优二叉决策树的问题。这里不详细讲它，简单来说，它会计算出各个属性的增益率，先根据增益率最大的属性做决策，可以理解为它是一种剪枝算法。

##### C4.5算法

C4.5是对ID3的改进。

### 二元决策图

BDD是用来表达布尔函数的数据结构，它的初始形态也是二叉决策树，从上一小节的二叉决策树的示例图和决策过程不难看出来它的运算方式是:

![image](https://songtianyi-blog.oss-cn-shenzhen.aliyuncs.com/age-character-shape-function.png)

x为择偶对象，x = {age, character, shape},  我们将其换成一般性的布尔函数, 表示为:

![image](https://songtianyi-blog.oss-cn-shenzhen.aliyuncs.com/f%28xyz%29=xyz.png)

那么对于布尔函数(电路中的与-或门):

![image](https://songtianyi-blog.oss-cn-shenzhen.aliyuncs.com/ab%2Bcd.png)

它的二叉决策树构造为:

![image](https://songtianyi-blog.oss-cn-shenzhen.aliyuncs.com/ab%2Bcd-bdt.png)

虚线表示**变量被赋值为0**，其连接的末端节点称为low child，实线表示**变量被赋值为1**，其连接的末端节点称为high child. 叶子节点(0|1)称为terminal node, 非terminal node称为decision node. 可以看到，terminal node的数量为2<sup>4</sup>, 随着变量数的上升，BDT的结果空间会指数级增加，它的局限性就体现出来了。结果空间很大，但结果集只有[0,1], 说明存在优化的空间，这里直接给出优化的规则:

* Rule1: 去掉重复的terminal node，得到下面优化后的图:

  ![image](https://songtianyi-blog.oss-cn-shenzhen.aliyuncs.com/duplicate-terminal-removed.png)

* Rule2: 当以节点n和以节点m作为root的子图，是同构的，可以消去一个，例如下图中被黑框标出来的以low child c为root的子图和以high child c为root的子图同构，以此类推得到Figure4:

  ![image](https://songtianyi-blog.oss-cn-shenzhen.aliyuncs.com/duplicate-nono-terminals-removed.png)

* Rule3: 如果节点n的所有出边指向同一个节点m，说明不论它的结果是什么，对最终结果是没有影响的，可以消去它，将n的所有入边指向m即可，以此推类，消去所有这类节点得到下图:

  ![image](https://songtianyi-blog.oss-cn-shenzhen.aliyuncs.com/remove-all-redundant-test-single.png)

经过这三个无损(不影响结果)的消除规则优化的BDD称为RBDD(Reduced Binary Decision Diagram), 它是一个有向无环图(DAG). 我们以图的形式讲述了从布尔函数到BDT再到BDD的过程，但是代码却不能这么写，前边提到了BDT会占用较大的空间，通用的做法是利用香农展开(也叫香农分解)来构造布尔函数的RBDD.

##### 香农分解

香农展开（英语：Shannon's expansion），或称香农分解（**Shannon decomposition**）是对布尔函数的一种变换方式。它可以将任意布尔函数表达为其中任何一个变量乘以一个子函数，加上这个变量的反变量乘以另一个子函数。<sup>3</sup>例如对于布尔函数:

![image](https://songtianyi-blog.oss-cn-shenzhen.aliyuncs.com/yz%2Bxyzneg%2Bxnegynegz.png)

我们选取x变量及其反变量作为被乘数, 那么最终的结果可以先记为:

![image](https://songtianyi-blog.oss-cn-shenzhen.aliyuncs.com/xempty%2Bxnegempty.png)

根据分解前的内容我们能够推算出部分括号里的内容:

![image](https://songtianyi-blog.oss-cn-shenzhen.aliyuncs.com/xyzneg%2Bxnegynegz.png)

但少了一项 `yz`, 在布尔代数中有:

![image](https://songtianyi-blog.oss-cn-shenzhen.aliyuncs.com/x%2Bxneg=1.png)

所以最终的分解的结果为:

![image](https://songtianyi-blog.oss-cn-shenzhen.aliyuncs.com/xyzneg%2Byz%2Bxnegynegz%2Byz.png)

更一般地，对于布尔函数`f`, 选取变量x及其反变量作为被乘数，它的香农分解结果为:

![image](https://songtianyi-blog.oss-cn-shenzhen.aliyuncs.com/xdotf1x%2Bxnegdotf0x.png)

其中，`f(1/x)`表示，将`f`中的x用1代替，`f(0/x)`表示，将`f`中的x用0代替。按照这种方法，对于之前的决策图的布尔函数的例子，一个完整的香农分解和还原过程如下:

![image](https://songtianyi-blog.oss-cn-shenzhen.aliyuncs.com/decomp-then-comp.png)



##### RBDD using Shannon expansion

那么我们如何基于香农分解来构造RBDD呢？依次选取a, b作为被乘数，可以得到:

![image](https://songtianyi-blog.oss-cn-shenzhen.aliyuncs.com/root-and-second-bdd.png)

可以看出，当a被赋值为0，b无论被赋值为0还是1，其结果都是`cd`, 因此当a被赋值为0的时候，b节点可以消除, 依次类推得到完整的RBDD图:

![image](https://songtianyi-blog.oss-cn-shenzhen.aliyuncs.com/bdd-with-boo-funcs.png)

##### ROBDD

即Reduced ordered binary decision diagram. 我们在用香农分解构造RBDD的时候，变量的选取顺序是a,b,c,d, 我们知道，在构造二叉决策树的时候，变量的顺序对于整个过程的复杂度影响很大，同样的，不同的变量顺序也会构造出不同的RBDD图，节点数也会有差异，那么就存在一个最佳变量顺序，依照这个顺序可以构建出最小的RBDD图。但是，找到这个最佳顺序是一个NP难(NP-hard)问题。

### 参考资料

1. [BDD](http://www.cs.utexas.edu/~isil/cs389L/bdd.pdf) 
2. [Logical connective](https://en.wikipedia.org/wiki/Logical_connective)
3. [香农展开](https://zh.wikipedia.org/wiki/%E9%A6%99%E5%86%9C%E5%B1%95%E5%BC%80)
4. [数学符号表](https://zh.wikipedia.org/wiki/%E6%95%B0%E5%AD%A6%E7%AC%A6%E5%8F%B7%E8%A1%A8)
5. [What is the main difference between binary decision tree and binary decision diagram(BDD)?](https://cs.stackexchange.com/questions/82394/what-is-the-main-difference-between-binary-decision-tree-and-binary-decision-dia)
6. [Binary Decision Diagram](https://nptel.ac.in/courses/106103016/module4/lec1/1.html)

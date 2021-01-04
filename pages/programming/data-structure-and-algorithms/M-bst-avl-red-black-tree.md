# 二叉搜索树-AVL-红黑树

作者: [songtianyi](http://songtianyi.info)

## 二叉搜索树

定义:

* 二分
* 左孩子小于父节点，右孩子大于父节点

假设我们有一个如下的数组:

``` C
/* C */
int a[10] = {1, 450, 3, 4, 56, 12, 123, 45, 23, 6};
```

它的构造过程如图:

![image](https://songtianyi-blog.oss-cn-shenzhen.aliyuncs.com/bst-build.png)

可以看出，二叉搜索树中的子树也是满足二叉搜素树的定义的；中序遍历是升序的；这棵树的高度为为 7 ，和数组长度相差无几，且大部分数据的高度超过 4，说明一定存在优化的空间。

### 插入和搜索

二叉搜索树的插入和搜索比较简单，这里直接给出代码。

``` C
struct node *bst_insert(struct node *curr, struct node *p) {
  if (curr == NULL) {
    return p;  //插入的节点的左右孩子的初始值一定要为NULL
  } else if (p->value < curr->value) {
    curr->left = bst_insert(curr->left, p);
  } else {
    curr->right = bst_insert(curr->right, p);
  }
  return curr;
}
```

``` C
/* C */

struct node *bst_search(struct node *curr, struct node *parent, int value,
                        int ret_flag) {
  if (curr == NULL) {
    // leaf node
    return NULL;
  } else if (curr->value == value) {
    // found, check ret flag
    // 返回的是要查找节点的父节点或者是要查找的节点
    // 使用父节点是因为这样便于删除的时候使用父节点进行删除
    if (ret_flag == 0) {
      return parent;
    } else {
      return curr;
    }
  } else if (value < curr->value) {
    return bst_search(curr->left, curr, value, ret_flag);
  } else {
    return bst_search(curr->right, curr, value, ret_flag);
  }
}
```

### 删除操作

删除相对麻烦一点点，分几种情况

1. 如果被删除的节点，没有左子树和右子树，直接删除即可

![image](https://songtianyi-blog.oss-cn-shenzhen.aliyuncs.com/bst-delete-1.png)

2. 如果被删除的节点，有左子树，没有右子树，那么将父节点的右指针指向左子树即可, 如下图左。
3. 同理，如果被删除的节点，没有左子树，有右子树，那么将父节点的左指针指向右子树即可，如下图右。

![image](https://songtianyi-blog.oss-cn-shenzhen.aliyuncs.com/bst-delete-2.png)

4. 如果被删除节点既有左子树，又有左子树。此时没办法把两个子树直接和父节点连起来，只能采取交换值的方法。因为要保持二叉搜索树的特性，所以要找到待删除节点的右子树中的最小值和其交换，

   这样交换后，待删除节点的左子树都小于交换后的值，右子树都大于交换后的值. 之后再删除被交换的节点，被交换节点的删除和1，2，3的情况一致。
例1:

![image](https://songtianyi-blog.oss-cn-shenzhen.aliyuncs.com/bst-delete-3.png)

例2:

![image](https://songtianyi-blog.oss-cn-shenzhen.aliyuncs.com/bst-delete-4.png)

### 优化

前面我们提到，我们构造的这棵树的高度为为 7 ，和数组长度相差无几，且大部分数据的高度超过 4，查找的效率相对来说，是比较低的，存在优化的空间。要优化构造出来的结构，只能从构造下手。
我们构造 BST 的过程是从数组的第一个元素开始的，那么从第 2 个元素开始构造呢？构造的结果会不一样。数组中，值的大小顺序决定着最终的结构，那么是否存在一个最佳的构造顺序呢？

## AVL

我们从目标出发，我们的目标是构造一个尽可能矮的二叉搜索树，这样平均检索效率才是最高的。用术语来描述就是:

* 是一棵 BST 树
* 每棵子树的左右子树的深度差不能超过1

![image](https://songtianyi-blog.oss-cn-shenzhen.aliyuncs.com/bst-avl-red-black-avl-demo.png)

> 图中的数字代表深度，深度从 1 开始。深度也可以从 0 开始，不影响结果。

满足这种特性的 BST 称为 Self-balancing binary search tree, 也称 AVL 树。

> AVL 树得名于它的发明者 G. M. Adelson-Velsky 和 E. M. Landis，他们在1962年的论文《An algorithm for the organization of information》中发表了它。

那我们怎么构建这样的 AVL 树呢？通过调整输入的值的顺序是不现实的，因为输入可能是流式的，没办法在当前时间点得到未来时间点的输入。那么可行的方法是，一边构建 BST, 一边将 BST 调整成 AVL, 而且是马上调整，因为我们要时刻保持 AVL 树的特性。这种调整是基于 `旋转` 实现的。

### 左旋

如图，当插入节点 14 知乎，以 1 为根的子树的左子树的深度为1，右子树的深度为 3，相差 2，不满足 AVL 的特性。此时，可以将 1 逆时针旋转（左旋），同时改变连接关系，将节点 10 作为子树的根结点，1 从父节点变为 10 的左子树，14 仍然作为 10 的右子树。
我们可以观察出，所谓的旋转是以子树的根为圆心，顺时针或者逆时针旋转，旋转之后，连接关系会被改变。

### 右旋

和左旋类似，不再赘述。通过这两种基本的旋转，我们能总结出一个旋转规律：

* 当右子树的深度小于左子树，右旋
* 当右子树的深度大于左子树，左旋

### 
接着我们来看一下较复杂的情况。

## 参考资料

* [树的高度和深度](https://blog.csdn.net/qq_36667170/article/details/84142019)
* [平衡二叉树（AVL树）及C语言实现](http://data.biancheng.net/view/59.html)

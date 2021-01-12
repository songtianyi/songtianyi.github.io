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

2. 如果被删除的节点，有左子树，没有右子树，那么将父节点的右指针指向左子树即可, 如下图左。此时还要区分被删除的节点是在其父节点的左边还是右边。
3. 同理，如果被删除的节点，没有左子树，有右子树，那么将父节点的左指针指向右子树即可，如下图右。此时还要区分被删除的节点是在其父节点的左边还是右边。

![image](https://songtianyi-blog.oss-cn-shenzhen.aliyuncs.com/bst-delete-2.png)

4. 如果被删除节点既有左子树，又有右子树。此时没办法把两个子树直接和父节点连起来，只能采取交换值的方法。因为要保持二叉搜索树的特性，所以要找到待删除节点的右子树中的最小值和其交换，

   这样交换后，待删除节点的左子树都小于交换后的值，右子树都大于交换后的值. 之后再删除被交换的节点，被交换节点的删除和1，2，3的情况一致。
例1:

![image](https://songtianyi-blog.oss-cn-shenzhen.aliyuncs.com/bst-delete-3.png)

例2:

![image](https://songtianyi-blog.oss-cn-shenzhen.aliyuncs.com/bst-delete-4.png)

### 完整代码

``` C
/* C */
/**
 * 二叉排序树模板
 * 插入函数 插入之前应先申请一个要插入的p节点 然后传进去
 * 查找函数 root为根节点 parent等于root value为要查找的值
 * ret_flag为0返回查找到的节点的父节点这样便于删除时使用  ret_flag
 * 为1返回查找到的节点的指针
 * 删除函数 传入要删除的节点的父节点和要删除的节点
 * 如果待删节点为父节点的左孩子is_left=1 如果为右孩子 is_left=1 构造函数
 * 将一个数组从start到end（不包括end）的范围构造为一个二叉排序树 root为根节点
 */
#include <stdio.h>
#include <stdlib.h>

struct node {
  int value;
  struct node *left, *right;
};
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

void bst_inorder_traversal(struct node *curr) {
  if (curr != NULL) {
    bst_inorder_traversal(curr->left);
    printf("(%p, %d)\n", curr, curr->value);
    bst_inorder_traversal(curr->right);
  }
}

void bst_preorder_traversal(struct node *curr) {
  if (curr != NULL) {
    printf("(%p, %d)\n", curr, curr->value);
    bst_preorder_traversal(curr->left);
    bst_preorder_traversal(curr->right);
  }
}

void bst_postorder_traversal(struct node *curr) {
  if (curr != NULL) {
    bst_postorder_traversal(curr->left);
    bst_postorder_traversal(curr->right);
    printf("(%p, %d)\n", curr, curr->value);
  }
}

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

int bst_delete(struct node *parent, struct node *p, int is_left) {
  if (p->left == NULL && p->right == NULL) {
    // leaft node
    if (is_left) {
      // p 为parent的左子叶
      // 将 parent的左指针置为空
      parent->left = NULL;
    } else {
      // p 为parent的右子叶
      parent->right = NULL;
    }
    free(p);
  } else if (p->left == NULL) {
    // 待删除节点无左子树，说明有右子树
    if (is_left) {
      // 将待删除的节点的右子树 赋值给父节点的左子树
      parent->left = p->right;
    } else {
      // 将待删除的节点的右子树 赋值给父节点的右子树
      parent->right = p->right;
    }
    free(p);
  } else if (p->right == NULL) {
    // 待删除节点无右子树，说明有左子树
    if (is_left) {
      parent->left = p->left;
    } else {
      parent->right = p->left;
    }
    free(p);
  } else {
    struct node *s = p->right;
    struct node *sp = p;
    //找右子树中最左的节点 或者找左子树中最右的节点
    //然后和要删除的位置交换value
    //这里选择前者
    while (s->left != NULL) {
      sp = s;
      s = s->left;
    }
    printf("%d --> %d\n", p->value, s->value);
    p->value = s->value;
    if (sp == p) {
      // p 的右子树没有左子树
      // 
      sp->right = s->right;
    } else {
      //因为s肯定没有左子树 所以把右子树接在父节点的左指针上就行了
      sp->left = s->right;
    }
    free(s);
  }
  return 1;
}
void bst_build(struct node *root, int *array, int start, int end) {
  // [start, end)
  while (start < end) {
    // create node
    struct node *p = malloc(sizeof(struct node));
    p->value = array[start];
    p->left = p->right = NULL;  // init
    bst_insert(root, p);
    start++;
  }
}

int main() {
  int a[10] = {1, 450, 3, 4, 56, 12, 123, 45, 23, 6};
  struct node *root = malloc(sizeof(struct node));
  root->left = root->right = NULL;
  root->value = a[0];
  bst_build(root, a, 1, 10);
  bst_inorder_traversal(root);
  printf("root %p %d\n", root, root->value);
  struct node *ans = bst_search(root, root, 56, 0);
  if (ans != NULL) {
    printf("ans value %d\n", ans->value);
    bst_delete(ans, ans->right, 1);
    bst_preorder_traversal(root);
    bst_inorder_traversal(root);
    bst_postorder_traversal(root);
  }
}

```

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

![image](https://songtianyi-blog.oss-cn-shenzhen.aliyuncs.com/bst-avl-red-black-left-rotate-1.png)

### 右旋

和左旋类似，不再赘述。通过这两种基本的旋转，我们能总结出一个旋转规律：

* 当右子树的深度小于左子树，右旋
* 当右子树的深度大于左子树，左旋

![image](https://songtianyi-blog.oss-cn-shenzhen.aliyuncs.com/bst-avl-red-black-right-rotate.png)

### 多次旋转

对于一直向左，或者一直向右延伸的情况，我们比较容易能够知道应该怎么旋转。接着我们来看一下较复杂的情况。

> 图中的数字 A/B 表示，该节点的值为 A，(该节点的左子树深度 - 该节点的左子树深度) = B

![image](https://songtianyi-blog.oss-cn-shenzhen.aliyuncs.com/bst-avl-red-black-complicate-rotate-question-mark.png)

如上图，当我们插入 3 这个节点后，导致了不平衡，如果 3 是插入在了 450 的右边，那么左旋就可以了，我们从物理学的角度来直观感受，插在右边会很明显地导致右边重左边轻，但现在插入了左边，那么到底是左边重一点，还是右边重一点，我们是不是很难靠直觉来判断了？
由于节点比较少，我们可以通过枚举来得知，一次旋转是不够的，需要两次旋转。

![image](https://songtianyi-blog.oss-cn-shenzhen.aliyuncs.com/bst-avl-red-black-right-left-rotate.png)

如上图，经过两次旋转(先右旋，后左旋)达到平衡, 写到这里我发现，可以把节点以及节点之间的联系想象成一个链条，左旋是逆时针**拉动链条**, 右旋是顺时针拉动链条，这和我们的生活常识是相通的。另外， 我们可以看出，第一次拉动是为第二次拉动做准备的，第一次拉动让链条变得更加平整，有序，这样第二次拉动就比较简单了。

再来看一个新的例子:

![image](https://songtianyi-blog.oss-cn-shenzhen.aliyuncs.com/bst-avl-red-black-left-right-rotate.png)

如上图，有了之前的经验，我们应该可以很快知道怎么旋转。

多加一个例子，这样我们才能更容易看出其规律:

![image](https://songtianyi-blog.oss-cn-shenzhen.aliyuncs.com/bst-avl-red-black-right-left-rotate-1.png)

结合这几个实际案例，我们现在大致可以弄明白两件事。

1. 旋转的触发条件
2. 旋转的方式

阐述一下:

> 深度差 = 左子树深度 - 右子树深度

1. 当插入节点 w，导致深度差为 -2 时，如果 w 是作为右子树插入，那么左旋就可以了
2. 当插入节点 w, 导致深度差为 -2 时，如果 w 是作为左子树插入，先右旋，让它变成情况 1，然后再左旋就可以了
3. 当插入节点 w, 导致深度差为 2 时，如果 w 是作为左子树插入，那么右旋就可以了
4. 当插入节点 w, 导致深度差为 2 时，如果 w 是作为右子树插入，先左旋，让它变成情况 2，然后再右旋就可以了

### AVL 实现

现在来考虑如何实现。根据前面的内容，可以得出以下结论:

1. 旋转是自底向上的，所以可以用递归
2. 需要知道左右子树的深度差，由于我们使用的是递归，高度的计算相对深度来说要简单，所以实现的时候用高度代替深度，结果不变。插入的叶子结点的高度为 1. 深度差或者高度差称为 balance factor, BF.
3. 左旋右旋可以复用
4. 旋转需要一个枢纽，枢纽是根据高度差的值为 2 或者 -2 来确定的, 称为 pivot.
5. 旋转的时候根会变化，连接关系需要调整

``` C
#include <stdio.h>
#include <stdlib.h>
struct node {
  int value;
  struct node *left, *right;
  int height;
};

// A utility function to get the height of the tree
int height(struct node *N) {
  if (N == NULL) return 0;
  return N->height;
}

int max(int a, int b) { return a > b ? a : b; }

// left rotate
// pivot x
struct node *left_rotate(struct node *x) {
  printf("left rotate %d\n", x->value);
  struct node *pivot = x->right;  // x 是旧的枢纽, pivot 是新的枢纽
  struct node *influenced = pivot->left;  // 左子树要跟随调整

  pivot->left = x;  // rotate
  // 因为被影响的左子树是新的枢纽的左子树，是必然大于旧枢纽的，所以放在旧枢纽的右边
  x->right = influenced;
  // 新的高度为 左子树高度 右子树高度之间的最大值再加自身
  x->height = max(height(x->left), height(x->right)) + 1;
  // 同理
  pivot->height = max(height(pivot->left), height(pivot->right)) + 1;
  // 返回新的枢纽，既新的根
  return pivot;
}

// right rotate
// pivot x
struct node *right_rotate(struct node *x) {
  printf("right rotate %d\n", x->value);
  struct node *pivot = x->left;  // new pivot
  struct node *influenced = pivot->right;

  pivot->right = x;
  x->left = influenced;
  // 新的高度为 左子树高度 右子树高度之间的最大值再加自身
  x->height = max(height(x->left), height(x->right)) + 1;
  // 同理
  pivot->height = max(height(pivot->left), height(pivot->right)) + 1;
  // 返回新的枢纽，即新的根
  return pivot;
}

// calc balance factor
int BF(struct node *x) { return height(x->left) - height(x->right); }

struct node *newN(int v) {
  struct node *n = malloc(sizeof(struct node));
  n->value = v;
  n->left = n->right = NULL;
  n->height = 1;
  return n;
}

struct node *avl_insert(struct node *curr, int v) {
  // BST
  if (curr == NULL) {
    return newN(v);
  }

  if (v < curr->value) {
    curr->left = avl_insert(curr->left, v);
  } else if (v > curr->value) {
    curr->right = avl_insert(curr->right, v);
  } else {
    return curr;  // NOT INSERT
  }
  curr->height = 1 + max(height(curr->left), height(curr->right));

  int bf = BF(curr);

  // CASE 3
  if (bf > 1 && v < curr->left->value) {
    return right_rotate(curr);
  }

  // CASE 1
  if (bf < -1 && v > curr->right->value) {
    return left_rotate(curr);
  }

  // CASE 4
  if (bf > 1 && v > curr->left->value) {
    curr->left = left_rotate(curr->left);
    return right_rotate(curr);
  }

  // CASE 2
  if (bf < -1 && v < curr->right->value) {
    curr->right = right_rotate(curr->right);
    return left_rotate(curr);
  }
  return curr;
}

void bst_inorder_traversal(struct node *curr) {
  if (curr != NULL) {
    bst_inorder_traversal(curr->left);
    printf("(%p, %d)\n", curr, curr->value);
    bst_inorder_traversal(curr->right);
  }
}

void bst_preorder_traversal(struct node *curr) {
  if (curr != NULL) {
    // printf("(%p, %d)\n", curr, curr->value);
    printf("(%p, %d), (%p, %p)\n", curr, curr->value, curr->left, curr->right);
    bst_preorder_traversal(curr->left);
    bst_preorder_traversal(curr->right);
  }
}

int main() {
  int a[10] = {1, 450, 3, 4, 56, 12, 123, 45, 23, 6};
  struct node *root = NULL;
  for (int i = 0; i < 10; i++) {
    root = avl_insert(root, a[i]);
  }

  bst_inorder_traversal(root);
  bst_preorder_traversal(root);
}
```

### AVL 删除操作

前面讲的都是关于插入时的旋转情况，那么删除呢？插入的时候，只要看插入节点的位置就可以了，因为在插入之前 avl 就已经是平衡的，但删除要稍麻烦一些，因为删除的情况就有多种。那我们就看删除的时候导致的变化。

![image](https://songtianyi-blog.oss-cn-shenzhen.aliyuncs.com/bst-avl-red-black-avl-delete-1.png)

![image](https://songtianyi-blog.oss-cn-shenzhen.aliyuncs.com/bst-avl-red-black-avl-delete-2.png)

我们观察如上两张图，删除的是同一个节点，但是第二张图需要多一次旋转。这种差异需要观察右子树的的 bf 值，当然，要先检查到不平衡的情况。总结如下:

``` C
/* C */
if (BF(curr) < -1 && BF(curr->right) <= 0) {
  left_rotate(curr);
} 

if(BF(curr) < -1 && BF(curr->right) > 0) {
  curr->right = right_rotate(curr->right);
  left_rotate(curr);
}
```

同理可得:

``` C
/* C */
if(BF(curr) > 1 && BF(curr->left) >= 0) {
  right_rotate(curr);
}

if(BF(curr) > 1 && BF(curr->left) < 0) {
  curr->left = left_rotate(curr->left);
  right_rotate(curr);
}
```

完整的删除代码如下:

> 注意只有一个节点的情况，被删除就没有节点了。

``` C
struct node *minN(struct node *x) {
  while (x->left != NULL) {
    x = x->left;
  }
  return x;
}

struct node *avl_delete(struct node *curr, int v) {
  // bst delete
  if (curr == NULL) {
    return NULL;
  }

  if (v < curr->value) {
    curr->left = avl_delete(curr->left, v);
  } else if (v > curr->value) {
    curr->right = avl_delete(curr->right, v);
  } else {
    // delete
    if (curr->left == curr->right) {
      // both null
      free(curr);
      curr = NULL;
    } else if (curr->left == NULL) {
      // has only right child
      struct node *t = curr;
      *curr = *curr->right;  // copy
      free(t);
    } else if (curr->right == NULL) {
      // has only left child
      struct node *t = curr;
      *curr = *curr->left;
      free(t);
    } else {
      // two childs
      struct node *t = minN(curr->right);
      curr->value = t->value;
      curr->right = avl_delete(curr->right, t->value);
    }
  }

  if (curr == NULL) {
    // zero node left
    return NULL;
  }

  curr->height = max(height(curr->left), height(curr->right)) + 1;

  int bf = BF(curr);

  if (bf > 1 && BF(curr->left) >= 0) {
    return right_rotate(curr);
  }

  if (bf > 1 && BF(curr->left) < 0) {
    curr->left = left_rotate(curr->left);
    return right_rotate(curr);
  }

  if (bf < -1 && BF(curr->right) <= 0) {
    return left_rotate(curr);
  }

  if (bf < -1 && BF(curr->right) > 0) {
    curr->right = right_rotate(curr->right);
    return left_rotate(curr);
  }

  return curr;
}
```

## red-black tree

AVL 的搜索性能是很好的，但是对于频繁插入和删除的场景, AVL 需要频繁的旋转操作，红黑树应运而生。红黑树的处理思路也很直接，既然频繁的旋转操作不利于性能，那就减少旋转的次数，减少旋转那就必然要牺牲平衡性。

## 参考资料

* [树的高度和深度](https://blog.csdn.net/qq_36667170/article/details/84142019)
* [平衡二叉树（AVL树）及C语言实现](http://data.biancheng.net/view/59.html)

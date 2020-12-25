# 算法优化之时空交换

作者: [songtianyi](http://songtianyi.info) create@2020/12/13

我们在最初学习算法，解算法题的时候，会经常遇到 “时间换空间”, “空间换时间" 这种说法。比如，当时间复杂度不可接受的时候，我们可以考虑在空间上做文章。
或者换个更肯定的说法，当时间复杂度已经被优化到极致的时候(未牺牲空间)，那么要想继续降低时间复杂度，必然要牺牲空间。

我们先看一道题目，来具体感受下。

两数之和

> 给定一个整数数组 nums 和一个目标值 target，请你在该数组中找出和为目标值的那 两个 整数，并返回他们的数组下标。你可以假设每种输入只会对应一个答案。但是，数组中同一个元素不能使用两遍。

示例:

> 给定 nums = [2, 7, 11, 15], target = 9
> 因为 nums[0] + nums[1] = 2 + 7 = 9
> 所以返回 [0, 1]

我们很容易想出暴力的方法解决这个问题。

``` c++
  vector<int> twoSum(vector<int>& nums, int target) {

        vector<int> *res = new vector<int>;
        for(int i = 0;i < nums.size()-1;i++) {
            for(int j = i+1;j < nums.size();j++) {
                if(nums[i] + nums[j] == target) {
                    res->push_back(i);
                    res->push_back(j);
                    return *res;
                }
            }
        }
        return *res;
    }

``` 

但是，如何将时间复杂度降低到 O(N) ? 好的算法往往是反直觉的，与其寻找两个数满足和为 target, 不如寻找一个数 nums[j], 满足 target - nums[j] = 已经出现过的 nums[i].

``` go
func twoSum(nums []int, target int) []int {
    m := make(map[int]int,0)
    for j, v := range nums {
        if i, ok := m[target-v]; ok {
            return []int{i,j} 
        }
        m[v] = j
    }
    return []int{0,0}
}
```

我们通过增加 map 来记录已经遍历过的值，来降低复杂度，以空间换时间。

但是这篇文章，不是告诉你可以这么做，因为做过算法的人都知道这种优化技巧，我想表达的是，必然可以这么做。**当时间最优的时候，空间一定不是最优的, 反之亦然**。

> 需要强调的是，这是我自己的论断，没有考证过资料，我也不能证明。

这个论断起源于我对复杂性的思考，我认为一件事物，它的复杂性是固定的，好比你家到公司的距离是固定的，你可以走路，可以开车，甚至坐直升机上班，改变的是时间，距离是不变的。

我思考这些东西，起初是为了反驳那些，以为上了什么新技术，新系统，就万事大吉的观点，不存在银弹，不存在一劳永逸的事情。

复杂性可以被转移/隐藏，但不会消失。比如，我们可以购买一些软件系统，来减少我们的工作量，付出金钱，将这些复杂性转移出去。再比如，我们可以利用 DSL，以及把大量代码封装复用，来减轻业务开发人员的工作量，对于他们来说，复杂性被隐藏起来了。

软件最大的特性是可以无限复制，但互联网的发展，开源才是基石，没有开源，我们就不能几乎 0 成本的把复杂性转移出去。开源是互联网如今如此成功的决定性因素。

复杂性是固定的这个论断，是受了信息熵的启发。熵在信息论中是对不确定度的度量，在数据压缩领域同样可以使用信息熵来度量文件内容的随机性，从而反映出压缩的极限。类似的，系统的复杂性可以和信息的熵值做类比，不管你是用什么手段，系统复杂性都会有一个被简化的极限。

事实上，的确有一些学者提出了度量复杂性的方法，比如 logic depth, effective complexity, statistical complexity. 
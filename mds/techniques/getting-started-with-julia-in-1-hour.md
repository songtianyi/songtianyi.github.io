# 1小时入门Julia

### 前言

`1分钟`

机器学习的热度一直不减，其相关技术必然是未来程序猿的必修课，要学就趁早。在深度学习领域，python应该是不二之选，但自己实在是爱不起来。python作为一门胶水语言，拥有极其丰富的第三方库，不管解决什么问题，它都应该是比较快的工具，值得大家学习。Julia是一个面向科学计算的高性能动态高级程序设计语言，其语法与其他科学计算语言(Matlab)相似，而且在许多情况下拥有能与编译语言相媲美的性能。另外，tensorflow和mxnet都有julia的binding，作为初学者(比如我)的上手工具应该没有问题。而且，学习一门新语言，也能打开视野，为未来的技术变迁做储备，毕竟性价比高的机会总是出现在新事物上。

### Julia是什么

> Julia is a highly productive language that runs fast

* 快

  性能是julia设计的初衷。科学计算需要大量的性能开销，主流的python并不能满足这一要求，但julia的设计者们仍然认为动态语言是更好的选择，得益于技术的进步，动态语言同样可以拥有静态语言一样的性能，于是julia在2012年诞生了(python诞生于1991)

* 动态类型

* optional typing

  一般情况下，动态语言的变量类型都是在运行时确定的，但对于julia来说是可选的，你可以在代码中申明类型，利用JIT，julia可以编译部分代码以提高性能，而这些申明，为JIT提供了用于优化性能的信息。Julia语法提供了预编译的选项。

* 多重派发(multiple dispatch)

  其实就是函数重载啦，是通过多重派发来实现的。多重派发是julia类型系统的核心特性。

* 多范式，IP,PP,OOP,FP,MP

* 考虑到了通用性

  虽然Julia是为科学计算而设计的，但也注重在其他领域的应用，所以在语法设计上不仅参考了R, MATLAB, Python，也同时吸取了Lisp, Perl, Lua, Ruby等语言的优点。

* coroutine

* 可以直接调用C，没有额外的封装

* 支持宏(Lisp-like)

### JIT(Just-In-Time)

即，即时编译。我们知道，静态语言是通过编译器将源码编译成机器码来执行的，只需编译一次；动态语言是通过解释器在程序运行时一句句边翻译边运行的，同一段代码可能需要翻译多次。即时编译则是两者的结合，即时编译器在运行时一句句编译代码并执行，并将编译结果缓存(具体的逻辑依赖于JIT的算法实现)，相对于解释器，性能开销要低很多。

### 安装

在官方[Dowload](https://julialang.org/downloads/)页面下载指定平台的安装包或者二进制包即可。本文使用的版本为`0.6.4`。安装好之后，可以直接执行，它会启动一个和python一样的交互式的shell(repl):

```bash
./julia
```

也可以用它来执行julia代码:

```bash
julia demo.jl
```

在此之前，你可能需要把julia加入环境变量中，比如mac下:

```shell
JULIA="/Applications/Julia-0.6.app/Contents/Resources/julia/bin/"
export PATH=$PATH:$JULIA
```

更多的用法请查看它的help文档。

### 类型系统

| Lang  | Typed | Static and dynamic  checks | Strongly checked | Weakly or strongly  typed | Dynamically or statically typed |       Type theories        | Paradigms          |
| :---: | :---: | :------------------------: | :--------------: | :-----------------------: | :-----------------------------: | :------------------------: | ------------------ |
| Julia |  ☑️   |             ❌              |        ❌         |          weakly           |           dynamically           | generic, overloading, duck | IP,SP,PP,OOP,FP,MP |

* *static and dynamic checks*: Julia是动态语言，只有动态检查，静态编译也是发生在运行时的。

* *strongly checked*: Julia允许可以在代码中使用宏标记，来告诉编译器略过边界检查[?]

* *weakly typed*: 类型是可变的

  ```julia
  a = 10
  a = "b"
  println(a)
  ```

* *dynamically typed*: 类型在运行时确定

* *type inference*: 支持类型推断


### 类型理论

* *generic*: 
* *overloading*: 基于multiple dispatch的函数重载是julia的主要特性。
* **


### 语法规范

##### Types

###### Primitive types

| 类型                                       | 解释   |
| ---------------------------------------- | ---- |
| Int8, UInt8, Int16, UInt16, Int32, UInt32, Int64, UInt64, Int128, UInt128 | 整形   |
| Char                                     |      |
| Bool                                     |      |
| Float16, Float32,  Float64               |      |
|                                          |      |
|                                          |      |
|                                          |      |
|                                          |      |
|                                          |      |

###### Composite types

| 类型   | 解释   |
| ---- | ---- |
|      |      |
|      |      |
|      |      |
|      |      |
|      |      |
|      |      |
|      |      |
|      |      |
|      |      |



### 编程范式

### 参考资料

1. [Style Guide](https://docs.julialang.org/en/v0.6.2/manual/style-guide/#Style-Guide-1)


# 1小时入门Julia

### 前言

`1分钟`

机器学习的热度一直不减，其相关技术必然是未来程序猿的必修课，要学就趁早。在深度学习领域，python应该是不二之选，但自己实在是爱不起来。python作为一门胶水语言，拥有极其丰富的第三方库，不管解决什么问题，它都应该是比较快的工具，值得大家学习。Julia是一个面向科学计算的高性能动态高级程序设计语言，其语法与其他科学计算语言(Matlab)相似，而且在许多情况下拥有能与编译语言相媲美的性能。值得一提的是，tensorflow和mxnet都有julia的binding，因此julia作为机器学习初学者的上手工具应该没有问题。而且，学习一门新语言，也能打开视野，为未来的技术变迁做储备，毕竟性价比高的机会总是出现在新事物上。

在开始之前，请先掌握[语言选型](how-to-choose-your-programming-language.md)里的概念。

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

即，即时编译。我们知道，静态语言是通过编译器将源码编译成机器码来执行的，只需编译一次；动态语言是通过解释器在程序运行时一句句边翻译边运行的，同一段代码可能需要翻译多次。即时编译则是两者的结合，即时编译器在运行时逐句()翻译代码并执行，并将翻译结果缓存(具体的逻辑依赖于JIT的算法实现)，相对于解释器，性能开销要低很多。

### 安装

在官方[Dowload](https://julialang.org/downloads/)页面下载指定平台的安装包或者二进制包，本文使用的版本为`0.6.4`, julia还在快速迭代中，不同版本之间会有差异。安装好之后，可以直接执行，它会启动一个和python一样的交互式的shell(repl):

```bash
./julia
```

也可以用它来执行julia代码:

```bash
julia demo.jl
```

在此之前，你可能需要把julia二进制加入环境变量中，比如macOS下:

```shell
JULIA="/Applications/Julia-0.6.app/Contents/Resources/julia/bin/"
export PATH=$PATH:$JULIA
```

更多的用法请查看它的help文档。

### 类型系统

| Lang  | Typed | Static and dynamic  checks | Strongly checked | Weakly or strongly  typed | Dynamically or statically typed |       Type theories        | Paradigms          |
| :---: | :---: | :------------------------: | :--------------: | :-----------------------: | :-----------------------------: | :------------------------: | ------------------ |
| Julia |  ☑️   |             ❌              |        ☑️        |          weakly           |           dynamically           | generic, overloading, duck | IP,SP,PP,OOP,FP,MP |

* *static and dynamic checks*: Julia是动态语言，只有动态检查，静态编译也是发生在运行时的。

* *strongly checked*: 关于类型系统的安全性检查，一直是一个比较难界定的问题，julia的commiter认为julia属于strongly checked的语言<sup>[2]</sup>, 他给出的理由是:

  * 没有指针运算

  * 没有类型双关(type punning)

    >  关于类型双关，简单来说就是通过一些奇技淫巧(通常是用指针操作内存)，绕过语言的类型系统，从而达到用该语言语法难以实现甚至不可能达到的效果，一个安全的类型系统当然是不允许这么做的。类型双关的具体定义可以参考wikipedia<sup>[3]</sup>, 还是比较容易理解的。

  在[语言选型](how-to-choose-your-programming-language.md)里讲到过，拥有隐式类型转换的语言属于weakly typed，我们来看下面的例子:

  ```r
  julia> pi + 1
  4.141592653589793
  ```

  浮点和整形可以相加，julia进行了隐式类型转换？不是，我们在repl里用`?`加表达式来看看repl给我们的解释

  ```
  help?> pi + 1
    +(x, y...)

    Addition operator. x+y+z+... calls this function with all arguments, i.e. +(x, y, z, ...).
  ```

  说明这里只是语法糖, Julia称之为[type promotion](https://docs.julialang.org/en/v0.6.4/manual/conversion-and-promotion/)。当我们需要类型转换的时候可以使用`convert`函数。

  ```
  julia> convert(Float64, pi + 1)
  4.141592653589793
  ```

* *weakly typed*: 类型是可变的

  ```julia
  a = 10
  a = "b"
  println(a)
  ```

* *dynamically typed*: 类型在运行时确定

* *type inference*: 支持类型推断。类型推断需要注意的地方是，在不同bit的硬件架构下，推断出的类型会不同

  ```
  # 32-bit system:
  julia> typeof(1)
  Int32

  # 64-bit system:
  julia> typeof(1)
  Int64
  ```


### 类型理论

* *generic*: 
* *overloading*: 基于multiple dispatch的函数重载是julia的主要特性。
* **


### 语法规范

##### Types

###### Primitive types

| 类型                                       | 解释                                       |
| ---------------------------------------- | ---------------------------------------- |
| Int8, UInt8, Int16, UInt16, Int32, UInt32, Int64, UInt64, Int128, UInt128 | 整形                                       |
| Char, String                             | 字符/字符串, String能够使用下标索引, 注意: Julia的下标都是从1开始的, 1-based. 关于String的更多内容可以查看[strings](https://docs.julialang.org/en/v0.6.4/manual/strings/) |
| Bool                                     | 真假值                                      |
| Float16, Float32,  Float64               | IEEE754-2008浮点,  2.5e-4,  1e10,  0.5f0,  0x1.8p3(16进制浮点),  Inf32, -Inf32, Inf, -Inf, …, NaN, NaN16 |
| any                                      | 任意类型                                     |
|                                          |                                          |
|                                          |                                          |
|                                          |                                          |
|                                          |                                          |

###### Composite types

| 类型       | 解释                                       |
| -------- | ---------------------------------------- |
| Complex  | 复数类型, i用im表示 ex.` 0 + 4im`               |
| Rational | 分数 ex. 6//9, 即9分之6                       |
| function | 函数，函数的定义在julia有更简洁的方法，ex.  f(x, y) = x + y, 这种写法更贴合科学计算里的公式。当然，函数名也可以是Unicode字符， ∑(x,y) = x + y。在julia里，算术运算符属于函数的语法糖。 |
| tuple    | 元组                                       |
| Channel  | 管道，先进先出的队列                               |
|          |                                          |
|          |                                          |
|          |                                          |
|          |                                          |

###### 匿名函数

在Julia里函数是一等公民(first-class objects), 能够将函数赋值给变量，也可以作为参数和返回值。

```
ulia> f = x -> x*x + 2*x - 1
(::#13) (generic function with 1 method)

julia> f(2)
7

julia> g = x -> x^2 + 2x - 1
(::#15) (generic function with 1 method)

julia> g(2)
7
```

函数的返回值可以为元组

```
julia> f = (x, y) -> (x, y)
(::#25) (generic function with 1 method)

julia> x,y = f(1,2)
(1, 2)
```

和python一样，函数的入参可以带默认值

```
julia> f = (x, y=1) -> x + y
(::#28) (generic function with 2 methods)

julia> f(2)
3
```

并且支持隐式return

###### Channel

Julia的Channel的Go的chan在使用上基本是一致的。

1. 创建一个没有buffer的channel, channel的写入会被阻塞，直到有人读取它。

   ```go
   // go
   ch := make(chan int, 0)
   ```

   ```julia
   // julia
   ch = Channel(0)
   ```

2. 创建一个带buffer的channel

   ```go
   // go
   ch := make(chan int, 10)
   ```

   ```
   // julia
   ch = Channel(10)
   ```

3. 使用put!和task!来写入和读取数据, 和golang的区别是，julia的channel在定义时可以不指定类型，当不指定类型时，默认为`any`可以写入不任意类型的数据。

   ```julia
   ch = Channel{String}(10)
   put!(ch, "Hello")
   put!(ch, "World")
   take!(ch)
   take!(ch)
   ```

4. 关闭

   ```julia
   close(ch)
   ```

5. 判断是否有数据

   ```julia
   isready(ch)
   ```

6. 比go channel方便的地方是，提供了fetch函数，fetch只会读取数据，不会remove掉数据

7. julia的channel在关闭后仍然可以读取数据，直到为空。

8. Channel可以和一个函数相绑定, 其接受一个匿名函数，并调用它，调用匿名函数时传入一个新建的channel，一般匿名函数会操作这个channel，最后Channel会将这个channel返回。

   ```julia
   chnl = Channel(c->foreach(i->put!(c,i), 1:4));
   ```

##### Variables

julia的变量比较特殊的地方是，它可以用Unicode(UTF-8)作为名字, 因为科学计算中，有很多特殊的数学符号。

```
julia> δ = 0.00001
1.0e-5

julia> 안녕하세요 = "Hello"
"Hello"
```

有一个问题是，这些特殊符号怎么输入？在julia的repl中，可以用`\`加单词打打印，比如上述的`δ`符号，英文名叫delta, 在repl里输入:

```
julia> \delta
```

按tab键，即可打印出`δ`

为了科学计算的便利，julia内置了很多常量和函数, 比如`pi`, `sqrt`等，且可以修改它们。

```
julia> pi
π = 3.1415926535897...

julia> pi = 3
WARNING: imported binding for pi overwritten in module Main
3

julia> pi
3

julia> sqrt(100)
10.0

julia> sqrt = 4
WARNING: imported binding for sqrt overwritten in module Main
4

```

##### Operators

| Expression                               | Name                                     | Description                              |
| ---------------------------------------- | ---------------------------------------- | ---------------------------------------- |
| `+x`                                     | unary plus                               | `+(1,2,3)=6`                             |
| `-x`                                     | unary minus                              | 如果-x = y , 则必然y + x = 0, 用来表示负数的         |
| `x + y`                                  | binary plus                              | performs addition                        |
| `x - y`                                  | binary minus                             | performs subtraction                     |
| `x * y`                                  | times                                    | performs multiplication                  |
| `x / y`                                  | divide                                   | performs division                        |
| `x \ y`                                  | inverse divide                           | equivalent to `y / x`                    |
| `x ^ y`                                  | power                                    | raises `x` to the `y`th power            |
| `x % y`                                  | remainder                                | equivalent to `rem(x,y)`                 |
|                                          |                                          |                                          |
| !x                                       | negation                                 | changes `true` to `false` and vice versa |
|                                          |                                          |                                          |
| `~x`                                     | bitwise not                              |                                          |
| `x & y`                                  | bitwise and                              |                                          |
| `x | y`                                  | bitwise or                               |                                          |
| `x ⊻ y`                                  | bitwise xor (exclusive or)               |                                          |
| `x >>> y`                                | [logical shift](https://en.wikipedia.org/wiki/Logical_shift) right | 整体向右移动，并在左边补0                            |
| `x >> y`                                 | [arithmetic shift](https://en.wikipedia.org/wiki/Arithmetic_shift) right | 整体向右移动，并在最高位填充符号位                        |
| `x << y`                                 | logical/arithmetic shift left            | 整体向左移动，并在右边补0                            |
|                                          |                                          |                                          |
| +=  -=  *=  /=  \=  ÷=  %=  ^=  &=  \|=  ⊻=  >>>=  >>=  <<= |                                          | 运算并赋值的简写形式                               |
|                                          |                                          |                                          |
| .                                        | dot operator                             | 可以和二元操作符比如 ^, %结合，用来对数组进行运算, ex.  `[1,2].^2` 的结果为`[1, 4]` |
|                                          |                                          |                                          |
| [`==`](https://docs.julialang.org/en/v0.6.4/stdlib/math/#Base.:==) | equality                                 |                                          |
| [`!=`](https://docs.julialang.org/en/v0.6.4/stdlib/math/#Base.:!=), [`≠`](https://docs.julialang.org/en/v0.6.4/stdlib/math/#Base.:!=) | inequality                               |                                          |
| [`<`](https://docs.julialang.org/en/v0.6.4/stdlib/math/#Base.:%3C) | less than                                |                                          |
| [`<=`](https://docs.julialang.org/en/v0.6.4/stdlib/math/#Base.:%3C=), [`≤`](https://docs.julialang.org/en/v0.6.4/stdlib/math/#Base.:%3C=) | less than or equal to                    |                                          |
| [`>`](https://docs.julialang.org/en/v0.6.4/stdlib/math/#Base.:%3E) | greater than                             |                                          |
| [`>=`](https://docs.julialang.org/en/v0.6.4/stdlib/math/#Base.:%3E=), [`≥`](https://docs.julialang.org/en/v0.6.4/stdlib/math/#Base.:%3E=) | greater than or equal to                 |                                          |
|                                          |                                          |                                          |
| ?:                                       |                                          | 条件运算符                                    |

##### Statements

###### begin..end

大部分语言中使用花括号`{}`来包裹相关联的表达式:

```rust
{
  let x = 1;
  let y = 2;
  let z = x + y;
}
```

而julia使用begin..end来包裹

```julia
begin
    x = 1
    y = 2
    println(x+y)
end
```

###### If..elseif..else..end

```julia
if x < y
    println("x is less than y")
elseif x > y
    println("x is greater than y")
else
    println("x is equal to y")
end
```

和拥有隐式类型转换的语言不同，这种写法会报类型错误

```
julia> if 1
           return 2;
       end
ERROR: TypeError: non-boolean (Int64) used in boolean context
```

###### while..end

while语句。此类通用语法，不再一一列举。

```julia
while true
    println("OK!")
    break
end
```

###### for

```
for i = 1:1000
for i in [1,4,0]
for s ∈ ["foo","bar","baz"]
```

###### try..catch..end

```julia
try
    throw(DomainError("foo"))
catch e
    println(e)
end
```

上述代码可以合并成一行, 为了避免catch后的变量和之后的表达式混淆，用`;`来分割它们。

```julia
try throw(BoundsError("bar")) catch e; println(e) end
```

当你不需要处理错误的时候，可以省略catch

```julia
try throw(BoundsError("bar")) end
```

###### finally

和Java一样，配合try..catch使用

```julia
f = open("file")
try
    # operate on file f
finally
    close(f)
end

```

##### Expressions

###### Compound expression

begin..end包裹起来的多个表达式可以当作一个表达式来求值

```julia
v = begin
    x = 1
    y = 2
    x + y
end
println(v)
```

还有另外两种同样作用的写法:

```julia
v = (x=1; y=2; x+y)
println(v)
```

```julia
v = begin x = 1; y = 2; x + y end
println(v)
```

###### Short-circuit evaluation

中文名为短路求值，是一种基于逻辑运算符的求值方法, 有点类似于条件表达式

```julia
true || 1
```

上述表达式的值为1，因为左边的表达式为真值，右边的表达式会被求值并返回/赋值

```julia
false && 2
```

上述表达式的值为false，因为左边的值为假值，因此右边的表达式会被忽略。我们来看一个使用此写法的阶乘函数:

```julia
function fact(n::Int)
    n >= 0 || error("n must be non-negative")
    n == 0 && return 1
    n * fact(n-1)
end
println(fact(5))
```

###### Constants

Julia使用`const`定义常量，将global里的常量用const标记，有助于JIT优化执行速度，局部作用域里的常量可以不用const标记，编译器能够自动将其识别出来。

##### Scoping

Julia的作用域不算特殊，主要有GLobal，Local，Module这三种作用域。

1. 每个module都有独立的Global Scope，module之间需要先引用才能访问, 但是module A的变量在module B里是只读的

2. 语句都会产生一个local scope, 除`了begin..end`, `if`语句。总的来说，**local scope的所有父级作用域**里的变量在local scope是可见的，反之则不可见，这和我们的经验是一致的。

   如果需要让local scope里的变量在父级作用域里可见，可以强制定义为global变量

   ```julia
   for i = 1:3
       global x=i
   end
   x  # 3
   ```

   如果local scope和global scope都有变量x，同名了，怎么办？

   如果不想用global里的x，可以将local 里的变量x 标记为 local, 或者在local scope里对x重新赋值

   ```julia
   // case1
   x,y=0,1
   function plus()
       x=1  # or local x = 1
       return x+y
   end
   plus()  # 2
   x  # 0
   y  # 1
   ```

   上述代码x被重新赋值，新产生了一个局部变量x，和global里的x不冲突。

   如果想用global里的x呢？按照总规则，global 的x在local scope里是天然可见的，直接使用即可。

   ```julia
   // case2
   x,y=0,1
   function plus()
       return x+y
   end
   plus()  # 1
   x  # 0
   y  # 1
   ```

   如果不仅仅是使用，还要修改global x呢(当然这么做是不推荐的)？在case1当中，x被修改后，就自动变成local的变量了，因此要将x指明为global，如下:

   ```julia
   // case3
   x,y=0,1
   function plus()
       global x=100
       return x+y
   end
   plus()  # 101
   x  # 100
   y  # 1
   ```

   你们有没有发现case1和case3本质上是一样的？都是用关键字显式地指明它所在的作用域。

##### Module



### 编程范式

### concurrency programming



### 参考资料

1. [Style Guide](https://docs.julialang.org/en/v0.6.2/manual/style-guide/#Style-Guide-1)
2. [is-julia-strongly-checked?](https://discourse.julialang.org/t/is-julia-a-strongly-checked-language/12990/3?u=songtianyi)
3. [类型双关](https://zh.wikipedia.org/wiki/%E7%B1%BB%E5%9E%8B%E5%8F%8C%E5%85%B3)


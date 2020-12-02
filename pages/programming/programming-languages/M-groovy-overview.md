# Groovy 概览

作者: songtianyi create@2020-11-24

## 前言

和 Go 的火热相比，Groovy 显得名不见经传。但 Groovy 目前在 tiobe 的排名比 Go 是要高的。Groovy 的成功案例有 Gradle, Grails, Spock testing等等。我们在用静态语言做数据处理的时候是非常痛苦的，而且在客户环境测试的时候，我们需要经过反复的修改，发布，上传，更新等操作，对客户体验影响很大。Groovy作为脚本语言，既能提供灵活性，又能复用 Java 的代码遗产，是一个不错的选项。

## Groovy 是什么

* 运行在 jvm 上，设计之初就考虑从 Java 过渡到 Groovy 的平滑性，能够load jar包，执行 java 函数，你甚至可以同时使用 java 语法和 Groovy 语法来编程；可以编译成 java 字节码，集成进 java 程序里运行；既对 java 友好，又具有比 java 更丰富的语法特性
* 提供闭包，元编程能力，还有强大的 DSL
* Gradual typing, 既支持静态类型(static typing)，也支持动态类型(dynamic typing)
* Groovy 的类型都属于 `java.lang.Object` 的子类型
* 多范式，IP, SP, PP, OOP, FP, MP

## 安装

[下载并安装](http://www.groovy-lang.org/download.html) groovy

## 类型系统

| Lang  | Typed | Static and dynamic  checks | Strongly checked | Weakly or strongly  typed | Dynamically or statically typed |         Type theories         | Paradigms          |
| :---: | :---: | :------------------------: | :--------------: | :-----------------------: | :-----------------------------: | :---------------------------: | ------------------ |
| Groovy|  ☑️   |             optional              |        ☑️        |          weakly           |           optional | generic, overloading, subtype | IP, SP, PP, OOP, FP, MP |

* optional typing(Gradual typing): optional typing 是指类型系统的检查既可在编译时，也可以在运行时，Groovy 将选择权留给使用者。
* weakly typed: 类型是可变的

``` 

groovy:000> a = '1'
===> 1
groovy:000> a.class
===> class java.lang.String
groovy:000> a = 1
===> 1
groovy:000> a.class
===> class java.lang.Integer
groovy:000>
```

* type inference: 支持类型推断

``` 

groovy:000> 1.class
===> class java.lang.Integer
groovy:000>
```

## 语法规范

虽然大部分 Groovy 代码和 Java 一致，但是 Groovy 语法并不是 Java 语法的超集(superset)。
比如，Java 不支持下面的 `for` 表达式:

``` java
for(init1,init2;test;inc1,inc2) 
```

Groovy 里的 `==` 是判断相等性(equality)，而不像 java 是判断同一性(identity)， `==` 在 Groovy 里被解释为 java 里的 `equals`

除了这些细微的差别，大部分的 java 语法都是可以被 Groovy 兼容的。Groovy 相对 Java 新增的语法包括:

* 通过新的表达式和运算符访问 java 对象

* 更丰富的对象创建方式

``` Groovy
def http = [
 100 : 'CONTINUE',
 200 : 'OK',
 400 : 'BAD REQUEST'
] 

def zh = [
    你的名字: "songtianyi",
    你的年龄: 18
]
```

* 提供了高级的流控制语法
* 新的数据类型，及附带的运算符和表达式
* 支持通过 `\` 符号分割代码
* 支持将 `""`里的内容解释成表达式
* `null` 在条件表达式里会被当作 `false` 来对待, 而在 java 里则会出现异常。

``` 

groovy:000>
groovy:000> a="1+1"
===> 1+1
groovy:000> evaluate(a)
===> 2
groovy:000>
```

除了新增的语法，Groovy 相对 Java 做了大量的语法优化，使我们写起来更美观和简洁。

* 当没有冲突的时候可以省略包的前缀，可以省略一些括号, 分号等

``` java
// java
java.net.URLEncoder.encode("a b");
```

``` Groovy
// Groovy
URLEncoder.encode 'a b' 
```

虽然 Groovy 提供了更多的灵活写法，但是我们需要斟酌使用，为自己的代码可读性负责。

* 包自动导入，无需指定包名。虽然 java 会自动导入 `java.lang.*`, 当然仅此而已。
* 不需要显式的类型转换
* 和 rust 一样，return 是可选的。

``` Groovy
def sum(a, b) {
    a + b
    // return a + b
}
```

* 不需要显式地 throw 捕捉到的 exception

### Types

#### range

 range 使用 `left..right` 形式表达。range 是一个对象，可以调用该对象的方法, 可以作为 `witch case`

``` Groovy
print 0..1
print 0..<2 // 不包含2
```

``` Groovy
def result = '' 
(5..9).each { element -> result += element } 
assert result == '56789'

assert 5 in 0..10

assert (0..10).isCase(5) 

def age = 36
switch(age){
 case 16..20 : insuranceRate = 0.05 ; break
 case 21..50 : insuranceRate = 0.06 ; break
 case 51..65 : insuranceRate = 0.07 ; break
 default: throw new IllegalArgumentException()
}
assert insuranceRate == 0.06 

def ages = [20, 36, 42, 56]
def midage = 21..50
assert ages.grep(midage) == [36, 42]
```

#### lists

相比 java，Groovy list 的初始化方式要简单的多。 `[item, item, item] `

``` Groovy

[] // 初始化一个空list
[1, 2, 3]
```

可以和 range 结合使用: 

``` Groovy
[0..10].each{x -> print x}
```

可以像 Golang 一样取子集:

``` Groovy
['a','b','c','d','e','f'][0..2] // output  [a, b, c]
```

从这个例子还可以看出，Groovy 的语法是相当灵活的，可以根据直觉去编码，一般都不会出错。

可以同时从 list 里取多个值:

``` Groovy
['a','b','c','d','e','f'][0, 2, 4] // output [a, c, e]
```

 相应地，你可以修改 list 的子集，可以同时修改多个值:
 

``` Groovy
 groovy:000> x = ['a','b','c','d','e','f']
===> [a, b, c, d, e, f]
groovy:000> x[0..2] = ['h','i','j']
===> [h, i, j]
groovy:000> x
===> [h, i, j, d, e, f]
groovy:000> print x
[h, i, j, d, e, f]===> null
groovy:000> x[0,1,5] = ['q','p','s']
===> [q, p, s]
groovy:000> print x
[q, p, j, d, e, s]===> null
```

可以很方便地插入一个列表:

``` Groovy
groovy:000> x=['q', 'p', 'j', 'd', 'e', 's']
===> [q, p, j, d, e, s]
groovy:000> x[0..0] = ['1','3','2']
===> [1, 3, 2]
groovy:000> print x
[1, 3, 2, p, j, d, e, s]===> null
```

甚至，list 还可以支持运算符:

``` Groovy
['a', 'b', 'c'] - ['a', 'b'] // output [c]

['a'] + ['b'] // output [a, b]

['a', 'b'] * 2 // output [a, b, a, b]

['a', 'b']  << 'c' // output [a, b, c], 相当于 append
```

## DSL

得益于 Groovy 灵活的语法，你可以很轻松地创建自己的 DSL(Domain specific language)

## Java 和 Groovy 的亲和性

### Java 调用 Groovy

编写一个 Groovy 类 `MyGroovyClass` , 然后编译成 `MyGroovyClass.class` , 将其放进 classpath , 然后可以在 java 中使用该类

``` java
new MyGroovyClass(); // create from Java 
```

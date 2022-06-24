# 1 小时入门 Rust

作者: [songtianyi](https://github.com/songtianyi) create@2018-07-29, update@2020-11-22

### 前言

 `1 分钟`

在系统地了解了编程语言的[类型特性和编程范式](https://gitbook.cn/gitchat/activity/5b57f6fd862f763b881c033e)之后，一直想验证下对这些知识的掌握程度，以及验证这些知识能否为我们入门一门语言提速，那么最佳的途径应该是选择一门新语言来上手实践。为什么选择 Rust？Rust 和 Go 一样年轻，如果说 go 是 C-like language，那么 Rust 就是 C++-like 的语言，有人称其为更安全的 C++, 对于长期从事 C++开发的程序猿可以学来尝鲜。初看 Rust 有点想放弃，[Rust 没有 GC](is-rust-garbage-collected.md)，并发的书写方式也并没有 Go 那么方便，但是多看几眼，它的某些优点还是吸引到了我，比如安全性，高性能，闭包等，所以本文最终以 Rust 为例，来做这两方面的验证。在阅读本文之前，掌握[类型特性和编程范式](https://gitbook.cn/gitchat/activity/5b57f6fd862f763b881c033e)里的概念是必要的，且阅读本文需要一定的编程基础。

### Rust 是什么

 `3 分钟`

> **Rust** is a systems programming language that runs blazingly fast, prevents segfaults, and guarantees thread safety

* 通用，静态编译型的系统编程语言(内联汇编)
* 高性能，零开销抽象，没有 GC
* 安全，线程无数据竞争

* 支持泛型，多态和操作符重载
* 多范式，FP, OOP, MP
* 高效 C 绑定

###### 零开销抽象

简单来说，在 Java 里，class A 有个成员 b，b 的类型是 class B，如果 A 的实例 a 引用 b 的成员函数 m，那么调用链是 a.b.m(), 这个调用过程需要两次指针访问，意味着更多的开销，而 c++里的 class，同样是抽象，但只需一次指针访问，相比未抽象的情况没有额外的一次开销，所以叫零开销，这种抽象实现方式叫零开销抽象。

### 安装

 `5 分钟`

linux 下可以直接执行这个命令来下载安装脚本并执行它。

```shell
curl https://sh.rustup.rs -sSf | sh
```

由于墙的原因，失败的概率会很高，在[这个页面](https://forge.rust-lang.org/infra/other-installation-methods.html#standalone)可以找到对应个系统的离线安装包。

验证安装结果:

```shell
rustc -V
```

编辑工具用 vscode，然后在命令行使用 rustc(v1.27.2)编译。

### 类型系统

 `10 分钟`

| Lang | Typed | Static and dynamic  checks | Strongly checked | Weakly or strongly  typed | Dynamically or statically typed |         Type theories         | Paradigms       |
| :--: | :---: | :------------------------: | :--------------: | :-----------------------: | :-----------------------------: | :---------------------------: | --------------- |
| Rust |  ☑️   |             ☑️             |        ☑️        |         strongly          |           statically            | generic, overloading, subtype | IP, SP, PP, OOP, FP |

* *static and dynamic checks*: Rust 是静态编译语言，自然有静态检查，且非常强大

* *strongly checked*: 安全性是 Rust 的第一大亮点，也是它的设计初衷。C/C++程序猿应该深有体会，内存泄漏和指针异常崩溃时常让我们的努力功亏一篑，Rust 在类型系统上下了很大功夫，尽量在编译阶段就能检测出这类错误，同时，编译时检查的加强也会降低运行时检查的性能开销。编译时检查需要依靠类型系统来提供信息，那么 Rust 的类型系统做了哪些事来达到这样的安全性呢？

  + 变量
    变量定义在 Rust 里称作变量绑定，变量默认是不可修改的,。

```rust
    fn main() {
    	let x = 5;
    	x = 6
    }
    ```

    上述代码编译不会通过

```shell
    error[E0384]: cannot assign twice to immutable variable `x`
     --> let.rs:3:3
      |
    2 |         let x = 5;
      |             - first assignment to `x`
    3 |         x = 6
      |         ^^^^^ cannot assign twice to immutable variable
    ```

    你们可能注意到了，x 的定义没有指明类型，是的，和许多现代编程语言一样，Rust 提供了类型推断。另外 Rust 是不允许使用未经初始化的变量的，虽然有类型推断但没有默认值，强迫我们使用更规范的方式去书写程序，因为默认值依赖于程序猿的经验以及运行平台，会有相应的编码风险。

```rust
    let mut x = 5; // 类型推断, 用 mut 来标记 使变量可修改
    x = 10;
    let mut y: i32 // 显式地指明类型为 int32
    ```

  + ownership/borrowing
    c/c++给程序猿提供了操作内存的自由度，但是内存管理对于缺乏经验的人来说比较困难，而且人总是会犯错的，GC 的引入解决了这个问题，但是也带来了新的问题，即性能开销。Rust 作为系统编程语言，安全和性能都是它所追求的，那么它是如何解决的呢？Rust 引入了生命周期和租借的概念，并作出如下限制:

    1. 所有的资源只能有一个所有者（owner）

```rust
       fn main() {
           // create string resource and assign it to a, a is the resource owner
           let a = String::new();
           // transfer the resource from a to _b, _b is the owner now
           let _b = a;
           // a cannot access the resource any more
           println!("{}", a); // compile error
       }
       ```

       我们可以把所有权再还回去，修改后的代码如下

```rust
       fn main() {
           let mut a = String::new();
           let _b = a; // 浅拷贝
           a = _b;
           println!("{}", a); // compile ok
       }
       ```

    2. 其它人可以租借这个资源。

```rust
       fn main() {
           let a = String::from("foo");
           let b = &a;
           println!("a {}, b {}", a, b);
       }
       ```

       租借其实就是引用。租借的形式有可变和不可变两种，最多只能有一个可变租借; 可以有多个不可变租借；当有可变租借时，不能有其他租借。

```rust
       fn main() {
           let a = String::from("foo");
           let b = &a;
           let c = &a;
           println!("a {}, b {}, c {}", a, b, c);
       }
       ```

    3. 但当这个资源被借走时，所有者不允许修改或释放该资源。

```rust
       fn main() {
           let mut a = String::from("foo");
           let b = &a;
           println!("a {}, b {}", a, b);
           a = String::from("bar"); // compile error
       }
       ```

       上面的代码中，a 被借给了 b，虽然 b 是不可修改的，但是 a 作为资源的所有者仍然不能修改该资源。那么被借出的资源能否够被修改呢？答案是能。虽然所有者不能修改，但是可以授予他人修改的权限，前提当然是资源本身是允许被修改的。

```rust
       fn main() {
           let mut a = String::from("foo");
           let n = String::from("bar");
           {
               let b = &mut a;
               *b = n;
               println!("b {}", b);
           }
           println!("a {}", a);
       }

       ```

       在上述代码中，我们先定义了可修改的 a 和 n，然后把 a 以可变的形式借给了 b，之后修改 b，在打印 a 之前，b 被销毁，归还了可变引用，因此 a 能够再次借出(打印)。

  + lifetime
    在上面的代码中，b 由于超出作用域而被自动销毁，使得我们能够再次正常使用 a(读写或者销毁)。但是语言的作用域并不总能达到这种效果，如果租借不能被归还(引用被销毁)，会导致变量无法正常使用。编译器需要一种机制能够让它知道引用是否被销毁，来完成它的检查，编程语言需要一种机制来确保引用的生命周期是要小于所有者的。这种机制即是 lifetime，一种显式地指定作用域的方法。再举一个例子来说明它的必要性:

```rust
    fn foo(x: &str, y: &str) -> &str {
        if x.len() > y.len() {
            x
        } else {
            y
        }
    }

    fn main() {
        let x = String::from("foo");
        let z;
        {
            let y = String::from("bar");
            // 租借 x 和 y，有可能返回 x 的引用，有可能返回 y 的引用
            z = foo(&x, &y);
        }
        // 如果返回的是 y 的引用，由于 y 已经被销毁，访问 z 属于非法访问
        println!("z = {}", z);
    }
    ```

    这段代码编译会不通过，因为编译器检查出了这种风险。

    lifetime 的指定方式:

```rust
    'a
    ```

    Rust 称之为 lifetime annotation。单引号是必须的，a 可以用其他字母/单词代替，但通常用 a, b, c。那么可以通过指定 lifetime 来修改上述代码使其通过。

```rust
    fn foo<'a, 'b: 'a>(x: &'a str, y: &'b str) -> &'a str
    ```

`'b: 'a` 的意思是限定了入参 y 的生命周期 `'b` 必须比入参 x 的生命周期 `'a` 要长，可以认为这是一个调用函数时的约束条件。完整代码如下:

```rust
    fn foo<'a, 'b: 'a>(x: &'a str, y: &'b str) -> &'a str {
        if x.len() > y.len() {
            x
        } else {
            y
        }
    }

    fn main() {
        let y = String::from("bar");
        let x = String::from("foo");
        {
            // y 的生命周期必须比 x 长
            let z = foo(&x, &y);
            println!("z = {}", z);
        }
    }

    ```

* *strongly typed*: 类型在确定之后不可变

* *statically typed*: 类型在编译时确定

### 类型理论

 `10 分钟`

##### 泛型

和 c++/Java 一样，Rust 的泛型风格基本类似

```rust
// generic function
fn foo<T>(_x: &[T]) {}

fn main() {
    foo(&[1, 2]);
}

```

除此之外还有泛型结构体等，这里不再一一列举，需要在实战中摸索。

```rust
struct SGen<T>(T);
fn main() {
    SGen(2);
}

```

值得一提的是，我们可以限定 `T` 的类型范围:

```rust
trait Graph {
    fn area(&self) -> f64;
}
// 限定 T 的类型必须是实现了 Graph 的类型
fn foo<T : Graph>(_x: &[T]) {}
```

还有另外一种表达能力更强的写法， `where` 语句:

```rust
fn foo<T>(_x: &[T]) where T : Graph {}
```

当我们限定的不是 T，而是使用 T 的方式时 `where` 会很有用:

```
use std::fmt::Debug;

trait PrintInOption {
    fn print_in_option(self);
}

// Because we would otherwise have to express this as `T: Debug` or
// use another method of indirect approach, this requires a `where` clause:
impl<T> PrintInOption for T where Option<T>: Debug {
    // We want `Option<T>: Debug` as our bound because that is what's
    // being printed. Doing otherwise would be using the wrong bound.
    fn print_in_option(self) {
        println!("{:?}", Some(self));
    }
}

fn main() {
    let vec = vec![1, 2, 3];

    vec.print_in_option();
}

```

上述代码中，我们限定了 `Option<T> : Debug` , 即 Option\<T>必须实现了 Debug trait。

##### 多态

即 subtyping。Rust 和 golang 一样并没有继承这一说，也没有 class，但 struct 是可以定义函数的，也能指定可见性。struct 和 trait 结合使用能够达到通常 OOP 中继承和多态的效果。

```rust
trait Graph {
    fn area(&self) -> f64;
}
// 定义一个结构体
struct Circle {
    x: f64,
    y: f64,
    radius: f64,
}
// 为 Circle 实现 Graph trait，或者说实现 Graph 接口
impl Graph for Circle {
    // 必须实现 area
    fn area(&self) -> f64 {
        std::f64::consts::PI * (self.radius * self.radius)
    }
}
// 定义一个新的结构体类型
struct Rec {
    x: f64,
    y: f64,
    length: f64,
    height: f64,
}
// 为 Rec 实现 Graph trait
impl Graph for Rec {
    // 必须实现 area
    fn area(&self) -> f64 {
        self.length * self.height
    }
}

fn print_g(g : &Graph) {
    println!("graph area {}", g.area());
}

fn main() {
    let c = Circle{
        x: 1.0,
        y: 1.0,
        radius: 1.0
    };
    let r = Rec {
        x: 1.0,
        y: 1.0,
        length: 1.0,
        height: 2.0,
    };
    print_g(&c);
    print_g(&r);
}

```

上述代码中 `print_g` 的入参类型为 `&Graph` , 既能将 `&Circle` 作为输入，也能将 `&Rec` 作为输入，即是多态用法。需要强调的是，trait 是没有类型关系的，我们不能说 Rec 是 Graph 的子类型, 这和其他基于类型关系的 subtyping 不一样。Rust 传统意义上的 subtyping 是在 lifetime 中体现的， `'big <: 'small` 意味着 big 的生命周期比 small 长，big 是 small 的子类型(subtype), 在使用 `'small` (它是一个类型)的地方都可以使用 `'big` 代替。

##### 重载

在 Rust 里操作符其实是语法糖，a + b 等价于 a. Add(b), 能够用操作符操作的类型都实现了 `std::ops::Add` 这个 trait，那我们为某个类型实现 Add trait，即重载了它的加法操作符。

```rust
use std::ops::Add;

#[derive(Debug)]
struct Point {
    x: i32,
    y: i32,
}

impl Add for Point {
    type Output = Point;
    fn add(self, other: Point) -> Point {
        Point {
            x: self.x + other.x,
            y: self.y + other.y,
        }
    }
}

impl std::fmt::Display for Point {
    fn fmt(&self, f: &mut std::fmt::Formatter) -> std::fmt::Result {
        write!(f, "({},{})", self.x, self.y)
    }

}

fn main() {
    let p1 = Point { x: 1, y: 0 };
    let p2 = Point { x: 2, y: 3 };

    let p3 = p1 + p2;

    println!("{}", p3)
}
```

Rust 没有函数重载。

### 语法规范

 `25 分钟`

##### Types

###### Primitive types

| 基础类型                  | 解释                                       |
| --------------------- | ---------------------------------------- |
| i8, i16, i32, i64, u8, u16 | 整数, i 代表有符号, u 代表无符号                       |
| f32, f64              | 浮点数, IEEE-754 标准                          |
| bool                  | 布尔型, true or false. `ex` . let b: bool = false; |
| char, str            | 字符/字符串                                   |
| isize, usize          | The pointer-sized unsigned integer type. 依赖运行平台指针大小的类型，在 32bit 的机器上，它是占用四个字节的整形，在 64 位的机器上它占用 8 个字节 |
| fn                    | 函数                                       |
| never                 | 书写为 `!` ，用来标记 never 类型                       |

###### Compound types

| 复合类型               | 解释                                       |
| ------------------ | ---------------------------------------- |
| array, slice, Vec | 数组/切片/向量数组，let b = [0; 20]; 定义大小为 20 的不可修改数组，并将所有的值初始化为 0，切片则是数组的引用 let sli = &b[..]，数组需定义大小，切片则不用; Vec 则是标准库提供的分配在堆上的变长数组 |
| struct             | 结构体. `ex` . struct test{a:b, c:d}, 可以使用 pub 来标记字段的可见性 |
| closure            | 闭包                                       |
| map                | rust 的标准库提供了 hash map 等高级数据结构               |
| fn pointer         | 函数指针. `ex` .  type Binop = fn(i32, i32) -> i32; Binop 是一个函数指针 |
| pointer, reference | 指针/引用, 指针的值和普通类型一样，可以被移动，拷贝，存储和返回，标准库提供了智能指针；引用则是指向别的值所在的内存地址的类型，分为 shared reference 和 mutable reference |
| enum               | 枚举, Rust 的枚举比 golang 表达更加丰富，它的成员可以为 struct 或者 tuple struct 或者 unit struct |
| union              | 联合                                       |
| recursive          | 使用递归方式定义的类型，struct，union，enum 都可以递归       |
| trait              | rust 里的 interface                          |
| tuple              | 元组                                       |

如果你看了我之前写的《编程语言选型》里的基础类型和复合类型，理解 Rust 的类型就会轻松一些，但是 Rust 还是提供了很多新的东西。

###### never type

never 类型是 Rust 里的特殊类型，在早期的版本里甚至称不上是类型，因为它不占用任何空间，不能像普通类型一样初始化。你可以认为它是一个不存在的类型，可以用来占位，下面的代码中，Result 枚举中的第二个类型是 never，当我们不需要返回错误时，可以用它来占位。

```rust
fn from_str(s: &str) -> Result<String, !> {
    Ok(String::from(s))
}
```

2016 年，Rust 将 `!` 升级成了一个标准的类型，意味着你可以用它来绑定变量。它的主要用途不变，但目前还在 `experimental` 的阶段。

```rust
let x: ! = panic!()
```

###### unit struct

```rust
struct u {}
```

###### tuple struct

```rust
struct t {i32, char}
```

###### recursive type

```rust
enum List<T> {
    Nil,
    Cons(T, Box<List<T>>)
}

let a: List<i32> = List::Cons(7, Box::new(List::Cons(13, Box::new(List::Nil))));
```

###### struct

给 struct 定义成员函数的方式和 golang 类似, 但使用 `impl` 关键字来标记, self 用来代替所实现的结构体。

```rust
struct Cicle {
    x: f64,
    y: f64,
    radius: f64,
}

impl Cicle {
    fn area(&self) -> f64 {
        // area
        std::f64::consts::PI * (self.radius * self.radius)
    }
    fn pos(&self) {
        println!("({}, {})", self.x, self.y);
    }
}

fn main() {
    let c : Cicle = Cicle{
        x: 1.0, y: 1.0, radius: 1.0
    };
    println!("{}", c.area());
    c.pos()
}
```

###### 元组索引

```rust
fn main() {
    let b = 32;
    let tuple = ("a", 3, b);
    println!("{} {} {}", tuple.0, tuple.1, tuple.2);
}
```

###### 函数

```rust
fn main() {
    let x = foo;
    println!("{}", x());
}
fn foo() -> i32 {
    110 // return 110;
}
```

和 Groovy 一样，Rust 支持隐式 return 语句，而且推荐这么做，当你这么做的时候末尾不要接分号，否则它会被当成一个表达式而不是 return 语句，对于这类书写错误，rustc 编译器会提示你怎么修正。

```rust
fn foo() -> i32 {
    110; // compile error
}
```

###### 类型别名

```rust
fn main() {
    type Alias = (i32, char); // 为元组定义一个别名
    let _t : Alias = (10, 'a');
}
```

###### 闭包

闭包的入参参数写在 `||` 内，之后是函数逻辑。注意，下面的代码如果不加 `||` ， 花括号内的值会被当作表达式先执行，然后将执行的返回值作为入参。

```rust
fn f(_g: F) {
    _g();
}
type F = fn() -> String;
fn main() {
    f(||{
        println!("rust-lang is best lang!");
        String::from("foo")
    })
}
```

###### 枚举

Rust 的枚举用法较多，和 java 一样可以带构造器。

```rust
enum Animal {
    Dog,
    Cat,
}

let mut a: Animal = Animal::Dog;
a = Animal::Cat;
```

```rust
enum Animal {
    Dog(String, f64),
    Cat { name: String, weight: f64 },
}

let mut a: Animal = Animal::Dog("Cocoa".to_string(), 37.2);
a = Animal::Cat { name: "Spotty".to_string(), weight: 2.7 };
```

###### 联合

rust 一开始是没有 union 类型的，因为 rust 的 enum 即是 tagged union，属于比较安全的 union 实现方式。后来加入了 untagged union, 在访问它的字段时要加 `unsafe`

```rust
#[repr(C)]
union MyUnion {
    f1: u32,
    f2: f32,
}
fn main() {
    let u = MyUnion { f1: 1 };
    unsafe {
        let f = u.f1;
        println!("{}", f);
    }
}

```

###### Trait

Rust 的 trait 类似于 golang 中的 interface，它告诉编译器一个类型必须提供哪些函数。你可以为任意类型实现某个 trait。

```rust
trait HasArea {
    fn area(&self) -> f64;
}

```

关于 trait 的使用，会在 subtyping 中介绍。Rust 中有个特殊的 trait `Drop` ，作用类似于析构函数，大家可以自行了解。

##### Statements

###### If

**if**语句和 golang 一样没有括号。

```rust
let x = 5;

if x == 5 {
    println!("x is five!");
} else if x == 6 {
    println!("x is six!");
} else {
    println!("x is not five or six :(");
}
```

但是语法糖会多一些。

```rust
let x = Some(3);
let a = if let Some(1) = x {
    1
} else if x == Some(2) {
    2
} else if let Some(y) = x {
    y
} else {
    -1
};
```

###### let

let 语句，用来绑定变量。

##### Operators

| Operator/Expression                      | Associativity       |
| ---------------------------------------- | ------------------- |
| `?` |                     |
| Unary `-`  `*`  `!`  `&`  `&mut` |                     |
| `as` | left to right       |
| `*`  `/`  `%` | left to right       |
| `+`  `-` | left to right       |
| `<<`  `>>` | left to right       |
| `&` | left to right       |
| `^` | left to right       |
| `|` | left to right       |
| `==`  `!=`  `<`  `>`  `<=`  `>=` | Require parentheses |
| `&&` | left to right       |
| `||` | left to right       |
| `..`  `..=` | Require parentheses |
| `=`  `+=`  `-=`  `*=`  `/=`  `%=`  `&=`  `|=`  `^=`  `<<=`  `>>=` | right to left       |

##### Expressions

表达式是语句(statements)的子集，这里按照 rust reference 文档，部分关于语句的语法也写在 expression 的范畴内，且只列举较陌生的表达式写法。

###### Path expression

Rust 使用 `::` 的方式来表达引用路径，和 C++类似。

```rust
 let y = String::from("bar");
```

###### ErrorPropagation Expression

错误传播表达式，和 Result\<T, E>相结合用来解决异常处理的问题，格式为表达式接问号:

```rust
Expression ?
```

当表达式为正常值时继续运行，当表达式为 Err 时立即返回。

```rust
fn main() {
    fn try_to_parse() -> Result<i32, std::num::ParseIntError> {
        let x: i32 = "123".parse()?; // x = 123
        let y: i32 = "24a".parse()?; // returns an Err() immediately
        Ok(x + y) // Doesn't run.
    }

    let res = try_to_parse();
    println!("{:?}", res);
}

```

###### TypeCastExpression

类型转换表达式，用 `as` 来表示:

```rust
let size: f64 = len(values) as f64;
```

###### Array expression

数组表达式，仅列举 Rust 中特别的数组初始化方式:

```rust
let a = [0; 128];
```

这里提一下，我们知道，数组是可以通过下标来访问的:

```rust
a[0]
```

如果其他的类型实现了 `std::ops::Index` trait 和 `std::ops::IndexMut` trait，那么这些类型也可以通过下标来访问，因为方括号的形式只是语法糖。

###### Closure expression

即闭包。Rust 的闭包写法稍微有些奇特，可能是因为 `->` 被用来标记函数回参了吧。

```rust
let plus_one = |x: i32| x + 1;
```

管道符内的是入参，其后的内容是一个表达式，注意， `{}` 也是一个表达式。

```rust
fn main() {
    let _f = |x: i32, y: i32| -> i32 {x + y};
    println!("{}", _f(1, 2));
}
```

也可以不指定返回类型，让编译器自行推断。Rust 的闭包 `||{}` 也是语法糖，底层仍然是通过 trait 来实现的。对于闭包的使用，较复杂的是如何返回一个闭包，具体代码如下:

```rust
fn factory(n: i32) -> Box<Fn(i32) -> i32> {
    Box::new(move |x| x + n)
}

fn main() {
    // factory 函数返回了一个闭包
    let f = factory(5);
    let answer = f(1);
    assert_eq!(6, answer);
}

```

在创建闭包的时候添加了一个关键字 `move` ，因为 n 是临时变量且在闭包中被借用，当闭包在当前函数 factory 外被调用，n 是不存在的，所以编译器不允许这么做， `move` 则告诉编译器，n 需要被拷贝，这样被拷贝的 n 就存在于闭包自己的内存栈中。Rust 要求返回值必须是固定大小的，而函数的大小不确定，用 Box 来封装之后，它的大小就确定了。

###### For expression

For 语句, 像脚本语言的写法。

```rust
for x in 1..100 {
    if x > 12 {
        break;
    }
    last = x;
}
```

###### Range expression

此表达式会创建并初始化一个结构体，看表和例子即可。

| Production             | Syntax        | Type                                     | Range           |
| ---------------------- | ------------- | ---------------------------------------- | --------------- |
| *RangeExpr*            | start `..` end  | [std::ops:: Range](https://doc.rust-lang.org/std/ops/struct.Range.html) | start ≤ x < end |
| *RangeFromExpr*        | start `..` | [std::ops:: RangeFrom](https://doc.rust-lang.org/std/ops/struct.RangeFrom.html) | start ≤ x       |
| *RangeToExpr*          | `..` end       | [std::ops:: RangeTo](https://doc.rust-lang.org/std/ops/struct.RangeTo.html) | x < end         |
| *RangeFullExpr*        | `..` | [std::ops:: RangeFull](https://doc.rust-lang.org/std/ops/struct.RangeFull.html) | -               |
| *RangeInclusiveExpr*   | start `..=` end | [std::ops:: RangeInclusive](https://doc.rust-lang.org/std/ops/struct.RangeInclusive.html) | start ≤ x ≤ end |
| *RangeToInclusiveExpr* | `..=` end      | [std::ops:: RangeToInclusive](https://doc.rust-lang.org/std/ops/struct.RangeToInclusive.html) | x ≤ end         |

```rust
1..2;   // std::ops::Range
3..;    // std::ops::RangeFrom
..4;    // std::ops::RangeTo
..;     // std::ops::RangeFulls
5..=6;  // std::ops::RangeInclusive
..=7;   // std::ops::RangeToInclusive
```

###### Match expression

match 表达式也是 Rust 的主要特色之一。除了可以当作常规的 switch 语句使用之外

```rust
let x = 1;

match x {
    1 => println!("one"),
    2 => println!("two"),
    3 => println!("three"),
    4 => println!("four"),
    5 => println!("five"),
    _ => println!("something else"),
}
```

还可以匹配更复杂的类型实例

```rust
match message {
    Message::Quit => println!("Quit"),
    Message::WriteString(write) => println!("{}", &write),
    Message::Move{ x, y: 0 } => println!("move {} horizontally", x),
    Message::Move{ .. } => println!("other move"),
    Message::ChangeColor { 0: red, 1: green, 2: _ } => {
        println!("color change, red: {}, green: {}", red, green);
    }
};
```

`_` 代表默认逻辑。

##### Modules

rust 的模块(包)引入语法和其他语言不太一样，我们先看下怎么定义一个模块。

```rust
pub mod math {
    pub fn f() -> f64 {
        1.1
    }
}
```

将上面的内容写入 math_mod.rs 中，然后在另外一个文件引入:

```rust
mod math_mod;
fn main() {
    println!("{}", math_mod::math::f());
}
```

引入时，也可以显式地指定路径:

```rust
#[path = "math_mod.rs"]
mod m;
fn main() {
    println!("{}", m::math::f());
}
```

可以使用 `use` 关键字来简化包的使用

```rust
#[path = "math_mod.rs"]
mod m;
use m::math;
fn main() {
    println!("{}", m::math::f());
    println!("{}", math::f());
}
```

也可以为 mod 或者 mod 里的 item 定义别名

```rust
#[path = "math_mod.rs"]
mod m;
use m::{math::f as mf};
fn main() {
    println!("{}", m::math::f());
    println!("{}", mf());
}
```

#### 编程范式

 `5 分钟`

##### 函数式编程

Rust 并不是纯函数式语言，语言的设计者们并不教条，执着在一种范式或类型特性上，而是从开发的角度出发，提供解决问题的方法，因此 Rust 作为一门年轻的现代语言，还是提供了函数式编程的途径。

* 闭包
* 迭代器，在函数式编程里，迭代器是流式处理(函数式风格)的基础
* 函数也是类型，可以作为参数和返回值

##### 面向对象编程

面向对象是一个很好的概念，但并不是所有情况下都是最优的选择，语言的设计者们权衡之后，都放弃了纯面向对象的方式，比如 Go。Rust 并不是一门面向对象语言，也没有类或者继承的概念，但确实可以像面向对象语言那样编程，因此也认为它具备面向对象编程这个范式。面向对象的三大特征是封装／继承／多态。封装不用说，struct 是可以定义成员函数的，多态特性我们在 subtyping 中也讲到过，那么继承呢？Rust 的继承写法也是通过 trait 来完成的，通过组合 trait 来建模对象之间的共性。

```rust
trait One { fn one(&self); }
trait Two: One { fn two(&self); }

trait Com: One + Two;

struct Foo;

impl Com for Foo {
  fn one(&self) {}
  fn two(&self) {}
}
```

`One + Two` 的语法是有说法的，TODO: Algebraic data type

##### 元编程

元编程一种程序修改自身的行为。学过 C 语言的应该知道它的宏概念，宏也属于元编程的范畴，预处理器会将宏代码替换成新的代码。C/C++的宏实现是基于文本替换的，属于不安全的宏。举一个例子:

```c
#define INCI(i) do { int a=0; ++i; } while(0)
int main(void)
{
    int a = 4, b = 8;
    INCI(a);
    INCI(b);
    printf("a is now %d, b is now %d\n", a, b);
    return 0;
}
```

C 的预处理器进行宏替换后的代码为:

```c
int main(void)
{
    int a = 4, b = 8;
    do { int a=0; ++a; } while(0);
    do { int a=0; ++b; } while(0);
    printf("a is now %d, b is now %d\n", a, b);
    return 0;
}
```

我们预期的结果应该是 a 被加 1 等于 5，b 被加 1 等 9，但是输出为:

```
a is now 4, b is now 9
```

> 这个例子不太恰当，一般我们不会犯这类错误，这里仅为了说明 C 语言宏实现的缺陷。

而 Rust 的宏实现要强大复杂的多，Rust 的宏系统借助了语法树及它的模式匹配。

```rust
macro_rules! foo {
    (x => $e:expr) => (println!("mode X: {}", $e));
    (y => $e:expr) => (println!("mode Y: {}", $e));
}

fn main() {
    foo!(y => 3);
}
```

Rust 的宏用 `!` 标记，比 C/C++的用大写来标记可读性要高。上述代码中 foo 这个宏会对 `y => 3` 进行模式匹配，将代码替换成 `=>` 后的内容，同时将表达式的值绑定到变量 e 上，可以看出它并不是简单的文本替换。Rust 的宏还有更高级的用法，这里不展开讲。

### 总结

 `1 分钟`

单从本文涉及到的内容来看，Rust 上手已经不算简单，因为 Rust 引入了一些其他语言没有的概念，比如 ownership/lifetime 等，trait 是 Rust 类型系统的核心特性，很多语法都是基于它来实现的。此外，本文未涉及到的内容还有很多，如条件编译/注释及文档/并发编程/内联汇编/C binding/crate/cargo 等，感兴趣的可以关注之后的文章。

### 参考资料

* [rust-lang reference](https://doc.rust-lang.org/stable/reference/items/use-declarations.html)

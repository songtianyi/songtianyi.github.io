# Rust 宏

## 前言

18年系统学习编程语言理论的时候快速学过 Rust，两年过去了还没实际使用过它做开发，最近在使用 TDengine 的时候，发现 TDengine 的 Go binding 没有实现订阅的接口，C++ 又没多大兴趣，于是在前人的基础上把 TDengine 的 Rust binding 写了一遍，然后使用 Rust 写了 业务逻辑的 API 接口。在做错误处理的时候，认识到了 Rust 宏的强大，所以想着重新学下 Rust 宏，做个笔记。

## C Macro

宏的概念我们在刚学计算的时候就接触过，C 语言里的 `#define xxx` 就是宏。

``` c
#define LENGTH_OF_ARRAY 5 // this is a define macro

int main() {
    int numbers[LENGTH_OF_ARRAY]; // initializes the array

    int i; // incrementing variable
    for (i = 0; i < LENGTH_OF_ARRAY; i++) {
        numbers[i] = i;
    }

    return 0;
}
```

但是老师或者书本里应该会告诉我们，尽量不要使用宏。复杂的宏定义会降低代码的可读性，而且容易写出意想不到的 bug，举个例子：

``` c
#define TEN 5 + 5

int main() {
    printf("%d", 5 * TEN);

    return 0;
}
```

只有能驾驭好它的程序员才能随心使用它。
C 语言的宏不仅是简单的字符串替换，它还支持参数:

``` c
#define ADD(X, Y) (X + Y)

int add(int a, int b) {
    return ADD(a, b);
}
// translate to
int add(int a, int b) {
    return (a + b);
}
```

## Rust declarative macros

Rust 宏相对 C 来说要复杂很多，自然也强大很多。我们最先接触到的宏应该是 `println!` . 它的定义是这样的:

``` rust
macro_rules! println {
    () => ($crate::print!("\n"));
    ($($arg:tt)*) => ({
        $crate::io::_print($crate::format_args_nl!($($arg)*));
    })
}
```

很难看懂对不对？
`macro_rules!` 相当于 `#define` , 用来标记这是一段宏定义， `println` 是宏的名称，括号里的内容是 `println` 这个宏具体的定义。

`()` 在我们忘记写函数的返回语句的时候会看到的提示:

``` 

 --> println.rs:3:5
  |
2 | fn return() -> i32 {
  |                --- expected `i32` because of return type
3 |     ()
  |     ^^ expected `i32`, found `()`

```

我们可以把 `()` 简单看做是 empty。
那么下面这段代码就比较容易理解了

``` rust
() => ($crate::print!("\n"))
```

我们使用 `println!` 宏的时候不写参数，就会匹配到这条语句，这条语句只会打印换行。
所以 `=>` 之前的 `()` 内的内容就是匹配模式，称为 `Matcher` , `=>` 之后的内容就是匹配到入参之后，待展开的逻辑，称为 `Transcriber` , 编译器利用入参和 `Transcriber` 来生成展开后的 Rust 代码。

<img src="https://songtianyi-blog.oss-cn-shenzhen.aliyuncs.com/matcher-transcriber.png" alt="matcher-transcriber" style="width:800px; height:500px"/>

`Matcher` 里的内容又可以分为两部分，name 和 designator:

<img src="https://songtianyi-blog.oss-cn-shenzhen.aliyuncs.com/matcher.png" alt="matcher-transcriber" style="width:800px; height:500px"/>

name 相当于变量名，用 `$` 符号标记，designator 可以理解为是预定义的正则表达式, 书写的时候直接用简写名称代替，有以下几种:

* item: an item, such as a function, a struct, a module, etc.
* block: a block (i.e. a block of statements and/or an expression, surrounded by braces)
* stmt: a statement
* pat: a pattern
* expr: an expression
* ty: a type
* ident: an identifier
* path: a path (e.g. foo, ::std::mem::replace, transmute::<_, int>, ...)
* meta: a meta item; the things that go inside #[...] and #![...] attributes
* tt: a single token tree

以 `map!` 宏为例来看下 HashMap 的初始化方式， 如下:

``` rust
use std::collections::HashMap;
macro_rules! map {
    ($($key:expr => $value:expr), *) => {
        {
            let mut hm = HashMap::new();
            $( hm.insert($key, $value); )*
            hm
		}
    }
}

fn main() {
	println!("{:#?}", map!(
	    "a" => "b",
	    "c" => "d"
	));
}
```

它所使用的 `Matcher` 是 `$($key:expr => $value:expr), *)` , 看起来有些复杂

`=>` 不能被替换成其他符号，如 `:` , `->` 等, 没有特殊意义，就是用来匹配文本中的 `=>` 符号, `$key:expr => $value:expr` 可以看待为 `expr => expr` , 相当于正则。之后，将这个正则包裹起来，加上 `*` 来表示这个正则可以被匹配多次，相当于 `(expr => expr)*`

<img src="https://songtianyi-blog.oss-cn-shenzhen.aliyuncs.com/repeat.png" alt="matcher-transcriber" style="width:800px; height:500px"/>

下面是一个更复杂的实际案例，用来简化 Field 的取值方法的编写:

``` rust
pub enum Field {
    tinyInt(i8),
    smallInt(i16),
    normalInt(i32),
    bigInt(i64),
    float(f32),
    double(f64),
    string(String),
    boolType(bool),
}

macro_rules! impl_as_fields {
    ($fn:ident, $pattern:pat => $v:expr, $type:ty) => {
        pub fn $fn(&self) -> $type {
            match *self {
                $pattern => $v,
                _ => {
                    println!("unexpected $type value {}", self);
                    Default::default()
                }
            }
        }
    };
}

impl Field {
    impl_as_fields!(as_i8, Field::tinyInt(v) => v, i8);
    impl_as_fields!(as_i16, Field::smallInt(v) => v, i16);
    impl_as_fields!(as_i32, Field::normalInt(v) => v, i32);
    impl_as_fields!(as_i64, Field::bigInt(v) => v, i64);
    impl_as_fields!(as_f32, Field::float(v) => v, f32);
    impl_as_fields!(as_f64, Field::double(v) => v, f64);
    impl_as_fields!(as_bool, Field::boolType(v) => v, bool);

    pub fn as_string(&self) -> String {
        match &*self {
            Field::string(v) => v.to_string(),
            _ => {
                println!("unexpected string value {}", self);
                "".to_string()
            }
        }
    }
}
```

上述的宏 `impl_as_fields` 会根据入参数展开成返回不同类型的函数定义(类似 as_string), 用到了多个 designator.

## Rust procedural macros

上一节所讲的 rust macro 属于 `declarative macro` , rust 还有一类宏, 叫 `procedural macro` .

#### #[derive]

一种是我们经常见到的 `derive` 属性, 需要打印一个结构体而又不想自己实现的时候，可以在结构体上运用 `#[derive(Debug)]` 来帮我们实现 `Debug` Trait.

``` rust
#[derive(Debug)]
struct Student {
    name: String,
    age: i32,
}

impl Student {
    fn new() -> Self {
        return Self {
            name: "".to_string(),
            age: -1,
        };
    }
}

fn main() {
    println!("{:?}", Student::new());
}
```

如果去除 `derive(Debug)` 则会遇到以下常见编译错误:

> --> derive.rs:17:22
>
> |
>
> 17 |     println!("{:?}", Student::new()); 
>
> |                      ^^^^^^^^^^^^^^ `Student` cannot be formatted using `{:?}`

>
> |
>
> = help: the trait `Debug` is not implemented for `Student`

>
> = note: add `#[derive(Debug)]` or manually implement `Debug`

>
> = note: required by `std::fmt::Debug::fmt`

>

`derive(Debug)` '神奇地'帮我们实现了一个自定义结构体的 `Debug` trait. 这实际上是编译器在编译的时候帮我们生成了实现代码，而不是在运行时，rust 是不支持反射的。

我们可以自己实现一个 `derive` 宏.

``` shell
# 创建一个 status crate
cargo new status  --lib
```

在 `status/src/lib.rs` 里定义 `Status` trait, 其功能为打印结构体的状态。

``` rust
pub trait Status {
    /// Return the status of `self`
    fn status(&self) -> String;
}
```

接着实现 `Status` macro.

``` shell
# 创建一个 status_derive crate
cargo new status_derive  --lib
```

> `declarative macro` 类似于字符串替换，只不过加了匹配规则和变量，让我们可以写更复杂的逻辑，而 `procedural macro` 提供了源码的 token 输入，即 `TokenStream` , 并提供了语法树工具，让我们有能力直接处理源码。

``` rust
// status_derive/src/lib.rs
use proc_macro2::TokenStream;
use quote::{quote, quote_spanned};
use syn::spanned::Spanned;
use syn::{parse_macro_input, parse_quote, Data, DeriveInput, Fields, GenericParam, Generics, Index};

#[proc_macro_derive(Status)]
pub fn derive_status(input: proc_macro::TokenStream) -> proc_macro::TokenStream {
    // 暂时留空
}
```

修改 `status/Cargo.toml` , 添加 status_derive crate 依赖.

``` toml
[dependencies]
status_derive = { path = "../status_derive" }
```

创建一个测试程序

``` shell
cargo new status_derive_test  --bin
```

并添加依赖:

``` toml
[dependencies]
status = { path = "../status" }
```

``` rust
// status_derive_test/src/lib.rs
use status::Status;

#[derive(Status)]
struct Student {
    name: String,
    age: i32,
    status: String,
}

impl Student {
    fn new() -> Self {
        return Self {
            name: "".to_string(),
            age: -1,
            status: "OK",
        };
    }
}

fn main() {
    println!("{:?}", Student::new().status());
}
```

目前代码还未完成，编译会失败，我们从目标出发，将 `derive_status` 函数填充完整。
我们的目标是生成一个函数， 如下:

``` rust
impl Status for Student {
    fn status(&self) -> String {
        format!("{}'s status is {}", self.name, self.status)
    }
}
```

先考虑的简单点，直接用 `quote!` 将字符串转成 `TokenStram` 返回

``` rust
let c = quote!(
    impl Status for Student {
        fn status(&self) -> String {
            format!("{}'s status is {}", self.name, self.status)
        }
    }
)
proc_macro::TokenStream::from(c)
```

这样是能成功的，但是不够通用，Student 被 hardcode 了，换个结构体名字就不适用了。这个时候要利用 `inupt` 参数:

``` rust
// 将输入做些处理以便使用
let input = parse_macro_input!(input as DeriveInput);
// 将结构体的名称取出来, 在 quote! 中以变量的形式引用
let name = input.ident;
let c = quote!(
    impl Status for #name {
        fn status(&self) -> String {
            format!("{}'s status is {}", self.name, self.status)
        }
    }
)
proc_macro::TokenStream::from(c)
```

如此，我们完成了一个名为 `Status` 的 `derive` macro, 可以运用在任意带有 `status` 字段的结构体上。

> input 的结构应该可以打印出来, 但我还没找到打印方法。知晓结构之后我们就能完成更复杂的代码生成逻辑

#### Attribute-like macros

和 `derive` macro 是类似的，可以理解为是将 `derive` 换成了更一般的名字， `derive` macro 是 `attribute-like macro` 的一种特例。
`derive` macro 只能用于 `struct` 和 `enum` , 而 `attribute-like macro` 可以运用在其它的对象上，比如函数。如果你用过 rust 的 web 框架，可能会见到下面的代码片段:

``` rust
#[route(GET, "/")]
fn index() {
}
```

`route` 宏的实现和 `derive` 有些区别:

``` rust
#[proc_macro_attribute]
pub fn route(attr: TokenStream, item: TokenStream) -> TokenStream {
}
```

* 使用的 `attribute` 是 `proc_macro_attribute`
* 它接受两个参数，`attr` 是 `GET, "/"` 这部分，`item` 存的是对应的函数，即:

``` rust
fn index() {}
```

其余的部分和 `derive` macro 的实现是一致的。

#### Function-like macros

顾名思义， `Function-like` macro 在使用上比较像函数，或者说像 `declarative` macro, 但相对函数和 `macro_rules!` 来说， `Function-like` macro 更加灵活，参数可以不固定。比较典型的例子是 `sql!` .

``` rust
let sql = sql!(SELECT * FROM posts WHERE id=1);
```

它的实现方式和前两种 `procedural` macro 是类似的:

``` rust
#[proc_macro]
pub fn sql(input: TokenStream) -> TokenStream {
}
```

## 参考资料

* [Macros](https://doc.rust-lang.org/book/ch19-06-macros.html)
* [HeapSize derive example](https://github.com/dtolnay/syn/tree/master/examples/heapsize)

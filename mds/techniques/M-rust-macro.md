# Rust 宏

## 前言
18年系统学习编程语言理论的时候，快速学过 Rust，两年过去了还没实际使用过它做开发，最近在使用 TDengine 的时候，发现 TDengine 的 Go binding 没有实现订阅的接口，C++ 又没多大兴趣，于是在前人的基础上把 TDengine 的 Rust binding 写了一遍，然后使用 Rust 写了 业务逻辑的 API 接口。在做错误处理的时候，认识到了 Rust 宏的强大，所以想着重新学下 Rust 宏，做个笔记。

## C Macro
宏的概念我们在刚学计算的时候就接触过，C 语言里的 `#define xxx` 就是宏。

```c
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
```c
#define TEN 5 + 5

int main() {
    printf("%d", 5 * TEN);

    return 0;
}
```
只有能驾驭好它的程序员才能随心使用它。
C 语言的宏不仅是简单的字符串替换，它还支持参数:
```c
#define ADD(X, Y) (X + Y)

int add(int a, int b) {
    return ADD(a, b);
}
// translate to
int add(int a, int b) {
    return (a + b);
}
```

## Rust macro
Rust 宏相对 C 来说要复杂很多。我们最先接触到的宏应该是 `println!`. 它的定义是这样的:
``` rust
macro_rules! println {
    () => { ... };
    ($($arg:tt)*) => { ... };
}
```
很难看懂对不对？
`macro_rules!` 相当于 `#define`, `println` 是宏的名称，用来做标记并最终被编译器展开。括号里的内容是 `println` 宏具体的定义。

`()` 在我们忘记写函数的返回语句的时候会看到的提示。
```
 --> println.rs:3:5
  |
2 | fn return() -> i32 {
  |                --- expected `i32` because of return type
3 |     ()
  |     ^^ expected `i32`, found `()`

```




# 关于 Rust GC 的争议

作者: [songtianyi](http://songtianyi.info)

### 前言

在[1 小时入门 Rust](getting-started-with-rust-in-1-hour.html)的文中，有一处说到，Rust 没有 GC，但有人对此有异议，所以单独写一篇文章来说明。在写文章的时候，做了些搜索，国外也有人持同样的观点。

### 什么是 GC

GC，全称 Garbage Collection，指的是内存自动化管理这种行为 <sup>[1]</sup>。GC, 也是 Garbage Collector 的缩写，是完成 Garbage Collection 这种行为的代码逻辑。

### 结论

先抛出结论，Rust 是没有 GC 的，不管是中文博客还是国外的 stackoverflow<sup>[3]</sup>基本都是这么认为的，而且在 Rust 的官方文档的 FAQ 里已经作了说明 <sup>[2]</sup>。引用如下:

> Is Rust garbage collected?
> No. One of Rust’s key innovations is guaranteeing memory safety (no segfaults) without requiring garbage collection.
>
> By avoiding GC, Rust can offer numerous benefits: predictable cleanup of resources, lower overhead for memory management, and essentially no runtime system. All of these traits make Rust lean and easy to embed into arbitrary contexts, and make it much easier to integrate Rust code with languages that have a GC.
>
> Rust avoids the need for GC through its system of ownership and borrowing, but that same system helps with a host of other problems, including resource management in general and concurrency.
>
> For when single ownership does not suffice, Rust programs rely on the standard reference-counting smart pointer type, Rc, and its thread-safe counterpart, Arc, instead of GC.
>
> We are however investigating optional garbage collection as a future extension. The goal is to enable smooth integration with garbage-collected runtimes, such as those offered by the Spidermonkey and V8 JavaScript engines. Finally, some people have investigated implementing pure Rust garbage collectors without compiler support.
>

### 论点

有异议的人应该是这么认为的:

##### 观点一

> Rust 的编译器会在变量超出作用域或者生命周期结束时，插入释放内存的代码，按照 GC 的定义，这种依靠编译器自动释放内存的行为属于 GC

按照 GC 字面的意思这么理解是说的过去的，但 GC 作为惯用语，通常并不单单指释放内存的行为，如果这么理解的话，那么 C 语言分配在栈上的变量，在超出作用域被自动释放的这种行为是否也能称为 GC 呢？不能，这点大家应该没有异议。因此，这种解释并不能说明 Rust 是有 GC 的。

##### 观点二

> Rust 有 reference counting，因此有 GC

在 wikipedia 的 GC 定义中，引用计数确实属于 GC 技术的一种 <sup>[4]</sup>，而且是三大主流 GC 技术之一。但官方并不认为拥有 reference counting 就等于拥有 GC，Rust 的引用计数只是应用在了智能指针上，编码的时候我们仍然需要认真考虑变量的生命周期，这种强制的方式并不 automatic，**只是换了一种更安全的方式让我们手动管理内存而已**。相比之下，Go 和 Java 这类真正拥有 GC 的语言，是完全不会以任何形式让我们去关心内存的释放的。

### 参考资料

1. [Garbage Collection](https://en.wikipedia.org/wiki/Garbage_collection_(computer_science))
2. [is-rust-garbage-collected](https://prev.rust-lang.org/en-US/faq.html#is-rust-garbage-collected)
3. [what-does-rust-have-instead-of-a-garbage-collector](https://stackoverflow.com/questions/32677420/what-does-rust-have-instead-of-a-garbage-collector)
4. [Reference counting](https://en.wikipedia.org/wiki/Garbage_collection_(computer_science)#Reference_counting)

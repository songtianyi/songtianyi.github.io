

# 关于Rust GC的争议

### 前言

在[1小时入门Rust](getting-started-with-rust-in-1-hour)的文中，有一处说到，Rust没有GC，但有人对此有异议，所以单独写一篇文章来说明。在写文章的时候，做了些搜索，国外也有人持同样的观点<sub>5</sub>。

### 什么是GC

GC，全称Garbage Collection，指的是内存自动化管理这种行为<sub>1</sub>。GC, 也是Garbage Collector的缩写，是完成Garbage Collection这种行为的代码逻辑。

### 结论

先抛出结论，Rust是没有GC的，不管是中文还是国外的stackoverflow<sub>3</sub>基本都是这么认为的，而且在Rust的官方文档的FAQ里已经作了说明<sub>2</sub>。引用如下:

> ### [Is Rust garbage collected?](https://www.rust-lang.org/en-US/faq.html#is-rust-garbage-collected)
>
> No. One of Rust’s key innovations is guaranteeing memory safety (no segfaults) *without* requiring garbage collection.
>
> By avoiding GC, Rust can offer numerous benefits: predictable cleanup of resources, lower overhead for memory management, and essentially no runtime system. All of these traits make Rust lean and easy to embed into arbitrary contexts, and make it much easier to [integrate Rust code with languages that have a GC](http://calculist.org/blog/2015/12/23/neon-node-rust/).
>
> Rust avoids the need for GC through its system of ownership and borrowing, but that same system helps with a host of other problems, including [resource management in general](http://blog.skylight.io/rust-means-never-having-to-close-a-socket/) and [concurrency](http://blog.rust-lang.org/2015/04/10/Fearless-Concurrency.html).
>
> For when single ownership does not suffice, Rust programs rely on the standard reference-counting smart pointer type, [`Rc`](https://doc.rust-lang.org/std/rc/struct.Rc.html), and its thread-safe counterpart, [`Arc`](https://doc.rust-lang.org/std/sync/struct.Arc.html), instead of GC.
>
> We are however investigating *optional* garbage collection as a future extension. The goal is to enable smooth integration with garbage-collected runtimes, such as those offered by the [Spidermonkey](https://developer.mozilla.org/en-US/docs/Mozilla/Projects/SpiderMonkey) and [V8](https://developers.google.com/v8/?hl=en) JavaScript engines. Finally, some people have investigated implementing [pure Rust garbage collectors](https://manishearth.github.io/blog/2015/09/01/designing-a-gc-in-rust/) without compiler support.

### 论点

有异议的人应该是这么认为的:

##### 观点一

> Rust的编译器会在变量超出作用域或者生命周期结束时，插入释放内存的代码，按照GC的定义，这种依靠编译器自动释放内存的行为属于GC

按照GC字面的意思这么理解是说的过去的，但GC作为惯用语，通常并不单单指释放内存的行为，如果这么理解的话，那么C语言分配在栈上的变量，在超出作用域被自动释放的这种行为是否也能称为GC呢？不能，这点大家应该没有异议。因此，这种解释并不能说明Rust是有GC的。

##### 观点二

> Rust有reference counting，因此有GC

在wikipedia的GC定义中，引用计数确实属于GC技术的一种<sub>4</sub>，但官方并不认为拥有reference counting就等于拥有GC，而且Rust的引用计数只是应用在了智能指针上，编码的时候我们仍然需要认真考虑变量的生命周期，这种强制的方式并不atomatic，**只是换了一种更安全的方式让我们手动管理内存而已**。相比之一，Go和Java这类真正拥有GC的语言，是完全不会以任何形式让我们去关心内存的释放的。

### 参考资料

1. [Garbage Collection](https://en.wikipedia.org/wiki/Garbage_collection_(computer_science))
2. [is-rust-garbage-collected](https://www.rust-lang.org/en-US/faq.html#is-rust-garbage-collected)
3. [what-does-rust-have-instead-of-a-garbage-collector](https://stackoverflow.com/questions/32677420/what-does-rust-have-instead-of-a-garbage-collector)
4. [Reference counting](https://en.wikipedia.org/wiki/Garbage_collection_(computer_science)#Reference_counting)
5. [Rust or Swift for system programming?](https://news.ycombinator.com/item?id=12032638)


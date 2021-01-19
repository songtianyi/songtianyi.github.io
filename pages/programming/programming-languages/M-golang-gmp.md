# Golang GMP 核心思想简介

## 背景

本篇文章是为了呼应 [编程核心概念](http://songtianyi.info/pages/programming/software-engineering/M-core-concepts-in-programming.html) 这篇文章而写，检验这些概念在技术实现里的应用，既是学习新知识，也是对旧知识的巩固。所以，在阅读本文之前，需要先阅读之前的 [编程核心概念](http://songtianyi.info/pages/programming/software-engineering/M-core-concepts-in-programming.html) 一文。

## 多线程和线程池

CPU 是比其他硬件快得多的资源，我们不希望在进行 io 操作的时候，CPU 还被占着。通过时间分片，多线程技术，我们可以将 CPU 调度到其他线程上，这个过程是由操作系统内核完成的。

![image](https://songtianyi-blog.oss-cn-shenzhen.aliyuncs.com/multi-thread.png)

每个线程只做一件事情，需要的时候新建，完成之后销毁。但线程的创建和销毁都是比较耗资源的，包括 CPU 和内存，难以满足高并发的需求，在 `编程核心概念` 一文中介绍道，对于这种场景我们可以考虑复用。

因此，我们在程序启动的时候，可以创建大量的线程，形成线程池，当有任务的时候，选择空闲的线程来执行任务。这个选择的过程称为调度。

问题是，怎么调度是比较好的呢？这对于普通开发者来说太难了，而 Golang GMP 帮我们解决了这个问题，开发者只管开 Goroutine 就行了，线程的调度交给 golang runtime.

![image](https://songtianyi-blog.oss-cn-shenzhen.aliyuncs.com/GMP-G-and-M.png)

概念回顾:

* time-sharing and asynchronous
* reusing
* io

## GMP

那么 G(Goroutine)M(Thread)P(Processor) 是如何调度的呢？
在高并发的场景，G 是 远大于 M 的，如果你看过[编程核心概念](http://songtianyi.info/pages/programming/software-engineering/M-core-concepts-in-programming.html)中的 `cache and buffer` 这一小节，应该很容易想到，这种情况可以使用 buffer，因为这里存在性能差距，生产者生产的速度远大于消费者的消费速度。

![image](https://songtianyi-blog.oss-cn-shenzhen.aliyuncs.com/GMP-G-global-queue.png)

如图，我们可以把 Goroutine 放入一个全局队列，然后 M 去获取并执行这些 Goroutine，但是，因为局部性原理，我们应该尽量保证连续的 G 在同一个 M 上执行。
所以，Go 抛弃了这种做法，引入了 Processor 的概念，P 和 M 绑定，每个 Processor 有自己的本地队列，还包括运行 G 所需要的资源，而这些资源是可以被重复利用的。当 P 的本地队列都满的时候，G 会被放入全局队列，对应的，当 P 的本地的队列的 G 都被执行完之后，P 会从全局队列拿 G，甚至会从其它 P 的本地队列去拿 G.

![image](https://songtianyi-blog.oss-cn-shenzhen.aliyuncs.com/GMP-with-P.png)

概念回顾:

* cache and buffer

至此，GMP 的核心思想已经讲完了，是不是比想象中的简单？ 剩下的细枝末节大家可以阅读参考资料，本文不再赘述。

## 参考资料

* [Golang 调度器 GMP 原理与调度全分析](https://learnku.com/articles/41728)

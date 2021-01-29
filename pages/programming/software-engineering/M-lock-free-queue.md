# 无锁队列

作者: [songtianyi](http://songtianyi.info) create@2021-01-28

## 前言

这篇文章源于一个实际案例，文件的并发读写，比如如何提高日志文件的并发写效率。在这种有性能差的场景里，我们可以使用内存 buffer （队列)来做写入缓冲，先将内容写到内存，再将内存整个刷到磁盘。
那么队列的并发写入，自然需要加锁，问题是如何做到无锁？

## CAS

CAS 全称 compare and swap, 它是一个原子操作, 伪代码如下:

``` c
function cas(p: pointer to int, old: int, new: int) is
    if *p ≠ old
        return false

    *p ← new

    return true
```

大致意思是，当我们要修改一个值当时候（将 old 修改为 new）先检查它的值是否等于 old, 如果相等就赋值为 new, 否则返回 false, 因为不相等说明该值已经被（其它线程）修改，这个时候就不能再贸然修改它。
CAS 是一个原子操作，CPU 只使用一条指令来表达和执行它，因此 CAS 是 lock free 的, 不需要加锁。

基于 CAS 我们可以实现无锁的并发写逻辑。

先看一个 Go 没有加锁的例子, 如下:

``` go
package main

import (
	"fmt"
	"sync"
)

func main() {
	i := 0
	wg := sync.WaitGroup{}
	wg.Add(10)
	for j := 0; j < 10; j++ {
		go func() {
			i++
			wg.Done()
		}()
	}
	wg.Wait()
	fmt.Println(i)
}
```

并发修改 i, 多次执行的结果是不一致的，如下:

``` 

songtianyi-mb$ go run concurrency.go
10
songtianyi-mb$ go run concurrency.go
9
songtianyi-mb$ go run concurrency.go
10
songtianyi-mb$ go run concurrency.go
10
songtianyi-mb$ go run concurrency.go
10
songtianyi-mb$ go run concurrency.go
10
songtianyi-mb$ go run concurrency.go
9
songtianyi-mb$ go run concurrency.go
10
```

加上基于 CAS 的 atomic 再试试:

``` go
package main

import (
	"fmt"
	"sync"
	"sync/atomic"
)

func main() {
	i := uint32(0)
	wg := sync.WaitGroup{}
	wg.Add(10)
	for j := 0; j < 10; j++ {
		go func() {
			atomic.AddUint32(&i, 1)
			wg.Done()
		}()
	}
	wg.Wait()
	fmt.Println(i)
}
```

执行多次结果是稳定且正确的。

## kfifo

linux kernel 里就有队列的实现 kfifo, 不过使用的是自旋锁(spinlock). 感兴趣的可以读一读[源码](https://elixir.bootlin.com/linux/v2.6.24.4/source/kernel/kfifo.c#L165)

#### spinlock

自旋锁特点是，当线程试图获得锁但没拿到的时候，线程会忙等(一直循环执行一段 test-and-set 的原子逻辑)，不会释放 CPU。所以，使用自旋锁的前提是，等待锁的时间足够短，否则会空耗 CPU，它的优点是不会休眠和唤醒的过程，避免了上下文切换的开销。

## lock-free queue

先用 C 实现一个简单的队列，

``` 

``` C
/* C */
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>

struct Queue {
  char *buf;
  int size;
  int out;
  int in;
};

struct Queue *newQ(int size) {
  struct Queue *q = malloc(sizeof(struct Queue));
  q->size = size;
  q->buf = malloc(sizeof(char) * size);
  q->out = q->in = 0;
  return q;
}

void enQ(struct Queue *q, char v) {
  q->buf[q->in % q->size] = v;
  q->in++;
}

char deQ(struct Queue *q) {
  char x = q->buf[q->out % q->size];
  q->out++;
  return x;
}

bool emptyQ(struct Queue *q) {
  if (q->out == q->in) {
    q->out = q->in = 0;
    return true;
  }
  return false;
}

void freeQ(struct Queue *q) {
  free(q->buf);
  free(q);
}

int main() {
  struct Queue *q = newQ(3);
  enQ(q, 'c');
  enQ(q, 'b');
  enQ(q, 'a');
  printf("%c\n", deQ(q));
  printf("%c\n", deQ(q));
  printf("%c\n", deQ(q));
  enQ(q, 'a');
  enQ(q, 'b');
  enQ(q, 'c');
  printf("%c\n", deQ(q));
  printf("%c\n", deQ(q));
  printf("%c\n", deQ(q));
  freeQ(q);
  return 0;
}
```

当并发入队出队的时候必然会有问题，我们尝试使用 CAS 来对修改的操作加锁

``` c
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>

struct Queue {
  char *buf;
  int size;
  int out;
  int in;
};

bool CAS(int *addr, int oldval, int newval) {
  if (*addr != oldval) {
    return false;
  }
  *addr = newval;
  return true;
}

struct Queue *newQ(int size) {
  struct Queue *q = malloc(sizeof(struct Queue));
  q->size = size;
  q->buf = malloc(sizeof(char) * size);
  q->out = q->in = 0;
  return q;
}

void enQ(struct Queue *q, char v) {
  int i;
  do {
    i = q->in;
    q->buf[i % q->size] = v;
  } while (__sync_bool_compare_and_swap(&q->in, i, i + 1) == false);
}

char deQ(struct Queue *q) {
  char x;
  int i;
  do {
    x = q->buf[q->out % q->size];
    i = q->out;
  } while (__sync_bool_compare_and_swap(&q->out, i, i + 1) == false);
  return x;
}

bool emptyQ(struct Queue *q) {
  if (q->out == q->in) {
    q->out = q->in = 0;
    return true;
  }
  return false;
}

void freeQ(struct Queue *q) {
  free(q->buf);
  free(q);
}

int main() {
  struct Queue *q = newQ(3);
  enQ(q, 'c');
  enQ(q, 'b');
  enQ(q, 'a');
  printf("%c\n", deQ(q));
  printf("%c\n", deQ(q));
  printf("%c\n", deQ(q));
  enQ(q, 'a');
  enQ(q, 'b');
  enQ(q, 'c');
  printf("%c\n", deQ(q));
  printf("%c\n", deQ(q));
  printf("%c\n", deQ(q));
  freeQ(q);
  return 0;
}
```

上述代码并没有严格测试和论证，只为了说明无锁队列的大致实现思路，感兴趣的可以阅读参考资料。

## 参考资料

* [atomic operation of Go language](https://www.fatalerrors.org/a/atomic-operation-of-go-language.html)
* [无锁队列的实现](https://coolshell.cn/articles/8239.html)

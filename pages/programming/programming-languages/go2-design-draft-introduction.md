# go2设计草案介绍

作者: [songtianyi](http://songtianyi.info) 2018-08-29

### 前言

Go，毫无疑问已经成为主流服务端开发语言之一，但它的类型特性却少的可怜，仅支持[structural subtyping](mds/techinques/how-to-choose-your-programming-language.md)。在TIOBE排名前二十的语言中，不管是上古语言Java, 还是2010年之后出现的新语言Rust/Julia等，都支持至少三种类型特性，对此社区抱怨很多，另外还有它的错误处理方式，以及在Go1.11版本才解决的依赖管理等问题。在最近的GopherCon2018上，官方放出了解决这些问题的草案(draft)，这些内容还没有成为正式的提案(proposal), 只是先发出来供大家讨论，最终会形成正式提案并被逐步引入到后续的版本中。此次放出的草案，集中讨论了三个问题，泛型/错误处理/错误值。

### 泛型

泛型是复用逻辑的一个有效手段，在2016和2017年的Go语言调查中，泛型都列在最迫切的需求之首，在Go1.0 release之后Go team就已经开始探索如何引入泛型，但同时要保持Go的简洁性(开发者喜爱Go的主要原因之一)，之前的几种实现方式都存在严重的问题，被废弃掉了，所以进展并不算快，导致部分人误解为Go team并不打算引入泛型。现在，最新的草案经过半年的讨论和优化已经确认可行(could work)，我们期待已久的泛型几乎是板上钉钉的事情了，那么Go的泛型大概长什么样？

在没有泛型的情况下，通过`interface{}`是可以解决部分问题的，比如[`ring`](https://golang.org/src/container/ring/ring.go)的实现，但这种方法只适合用在数据容器里, 且需要做类型转换。当我们需要实现一个通用函数时，就做不到了，例如实现一个函数，其返回传入的map的key:

```go
package main

import "fmt"

func Keys(m map[interface{}]interface{}) []interface{} {
	keys := make([]interface{}, 0)
	for k, _ := range m {
		keys = append(keys, k)
	}
	return keys
}

func main() {
	m := make(map[string]string, 1)
	m["demo"] = "data"
	fmt.Println(Keys(m))
}
```

 这样写连编译都通过不了，因为类型不匹配。那么参考其他支持泛型的语言的语法，可以这样写:

```go
package main

import "fmt"

func Keys<K, V>(m map[K]V) []K {
	keys := make([]K, 0)
	for k, _ := range m {
		keys = append(keys, k)
	}
	return keys
}

func main() {
	m := make(map[string]string, 1)
	m["demo"] = "data"
	fmt.Println(Keys(m))
}
```

但是这种写法是有缺陷的，假设append函数并不支持string类型，就可能会出现编译错误。我们可以看下其他语言的做法:

```rust
// rust
fn print_g<T: Graph>(g : T) {
    println!("graph area {}", g.area());
}
```

Rust在声明T的时候，限定了入参的类型，即入参 *g* 必须是实现了Graph的类型。和[Rust](mds/techniques/getting-started-with-rust-in-1-hour.md)的nominal subtyping不同，Go属于structural subtyping，没有显式的类型关系声明，因此不能使用此种方式。Go在草案中引入了`contract`来解决这个问题，语法类似于函数, 写法更复杂，但拥有和Rust trait相媲美的表达能力:

```go
// comparable contract
contract Equal(t T) {
	t == t
}
// addable contract
contract Addable(t T) {
	t + t
}
// 约束类型T必须拥有函数 func String() string
contract stringer(x T) {
	var s string = x.String()
}
```

上述代码分别约束了T必须是可比较的(comparable)，必须是能做加法运算(addable)的。使用方式很简单, 定义函数的时候加上`contract`即可:

```go
func Sum(type T Addable(T))(x []T) T {
	var total T
	for _, v := range x {
		total += v
	}
	return total
}

var x []int
total := Sum(int)(x)
```

上述代码约束了入参 *x* 的类型T必须是可以做加法运算的类型。

> 可能大家会有跟我一样的疑问，为什么是(type T Addable) , 而不是 \<T>, 为什么不用惯用的尖括号？
>
> 官方给出的解释是 [*keep the Go parser simple*](https://go.googlesource.com/proposal/+/master/design/go2draft-contracts.md#why-not-use-like-c_and-java)

得益于类型推断，在调用Sum时可以简写成:

```go
total := Sum(x)
```

contract在使用时，如果参数是一一对应的(可推断), 也可以省略它的参数:

```go
// Addable(T) --> Addable
func Sum(type T Addable)(x []T) T {
	var total T
	for _, v := range x {
		total += v
	}
	return total
}
```

不可推断时就需要指明该contract是用来约束谁的:

```go
// Equal用来约束类型K，而不是类型V
func Keys(type K, V Equal(K))(m map[K]V) []K {
	...
}
```

当然，下面的写法也可以推断，最终的形式就看社区的反馈和Go team的抉择了:

```go
func Keys(type K Equal, V)(m map[K]V) []K {
	...
}
```

关于实现方面的内容，这里不再讨论，留给高手吧。官方开通了反馈渠道，可以去[提意见](https://github.com/golang/go/wiki/Go2GenericsFeedback)，对于我来说，唯一不满意的地方是显式的`type`关键字, 可能是为了方便和后边的函数参数相区分吧。

### 错误处理

健壮的程序需要大量的错误处理逻辑，在极端情况下，错误处理逻辑甚至比业务逻辑还要多，那么更简洁有效的错误处理语法是我们所追求的。

先看下目前Go的错误处理方式，一个拷贝文件的例子:

```go
func CopyFile(src, dst string) error {
	r, err := os.Open(src)
	if err != nil {
		return fmt.Errorf("copy %s %s: %v", src, dst, err)
	}
	defer r.Close()

	w, err := os.Create(dst)
	if err != nil {
		return fmt.Errorf("copy %s %s: %v", src, dst, err)
	}

	if _, err := io.Copy(w, r); err != nil {
		w.Close()
		os.Remove(dst)
		return fmt.Errorf("copy %s %s: %v", src, dst, err)
	}

	if err := w.Close(); err != nil {
		os.Remove(dst)
		return fmt.Errorf("copy %s %s: %v", src, dst, err)
	}
    return nil
}
```

上述代码中，错误处理的代码占了总代码量的近50%！

Go的`assignment-and-if-statement `错误处理语句是罪魁祸首，草案引入了`check`表达式来代替它:

```go
r := check os.Open(src)
```

但这只代替了赋值表达式和if语句，从之前的例子中我们可以看到，有四行完全相同的代码:

```go
return fmt.Errorf("copy %s %s: %v", src, dst, err)
```

它是可以被统一处理的, 于是Go在引入`check`的同时引入了`handle`语句，官方称之为handler:

```go
handle err {
	return fmt.Errorf("copy %s %s: %v", src, dst, err)
}
```

修改后的代码为:

```go
func CopyFile(src, dst string) error {
	handle err {
		return fmt.Errorf("copy %s %s: %v", src, dst, err)
	}

	r := check os.Open(src)
	defer r.Close()

	w := check os.Create(dst)
	handle err {
		w.Close()
		os.Remove(dst) // (only if a check fails)
	}

	check io.Copy(w, r)
	check w.Close()
	return nil
}
```

check失败后，error先被最里层的(inner most)handler处理，接着被上一个(按照语法顺序)handler处理，直到某个handler执行了`return`语句。

Go team对该草案的期望是能够减少错误处理的代码量, 且兼容之前的错误处理方式, 要求不算高，这个设计也算能接受吧。

[反馈渠道](https://golang.org/wiki/Go2ErrorHandlingFeedback)

### 错误值

Go的错误值目前存在两个问题。一，错误链(栈)没有被很好地表达；二，缺少更丰富的错误输出方式。在该草案之前，已经有不少第三方的package实现了这些功能，现在要进行标准化。目前，对于多调用层级的错误，我们使用fmt.Errorf或者自定义的Error来包裹它:

```go
package main

import (
	"fmt"
	"io"
)

type RpcError struct {
	Line uint
}

func (s *RpcError) Error() string {
	return fmt.Sprintf("(%d): no route to the remote address", s.Line)
}

func fn3() error {
	return io.EOF
}

func fn2() error {
	if err := fn3(); err != nil {
		return &RpcError{Line: 12}
	}
	return nil
}
func fn1() error {
	if err := fn2(); err != nil {
		return fmt.Errorf("call fn2 failed, %s", err)
	}
	return nil
}
func main() {
	if err := fn1(); err != nil {
		fmt.Println(err)
	}
}
```

此程序的输出为:

```
call fn2 failed, (12): no route to the remote address
```

很明显的问题是，我们在main函数里对error进行处理的时候不能进行类型判断, 比如使用if语句判断:

```go
if err == io.EOF { ... }
```

或者进行类型断言:

```go
if pe, ok := err.(*os.PathError); ok { ... pe.Path ... }
```

它是一个RpcError还是io.EOF? 无从知晓。一大串的错误信息，人类可以很好地理解，但对于程序代码来说就很困难。

##### error inspection

草案引入了一个error wrapper来包裹错误链, 它相当于一个指针，将错误栈链接起来:

```go
package errors

// A Wrapper is an error implementation
// wrapping context around another error.
type Wrapper interface {
	// Unwrap returns the next error in the error chain.
	// If there is no next error, Unwrap returns nil.
	Unwrap() error
}
```

每个层级的error都实现这个wrapper，这样在main函数里，我们可以通过err.Unwrap() 来获取下一个层级的error。另外，草案引入了两个函数来简化这个过程:

```go
// Is reports whether err or any of the errors in its chain is equal to target.
func Is(err, target error) bool

// As checks whether err or any of the errors in its chain is a value of type E.
// If so, it returns the discovered value of type E, with ok set to true.
// If not, it returns the zero value of type E, with ok set to false.
func As(type E)(err error) (e E, ok bool)
```

##### error formatting

有时候我们需要将错误信息分类，因为某些情况下你需要所有的信息，某些情况下只需要部分信息，因此草案引入了一个interface:

```go
package errors

type Formatter interface {
	Format(p Printer) (next error)
}
```

error类型可以实现Format函数来打印更详细的信息:

```go
func (e *WriteError) Format(p errors.Printer) (next error) {
	p.Printf("write %s database", e.Database)
	if p.Detail() {
		p.Printf("more detail here")
	}
	return e.Err
}

func (e *WriteError) Error() string { return fmt.Sprint(e) }
```

在你使用`fmt.Println("%+v", err)`打印错误信息时，它会调用Format函数。

[反馈渠道](https://github.com/golang/go/wiki/Go2ErrorValuesFeedback)

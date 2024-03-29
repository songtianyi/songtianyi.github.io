# Go2 泛型设计草案更新

作者: [songtianyi](http://songtianyi.info) create@2020/12/03

### 前言

18 年的时候，go team 发布了 Go2 的几个新特性的草案，其中包括呼声较高的泛型，当时[写了一篇文章做了介绍](http://songtianyi.info/pages/programming/languages/go2-design-draft-introduction.html)。最近 Go team 对泛型的设计草案进行了较大的改动，有必要更新下这个改动并分享出来。

### contracts

在 18 年释出的草案中，是使用 `contract` 来约束泛型的类型参数(type parameters)的，最新的草案放弃了这种做法, 用已有的概念 `interface` 代替。
在继续之前，先来熟悉 `type parameter` 这个概念:

> Generic code is code that is written using types that will be specified later. Each unspecified type is called a type parameter.
> When running the generic code, the type parameter will be set to a type argument.

好，继续。回顾下 `contract` 形式的例子:

```go
contract stringer(T) {
	T String() string
}

func Stringify(type T stringer)(s []T) (ret []string) {
	for _, v := range s {
		ret = append(ret, v.String()) // now valid
	}
	return ret
}

strSlice = []string{}

```

上述代码约束了入参 s 的类型 T 必须是实现了 String 函数的类型

### interface

那么改用 interface 之后怎么做？

```go
// Stringer is a type constraint that requires the type argument to have
// a String method and permits the generic function to call String.
// The String method should return a string representation of the value.
type Stringer interface {
	String() string
}

// Stringify calls the String method on each element of s,
// and returns the results.
func Stringify[T Stringer](s []T) (ret []string) {
	for _, v := range s {
		ret = append(ret, v.String())
	}
	return ret
}

```

上述代码，使用 `Stringer` interface 来约束入参 s 的类型 T 必须是实现了 `String() string` 函数的类型。
除了使用自定义的 interface 来约束之外，Go 内置了 `any` 来指明入参是可以为任意类型的, 当我们不需要约束的时候可以使用 `any` 来维持写法的一致性, `any` 相当于 `interface{}` 。

```go
// Print prints the elements of any slice.
// Print has a type parameter T and has a single (non-type)
// parameter s which is a slice of that type parameter.
func Print[T any](s []T) {
    for _, v := range s {
		fmt.Println(v)
	}
}
```

interface 我们经常会用到，是一个已经非常熟悉的概念，而且使用 interface 可以避免不必要的重复定义的情况。以上面的 `Stringer` 为例，如果使用 contract 来对 `Stringify` 函数的入参类型进行约束，我们需要定义:

```go
// 约束
contract stringer_c(T) {
	T String() string
}

// Stringer 接口
type Stringer interface {
	String() string
}

// 入参 s 被约束为实现了 String() string 函数的类型
func Stringify[T stringer_c](s []T) (ret []string) {
	for _, v := range s {
		ret = append(ret, v.String())
	}
	return ret
}

// 实现了 String() string 的结构体
type IStringer struct {
	v string
}

// String() string 实现
func (i *IStringer) String() string {
	return v
}

var i_stringer IStringer
Stringfy([]IStringer{i_stringer}) // 合法入参
```

从上面的代码可以看出， `stringer_c` contract 其实和 `Stringer` interface 是重复的。

看到这里是不是觉得这个改动还是很棒的？相对 contract 来说，interface 更好理解，有时候也可以省掉重复的定义。

但是，interface 只能定义函数，因此，我们只能使用 interface 来约束 T 必须实现的函数，而不能约束 T 所能支持的运算。

使用 contract 来约束类型参数所支持的运算符的例子:

```go
// comparable contract
contract ordered(t T) {
  t < t
}
func Smallest[T ordered](s []T) T {
	r := s[0] // panic if slice is empty
	for _, v := range s[1:] {
		if v < r { // OK
			r = v
		}
	}
	return r
}
```

很方便。但使用 interface 就没那么方便了:

```go
package constraints

// Ordered is a type constraint that matches any ordered type.
// An ordered type is one that supports the <, <=, >, and >= operators.
type Ordered interface {
	type int, int8, int16, int32, int64,
		uint, uint8, uint16, uint32, uint64, uintptr,
		float32, float64,
		string
}

// Smallest returns the smallest element in a slice.
// It panics if the slice is empty.
func Smallest[T constraints.Ordered](s []T) T {
	r := s[0] // panics if slice is empty
	for _, v := range s[1:] {
		if v < r {
			r = v
		}
	}
	return r
}
```

> 要写一大堆... 心里一阵 mmp... 先别慌!

`Ordered` interface 里列出来的类型是 `Ordered` 约束可以接受的类型参数。由此看来，针对运算符的约束写起来变的更复杂了，幸运的是，go 会内置常用的约束, **不用我们自己来写**.
而且，约束是可以组合的:

```go
// ComparableHasher is a type constraint that matches all
// comparable types with a Hash method.
type ComparableHasher interface {
	comparable
	Hash() uintptr
}
```

上述代码是一个约束，它约束类型参数必须是可比较的，而且实现了 `Hash() uintptr` 函数。

```go
// StringableSignedInteger is a type constraint that matches any
// type that is both 1) defined as a signed integer type;
// 2) has a String method.
type StringableSignedInteger interface {
	type int, int8, int16, int32, int64
	String() string
}
```

类似地，可以将可接受的类型列表(type list)和函数约束放在一起。

讲到这里，关于泛型改动的核心内容已经讲完了，更复杂的用法可以查看文档 [go2draft-type-parameters](https://go.googlesource.com/proposal/+/refs/heads/master/design/go2draft-type-parameters.md).

个人认为，这个改动是一个比较成功的改动，没有引入新的概念，通过内置一些约束，支持约束组合来方便开发者。

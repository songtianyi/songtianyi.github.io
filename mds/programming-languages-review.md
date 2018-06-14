# Programming Languages Review

作者: [songtianyi](https://github.com/songtianyi/songtianyi.github.io), 2018-06-07

### 为什么会有这篇文章？

从接触编程到现在，也学过不少语言，c/c++, qt，shell，node, golang, java, 前端的语言js/css3/html5也略懂一二，但是在语言选型的时候仍然会有困难，虽然能够根据自己的经验去做选择，大概率也不会错，毕竟主流语言也就那么几个，不管选哪个最终都能解决问题，但是针对自己的业务场景，不同语言带来的工作量差异还是很显著的，如果只是根据的经验和主观想法去选择，如何说服别人采纳你的意见呢？

### 讲什么？

编程语言往大了讲是很复杂的，语法，类型系统，编译原理，编译器，解释器，内存模型，并发模型，工具链等等，单拿一点出来都能写一本书了。所以本文专注在类型系统(type systems)，语法(grammar)，编程范式(programming paradigms)，目的是为了有能力根据业务场景选择合适的语言.

### 类型系统

什么是类型？在软件执行的过程中，变量可以为很多值，定义变量的边界的描述即类型。变量可以被赋予类型(即变量有边界)的语言称为类型语言(**typed language**)，无类型语言(**untyped language**)没有类型，或者说只有一个全局类型，能够存储所有的值。 类型语言的我们见得多了，无类型的呢？lambda演算(pure  λ-calculus)是无类型的，汇编和LISP也是无类型的.  

变量类型的指定可以是显式的

```go
// golang
var foo int
```

也可以是隐式的

```haskell
-- haskell
fac :: Int -> Int -- 这一行可以省略
fac 0 = 1
fac n = n * fac (n - 1)
```

```haskell
fac 0 = 1
fac n = n * fac (n - 1)
```

类型系统会自动赋予变量类型，这种行为称为类型推断(type inference)。

##### 类型检查

类型系统是类型语言的组成部分, 负责跟踪变量的类型，判断代码是否满足类型约束，这种行为称为类型检查**typechecking**, 类型检查是保证程序稳定运行的手段，同时又分为运行时检查(runtime checks)和静态检查(static checks), 运行时检查也叫动态检查(dynamic checking). 

类型系统做了静态检查，还有必要做动态检查嘛？有，比如数组的边界检查，就必须在runtime做。运行时的类型检查会导致程序运行终止(fail-stop)，为什么还要检查呢？让它运行到无法继续执行为止不就好了？类型检查虽然会出错，但是阻止了更恶劣的错误(untrapped errors)的发生，比如保证gc等机制能够正常运转.  动态检查的缺点是会导致fail-stop，也会消耗资源，影响性能，所以通常我们认为拥有静态检查的类型系统的语言会更稳定高效。但是静态检查就足够安全了吗？不一定，因为某些语言在静态检查时没有检查一些危险操作，比如C指针的运算和转换，这类语言称为**weekly checked**, 反之称为**strongly checked**

类型系统除了提供类型检查，保证程序的安全行之外，还可以提供信息给编译器，以优化执行效率。同时，类型系统是对现实世界的抽象，可读性高，也是更高级别抽象(如编程范式)的基础。所以，无类型的语言在选型时基本会被排除掉。

##### 强类型和弱类型

在语言的抉择上，`静态检查`，`动态检查`和`检查范围`这几个角度影响的是程序的稳定性和执行效率，那么开发效率呢？此时要引入另外一个维度，`强类型`和`弱类型`，强类型是指一旦被指定类型，不可变，弱类型则可变，可变也分为隐式和显式两种。

```javascript
// js 弱类型，隐式可变
x = 1
y = "2"
z = x + y
```

弱类型提升了我们的开发效率。

总结，在语言的抉择上，我们可以从类型系统的静态检查，动态检查，检查范围及类型是否可变这几个维度来考虑，在开发效率和执行效率之间做权衡。无类型的系统可以很安全，但是可维护性差，基本被排除在系统开发之外。

看到这里，你会发现我并没有讲什么是动态类型语言，静态类型语言。因为这个维度并不是影响我们抉择的本质。动态类型语言其实指的就是只有动态检查的语言，静态类型指拥有静态检查的语言，此类型非彼类型，个人觉得是翻译的锅。

##### 类型推断

类型推断(type inference)是类型系统中推测一段代码(声明，表达式等)的类型的过程。类型推断让我们在编写代码时能够略去类型的声明，并且不会影响到类型检查。如果值的类型仅在运行时才能被确定，这类语言被称为动态语言(dynamically typed), 同样的，如果值的类型仅在编译时被确定，这类语言被称为静态语言(statically typed).

### 类型理论

类型理论涉及到的内容和类型系统会有部分重叠，你可以理解为类型理论是服务于类型系统的，即，我们使用了哪些理论来构建我们的类型系统，或者说该语言的类型系统实现了哪些特性。一门语言的类型系统一般只会实现其中的某几种特性，来满足特定场景的需求。

##### polymorphism type

1. *Ad hoc polymorphism*: 一个函数会根据有限的类型组合拥有不同的实现，函数重载(function overloading)和操作符重载(operator overloading)依赖于此. 从polymorphism性质实现的角度讲，此类属于编译时多态(static polymorphism).

   ```java
   // java
   public int Add(int a, int b) {
       return a + b;
   }
   public String Add(String a, String b, String c) {
       return a + b +c;
   }
   ```

2. *Parametric polymorphism*: 声明的类型未被指定为某一类型，而在实现时可以指定任意类型，即通常我们所说的范型，在C++里称为模板(template). 从polymorphism性质实现的角度讲，此类属于编译时多态(static polymorphism).

   ```java
   // java    
   ...

   public class ObjectsServiceFactory<T> {

       public T save(T o) throws Exception {
           try {
               return repository.save(o);
           } catch (Exception e) {
               throw new DatabaseOperationException(String.format("save object %s failed, %s", o.toString(), e.getMessage()));
           }
       }

       public void delete(T o) {
           repository.delete(o);
       }
   }

   ...

   ObjectsServiceFactory s = new ObjectsServiceFactory<String>();
   ObjectsServiceFactory i = new ObjectsServiceFactory<Integer>();
   s.save("demo");
   i.save(100)
   ```

3. *Subtype polymorphism*: 一个变量可以指代多个拥有共同父类的子类实例，即我们常说的多态。从polymorphism性质实现的角度讲，此类属于运行时多态(dynamic polymorphism). 

   ```c++
   // c++
   #include<iostream>
   using namespace std;

   class Animal {
   public :
       virtual void shout() = 0;
   	virtual ~Animal(){}
   };

   class Dog :public Animal {
   public:
       virtual void shout(){ cout << "dog"<<endl; }
   };
   class Cat :public Animal {
   public:
       virtual void shout(){ cout << "cat"<<endl; }
   };
   class Bird : public Animal {
   public:
       virtual void shout(){ cout << "bird"<<endl; }
   };

   int main() {
       Animal * animal1 = new Dog;
       Animal * animal2 = new Cat;
       Animal * animal3 = new Bird;

       animal1->shout();
       animal2->shout();
       animal3->shout();

       delete(animal1);
       delete(animal2);
       delete(animal3);
       return 0;
   }
   ```

4. *Row polymorphism*: 也叫duck typing，针对结构体类型，从功能(purpose)的角度对类型归类。通常，对象是根据它们的类型来确定之间的关系，比如subtyping中的继承，而duck typing是通过函数，如果它们实现了相同的函数，就认为它们是同一类，"If it walks like a duck and it quacks like a duck, then it must be a duck."  如果它走路像鸭子(实现了walk()函数)，也会像鸭子一样发出嘎嘎声(实现了gaga())函数，那它就是一只鸭子。

   ```python
   # python
   class Duck:
       def fly(self):
           print("Duck flying")

   class Airplane:
       def fly(self):
           print("Airplane flying")

   class Whale:
       def swim(self):
           print("Whale swimming")

   def lift_off(entity):
       entity.fly()

   duck = Duck()
   airplane = Airplane()
   whale = Whale()

   lift_off(duck) # prints `Duck flying`
   lift_off(airplane) # prints `Airplane flying`
   lift_off(whale) # Throws the error `'Whale' object has no attribute 'fly'`
   ```

   duck typing也是go语言的主要特性，但是，严格来说并不算，因为duck typing发生在运行时，且没有显式的**interface**声明，上面的python示例就是典型的duck typing。

5. *Polytypism*: 函数式编程语言里的范型特性。以Haskell为例，函数的定义比较具体化，单一化，缺乏可扩展性和高度复用性，在Haskell语言上可以引入一种泛型机制解决上述问题，这种泛型机制主要体现在泛型函数的定义上，泛型函数的定义不同于以往的函数定义方法，当泛型函数遇到某种未定义的类型参数时，它依靠泛型算法分析参数类型的结构，进行相关转换，可以自动生成函数定义，这种方法可以提高程序的复用程度，优化函数功能的定义。<sup>[2]</sup>

*PS. polymorphism翻译为多态性，但不单单指面向对象里的多态，而是指类型系统里的多态性质。编译时多态，是在编译时就能推导出类型或调用关系，宏也是一种编译时多态。运行时多态的实现依赖于虚函数机制(virtual function), 是在运行时确定调用关系。多态性质的引入可以提高代码的复用率*

##### dependent types

依赖类型（或依存类型，dependent type）是指依赖于值的类型<sup>[4]</sup>, 此特性通过极其丰富的类型表达能力使得程序规范得以借助类型的形式被检查，从而有效减少程序错误。依赖类型的两个常见实例是依赖函数类型(又称**依赖乘积类型**, **Π-类型**)和依赖值对类型(又称**依赖总和类型**、**Σ-类型**)。

一个依赖函数的返回值的类型可以依赖于某个参数的具体值，而非仅仅参数的类型，例如，一个输入参数为整型值n的函数可能返回一个长度为n的数组

```idris
-- Idris 连接两个列表
-- Vect n a 是依赖函数类型，a是列表元素的类型，n是输入参数，Vect n a 返回一个长度为n的列表
app : Vect n a -> Vect m a -> Vect (n + m) a
```

一个依赖值对类型中的第二个值可以依赖于第一个值，例如，可表示一对这样的值：它由一对整数组成，其中的第二个数总是大于第一个数。

```idris
def do(i : {i:Int | i<=j}, j : Int) :=
  // do something
```

```idris
do(10, 1) // compile error
```

```idris
do(1, 10) // ok
```

以依赖类型系统为基础的编程语言大多同时也作为构造证明与可验证程序的辅助工具而存在，如 Coq 和 Agda（但并非所有证明辅助工具都以类型论为基础）；近年来，一些以通用和系统编程为目的的编程语言被设计出来，如 Idris。

### 语法

一门语言的规范，首先是类型(type), 声明(statements), 表达式(expressions)等， 其次是作用域(scoping)。

##### Statements

##### Expressions

##### Packages

##### Scoping

作用域是名称(比如变量的声明)和其实体(比如变量的定义)的绑定规则, 这些规则保证了程序是无歧义的。

1. *global scop*e:
2. *expression scope*:
3. *block scope*: 
4. ​

##### 

### 编程范式

xxx

也可以理解为思维模式，比如oop是一种编程范式，什么时候用oop合适，什么时候没有会更好？

##### OOP

##### FP

##### pp

##### FRP

### 工具链

##### 依赖管理

##### 编译器/解释器

##### 框架

### 选型

##### 术语说明

* *static and dynamic checks*: 指该语言的类型系统会进行静态检查和动态检查
* *strongly checked*: 以检查范围的大小作为标准，意味着类型系统的类型检查(type checking)已经尽可能消除了类型错误
* *weekly typed*: 类型可变
* *strongly typed*: 类型不可变
* *dynamically typed*: 值的类型仅在运行时确定
* *statically typed*: 值的类型仅在编译时确定

|    Lang     | Typed |  PP  | OOP  |  FP  | FRP  | static and dynamic  checks | weekly typed | strongly checked | dynamically/statically typed |
| :---------: | :---: | :--: | :--: | :--: | :--: | :------------------------: | :----------: | :--------------: | :--------------------------: |
|  Assembly   |   ❌   |      |      |      |      |             ❌              |              |        ❌         |                              |
|    Java     |  ☑️   |      |      |      |      |             ☑️             |              |                  |                              |
|      C      |  ☑️   |      |      |      |      |             ☑️             |              |        ❌         |                              |
|     C++     |  ☑️   |      |      |      |      |             ☑️             |              |                  |                              |
|   Python    |       |      |      |      |      |                            |              |                  |                              |
|     C#      |       |      |      |      |      |                            |              |                  |                              |
|     PHP     |       |      |      |      |      |                            |              |                  |                              |
| JavaScript  |       |      |      |      |      |                            |              |                  |                              |
|    Ruby     |       |      |      |      |      |                            |              |                  |                              |
|      R      |       |      |      |      |      |                            |              |                  |                              |
|     Go      |       |      |      |      |      |                            |              |                  |                              |
| Objective-C |       |      |      |      |      |                            |              |                  |                              |
|    Perl     |       |      |      |      |      |                            |              |                  |                              |
|    Swift    |       |      |      |      |      |                            |              |                  |                              |
|    Scala    |       |      |      |      |      |                            |              |                  |                              |
|    Lisp     |   ❌   |      |      |      |      |                            |      ☑️      |        ☑️        |                              |
|   Prolog    |       |      |      |      |      |                            |              |                  |                              |
|   Erlang    |       |      |      |      |      |                            |              |                  |                              |
|     Lua     |       |      |      |      |      |                            |              |                  |                              |
|   Haskell   |       |      |      |      |      |                            |              |                  |                              |
|   Kotlin    |       |      |      |      |      |                            |              |                  |                              |
| TypeScript  |       |      |      |      |      |                            |              |                  |                              |

![Tree format](http://on-img.com/chart_image/5b20fa53e4b06350d462d78b.png)

### 编程语言的终极形态？

人类用自然语言描述对象和行为，编程语言用类型系统来描述对象，用语法来描述行为，二进制的世界是对现实世界的模拟。我们用自然语言描述对象和行为的时候觉得很方便是因为，我们花了多年的时间去学习大量的先验知识，计算机没有任何先验知识, TODO

### 参考文献

1. [《Type Systems》, Luca Cardelli](http://www.cs.colorado.edu/~bec/courses/csci5535/reading/cardelli-typesystems.pdf)
2. [《函数式语言泛型特性的研究与实现》, LI Yang, YU Shangchao, WANG Peng](http://cea.ceaj.org/CN/article/downloadArticleFile.do?attachType=PDF&id=29391)
3. [《Types and Programming Languages》, Benjamin C. Pierce](https://www.asc.ohio-state.edu/pollard.4/type/books/pierce-tpl.pdf)
4. [依赖类型, wiki](https://zh.wikipedia.org/wiki/%E4%BE%9D%E8%B5%96%E7%B1%BB%E5%9E%8B)
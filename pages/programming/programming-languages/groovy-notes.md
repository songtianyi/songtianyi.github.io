# Groovy 笔记

### Groovy 是什么

Groovy 是一种面向对象的动态类型语言，与 Java 一样运行在 JVM 上。

### 简介

Apache Groovy 是一个**功能强大、可选类型**的**动态**语言，有**静态编译**能力。旨在通过**简单、熟悉、易学的语法**来提高 Java 平台的开发人员的开发效率。它与任何 Java 程序无缝集成，并可以为你的应用提供强大的功能，包括**脚本能力、领域特定语言（Domain-Specific Language）、**运行和编译时**元编程**和**函数式**编程。

### JDK 和 GDK 之间的关系

GDK 是基于 JDK 的，所以在 Java 代码和 Groovy 代码之间传递对象时，无需任何转换。当处在同一 JVM 中时，Java 端和 Groovy 端使用的是同一对象

### 特点

* **平坦的学习曲线**:简洁，可读性和表现力的语法，易于学习 Java 开发人员。
* **强大的功能**:闭包、构建、运行时与编译时元编程、函数式编程、类型推断和静态编译。
* **平滑的 Java 集成**:与 Java 及任何第三方库无缝透明地集成和互操作。
* **领域特定语言**:灵活和可锻铸语法，先进的集成和定制机制，在应用程序中集成可读的业务规则。
* **充满活力和丰富的生态系统**:Web 开发，并发、异步、并行库，测试框架，构建工具，代码分析，GUI 构建等。
* **脚本和测试粘合：**为所有的构建和自动化任务编写简洁可维护的测试。

Groovy 还有其他一些使这门语言更为轻量级、更为易用的特性，试举几例如下:

* return 语句几乎总是可选的 
* 尽管可以使用分号分隔语句，但它几乎总是可选的
* 方法和类默认是公开（public）的
* ?. 操作符只有对象引用不为空时才会分派调用
* 可以使用具名参数初始化 JavaBean
* Groovy 不强迫我们捕获自己不关心的异常，这些异常会被传递给代码的
* 静态方法内可以使用 this 来引用 Class 对象

### 语法示例

``` 
public class GroovyTest {
    // sum method
    def static sum(n, closure) {
      for(int i = 2; i <= n; i += 2) {
        closure(i)
      }
      // return 2
      2
    }
    
    def static curried(closure) {
        Date date = new Date()
        def curriedClosure = closure.curry(date)
        curriedClosure("papapa")
    }
    
    def static paramsDemo(a, b, c, closure) {
        closure(a + b + c, a + b)
    }
    
    def static dynamic(data, closure){
        if(closure.maximumNumberOfParameters == 1){
            closure(data)
        }else{
            closure(data, " lala ")
        }
    }
    
    def static examingClosure(closure) {closure()}
    
    public static void main(String []args){
        println "java in groovy!"
        for(int i =  0;i < 10;i++) {
            System.out.print(i);
            print i + ","
        }
        println "\nrange for";
        for (i in 0..2) {
            print i
        }
        println "\nclosure"
        0.upto(10){
            print "$it"
        }
        println  "\nrepeat "
        3.times {
            print "index $it,"
            print "ho "
        }
        println "\nstep demo"
        1.step(10, 5) {
            print "$it,"
        }
        println "\nsystem command invocation!"
        print "java -version".execute().text;

        println "\na new way to check null"
        String a = null
        a?.print()

        println "\ncatch exception is not necessary!"
        println "semicolon is not necessary!"
       
        // evaluate expression in string
        println "${1==0}"

        def total = 1
        // 666
        println "${sum(10, {index -> println "$index";total *= index})}"
        println total
        
        sum(10){index -> total *= index}
        println total
        
        paramsDemo("hello ", "world", "!") {
            cb1, cb2 -> println cb1 + cb2
        }
        curried(){
             date, event -> println date.toString() + " " + event 
        }
        dynamic("666"){
            data -> println data
        }
        dynamic("666") {
            aa, bb -> println aa + bb
        }
        dynamic("666") {
            // default maxmiumNumberOfParameters == 1
            println it
        }
        
        examingClosure() {
            -> L:{
                println getClass().name
                println this.getClass().superclass.name
                println owner.getClass().superclass.name
                println delegate.getClass().superclass.name
                
                examingClosure() {
                    println getClass().name
                    println this.getClass().superclass.name
                    println owner.getClass().superclass.name
                    println delegate.getClass().superclass.name
                }
            }
        }
        
        // string minus
        def str = "It's a rainy day in Seattle"
        println str

        str -= "rainy "
        println str
        
        // turn string to regex pattern
        str = ~'hello'
        println str.getClass().name
        
        // list
        def lst = [1,2,3,5,8,13]
        println lst.getClass().name
        println lst[0]
        println lst[-1]
        println lst[2..3]
        def left = 3
        def right = 4
        println lst[left..right]
        // list ops
        lst.each(){println it}
        println lst.collect{ it * 2}
        println lst.find{ it == 13}
        println lst.collect{it}.sum()
        def flattened = [["ni", "shi"], "sha", "bi", "ba"].flatten()
        println flattened
        println flattened - ["ni", "shi"]
        println flattened*.size()
        lst.with{
            add(3)
            println "with"
            println size()
            println contains(3)
        }
        
        // map
        def langs = ['C++' : 'Stroustrup', 'Java' : 'Gosling', 'Lisp' : 'McCarthy', 'AD': "99"]
        println langs.getClass().name
        // map ops
        println langs["C++"]
        println langs."C++"
        langs.each{item -> println item}
        langs.each{k, v -> println k + ":" + v}
        println langs.any{k, v -> v =~ ~"[A-Za-z]"}
        println langs.every{k, v -> v =~ ~"[A-Za-z]"}
        
        def friends = [ briang : 'Brian Goetz', brians : 'Brian Sletten', 
           davidb : 'David Bock', davidg : 'David Geary',
           scottd : 'Scott Davis', scottl : 'Scott Leberknight', 
           stuarth : 'Stuart Halloway']

        def groupByFirstName = friends.groupBy { it.value.split(' ')[0] }
        groupByFirstName.each { firstName, buddies ->
            println "$firstName : ${buddies.collect { key, fullName -> fullName }.join(', ')}"
        }
  }
}
```

### 存在的陷阱

* Groovy 将==操作符映射到了 Java 中的 equals()方法，当且仅当该类没有实现 Comparable 接口时，才会这样映射。如果实现了 Comparable 接口，则==会被映射到该类的 compareTo()方法. 可以使用 groovy 的**is**方法来判等
* 编译时类型检查默认为关闭，Groovy 编译器不会验证类型，相反，它只是进行强制类型转换，然后将其留给运行时处理。Groovy 编译器可能看上去不够严格，但是对于 Groovy 的动态和元编程等强项而言，这种行为是必要的，我们也可以选择性地增强编译时类型检查。可以使用特殊的注解@TypeChecked，让 Groovy 去检查这些种错误，这个注解可以用于类或单个方法上。如果用于一个类，则类型检查会在该类中所有的方法、闭包和内部类上执行。如果用于一个方法，则类型检查仅在目标方法的成员上执行。我们还可以使用 SKIP 参数去掉一些具体的方法，不对它们进行静态类型检查。可以使用@CompileStatic 注解让 Groovy 执行静态编译。这样为目标代码生成的字节码会和 javac 生成的字节码很像，性能足以与 Java 媲美

* **def**和**in**都是 Groovy 中的新关键字。def 用于定义方法、属性和局部变量。in 用于在 for 循环中指定循环的区间，比如 for(i in 1..10)。当把现有的 Java 代码当作 Groovy 代码时，要小心这些新关键字引起的语义变化。不要定义名为 it 的变量

* 不要在 java 中使用这样的代码段

  

``` 
  // Java 代码
  public void method() {
    System.out.println("in method1");

    {
      System.out.println("in block");
    }
  }
  ```

  Java 中的代码块定义了一个新的作用域，但是 Groovy 会感到困扰。Groovy 编译器会错误地认为我们是要定义一个闭包，并给出编译错误。在 Groovy 中，方法内不能有任何这样的代码块。

* 注意闭包与匿名内部类的冲突

* 不要一开始就强制使用闭包去写代码，在代码重构，review 的阶段引入也是合适的

* 要在 Groovy 中创建基本类型的数组，不能使用我们在 Java 中所习惯的方式

  

``` 
  int[] arr = new int[] {1, 2, 3, 4, 5}; // java
  int[] arr = [1, 2, 3, 4, 5] // groovy
  def arr = [1, 2, 3, 4, 5] as int[] // groovy
  ```

### 哪些情况下需指明类型

在使用 Groovy 编程时，我倾向于省略类型. 当然在必要的情况下，我也会选择指明类型。比如，

* JUnit 要求测试方法为 void 类型
* 在 Grails 对象关系映射（GORM）中把类型映射到数据库。
* 如果要为使用静态类型语言的程序员开发 API，那我们会在静态类型的、面向客户的 API 中指明方法形参的类型

### Groovy 和 Java 混用

要在 Groovy 代码中使用 Groovy 类，无需做什么，直接就可以工作。我们只需要确保所依赖的类在类路径（classpath）下，要么是源代码，要么是字节码。要把一个 Groovy 脚本拉到我们的 Groovy 代码中，可以使用 GroovyShell。而如果要在 Java 类中使用 Groovy 脚本，则可以使用 JSR 223 提供的 ScriptEngine API。如果想在 Java 中使用 Groovy 类，或者想在 Groovy 中使用 Java 类，我们可以利用 Groovy 的联合编译（joint-compilation）工具

##### 运行 groovy

要运行 Groovy 代码，我们有两个选择。

* 一个是对源代码运行 groovy 命令。Groovy 会自动在内存中编译代码并执行。我们不必引入一个明确的编译步骤。

* 第二个方法，如果想用类似 Java 的那种更传统的方法，即显式的编译代码来创建字节码（.class 文件），可以使用 groovyc 编译器。要执行编译好的字节码，可以像执行编译好的 Java 代码那样使用 java 命令。唯一的区别是，我们需要把 groovy-all-2.1.0.jar 文件放在 classpath 下。记得在 classpath 里添加一个句点（.），这样 java 命令就可以找到当前目录下的类了。这一 Java 存档文件（JAR）在 GROOVY_HOME 下的 embeddable 目录中。

  

``` 
  java -classpath $GROOVY_HOME/embeddable/groovy-all-2.1.0.jar:. $groovy_file
  ```

##### 在 Groovy 中使用 Groovy 类

要在 Groovy 代码中使用一个 Groovy 类，只需要确保该类在我们的 classpath 下。可以使用 Groovy 源代码，也可以把源代码编译成.class 文件并使用该文件——随我们选择。当我们的 Groovy 代码引用了一个 Groovy 类时，Groovy 会以该类的名字在我们的 classpath 下查找.groovy 文件；如果找不到，则以同样的名字查找.class 文件.

##### 利用联合编译混合使用 Groovy 和 Java

如果 Groovy 类是预先编译好的，那我们就可以方便地在 Java 中使用.class 文件或 JAR 包。来自 Java 的字节码和来自 Groovy 的字节码，对 Java 而言没什么区别；我们必须把 Groovy JAR 文件放在我们的 classpath 下，类似于我们使用 Spring、Hibernate 或其他框架/类库的 JAR 文件时的做法。

如果我们只有 Groovy 源代码，而非字节码，又会怎样呢？请记住，当我们的 Java 类依赖其他 Java 类时，如果没有找到字节码，javac 将编译它认为必要的任何 Java 类。不过 javac 对 Groovy 可没这么友好。幸好 groovyc 支持联合编译。当我们编译 Groovy 代码时，它会确定是否有任何需要编译的 Java 类，并负责编译它们。因此我们可以自由地在项目中混合使用 Java 代码和 Groovy 代码，而且不必执行单独的编译步骤。简单地调用 groovyc 就好。

要利用联合编译，我们需要使用-j 编译标志。使用-J 前缀把标志传给 groovy 编译器.

``` 
groovyc -j JavaClass.java UseJavaClass.groovy -Jsource 1.6
```

-Jsource 1.6 会把可选的选项 source = 1.6 发送给编译器。使用 javap 检查生成的字节码，会发现 JavaClass 作为一个普通的 Java 类，扩展了 java.lang. Object，而 UseJavaClass 扩展了 groovy.lang. Script。

##### 在 Java 中创建与传递 Groovy 闭包

如果仔细检查，我们会发现，当 Groovy 调用一个闭包时，它只是使用了一个名为 call()的特殊方法。要在 Java 中创建一个闭包，我们只需要一个包含该方法的类。如果 Groovy 代码要向闭包传递实参，我们必须确保 call()方法接受这些实参作为形参.

##### 在 Java 中调用 Groovy 动态方法

每个 Groovy 对象都实现了 GroovyObject 接口，该接口有一个叫作 invokeMethod()的特殊方法。该方法接受要调用的方法的名字，以及要传递的参数。在 Java 这一端，invokeMethod()可以用来调用 Groovy 中使用元编程动态定义的方法. 从 Java 中可以使用任何 Groovy 类，这点没有限制，不管它们是否是动态的。

##### 在 Groovy 中使用 Java 类

在 Groovy 中使用 Java 类简单且直接。如果我们想使用的 Java 类是 JDK 的一部分，可以像在 Java 中那样导入这些类或它们的包。Groovy 默认会导入很多包和类，因此，如果我们想使用的类已经导入（比如 java.util. Date），直接用就可以了，无需再导入.

如果想使用一个自己的 Java 类，或者不是标准 JDK 中的类，在 Groovy 中可以像在 Java 中那样导入它们。请确保导入了必要的包或类，或者使用类的全限定名来引用它们。当运行 groovy 时，可以使用-classpath 选项指定.class 文件或 JAR 包的路径。如果类文件和我们的 Groovy 代码在同一目录下，则不需要通过该选项指定目录。

如果想显式地编译 Groovy 调用了 java 的代码，不必分别编译 Java 和 Groovy。可以使用联合编译代替。

##### 从 Groovy 中使用 Groovy 脚本

使用 GroovyShell，我们可以在任何文件（或字符串）中对脚本调用 evaluate()方法，以执行该脚本。

``` 
evaluate(new File('Script1.groovy'))
```

如果我们想向脚本传递一些参数，又该怎么办呢？我们可以使用一个 Binding 实例来绑定变量

``` 
println "In Script2"

name = "Venkat"

shell = new GroovyShell(binding)
result = shell.evaluate(new File('Script1a.groovy'))

println "Script1a returned : $result"
println "Hello $name"
```

在发起调用的脚本中，我们创建了一个变量 name（与被调用脚本中用到的变量名字相同）。当创建 GroovyShell 的实例时，我们将当前的 Binding 对象传给了它（每个脚本执行时都有一个这样的对象）。被调用脚本现在就可以使用（读取和设置）发起调用脚本所知道的变量了.

如果不希望影响当前的 binding， 而是想将其与被调用脚本的 binding 分开，我们只需要创建一个新的 Binding 实例，在该实例上调用 setProperty()来设置变量名和值，并将其作为创建 GroovyShell 实例时的一个参数

``` 
println "In Script3"

binding1 = new Binding()
binding1.setProperty('name', 'Venkat')
shell = new GroovyShell(binding1)
shell.evaluate(new File('Script1a.groovy'))

binding2 = new Binding()
binding2.setProperty('name', 'Dan')
shell.binding = binding2
shell.evaluate(new File('Script1a.groovy'))
```

##### 从 Java 中使用 Groovy 脚本

如果想在 Java 中使用 Groovy 脚本，我们可以利用 JSR 223（JSR 即 Java Specification Request，Java 规范请求）需要确保…/jsr223-engines/groovy/build/groovy-engine.jar 在我们的 classpath 下

### MOP 与元编程

元编程（meta programming）意味着编写能够操作程序的程序，包括操作程序自身。像 Groovy 这样的动态语言通过元对象协议（MetaObject Protocol，MOP）提供了这种能力。利用 Groovy 的 MOP，创建类、编写单元测试和引入模拟对象都很容易。在 Groovy 中，使用 MOP 可以动态调用方法，甚至在运行时合成类和方法。借助 MOP，在 Groovy 中可以创建内部的领域特定语言。

##### Groovy 对象

Groovy 对象是带有附加功能的 Java 对象。在一个 Groovy 应用中，我们会使用三类对象：POJO、POGO 和 Groovy 拦截器。POJO（Plain Old Java Object）就是普通的 Java 对象，可以使用 Java 或 JVM 上的其他语言来创建。POGO（Plain Old Groovy Object）是用 Groovy 编写的对象，扩展了 java.lang. Object，同时也实现了 groovy.lang. GroovyObject 接口。Groovy 拦截器是扩展了 GroovyInterceptable 的 Groovy 对象，具有方法拦截功能。Groovy 这样定义的 GroovyObject 接口:

``` 
//这是 Groovy 源代码中 GroovyObject.java 的一个片段
package groovy.lang;
public interface GroovyObject {
  Object invokeMethod(String name, Object args);
  Object getProperty(String property);
  void setProperty(String property, Object newValue);
  MetaClass getMetaClass();
  void setMetaClass(MetaClass metaClass);
}
```

我们可以通过调用 setMetaClass()修改它的 MetaClass。这给我们一种对象在运行时修改了它的类的感觉.

当我们调用一个方法时，Groovy 会检查目标对象是一个 POJO 还是一个 POGO. 对于一个 POJO，Groovy 会去应用类（application-wide）的 MetaClassRegistry 取它的 MetaClass，并将方法调用委托给它。因此，我们在它的 MetaClass 上定义的任何拦截器或方法，都优先于 POJO 原来的方法.

对于一个 POGO, 如果对象实现了 GroovyInterceptable，那么所有的调用都会被路由给它的 `invokeMethod()` , 在这个拦截器内，我们可以把调用路由给实际的方法，使类 AOP（Aspect-Oriented Programming，面向方面编程）的操作成为可能. 如果该 POGO 没有实现 GroovyInterceptable，那么 Groovy 会先查找它的 MetaClass 中的方法，之后，如果没有找到，则查找 POGO 自身上的方法。 如果该 POGO 没有这样的方法，Groovy 会以方法名查找属性或字段。如果属性或字段是 Closure 类型的，Groovy 会调用它，替代方法调用。如果 Groovy 没有找到这样的属性或字段，它会做最后两次尝试。如果 POGO 有一个名为 methodMissing()的方法，则调用该方法。否则调用 POGO 的 invokeMethod()。如果我们在 POGO 上实现了这个方法，它会被调用。invokeMethod()的默认实现会抛出一个 `MissingMethodException` .

#### 使用 MOP 拦截方法

#### MOP 方法注入

使用 MiXin 注入方法

``` 
class Friend {
  def listen() {
    "$name is listening as a friend"
  }
}
```

name 属性本身没有在这个类中做任何定义，它将由该类所混入的类提供。

首先，可以使用@Mixin 注解语法，将 Mixin 注入到 Person 类中（如下面代码所示）。作为一种选择，也可以使用静态初始化器将 Mixin 引入到这个类中，就像这样：class Person { static { mixin Friend} ...}。

``` 
@Mixin(Friend)
class Person {
  String firstName
  String lastName  
  String getName() { "$firstName $lastName"}
}

john = new Person(firstName: "John", lastName: "Smith")
println john.listen()
```

在这个例子中，Friend 的方法被添加到了 Person 中. 通过向注解提供由多个类名组成的列表，可以混入多个类，就像这样：@Mixin([Friend, Teacher])。

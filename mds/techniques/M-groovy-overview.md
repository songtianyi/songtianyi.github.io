# Groovy 概览

作者: songtianyi create@2020-11-24

## 前言

和 Go 的火热相比，Groovy 显得名不见经传。但 Groovy 目前在 tiobe 的排名比 Go 是要高的。Groovy 的成功案例有 Gradle, Grails, Spock testing等等。我们在用静态语言做数据处理的时候是非常痛苦的，而且在客户环境测试的时候，我们需要经过反复的修改，发布，上传，更新等操作，对客户体验影响很大。Groovy作为脚本语言，既能提供灵活性，又能复用 Java 的代码遗产，是一个不错的选项。

## Groovy 是什么

* 运行在 jvm 上，设计之初就考虑从 Java 过渡到 Groovy 的平滑性，能够load jar包，执行 java 函数，你甚至可以同时使用 java 语法和 Groovy 语法来编程；可以编译成 java 字节码，集成进 java 程序里运行；既对 java 友好，又具有比 java 更丰富的语法特性
* 提供闭包，元编程能力，还有强大的 DSL
* Gradual typing, 既支持静态类型(static typing)，也支持动态类型(dynamic typing); Groovy 的类型都属于 java.lang. Object 的子类型

* 多范式，IP, PP, OOP, FP, MP

## Java 和 Groovy 的亲和性

### Java 调用 Groovy

编写一个 Groovy 类 `MyGroovyClass` , 然后编译成 `MyGroovyClass.class` , 将其放进 classpath , 然后可以在 java 中使用该类

``` java
new MyGroovyClass(); // create from Java 
```

# 错误处理

作者: songtianyi

## 前言

错误处理是软件开发当中一个十分重要的话题，程序员一部分时间用来构思算法逻辑，另外，很大一部分时间是用来写错误处理逻辑的，你需要考虑各种奇怪的用户输入，应对不稳定的网络，各种协作对接上的失败等等。
程序是否健壮，几乎完全取决于错误处理做的足不足够细致。

## 错误分类

我们可以按照不同的维度对错误场景进行分类，方便我们记忆，可以选取其中一个或者多个来作为自己的分类方式。

* 预期内 - 可能发生
    - 网络 io
    - 存储(文件，磁盘, 数据库) io
* 非预期 - 必须是什么
    - (用户/函数)输入校验
    - 返回值校验
    - 边界检查

* 可忽略 - 不影响调用者的错误
* 不可忽略 - 影响调用者

* io
  + 网络 io
    - 路由不通
    - 端口不通
    - 超时
  + 存储 io
    - 文件不存在
    - Not enough free disk space
    - Out of memory
    - 超时
  + 用户/函数输入
  + 返回值
  + 内存 io
    - index out of bounds
    - index out of range

## 错误处理的方式

错误处理大致分为这几个步骤
* 检查错误
* 释放资源/回退已执行逻辑
* 收集上下文，构建错误信息
* 打印错误
* 重试
* 抛出/返回错误信息给调用者

## 编程语言带来的差异

## 错误案例

#### 用异常代替流程控制

```JAVA
Object a = null;

try {
  a = repository.findById(id);
}catch(ObjectNotFoundException e) {
  // not exist
  doSomething();
  return
}

// exist
doSomething(a)
```

```java
Boolean exist = repository.existById(id);

if (exist) {
  Object a = repository.findById(id).;
  doSomething(a);
}else {
  doSomething();
}

```

#### 未处理异常

```JAVA
for (String id : ids) {
    try {
        credentialService.deleteCredential(id);
    } catch (Exception e) {
        logger.debug(e.getMessage(), e);
        continue;
    }
}
```

这里存在的问题是未抛出错误，也存在事物的问题（不过在体验上影响倒不大）。如果这里抛了错，那前端会收到错误，前端认为执行失败，可以不用刷新页面，导致客户看到的和实际不一致，
然后继续选中已经被删除的部分，可能会马上遇到错误，如果客户不刷新页面，那这个功能就没法儿使用了，从这个角度讲，上述代码的处理是对的。但是，上述代码，在客户删除"成功"之后，
前端刷新页面，有部分之前选中的数据仍然存在，会给客户造成的困扰，也会影响后端定位问题的效率。

```JAVA
try {
  repository.deleteCredentialWithIds(List<String> ids)
}catch(Exception e) {
  throw e
}
```

## 参考资料

[The Exists Query in Spring Data](https://www.baeldung.com/spring-data-exists-query)

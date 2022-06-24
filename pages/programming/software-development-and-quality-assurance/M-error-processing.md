# 错误处理

作者: songtianyi

## 前言

错误处理是软件开发当中一个十分重要的话题，程序员一部分时间用来构思算法逻辑，另外，很大一部分时间是用来写错误处理逻辑的，你需要考虑各种奇怪的用户输入，应对不稳定的网络，各种协作对接上的失败等等。
程序是否健壮，几乎完全取决于错误处理做的足不足够细致。

## 错误分类

我们可以按照不同的维度对错误场景进行分类，方便我们记忆，可以选取其中一个或者多个来作为自己的分类方式。

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
  + 接口/函数返回值
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

## 编程语言带来的编码差异

##### go

```Go
func (s *Vendor) GetSSHInitializer() SSHInitializer {
	return func(c *ssh.Client, req *protocol.CliRequest) (r io.Reader, w io.WriteCloser, session *ssh.Session, err error) {

		session, err = c.NewSession()
		if err != nil {
			return nil, nil, nil, fmt.Errorf("new ssh session failed, %s", err)
		}

		// get stdout and stdin channel
		r, err = session.StdoutPipe()
		if err != nil {
			session.Close()
			return nil, nil, nil, fmt.Errorf("create stdout pipe failed, %s", err)
		}

		if s.Echo {
			modes := ssh.TerminalModes{
				ssh.ECHO: 1, // enable echoing
			}
			if err = session.RequestPty("vt100", 0, 2000, modes); err != nil {
				return nil, nil, nil, fmt.Errorf("request pty failed, %s", err)
			}
		}

		w, err = session.StdinPipe()
		if err != nil {
			session.Close()
			return nil, nil, nil, fmt.Errorf("create stdin pipe failed, %s", err)
		}

		if err = session.Shell(); err != nil {
			session.Close()
			return nil, nil, nil, fmt.Errorf("create shell failed, %s", err)
		}

		return r, w, session, nil
	}
}
```

不同函数抛出的错误文本可能是相同的，所以需要加上上下文，用来区分。

#### rust

```rust
pub enum Result<T, E> {
    Ok(T),
    Err(E),
}
```

```rust
let x: Result<i32, &str> = Ok(-3);
assert_eq!(x.is_err(), false);

let x: Result<i32, &str> = Err("Some error message");
assert_eq!(x.is_err(), true);
```

```rust
let version = parse_version(&[1, 2, 3, 4]);
match version {
    Ok(v) => println!("working with version: {:?}", v),
    Err(e) => println!("error parsing header: {:?}", e),
}

let v = version.unwrap()

if (version.is_err()) {

}

if (version.is_ok()) {

}
```

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
  doSomething();
}else {
  doSomething();
}

```

#### 未处理异常

```java
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

```java
try {
  repository.deleteCredentialWithIds(List<String> ids)
}catch(Exception e) {
  throw e
}
```

#### 错误信息没有上下文

 `FF02::3/255.255.255.255 is not ip`

 大概能猜到是解析的问题，但是是哪个设备配置的问题？如果有多个设备有这个地址怎么办？

> 功能 -> 设备 -> 对象类型 -> FF02::3/255.255.255.255 is not ip

```Go
// Go

func A() error {
  return error("xxx is not ip")
}

func B() error {
  if err := A(); err != nil {
    return errors("call A error:", err)
  }
}

func C() error {
  if err := B(); err != nil {
    return errors("search policy in device", device.name, "error:", err)
  }
}

// serach policy in device hawei202 error: call A error: xxx is not ip

```

> 报错明确也能方便我们输出错误定位/处理的文档

#### null 返回值

```java
    private Speed getSpeed(Integer speedInt) {
        if (null != speedInt) {
            switch (speedInt) {
                case 10: return Speed.SPEED_10Mb;
                case 100: return Speed.SPEED_100Mb;
                case 1000: return Speed.SPEED_1000Mb;
                case 10000: return Speed.SPEED_10000Mb;
                default:
                    // nothing to do
            }
        }
        return null;
    }
```

```java
private Optional<Speed<> speed(Integer speed) {
  if (null == speed) {
    return Optional.empty()
  }
  switch (speed) {
     case 10: return Speed.SPEED_10Mb;
     case 100: return Speed.SPEED_100Mb;
     case 1000: return Speed.SPEED_1000Mb;
     case 10000: return Speed.SPEED_10000Mb;
     default:
      return Speed.SPEED_UNKNOWN
 }
}
```

```java
private Speed speed(Integer speed) {
  if (null == speed) {
      return Speed.SPEED_UNKNOWN
  }
  switch (speed) {
     case 10: return Speed.SPEED_10Mb;
     case 100: return Speed.SPEED_100Mb;
     case 1000: return Speed.SPEED_1000Mb;
     case 10000: return Speed.SPEED_10000Mb;
     default:
      return Speed.SPEED_UNKNOWN
 }
}
```

## 参考资料

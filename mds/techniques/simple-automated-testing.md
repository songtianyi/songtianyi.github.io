# 简易自动化接口测试

### 前言

虽然[SKY-CLOUD.NET](http://www.sky-cloud.net)是家规模很小的公司，但在devops方面的建设可能不输大部分软件企业。因为我们面向是金融行业的to-B企业，对于上线后的质量要求很高，所以在开发的同时，我们的devops建设也是同步的。在产品开发之初，我们使用jira的套件来管理开发流程和托管代码; 单元测试我们采用testNG, 覆盖率在97%以上, 测试代码量占比25%;我们基于jenkins和docker搭建了完善的CI/CD流程。在接口测试上我们分为两部分, 一部分是, spring-boot框架会将CRUD接口分为三个层次, controller-service-repository, 在写单元测试的时候, 会覆盖service层, 这样也间接覆盖到了接口层面的测试; 另一部分是, 在开发完接口之后, 我们用文档来记录接口测试用例并测试。在前端测试上, 我们初步用上了e2e。测试工具我们用swagger和postman。即使如此, 还是存在不少痛点。

- 接口多

  >  controller就有28个, 只算CRUD, 接口总量也达到了140个

- 单个接口需要的测试用例集较大

  >  因为我们管理的是多个不同品牌的防火墙(cisco, juniper, hillstone, checkpoint等)上的对象和策略, 边界条件很多

- 数据之间有依赖，测试时需要联动

  > 比如在调用接口之前需要获取token

- 接口之间有顺序，测试时需要联动

  > 对于功能性产品, 这应该是普遍的痛点。比如开通防火墙策略时, 要调用6个接口来完成这个过程, 中间每一步都需要用户来参与

- 部分接口的前置条件复杂，否则无法保证预期结果

  > 比如防火墙配置搜索接口, 它的预期输出依赖于设备上的配置或者叫设备状态。在A设备上测试没问题，在B设备上可能就出错了。

- 测试用例用文档沉淀，每次只能复制粘贴

  > 文档的编辑和每次测试时的复制粘贴都是非常繁琐枯燥的工作, 没人会乐意做这些事情。而且在产品迭代的过程中, 接口的变动也是很频繁的, 也进一步加剧了这个负担。

### 简易自动化接口测试

##### 测试用例的管理

用db来管理测试用例，可通过接口进行测试用例的增删改查; db选用mongodb，json友好，这样未来单元测试的用例也能够用mgo来管理(testNG支持从db读取测试用例)。

###### nest.js

测试用例的API使用nest.js框架开发, 提供增删改查和运行测试等接口，完整代码见[nap-tcm](https://github.com/songtianyi/nap-tcm) 。选用TypeScript，一方面是为了实际上手学习一下这门新兴语言, 另一方面是因为js对json十分友好, template string也方便我们解决数据依赖问题。

##### 测试用例的格式

测试用例的格式很关键，除了可以录入输入和预期输出之外，还需要解决数据依赖的问题，我在测试用例当中加了*prerequisites*字段，作为当前用例的前置用例，在运行当前用例之前需运行它的前置用例或者取前置用例运行结果的缓存。如果前置用例测试不通过，此用例无法进行。前置用例的实际结果会作为当前用例的输入，我们来看具体的格式是什么样子的。

```json
[
  {
    "prerequisites": [],
    "_id": "5b4c4ff30207459803bfb3df",
    "api": "/api/auth",
    "method": "POST",
    "when": {
      "body": {
        "username": "admin",
        "password": "xxxxx"
      }
    },
    "then": {
      "statusCode": 200,
      "headers": {
        "authorization": "$regex{Bearer [\\w-.]+}"
      }
    },
    "__v": 0
  },
  {
    "prerequisites": [
      "5b4c4ff30207459803bfb3df"
    ],
    "_id": "5b4c50210207459803bfb3e0",
    "api": "/api/users",
    "method": "GET",
    "when": {
      "headers": {
        "authorization": "$context{5b4c4ff30207459803bfb3df.headers.authorization}"
      },
      "params": "?page=0&size=1"
    },
    "then": {
      "statusCode": 200
    },
    "__v": 0
  }
]
```

在上面的json数据中，第一个测试用例的预期输出`then`中的*authorization*使用正则表达式来验证是否符合要求。第二个测试即`_id:"5b4c50210207459803bfb3e0" `, 它的*authorization*字段的值依赖于第一个测试用例的输出。这类特殊规则都使用如下的格式来书写:

```javascript
$identifier{content}
```

可以根据具体需求来扩展。因为目前的测试用例还不完备，仅支持`$regex{...}`和`$context{...}`, regex用来标记花括号内的内容是一个正则表达式, context用来标记花括号内的内容是一个变量取值

##### 测试用例的运行

测试用例的运行也放在了测试用例管理程序中，前面也提到过，js的元编程很容易解析`$context{a.b.c}`这类数据。运行的逻辑也很简单，即dfs，运行的结果返回给上一层，目前还未支持将结果缓存起来。

##### 测试用例的编排

使用特殊规则的字符串解决了数据依赖问题，测试用例之间的顺序依赖则需使用编排引擎来解决，完整代码见[gflow](https://github.com/songtianyi/gflow)。首先是设计编排的格式。编排格式采用yaml, 未来也可以支持json等格式。写法也很简单明了。

```yaml
# choose run mode
# serial: executed one by one
# parallel: run test case concurrently
# mode is case insensitive
mode: serial
# retry once when fail
retry: 1
# workflow
workflow:
  # steps
  - step:
      # step type
      type: nap
      # step label
      label: "auth api"
      # additional customized data that would be used to run this step
      # the first character of the field name must be uppercase
      data:
        # test case selector
        Selector: "TODO"
        # test case uuid(mongo object id)
        Uuid: "5b4c4ff30207459803bfb3df"
  - step:
       type: nap
       label: "get user list"
       data:
         Uuid: "5b4c50210207459803bfb3e0"
```

type用来hook对应的代码，label用来标记step，data用来指明测试用例及相关数据。如果你要编排自己的测试用例，可能需要开发一个自己的step，会golang应该就很轻松。

### 后续

看完之后是不是觉得很简单?目前这个构思和实现能够满足我们的需求，随着测试用例从代码仓库移植到nap-tcm, 肯定会遇到一些问题，也会带来一些改进。如果你有更好的建议也可以跟我联系，或者提pr/issue。

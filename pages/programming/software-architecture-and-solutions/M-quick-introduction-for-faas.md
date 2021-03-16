# FaaS 简介

作者: [songtianyi](http://songtianyi.info)

### 前言

FaaS(Function as a service)是最近几年兴起的 serverless 架构的计算服务(computing services)。早在 2010 年，就有一些初创公司提供这类服务，如 PiCloud, 你可以编写 job(function)并远程调用(Cloud.call), 然后获取到执行结果(Cloud.result). 在 2014 年 10 月 13，亚马逊发布了自己的 FaaS 服务 Lambda, Google/Microsoft/IBM 也在 2016 年相继推出了自己的 faas 服务，2017 年 oracle 推出了 cloud fn.

### FaaS VS Serverless

serverless 是一种架构模型，旨在向开发者屏蔽应用部署的几乎所有细节，开发者也无需关心应用的伸缩。faas 是基于 serverless 架构的一种服务，用户只需提供自己的逻辑，faas 服务可以调动海量的计算资源来运行这段逻辑并返回结果。

### Faas VS PaaS

* 用户在使用 PaaS 服务的时候仍然需要主动申请资源，自己去考虑扩容或者缩容，而 faas 则不需要
* paas 服务始终有一个 server 在运行并提供服务，一直在消耗资源，哪怕没有请求进来，而 faas 只会在用户发起请求的时候启动 server 并消耗资源，属于真正的按需计算

### 上手实践

1. 在 https://stdlib.com 上注册一个账号

2. 本地安装

   

``` bash
   npm install lib.cli -g
   ```

3. 创建并部署自己的应用

   

``` shell
   mkdir stdlib-workspace
   cd stdlib-workspace
   # 初始化
   lib init
   # 创建
   lib create default
   # cd 到 default 目录执行
   lib .
   # 部署
   lib up dev
   # 调用
   lib songtianyi.default[@dev]
   # 传参
   lib songtianyi.uppercase[@dev] --name "asf"
   ```

### Faas 的现状

* 布局者众多，主流云厂商(国外 aws, google cloud, azure, 国内腾讯，阿里，华为)都已支持 faas，和自身产品及服务集成度最高的是 aws
* 主流 function 语言是 js，这取决于语言的自身特性
* 开源项目众多

![faas-opensource](https://songtianyi-blog.oss-cn-shenzhen.aliyuncs.com/faas-opensource.jpg)

* 应用场景

  + 微服务
  + 视频/图片(今日头条大规模视频处理的挑战与应对, UCloud UGC)
  + 流式事件处理
  + 事件驱动架构
  + IoT
  + 跨云/混合云
  + 边缘计算(edge computing, 雾计算)

* landscape

  

![image](https://songtianyi-blog.oss-cn-shenzhen.aliyuncs.com/cncf-serverless-landscape.png)

### Faas 的未来

* cncf(wg-serverless)
* faaslang
* [cloudevents](https://github.com/cloudevents/spec)
* firecracker

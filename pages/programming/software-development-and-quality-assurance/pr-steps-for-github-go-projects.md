#  Github Go 项目 PR 方式

作者: [songtianyi](http://songtianyi.info) 2018-09-14

### 前言

由于 Go 的 import 路径限制，fork 出来的 Go 项目不能使用 fork 后的路径编译，只能使用源代码的路径。

### PR

这里以 golory 项目和我自己的账户来举例。

##### 简洁方式

- fork golory 到 songtianyi 的账户下

  登录账户，在 1pb-club/golory 项目主页点击**fork**按钮

- 将 fork 仓库 clone 到本地, 并指定目录

  ```bash
  git clone https://github.com/songtianyi/golory.git $GOPATH/src/github.com/1pb-club/golory
  ```

- 修改代码/commit/push 等操作

- 创建 pr，将远程的 songtianyi/golory 合并到远程的 1pb-club/golory

##### 通用方式

简洁方式的前提是你不会编辑 1pb-club/golory 仓库下的代码，因为它被 fork 代码覆盖了，当这个前提不成立的时候可以使用下面的方法。

* fork golory 到 songtianyi 的账户下

  登录账户，在 1pb-club/golory 项目主页点击**fork**按钮

* 将 fork 仓库 clone 到本地

  ```bash
  git clone https://github.com/songtianyi/golory.git
  ```

* 将 1pb-club/golory 的远程仓库设置为本地 songtianyi/golory 的 remote，命名为 upstream

  ```bash
  cd $YOUR_FORKED_PATH_PREFIX/songtianyi/golory
  git remote add upstream https://github.com/1pb-club/golory.git
  ```

* 本地 songtianyi/golory(即 fork)和远程 1pb-club/golory 的代码同步方式 (master 可以替换成其他分支)

  ```bash
  cd $YOUR_FORKED_PATH_PREFIX/songtianyi/golory
  git pull upstream master
  ```

* 本地 songtianyi/golory 和远程 songtianyi/golory 的代码同步方式

  ```bash
  cd $YOUR_FORKED_PATH_PREFIX/golory
  git push origin master
  ```

* 获取源 1pb-club/golory 源代码

  ```bash
  go get github.com/1pb-club/golory
  ```

* 将远程的 songtianyi/golory 设置为本地 1pb-club/golory 的 remote，命名为 fork

  ```bash
  cd $GOPATH/src/github.com/1pb-club/golory
  git remote -v
  git remote add fork https://github.com/songtianyi/golory.git
  git remote -v
  ```

* 在本地 1pb-club/golory 修改代码并 build

* 将本地 1pb-club/golory 的 commit 推送到远程的 songtianyi/golory

  ```bash
  git push fork master
  ```

* 创建 pr，将远程的 songtianyi/golory 合并到远程的 1pb-club/golory

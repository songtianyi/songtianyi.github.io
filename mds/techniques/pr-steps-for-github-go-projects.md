#  Github Go项目PR方式

作者: [songtianyi](http://songtianyi.info) 2018-09-14

### 前言

由于Go的import路径限制，fork出来的Go项目不能使用fork后的路径编译，只能使用源代码的路径。

### PR

这里以golory项目和我自己的账户来举例。

##### 简洁方式

- fork golory到songtianyi的账户下

  登录账户，在1pb-club/golory项目主页点击**fork**按钮

- 将fork仓库clone到本地, 并指定目录

  ```bash
  git clone https://github.com/songtianyi/golory.git $GOPATH/src/github.com/1pb-club/golory
  ```

- 修改代码/commit/push等操作

- 创建pr，将远程的songtianyi/golory合并到远程的1pb-club/golory

##### 通用方式

简洁方式的前提是你不会编辑1pb-club/golory仓库下的代码，因为它被fork代码覆盖了，当这个前提不成立的时候可以使用下面的方法。

* fork golory到songtianyi的账户下

  登录账户，在1pb-club/golory项目主页点击**fork**按钮

* 将fork仓库clone到本地

  ```bash
  git clone https://github.com/songtianyi/golory.git
  ```

* 将1pb-club/golory的远程仓库设置为本地songtianyi/golory的remote，命名为upstream

  ```bash
  cd $YOUR_FORKED_PATH_PREFIX/songtianyi/golory
  git remote add upstream https://github.com/1pb-club/golory.git
  ```

* 本地songtianyi/golory(即fork)和远程1pb-club/golory的代码同步方式, master可以替换成其他分支

  ```bash
  cd $YOUR_FORKED_PATH_PREFIX/songtianyi/golory
  git pull upstream master
  ```

* 本地songtianyi/golory和远程songtianyi/golory的代码同步方式

  ```bash
  cd $YOUR_FORKED_PATH_PREFIX/golory
  git push origin master
  ```

* 获取源1pb-club/golory源代码

  ```bash
  go get github.com/1pb-club/golory
  ```

* 将远程的songtianyi/golory设置为本地1pb-club/golory的remote，命名为fork

  ```bash
  cd $GOPATH/src/github.com/1pb-club/golory
  git remote -v
  git remote add fork https://github.com/songtianyi/golory.git
  git remote -v
  ```

* 在本地1pb-club/golory修改代码并build

* 将本地1pb-club/golory的commit推送到远程的songtianyi/golory

  ```bash
  git push fork master
  ```

* 创建pr，将远程的songtianyi/golory合并到远程的1pb-club/golory
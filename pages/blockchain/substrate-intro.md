# Substrate Introduction

作者: songtianyi create@2022-07-09, WIP

## 什么是 Substrate

Substrate 是 Ethereum 创始人之一 [Gravin Wood](https://en.wikipedia.org/wiki/Gavin_Wood) 另起炉灶开发的一个基于 Rust 的区块链开发框架。基于 Substrate 框架，普通开发者能够快速开发出以太坊级别(技术方面)的区块链。比较知名的是 Parity 的 Polkadot. 在 Polkadot 出现之前，区块链有两种玩法，一种是基于 Ethereum EVM 去做合约上的创新，一种是把 Ethereum 复制过来，改改代码做共识或者其它方面的技术创新，甚至去构建自己的生态。而 Polkadot 的出现让链与链之间的互操作变得更加方便，你可以在 Polkadot 上玩合约，像 Ethereum 生态一样；也可以自己基于 Substrate 去快速开发出自己的新链，引入自己的共识，甚至虚拟机; 可以自己单玩，也可以以 parachain 的形式接入到 Polkadot 的大生态里面。从技术的角度讲，Polkadot 比 Ethereum 更加先进，但生态方面，Polkadot 还不足以挑战 Ethereum，目前仍然是强者恒强的局面。

Substrate 有着自己的显著特征:
* 模块化设计，二次开发极为方便
* 通过 [XCM](https://wiki.polkadot.network/docs/learn-crosschain) 和 [bridges](https://wiki.polkadot.network/docs/learn-bridges) 显著增加了链与链之间的互操作性。
* 升级更加方便，不太容易出现分叉
* 可以独立运行，也可以接入 relay chain，比如 Polkadot 或者 Kusama

## 架构

很容易想到，Substrate 作为链的开发框架，至少得有两部分，公共部分和自定义逻辑部分。公共部分用来解决网络、通信、存储、共识、监控等基本问题，自定义逻辑部分用来方便开发者编写和发布自己的应用逻辑。

<img src="https://songtianyi-blog.oss-cn-shenzhen.aliyuncs.com/sub-arch-1.avif" width="30%">

用术语来讲的话，这两部分分别是 Outer node 和 WebAssembly Runtime. Outer node 除了图中所列的几个核心功能外，还有:
* Execution environments: 负责将请求分发给不同的执行环境，Substate 支持 Runtime 以两种方式执行，WebAssembly 和 native Rust

Substrate 框架的代码结构分为三个主要层次:
 - Substrate Core: 对应 Outer Node 部分
 - Substrate FRAME: Framework for Runtime Aggregation of Modularized Entities, 主要是方便开发者开发自己的 Runtime, 它们称为 [pallet](https://docs.substrate.io/reference/glossary/#pallet)
 - Substrate Node

 <img src="https://songtianyi-blog.oss-cn-shenzhen.aliyuncs.com/technical-freedom.avif" width="30%">

## Runtime

Runtime 包含了所有的业务逻辑，包括校验和执行 transaction, 和 Outer node 交互等等。Runtime 可以编译成 WebAssembly, 它能够带来以下好处:
* Support for forkless upgrades.
* Multi-platform compatibility.
* Runtime validity checking.
* Validation proofs for relay chain consensus mechanisms.

和其它的 blockchain 一样，基于 Substrate 的 blocchain 也是一个分布式的账本，或者说是一个分布式数据库，Runtime 相当于是 state transition function, 负责改变和存储状态。

<img src="https://songtianyi-blog.oss-cn-shenzhen.aliyuncs.com/state-transition-function.avif" width="30%">

在 Substrate 中, Outer node 是通过 Runtime 提供的 API 来获取一些信息的。 `sp_api` crate 提供了一个 `interface` 让大家可以借助 [ `impl_runtime_apis` ](https://paritytech.github.io/substrate/master/sp_api/macro.impl_runtime_apis.html) macro 实现自己的 API.

大部分基于 Substate 的链都实现了下面几个 API(interface):

* *BlockBuilder* for the functionality required to build a block.
* *TaggedTransactionQueue* for validating transactions.
* *OffchainWorkerApi* for enabling offchain operations.
* *AuraApi* for block authoring and validation using a round-robin method of consensus.
* *SessionKeys* for generating and decoding session keys.
* *GrandpaApi* for block finalization into the runtime.
* *AccountNonceApi* for querying transaction indices.
* *TransactionPaymentApi* for querying information about transactions.
* *Benchmark* for estimating and measuring execution time required to complete transactions.

除了这些， `Core` 和 `Metadata` interface 是必须要实现的。

我们可以自行编码实现自己的 Runtime, 也可以借助 FRAME. FRAME 提供了很多实用的 pallet. 我们从这些内置的 pallet 中挑选一些出来就可以构造出特定场景使用的区块链。

<img src="https://songtianyi-blog.oss-cn-shenzhen.aliyuncs.com/compose-runtime.avif" width="30%">

FRAME 还提供了一些基础库和 pallet, 我们开发的时候都会用到:
* FRAME system crate: `frame_system` provides low-level types, storage, and functions for the runtime.
* FRAME support crate: `frame_support` is a collection of Rust macros, types, traits, and modules that simplify the development of Substrate pallets.
* FRAME executive pallet: `frame_executive` orchestrates the execution of incoming function calls to the respective pallets in the runtime.

## node-template

node-template 是 Parity 官方提供的基于 Substrate 的一个可用的区块链样例。 根据[指引](https://docs.substrate.io/quick-start/) 可以编译启动 template 节点。在启动之前你需要详细看下 node-template 的[子命令及启动选项](https://docs.substrate.io/reference/command-line-tools/node-template/)。
这里主要强调下节点的几种运行模式

#### archive nodes

`archive node` 会保存所有的 block, 方便 block explorer 等场景的使用，启动方式如下:

```shell
./target/release/node-template --pruning archive
```

#### full nodes

full node 是经过精简的，它只保存固定数量的区块数据以及创世区块(genesis block), 默认是保存 256 个区块。通过 validator 选项可以启动一个默认保存 256 个区块的 node:

```shell
./target/release/node-template --validator
```

也可以指定保存的区块的数量:

```shell
./target/release/node-template --validator --pruning 10
```

#### light client nodes

通过 `--light` 选项，你可以让节点以 light client 的模式运行。light client node 主要的作用是向外暴露接口，方便用户读取 block headers, 提交 transaction 等，不负责出块。你可以理解为它是 read-only 的，不会修改区块链的状态, 因此 light client node 只需要保存当前的状态。

```bash
./target/release/node-template --light
```

## node-template codebase

打开 node-template 的源码，可以看到源码中有三个主要目录
* node - cli, 自定义 rpc 接口等
* pallet - 自定义 runtime 逻辑，以 pallet 的形式封装，并在 runtime 目录被引入。代码中提供了一个 pallet 样例。
* runtime - 用于构造出最终的链上逻辑, 可以看到在 runtime 中是如何引入自定义的 pallet 的

```rust
/// Import the template pallet.
pub use pallet_template;

/// ...

/// Configure the pallet-template in pallets/template.
impl pallet_template::Config for Runtime {
	type Event = Event;
}

// Create the runtime by composing the FRAME pallets that were previously configured.
construct_runtime!(
	pub enum Runtime where
		Block = Block,
		NodeBlock = opaque::Block,
		UncheckedExtrinsic = UncheckedExtrinsic
	{
		System: frame_system,
		RandomnessCollectiveFlip: pallet_randomness_collective_flip,
		Timestamp: pallet_timestamp,
		Aura: pallet_aura,
		Grandpa: pallet_grandpa,
		Balances: pallet_balances,
		TransactionPayment: pallet_transaction_payment,
		Sudo: pallet_sudo,
		// Include the custom logic from the pallet-template in the runtime.
		TemplateModule: pallet_template,
	}
);
```

## pallets

在动手开发自己的 pallet 之前，我们需要了解并熟悉 substrate 提供的已有的 pallet.

#### System pallets

前面提到过，这里也不单独再做介绍，System pallets 更多的是在我们的开发过程中起一个辅助的作用。

#### Functional pallets

比较通用的功能型的 pallet, 开箱即用，还有人帮你维护。

###### [pallet_assets](https://paritytech.github.io/substrate/master/pallet_assets/index.html)

用来管理代币, 包括挖矿，转账，冻结，销毁等一系列操作。

## 参考资料

* [Polkadot Wiki](https://wiki.polkadot.network/)

# Oracle

作者: songtianyi create@2022-07-18

## Oracle Problem

在合约出现之前，区块链，像 bitcoin 这种，不同的节点之间是很容易达成共识的，因为每个节点的逻辑，状态都是完全同步的。合约出现之后，我们可以在合约中编写任意的应用逻辑，因而就出现了一种场景，在合约中调用 web2.0 服务的接口，以提供某种计算输入，比如某标的资产当前的价格。如果合约只是调用链上数据，和前面说的一样，链上数据是完全同步的，因而合约逻辑的计算结果自然应该是一致的，但如果调用了链下的数据，那就会出现一个问题，不同节点的同一个合约在执行的时候，调用链下 API 接口的结果是否都一致呢？如果不一致，怎么解决？此类链下数据的可用性、准确性、一致性、信任和安全问题被称为 Oracle Problem. 解决的方案不止一种，比如，对于资产价格这种场景，我可以容忍一定程度的误差，或者我的合约逻辑只要求价格大于某一个值，亦或者，我可以在一个节点上调用多次 API 接口，取他们的平均值等等。本文主要介绍各个不同的 Oracle Problem 解决方案。

## Decentralized interoperability solution

<img src="https://songtianyi-blog.oss-cn-shenzhen.aliyuncs.com/decentralized-interoperability-solution.jpg">

该方案的做法是引入第三方 oracle 服务。

> 之所以称为第三方，是因为 smart contract 的交互对象是 API，并不是 oracle，oracle 这一层属于额外的第三方。

smart contract 可以调 oracle 服务，而不是直接调 API, oracle 服务可以保证结果的一致性，至少对 smart contract 来说各个节点的调用结果是一致的。但存在的问题是，它的治理方式是中心化治理，而且它的数据来源并不一定可靠，此种方式的 oracle 服务，对不同的数据来源并不会区别对待。

## API3

API3 认为中间层的存在增加了攻击面，而且并不高效，因为 oracle 这一层也需要做去中心化，也需要从中分享收益，在 API3 看来，这一层是完全没必要的。另外，API3 认为，加了一层 oracle 服务，对 smart contract 来说，API 这一层就变得没有那么透明了，不便于开发者从质量、价格、便利性等方面作出自己的判断和选择。

API3 提出了一种 first-party oracles 的方法，如下图:

<img src="https://songtianyi-blog.oss-cn-shenzhen.aliyuncs.com/API3-mechanics.jpg" width="40%">

#### Decentralized APIs

API provider 可以运行自己的 oracle 节点，API3 称之为 Airnode. API provider 会对自己提供的 response 进行签名，防止自己的数据被恶意篡改，也不担心会在传输的过程中泄漏。

<img src="https://songtianyi-blog.oss-cn-shenzhen.aliyuncs.com/decentralized-apis.jpg" width="40%">

该方案除了解决 `Decentralized interoperability solution` 的种种问题之外，又从 API provider 的角度进行了以下改善:
* Airnode is designed to be deployed once by the API provider, then not require
any further maintenance
* It does not require the node operator to handle cryptocurrency at all. Its
protocol is designed in a way that the requester covers all gas costs. This is achieved by each Airnode having a separate wallet for each requester, similar
to how cryptocurrency exchanges automatically designate wallets for users to deposit
funds to. The requester funds this wallet with the native currency (e.g., ETH), either
in a lump sum or through per-request microtransactions. With the Airnode protocol, the API
providers do not have to concern themselves with gas costs, and can use typical
pricing models such as monthly subscription fees.
*  it is possible
to operate the containerized version of Airnode on-premises, yet using the serverless
version will be recommended for almost all use cases.
*  Airnode is planned to support the publish–subscribe pattern, where the
user requests the oracle to call back a specifific method when parametrized conditions
are met

API3 已经借助 data provider 提供了许多可用的 [APIs](https://api3.org/apis)

#### API3 DAO

Decentralized interoperability solution 采用的是中心化治理的方式，中心化治理的问题在于，管理实体(governing entity) 有权利修改 smart contract 和 oracle 之间的输入输出数据，如果 governing entity 作恶，会给用户造成巨大的损失。
API3 引入了 DAO, 所有持有 API3 token 的人都机会参与到 dAPI 的治理当中。特别的是，它并不是单一的 DAO, 而是由 main DAO + sub-DAOs 组成的 DAO<sup>2</sup>，如下图:

<img src="https://songtianyi-blog.oss-cn-shenzhen.aliyuncs.com/dao-square.jpg" width="50%">

通过更精细化的分组，将风险控制到最小。

#### API3 tokenomics

###### Coverage staking pool

API3 的 token 持有者，可以选择将自己的 token 质押到 `coverage staking pool` , 可以理解为它是一个保险池，当 dAPI user 遭受损失的时候，用来做赔付的，目前年化收益率为 14.72%, token 总量为 54, 871, 078.91

参与 API3 DAO 的治理可以直接获得 token 奖励。

#### dAPI Insurance

API3 开发了基于 Kleros 的链上保险服务，以此来弥补 dAPI user 因为 dAPI 的问题而导致的损失，API3 认为，即使他们不提供该项服务，dAPI user 也会基于自身利益的考虑去使用第三方的此类解决方案。dAPI user 会在订阅 dAPI 的时候收到一份特定的保险，API3 DAO 会评估风险及 user 的使用场景来确定数量。该数量也会随着 dAPI 的扩容而发生变化，因为扩容会增加风险。

#### Airnode Intro

Airnode 的意义在于，它可以方便 api provider 去跑自己的 oracle 节点，只需要关心自己的 api 逻辑即可，也不需要关心如何运维这个节点。对于 dAPI 的使用者，即 contract 的开发者来说，也很方便。

Airnode 最重要的事情是将 API user 的 contract 和 dAPI 的交互打通。

<img src="https://songtianyi-blog.oss-cn-shenzhen.aliyuncs.com/two-parts-of-airnode.jpg" width="30%">

API3 在各个 blockchain 中部署了一个 proxy contract, 叫 AirnodeRrpV0.sol, 目前应该只支持基于 EVM 的合约。API user 或者说 requester 的合约需要访问链下 API 数据的时候，先 call `AirnodeRrpV0` 的 `makeFullRequest` , proxy contract 会把请求数据记录到 event logs, event logs 就是链上和链下交互的关键。Airnode 会去 event logs 拿请求数据，然后执行请求，然后调用 proxy contract `fulfill` 接口，把执行结果塞给 proxy contract, proxy contract 再回调 requester 的 contract 把请求结果返回去。

<img src="https://songtianyi-blog.oss-cn-shenzhen.aliyuncs.com/developer-overview.a4d61dbe.png" width="30%">

###### API Integration

参考 [API3 Airnode notes](api3-airnode-notes.html)

## 参考资料

* [API3: Decentralized APIs for Web 3.0](https://drive.google.com/file/d/1GzkLKc6DYxImgeDhoKLA4wHGlE0eGGgo/view)
* [Airnode doc](https://docs.api3.org/airnode/latest)

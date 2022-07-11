# Darwinia Network 跨链方案

作者: songtianyi

### shadow service

shadow service 的主要目的是获取并验证区块，然后生成区块的 MMR(Merkle Mountain Range)，因为有些链并不是 MMR 结构(先忽略  shadow 在整个跨链中的作用)。
具体的方式是:

1. 通过链的 RPC 接口循环获取区块信息以及生成 MMR 所需的其它信息
2. 获取到的区块信息需要进行验证并处理，处理成后续 MMR 生成逻辑所需要的结构，这时候可以借助链的源码来帮助这一步的编码工作，也可以自己实现。如果借助链的源码就需要用 FFI 包一层
3. 用 Rust 实现 MMR 的生成逻辑，生成之后保存在 DB
4. 将 MMR 信息通过 API 接口或者 CLI 工具暴露给外部服务使用

代码结构大致如下:

```
├── api(step4)
│   ├── Cargo.toml
├── ffi(step1 and step2)
│   ├── Cargo.toml
├── mmr (step3 ckb-merkle-mountain-range)
│   ├── Cargo.toml
├── src(step4)
│   ├── bin
│   │   └── shadow.rs
│   ├── cmd
│   │   ├── count.rs
│   ├── mmr
│   │   ├── mod.rs
│   │   └── runner.rs
```

shadow service 新增一个链的支持需要考虑以下几点:

* RPC 接口: 地址，请求参数
* 区块验证: 不同的共识算法的区块验证方式有差异，即使区块结构相同
* [MMR](https://blog.csdn.net/liangyihuai/article/details/103129061): MMR 的生成和查询
* 接口: API, CLI

#### ethereum mainnet

etherum 主网使用的是 PoW 共识，区块结构如下

```go
// Block represents an entire block in the Ethereum blockchain.
type Block struct {
	header       *Header
	uncles       []*Header
	transactions Transactions

	// caches
	hash atomic.Value
	size atomic.Value

	// Td is used by package core to store the total difficulty
	// of the chain up to and including the block.
	td *big.Int

	// These fields are used by package eth to track
	// inter-peer block relay.
	ReceivedAt   time.Time
	ReceivedFrom interface{}
}

// Header represents a block header in the Ethereum blockchain.
type Header struct {
	ParentHash  common.Hash    `json:"parentHash"       gencodec:"required"`
	UncleHash   common.Hash    `json:"sha3Uncles"       gencodec:"required"`
	Coinbase    common.Address `json:"miner"            gencodec:"required"`
	Root        common.Hash    `json:"stateRoot"        gencodec:"required"`
	TxHash      common.Hash    `json:"transactionsRoot" gencodec:"required"`
	ReceiptHash common.Hash    `json:"receiptsRoot"     gencodec:"required"`
	Bloom       Bloom          `json:"logsBloom"        gencodec:"required"`
	Difficulty  *big.Int       `json:"difficulty"       gencodec:"required"`
	Number      *big.Int       `json:"number"           gencodec:"required"`
	GasLimit    uint64         `json:"gasLimit"         gencodec:"required"`
	GasUsed     uint64         `json:"gasUsed"          gencodec:"required"`
	Time        uint64         `json:"timestamp"        gencodec:"required"`
	Extra       []byte         `json:"extraData"        gencodec:"required"`
	MixDigest   common.Hash    `json:"mixHash"`
	Nonce       BlockNonce     `json:"nonce"`
}
```

PoW 的特点是计算复杂，验证相对简单, 且每个人都能出块。

```Go
type Header struct {
  Nonce [8]byte
  ...
}
```

通过不断修改 Nonce 的值并计算区块的 hash 值来得一个合法的(比如小于某一阈值)区块的过程就是我们通常所说的挖矿。 ethereum 的 PoW 实现命名为 ethash, 和标准 PoW 的实现大致一样，区别是:

* 区块验证增加了 MixDigest 字段
* 使用改动过的 `Dagger-Hashimoto` 算法生成 hash 值。该算法分为 Dagger 和 Hashimoto 两部分，Dagger 用来生成数据集(DAG)，增大内存消耗，防止算力攻击，Hashimoto 使用区块 Header 的哈希和 Nonce 字段以及 DAG 数据集生成一个最终的 hash(digest). DAG 的生成和 epoch 相关, 它的大小每过一个 epoch 就会增加。

#### huobi-eco-chain-to-darwinia

heco 链使用的是 PoA(Proof of Authority) + PoS(Proof of Stake) 的共识机制，而 heco 的代码是从 ethereum copy 过来的，所以 heco 链的共识是在 ethereum clique 的基础上改的。PoS 的逻辑是通过合约实现的，然后以 ABI 的形式调用。

> heco mainnet 的 epoch length 为 200, 出块周期为 3s, 参考 [Genesis](https://docs.hecochain.com/#/genesis)

虽然共识有差异，但是块结构是没有变化的，获取块数据的接口也没有变化。

```shell
# get recent block number
curl -s -H 'content-type:application/json' -X POST --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":83}' https://http-mainnet-node.huobichain.com
```

```shell
# get block by number
curl -s -H 'content-type:application/json' -X POST --data '{"jsonrpc":"2.0","method":"eth_getBlockByNumber","params":["0x39b857", false],"id":83}' https://http-mainnet-node.huobichain.com
```

* [heco chain mainnet](https://docs.hecochain.com/#/mainnet)
* [heco chain tetnet](https://docs.hecochain.com/#/testnet)

在 PoA 共识中，是由合格的验证人来出块，链在启动的时候会内置一些合格的验证人节点，这些验证人会轮流出块，出块时会附带投票信息，投票信息会决定下一个 epoch 的合格验证人列表。当 `blockNumber % epochLength == 0` 时，会产生一个不包含投票信息但包含当前签名者列表的块，这个 block 称之为 checkpoint

```Go
type Vote struct {
  Signer    common.Address // 此次投票是由谁投的
  Block     uint64         // 此次投票是在哪个高度的block上投的
  Address   common.Address // 此次投票是投给谁的
  Authorize bool           // 这是一个加入票（申请被投人成为签名者）还是踢出票（申请将被投人踢出签名者列表）
}

type Tally struct {
  Authorize bool // 这是加入票的统计还是踢出票的统计
  Votes     int  // 目前为止累计的票数
}
```

虽然 clique 相比 ethash, 区块结构并没有变化，但是字段的含义发生了变化:

* extra: genesis block - 32字节的前缀(extraVanity) + 所有signer的地址 + 65字节的后缀(extraSeal), 保存signer的签名, 其他 block 的 Extra 字段只包括 extraVanity 和 extraSeal
* Nonce: Nonce 字段存放投票信息: 添加(nonceAuthVote: 0xffffffffffffffff )或者移除(nonceDropVote: 0x0000000000000000)一个 signer
* Coinbase: Coinbase 字段存放被投票的地址，比如，signerA 的一个投票: 加入signerB, 那么 Coinbase 存放 B 的地址
* MixDigest: clique 没有使用这个值，初始化为 `common.Hash{}`, 校验的也是这个值

而 heco chain 的共识(congress 目录)相对于 clique 字段的意义也有些变化:

> signer 在 heco 里面改成了 validator

* Coinbase: congress 会把 validator 的地址放进 Coinbase, 而 clique 在 Prepare 的时候 Coinbase 被赋值为了 `common.Address{}`

| Fields   |      Ethash   |  Clique | HPoS(Congress) |
|:-:|:-------------:|:------:|:---------:|
| Extra |  -- | extraVanity + signers? + extraSeal | extraVanity + validators? + extraSeal|
| Nonce |    random hash | vote action | -- |
| Coinbase |  miner address | vote target address | validator address |
| MixDigest | for verifying | -- | -- |

块校验:

块结构和字段含义弄清楚以后就可以校验块了。 整个过程可以仿照共识代码当中的 `verifySeal` 来进行，snapshot 也可以通过接口拿到。 共识的 PoS 部分对块的校验没有影响，PoS 只负责选 validator 不负责出块逻辑。PoS 是每个 epoch 更新一次 validator 集合。

```Go
	// do epoch thing at the end, because it will update active validators
	if header.Number.Uint64()%c.config.Epoch == 0 {
		newValidators, err := c.doSomethingAtEpoch(chain, header, state)
		if err != nil {
			return err
		}

		validatorsBytes := make([]byte, len(newValidators)*common.AddressLength)
		for i, validator := range newValidators {
			copy(validatorsBytes[i*common.AddressLength:], validator.Bytes())
		}

		extraSuffix := len(header.Extra) - extraSeal
		if !bytes.Equal(header.Extra[extraVanity:extraSuffix], validatorsBytes) {
			return errInvalidExtraValidators
		}
	}
```

snapshot 核心逻辑:

```go
		// If we're at the genesis, snapshot the initial state. Alternatively if we're
		// at a checkpoint block without a parent (light client CHT), or we have piled
		// up more headers than allowed to be reorged (chain reinit from a freezer),
		// consider the checkpoint trusted and snapshot it.
		if number == 0 || (number%c.config.Epoch == 0 && (len(headers) > params.FullImmutabilityThreshold || chain.GetHeaderByNumber(number-1) == nil)) {
			checkpoint := chain.GetHeaderByNumber(number)
			if checkpoint != nil {
				hash := checkpoint.Hash()

				validators := make([]common.Address, (len(checkpoint.Extra)-extraVanity-extraSeal)/common.AddressLength)
				for i := 0; i < len(validators); i++ {
					copy(validators[i][:], checkpoint.Extra[extraVanity+i*common.AddressLength:])
				}
				snap = newSnapshot(c.config, c.signatures, number, hash, validators)
				if err := snap.store(c.db); err != nil {
					return nil, err
				}
				log.Info("Stored checkpoint snapshot to disk", "number", number, "hash", hash)
				break
			}
		}
```

snapshot 校验:

```Go
	if _, ok := snap.Validators[signer]; !ok {
		return errUnauthorizedValidator
	}
	for seen, recent := range snap.Recents {
		if recent == signer {
			// Validator is among recents, only fail if the current block doesn't shift it out
			if limit := uint64(len(snap.Validators)/2 + 1); seen > number-limit {
				return errRecentlySigned
			}
		}
	}
```

```Go
snap.Recents[number] = validator
```

#### binance-smart-chain-to-darwinia

bsc 和 heco chain 是完全一个套路，copy ethereum 然后修改共识，bsc 用的共识也是 PoA + DPoS(Deputy Proof of Stake), 取名为 PoSA(Proof of Staked Authority), 在代码里命名为 parlia. 所以这两个链在官网上没有技术白皮书，只有简单的介绍。因此，重点还是看 ethereum 的文档，然后看共识部分的代码。

> bsc mainnet 的 epoch length 为 200, 出块周期为 3s, 参考 [Genesis](https://github.com/binance-chain/bsc/releases/download/v1.0.0-alpha.0/binary.zip)

和 heco chain 的区别:

1. 对 gasLimit 和 gasFee 做了校验
2. authority set 生效的时间不同，heco 在 checkpoint block 修改并立即生效新的 authority set，而 bsc 在 checkpoint block 修改 authority set, 但会等待 N/2 个 block 才会使其生效。
3. 共识相关的 API 的 namespace 为 parlia

#### 共识代码对比

| Concepts   |      go-ethereum Clique   |  Heco Congress | BSC Parlia |
|:-:|:-------------:|:------:|:---------:|
| Namespace |  clique | congress | parlia |
| Snapshot | 根据 [Votes](https://github.com/HuobiGroup/huobi-eco-chain/blob/fd84c6482659118037ea9109c8d759e879a00dbe/consensus/clique/snapshot.go#L58) 更新 signer 列表| 从 [checkpoint extra data 获取最新的 signer](https://github.com/HuobiGroup/huobi-eco-chain/blob/fd84c6482659118037ea9109c8d759e879a00dbe/consensus/congress/snapshot.go#L155) | [RecentForkHashes](https://github.com/binance-chain/bsc/blob/032970b2deeffe3b7f87703753d7be9a09906758/consensus/parlia/snapshot.go#L46), [delay N/2 block](https://github.com/binance-chain/bsc/blob/032970b2deeffe3b7f87703753d7be9a09906758/consensus/parlia/snapshot.go#L191) |
| API | 通过 [proposal](https://github.com/stars-labs/heco-chain/blob/fd84c6482659118037ea9109c8d759e879a00dbe/consensus/clique/api.go#L107) 修改 authority set  | 去除了 vote 逻辑 | 去除了 vote 逻辑和 Status 接口 |
| ABI | -- | [Solidity contracts](https://github.com/HuobiGroup/huobi-eco-contracts/blob/master/contracts/Validators.sol) | [Solidity Contracts](https://github.com/binance-chain/bsc-genesis-contract/blob/3b1ed714e189a8fa4b482211f0a07053517b0dde/contracts/BSCValidatorSet.sol#L18) |
|  Core | - | [contracts](https://github.com/HuobiGroup/huobi-eco-chain/blob/fd84c6482659118037ea9109c8d759e879a00dbe/consensus/congress/congress.go#L562), [Verify ForkHash](https://github.com/HuobiGroup/huobi-eco-chain/blob/fd84c6482659118037ea9109c8d759e879a00dbe/consensus/congress/congress.go#L317) | [wiggleTime(1 second)](https://github.com/binance-chain/bsc/blob/032970b2deeffe3b7f87703753d7be9a09906758/consensus/parlia/parlia.go#L56), [Gas verify](https://github.com/binance-chain/bsc/blob/032970b2deeffe3b7f87703753d7be9a09906758/consensus/parlia/parlia.go#L406), [contracts](https://github.com/binance-chain/bsc/blob/032970b2deeffe3b7f87703753d7be9a09906758/consensus/parlia/parlia.go#L617), [SealHash 增加了 ChainID](https://github.com/binance-chain/bsc/blob/032970b2deeffe3b7f87703753d7be9a09906758/consensus/parlia/parlia.go#L1145), [delay 的计算更复杂](https://github.com/binance-chain/bsc/blob/032970b2deeffe3b7f87703753d7be9a09906758/consensus/parlia/parlia.go#L1176), [Verify ForkHash](https://github.com/binance-chain/bsc/blob/032970b2deeffe3b7f87703753d7be9a09906758/consensus/parlia/parlia.go#L367) |

### 验证

#### bsc header 的验证

substrate 需要验证 bsc 的 header 和交易信息，因此需要维护一个当前合法的 authority set
1. 设定一个初始的 checkpoint header
2. 从初始的 checkpoint header + epoch_length 开始提交 header，只需提交 1 + N/2 个，且第一个 header 是 checkpoint block header
3. 遍历所有 header
4. 针对提交的 header 做一些基础的检查
5. 从 header 中提取签名者，如果 N/2 个 header 的签名者都不同，且都是合法的，那么 checkpoint header 中的新的 authority set 就可以生效了。

## 参考资料

* [heco chain docs](https://docs.hecochain.com/#/)
* [eth json-rpc api](https://eth.wiki/json-rpc/api)
* [BSC Consensus](https://docs.binance.org/smart-chain/guides/concepts/consensus.html)

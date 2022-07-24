# Substrate off-chain worker

作者: songtianyi create@2022-07-24

## Features

相较于 Oracle 这类通过 events log 方式， substrate 提供了一种集成度更高的链上链下的数据交互方式。

* Off-chain worker 以 pallet 的形式存在于 substrate node, 但独立于 substrate runtime
* Off-chain worker 可以读写 substrate node 本地存储
* Off-chain worker 可以很方便地访问 on-chain 的数据
  > Access to the local keystore to sign and verify statements or transactions.
* Off-chain worker 中的业务的逻辑可以不限制执行时间，执行结果可以是 non-deterministic.
  + web requests
  + encryption/decryption and signing of data
  + random number generation
  + CPU-intensive computations
  + enumeration/aggregation of on-chain data
  + Access to the node's precise local time
  + The ability to sleep and resume work
* Off-chain worker 可以充当 client 的角色，向 substrate runtime 发送 transaction； 向 substrate node 外部发送 HTTP 请求并接收 response
* On-chain logic 可以通过 off-chain indexing 来将数据写入到 off-chain storage, 但只能写不能读

<img src="https://songtianyi-blog.oss-cn-shenzhen.aliyuncs.com/substrate-offchain-worker-arch.jpg">

#### Off-Chain Storage

Off-chain storage 只存在于当前节点，不会同步到其它节点，由于 off-chain worker 会在出块的时候被触发执行，且执行是异步的，所以会存在多个 worker 执行实例，如下图:

<img src="https://songtianyi-blog.oss-cn-shenzhen.aliyuncs.com/worker-entry.jpg">

在开发 worker 的时候要注意并发问题。

多个 worker 实例之间是可以共享 storage 的。storage 的内容可以从外部通过 rpc 来获取。

#### Off-Chain Indexing

除了 off-chain storage， substrate 提供了 off-chain indexing, 它是专门用于 on-chain logic 的，而 storage 主要用于 worker. off-chain indexing 会被同步到其它节点

## Developer guide

#### Entrypoint

```rust
decl_module! {
  pub struct Module<T: Trait> for enum Call where origin: T:: Origin {

    // --snip--

    fn offchain_worker(block: T::BlockNumber) {
      debug::info!("Hello World.");
    }

  }
}
```

`offchain_worker` 是固定的入口函数

#### Signed transaction

```rust
decl_module! {
  pub struct Module<T: Trait> for enum Call where origin: T:: Origin {

    // --snip--

    pub fn onchain_callback(origin, _block: T::BlockNumber, input: Vec<u8>) -> dispatch::Result {
      let who = ensure_signed(origin)?;
      debug::info!("{:?}", core::str::from_utf8(&input).unwrap());
      Ok(())
    }

    fn offchain_worker(block: T::BlockNumber) {
      // Here we specify the function to be called back on-chain in next block import.
      let call = Call::onchain_callback(block, b"hello world!".to_vec());
      T::SubmitSignedTransaction::submit_signed(call);
    }

  }
}
```

#### Unsigned transaction

```rust
decl_module! {
  pub struct Module<T: Trait> for enum Call where origin: T:: Origin {

    // --snip--

    pub fn onchain_callback(_origin, _block: T::BlockNumber, input: Vec<u8>) -> dispatch::Result {
      debug::info!("{:?}", core::str::from_utf8(&input).unwrap());
      Ok(())
    }

    fn offchain_worker(block: T::BlockNumber) {
      // Here we specify the function to be called back on-chain in next block import.
      let call = Call::onchain_callback(block, b"hello world!".to_vec());
      T::SubmitUnsignedTransaction::submit_unsigned(call);
    }

  }
}
```

去掉校验即可

#### Fetching External Data

```rust
use sp_runtime::{
  offchain::http,
  transaction_validity::{

    TransactionValidity, TransactionLongevity, ValidTransaction, InvalidTransaction

  }
}; // --snip--decl_module! {
  pub struct Module<T: Trait> for enum Call where origin: T:: Origin {

    // --snip--

    fn offchain_worker(block: T:: BlockNumber) {
      match Self::fetch_data() {
        Ok(res) => debug::info!("Result: {}", core::str::from_utf8(&res).unwrap()),
        Err(e) => debug::error!("Error fetch_data: {}", e),
      };
    }

  }
}impl<T: Trait> Module<T> {
  fn fetch_data() -> Result<Vec<u8>, &'static str> {

    // Specifying the request
    let pending = http::Request::get("https://min-api.cryptocompare.com/data/price?fsym=BTC&tsyms=USD")
      .send()
      .map_err(|_| "Error in sending http GET request")?;

    // Waiting for the response
    let response = pending.wait()
      .map_err(|_| "Error in waiting http response back")?;

    // Check if the HTTP response is okay
    if response.code != 200 {
      debug::warn!("Unexpected status code: {}", response.code);
      return Err("Non-200 status code returned from http request");
    }

    // Collect the result in the form of bytes
    Ok(response.body().collect::<Vec<u8>>())

  }
}
```

## 参考资料

* [off-chain features](https://core.tetcoin.org/docs/en/knowledgebase/learn-substrate/off-chain-features)

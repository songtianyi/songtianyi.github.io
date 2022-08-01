# Chainlink

## Chainlink vs API3

Chainlink 和 API3 在技术方案上并没有本质上的区别，但在实现的细节上有区别
* API3 的 接口定义是放进 airnode 的，而 chainlink 是直接放进 contract 里的，
* API3 和 chainlink 都有套一层 contract 壳 去做请求和回调，分别是 AirnodeRrpV0 和 ChainlinkClient
* Chainlink 的使用文档比 API3 要清晰，数据的使用方很容易上手。
* Chainlink 没有 airnode 的概念，但对于价格数据，有分布式的节点通过 ocr + aggregator 来完成
* Chainlink 的生态看起来比 API3 更好一些，即，Chainlink 目前走在 API3 前面
* Chainlink 的 API 请求是全部放在 contract 还是有单独的运行逻辑还不确定。

## Data feeds

Chainlink 已经集成好了一些第三方数据，供链上合约调用，主要是价格方面的数据。使用方式也很简单，在自己的 contract 里调用 chianlink 的 `Aggregator` contract 即可。

```js
// SPDX-License-Identifier: MIT
pragma solidity ^ 0.8 .7;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract PriceConsumerV3 {

    AggregatorV3Interface internal priceFeed;

    /**
     * Network: Rinkeby
     * Aggregator: ETH/USD
     * Address: 0x8A753747A1Fa494EC906cE90E9f37563A8AF630e
     */
    constructor() {
        priceFeed = AggregatorV3Interface(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);
    }

    /**
     * Returns the latest price
     */
    function getLatestPrice() public view returns(int) {
        (
            /*uint80 roundID*/
            ,
            int price,
            /*uint startedAt*/
            ,
            /*uint timeStamp*/
            ,
            /*uint80 answeredInRound*/
        ) = priceFeed.latestRoundData();
        return price;
    }
}
```

那 data feed 的数据从哪里来的呢？链下的去中心化 oracle 节点会用 OCR(off-chain reporting) 技术来 aggregate 数据

#### OCR

chainlink 用的 ocr 比较简单。选一个 leader 节点去接收其它节点上报的价格数据，组装数据, 发给其它节点去验证，没问题的话，leader 节点就组装最终的 report 发给其他节点。随机选一个节点，将 report 上报给 aggregator. `aggregator` 校验数据，没问题就取所有数据的 `median` value

## VRF

## Using Any API

```python
//SPDX-License-Identifier: MIT
pragma solidity ^ 0.8 .7;

import '@chainlink/contracts/src/v0.8/ChainlinkClient.sol';
import '@chainlink/contracts/src/v0.8/ConfirmedOwner.sol';

/**
 * Request testnet LINK and ETH here: https://faucets.chain.link/
 * Find information on LINK Token Contracts and get the latest ETH and LINK faucets here: https://docs.chain.link/docs/link-token-contracts/
 */

/**
 * THIS IS AN EXAMPLE CONTRACT THAT USES HARDCODED VALUES FOR CLARITY.
 * THIS IS AN EXAMPLE CONTRACT THAT USES UN-AUDITED CODE.
 * DO NOT USE THIS CODE IN PRODUCTION.
 */

contract MultiWordConsumer is ChainlinkClient, ConfirmedOwner {
    using Chainlink
    for Chainlink.Request;

    bytes32 private jobId;
    uint256 private fee;

    // multiple params returned in a single oracle response
    uint256 public btc;
    uint256 public usd;
    uint256 public eur;

    event RequestMultipleFulfilled(bytes32 indexed requestId, uint256 btc, uint256 usd, uint256 eur);

    /**
     * @notice Initialize the link token and target oracle
     * @dev The oracle address must be an Operator contract for multiword response
     *
     *
     * Rinkeby Testnet details:
     * Link Token: 0x01BE23585060835E02B77ef475b0Cc51aA1e0709
     * Oracle: 0xf3FBB7f3391F62C8fe53f89B41dFC8159EE9653f (Chainlink DevRel)
     * jobId: 53f9755920cd451a8fe46f5087468395
     *
     */
    constructor() ConfirmedOwner(msg.sender) {
        setChainlinkToken(0x01BE23585060835E02B77ef475b0Cc51aA1e0709);
        setChainlinkOracle(0xf3FBB7f3391F62C8fe53f89B41dFC8159EE9653f);
        jobId = '53f9755920cd451a8fe46f5087468395';
        fee = (1 * LINK_DIVISIBILITY) / 10; // 0,1 * 10**18 (Varies by network and job)
    }

    /**
     * @notice Request mutiple parameters from the oracle in a single transaction
     */
    function requestMultipleParameters() public {
        Chainlink.Request memory req = buildChainlinkRequest(
            jobId,
            address(this),
            this.fulfillMultipleParameters.selector
        );
        req.add('urlBTC', 'https://min-api.cryptocompare.com/data/price?fsym=ETH&tsyms=BTC');
        req.add('pathBTC', 'BTC');
        req.add('urlUSD', 'https://min-api.cryptocompare.com/data/price?fsym=ETH&tsyms=USD');
        req.add('pathUSD', 'USD');
        req.add('urlEUR', 'https://min-api.cryptocompare.com/data/price?fsym=ETH&tsyms=EUR');
        req.add('pathEUR', 'EUR');
        sendChainlinkRequest(req, fee); // MWR API.
    }

    /**
     * @notice Fulfillment function for multiple parameters in a single request
     * @dev This is called by the oracle. recordChainlinkFulfillment must be used.
     */
    function fulfillMultipleParameters(
        bytes32 requestId,
        uint256 btcResponse,
        uint256 usdResponse,
        uint256 eurResponse
    ) public recordChainlinkFulfillment(requestId) {
        emit RequestMultipleFulfilled(requestId, btcResponse, usdResponse, eurResponse);
        btc = btcResponse;
        usd = usdResponse;
        eur = eurResponse;
    }

    /**
     * Allow withdraw of Link tokens from the contract
     */
    function withdrawLink() public onlyOwner {
        LinkTokenInterface link = LinkTokenInterface(chainlinkTokenAddress());
        require(link.transfer(msg.sender, link.balanceOf(address(this))), 'Unable to transfer');
    }
}
```

和 API3 的明显区别是，API3 将请求的内容放进了 airnode，而 chainlink 是放进合约里的，相比之下，chainlink 的做法要更为灵活。

#### Existing Job Request

existing job 是一些预定好请求内容的 job (注意代码中的 jobId), 可以直接用，contract 负责接收数据即可。

```JS
// SPDX-License-Identifier: MIT
pragma solidity ^ 0.8 .7;

import '@chainlink/contracts/src/v0.8/ChainlinkClient.sol';
import '@chainlink/contracts/src/v0.8/ConfirmedOwner.sol';

/**
 * Request testnet LINK and ETH here: https://faucets.chain.link/
 * Find information on LINK Token Contracts and get the latest ETH and LINK faucets here: https://docs.chain.link/docs/link-token-contracts/
 */

/**
 * THIS IS AN EXAMPLE CONTRACT THAT USES HARDCODED VALUES FOR CLARITY.
 * THIS IS AN EXAMPLE CONTRACT THAT USES UN-AUDITED CODE.
 * DO NOT USE THIS CODE IN PRODUCTION.
 */

contract GetGasPrice is ChainlinkClient, ConfirmedOwner {
    using Chainlink
    for Chainlink.Request;

    uint256 public gasPriceFast;
    uint256 public gasPriceAverage;
    uint256 public gasPriceSafe;

    bytes32 private jobId;
    uint256 private fee;

    event RequestGasPrice(
        bytes32 indexed requestId,
        uint256 gasPriceFast,
        uint256 gasPriceAverage,
        uint256 gasPriceSafe
    );

    /**
     * @notice Initialize the link token and target oracle
     *
     * Rinkeby Testnet details:
     * Link Token: 0x01BE23585060835E02B77ef475b0Cc51aA1e0709
     * Oracle: 0xf3FBB7f3391F62C8fe53f89B41dFC8159EE9653f (Chainlink DevRel)
     * jobId: 7223acbd01654282865b678924126013
     *
     */
    constructor() ConfirmedOwner(msg.sender) {
        setChainlinkToken(0x01BE23585060835E02B77ef475b0Cc51aA1e0709);
        setChainlinkOracle(0xf3FBB7f3391F62C8fe53f89B41dFC8159EE9653f);
        jobId = '7223acbd01654282865b678924126013';
        fee = (1 * LINK_DIVISIBILITY) / 10; // 0,1 * 10**18 (Varies by network and job)
    }

    /**
     * Create a Chainlink request the gas price from Etherscan
     */
    function requestGasPrice() public returns(bytes32 requestId) {
        Chainlink.Request memory req = buildChainlinkRequest(jobId, address(this), this.fulfill.selector);
        // No need extra parameters for this job. Send the request
        return sendChainlinkRequest(req, fee);
    }

    /**
     * Receive the responses in the form of uint256
     */
    function fulfill(
        bytes32 _requestId,
        uint256 _gasPriceFast,
        uint256 _gasPriceAverage,
        uint256 _gasPriceSafe
    ) public recordChainlinkFulfillment(_requestId) {
        emit RequestGasPrice(_requestId, _gasPriceFast, _gasPriceAverage, _gasPriceSafe);
        gasPriceFast = _gasPriceFast;
        gasPriceAverage = _gasPriceAverage;
        gasPriceSafe = _gasPriceSafe;
    }

    /**
     * Allow withdraw of Link tokens from the contract
     */
    function withdrawLink() public onlyOwner {
        LinkTokenInterface link = LinkTokenInterface(chainlinkTokenAddress());
        require(link.transfer(msg.sender, link.balanceOf(address(this))), 'Unable to transfer');
    }
}
```

## Introduction to Chainlink Keepers

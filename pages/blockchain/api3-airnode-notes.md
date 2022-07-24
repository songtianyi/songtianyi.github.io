# API3 Airnode notes

作者: songtianyi create@2022-07-23

这篇文章是我自己跑通 API3 整个流程所涉及到的 contract, wallet, provider 等信息，并非讲解。更详细的讲解请参考官方文档。

## AirnodeRrp

* [Source code](https://github.com/api3dao/airnode/blob/v0.7/packages/airnode-protocol/contracts/rrp/requesters/RrpRequesterV0.sol)
* [Deployed on-chain contracts](https://docs.api3.org/airnode/v0.7/reference/airnode-addresses.html)

> Moombeam alpha testnet: 0xa0AD79D995DdeeB18a14eAef56A549A04e3Aa1Bd
>
> Eth Rinkeby: 0xa0AD79D995DdeeB18a14eAef56A549A04e3Aa1Bd

## Requester

[Example requester contracs](https://github.com/api3dao/airnode/tree/v0.7/packages/airnode-examples/contracts)

> My Moonbeam alpha contract: 0x9F1445F83758D8Dc7C07F5a282aa2573cfd0a8f6
>
> My Eth Rinkeby contract: 0x7254228c9EAaDd76EcaD80CDa8339BDd4B01577f

## Airnode address

```
npx @api3/airnode-admin generate-mnemonic
This mnemonic is created locally on your machine using "ethers.Wallet.createRandom" under the hood.
Make sure to back it up securely, e.g., by writing it down on a piece of paper:
taxi balance fine alert urban trip forum student question job hazard devote
The Airnode address for this mnemonic is: 0x2156217a193B4bC6c3c24012611D124310663060
The Airnode xpub for this mnemonic is: xpub6CBLYPPSoj1f5Lndxrqca5FcEpFi8nBPZQfvDc8gWPkprmUqqpBsJvdTzW9GzYqEXJtAR1nczHmpqefCPWLTBYFgss3Xh4vtUNYUapXVR2p
```

#### derive-airnode-address

```bash
❯ npx @api3/airnode-admin derive-airnode-address \
--airnode-mnemonic "taxi balance fine alert urban trip forum student question job hazard devote"
```

#### derive-airnode-xpub

```bash
npx @api3/airnode-admin derive-airnode-xpub --airnode-mnemonic "taxi balance fine alert urban trip forum student question job hazard devote"
```

## Sponsor a requester

#### Moonbeam alpha

```bash
npx @api3/airnode-admin sponsor-requester \
  --provider-url https://moonbeam-alpha.api.onfinality.io/public \
  --sponsor-mnemonic "aisle genuine false door mouse sustain caught flock pyramid sister scan disease" \
  --requester-address 0x9F1445F83758D8Dc7C07F5a282aa2573cfd0a8f6
```

> Requester address 0x9F1445F83758D8Dc7C07F5a282aa2573cfd0a8f6 is now sponsored by 0x944e24Ded49747c8278e3D3b4148da68e5B6672C

#### Rinkeby

```bash
npx @api3/airnode-admin sponsor-requester \
  --provider-url https://rinkeby.infura.io/v3/e5cbadfb7319409f981ee0231c256639 \
  --sponsor-mnemonic "aisle genuine false door mouse sustain caught flock pyramid sister scan disease" \
  --requester-address 0x7254228c9EAaDd76EcaD80CDa8339BDd4B01577f
```

> Requester address 0x7254228c9EAaDd76EcaD80CDa8339BDd4B01577f is now sponsored by 0x944e24Ded49747c8278e3D3b4148da68e5B6672C

## Run airnode

#### secrets.env

```
CHAIN_PROVIDER_URL="https://moonbeam-alpha.api.onfinality.io/public"
AIRNODE_WALLET_MNEMONIC="taxi balance fine alert urban trip forum student question job hazard devote"
```

#### Local run

```bash
docker run --detach \
  --net host \
  --volume "$(pwd)/config:/app/config" \
  --name quick-deploy-container-airnode \
  api3/airnode-client:0.7.2
```

## Make a request

#### derive-sponsor-wallet-address

```bash
npx @api3/airnode-admin derive-sponsor-wallet-address \
  --airnode-xpub xpub6CBLYPPSoj1f5Lndxrqca5FcEpFi8nBPZQfvDc8gWPkprmUqqpBsJvdTzW9GzYqEXJtAR1nczHmpqefCPWLTBYFgss3Xh4vtUNYUapXVR2p \
  --airnode-address 0x2156217a193B4bC6c3c24012611D124310663060 \
  --sponsor-address 0x944e24Ded49747c8278e3D3b4148da68e5B6672C
```

> Sponsor wallet address: 0xdb2E1351c5De993629e703b51A730D7A6Ed24271

#### Encoding script

[airenode-abi](https://docs.api3.org/airnode/v0.7/reference/packages/airnode-abi.html)

```typescript
import { encode } from '@api3/airnode-abi';

//const parameters = [
//  { type: 'string32', name: 'coinIds', value: 'api3' },
//  { type: 'string32', name: 'coinVs_currencies', value: 'usd' },
//];

const parameters = [
  { type: 'int256', name: 'price', value: '999' }
];
const encodedData = encode(parameters);

console.log(encodedData);
```

#### fill requester makeRequest call

> 0x2156217a193B4bC6c3c24012611D124310663060
>
> 0x6db9e3e3d073ad12b66d28dd85bcf49f58577270b1cc2d48a43c7025f5c27af6
>
> 0x944e24Ded49747c8278e3D3b4148da68e5B6672C
>
> 0xdb2E1351c5De993629e703b51A730D7A6Ed24271
>
> {abi encoding data}

###### Example request data

```json
{"coinIds":"api3", "coinVs_currencies":"usd"}
0x3173730000000000000000000000000000000000000000000000000000000000636f696e496473000000000000000000000000000000000000000000000000006170693300000000000000000000000000000000000000000000000000000000636f696e56735f63757272656e636965730000000000000000000000000000007573640000000000000000000000000000000000000000000000000000000000
```

## incomingFulfillments

## 参考资料

* [Airnode offcial doc v0.7](https://docs.api3.org/airnode/v0.7/)

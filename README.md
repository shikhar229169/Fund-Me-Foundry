# Fund-Me-Foundry

This reposiory contains the Fund-Me project which allows an individual to receive fundings from people and can withdraw these fundings into their wallets.

To deploy contract, run:
```
  forge script script/deployFundMe.s.sol --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY --broadcast -vvvv
```

To deploy contract and verify it, run:
```
  forge script script/deployFundMe.s.sol --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY --broadcast --verify --etherscan-api-key $ETHERSCAN_API_KEY -vvvv
```

To run test:
```
  forge test
```

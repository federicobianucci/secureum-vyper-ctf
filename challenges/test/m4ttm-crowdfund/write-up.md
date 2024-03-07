# m4ttm-crowdfund - Solution

## Find the vulnerability

This challenge seems to be hard because it contains code with many functions but if we look at requirements and setup we could easily find the solution. The `isSolved` function require that `self.totalSupply == 0`.

What function can we use? Burn function, but it has the check `assert _executor == self or _executor == self.owner or _executor == _from`.

However, if we look at test setup, we notice that we are contract's owner. Bingo!

## Exploit the contract

To pass the challenge call burn function for each accounts.

```solidity
for (uint256 i; i < accounts.length; i++) {
    crowdfund.burn(accounts[i], crowdfund.balanceOf(accounts[i]));
}
```

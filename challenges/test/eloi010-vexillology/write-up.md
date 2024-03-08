# eloi010-vexillology - Solution

## Find the vulnerability

Looking at the contract we immediatly notice that it's impossible to capture the flag using `set_captured` function. Inspecting the other functions the only different thing we note is the assignment `self.country_flag = ~Flag.INVERTED`.

Let's dive in on how enumsworks in vyper through this article: https://medium.com/@de33/enums-in-vyper-0-3-4-6ec2d387bc3a.

```
FOLDED      00001
HOISTED     00010
INVERTED    00100
HALF_MAST   01000
CAPTURED    10000
```

Inverting the INVERTED flag will result in 11011, not the CAPTURED flag.

However, inspectig the `isSolved` function, we notice the there is no equality check but `in`. As per vyper [doc](https://docs.vyperlang.org/en/stable/types.html?highlight=enums#enums):

> in is not the same as strict equality (==). in checks that any of the flags on two enum objects are simultaneously set, while == checks that two enum objects are bit-for-bit equal

Bingo!

## Exploit the contract

To exploit the contract we just need to call the `invert_flag` function.

```solidity
vyperVexillology.hoist_flag();
vyperVexillology.invert_flag();
```

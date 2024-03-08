# zac369-byte-brew - Solution

## Find the vulnerability

This is funniest challenge. We need to satisfiy `self.calculateHash() == 0x44151f2d1d75e470fe53e66a10133905bb427c52162de88f778835705f0c5b43`.

We only have this function:

```python
@external
def modify(numChars: uint256, slot: uint256):
    a: uint256 = numbers[slot % 7]
    self.generate(numChars)
    self.answerSlots[slot % 7] = a
```

It basically copy numbers from an array `numbers` to another array `answerSlots` that is used by `calculateHash` and it seems it calls an unusefull function in the middle. It can't work!

Let's investigate what that function do:

```python
@internal
def generate(numChars: uint256):
    tempA: String[31] = self.vypers[numChars % 32]
    tempB: String[32] = concat(tempA, "z")
```

It simply concat a "z" after a temp variable but we found this https://security.snyk.io/vuln/SNYK-PYTHON-VYPER-6179658. Bingo!
We can alter memory so we can alter `answerSlots` assignments. But how?

First we need to solve a logic problem. The problem:

```
"I went to the cafe to get some c0ffee" X2

0 170 0 52428 0 15658734 16777215

Problem:

"In the cozy cafe, patrons gathered to savor the rich c0ffee aroma wafting through the air.
The menu boasted many delicious f00d options, from hearty breakfasts to savory lunches.
Among the favorites were succulent beef dishes that satisfied even the most discerning palates.
For those seeking lighter options, there was the popular decaf c0ffee, allowing patrons to unwind without the caffeine jolt.
As the evening approached, some customers decided to call it an evening and went to bed." X2

? ? ? ? ? ? ?
```

If we put the constant array in hex it wil result in:

`[0, 0xaaaa...aaaa, 0xbbbb...bbbb, 0xcccc...cccc, 0xdddd...ddd, 0xeeee...eeee, 0xffff...ffff]`

Problem values 0 170 0 52428 0 15658734 16777215 are simply constants values shifted right by 32 minus the numbers of occurence in the phrase in the words that contains only that letters (including the 0). Boom!

cafe c0ffee -> 1a 0b 2c 0d 3e 3f

If we do the same to the other phrase we obtain 2a 2b 4c 3d 9e 8f

How can we achieve that? Remember `generate` function? Passing a specific `numChars` we can choose from `self.vypers` that is an array of string with different lengths, from 0 to 31, and concatenating z we obtain a maximum of 32 bytes length. So we can decide how to alter memory shifting right `a` variable (`a: uint256 = numbers[slot % 7]`) by numChars bytes where `numChars = 32 - occurence of letter`.

## Exploit the contract

```solidity
zacByteBrew.modify(32 - 2, 1);
zacByteBrew.modify(32 - 2, 2);
zacByteBrew.modify(32 - 4, 3);
zacByteBrew.modify(32 - 3, 4);
zacByteBrew.modify(32 - 9, 5);
zacByteBrew.modify(32 - 8, 6);
```

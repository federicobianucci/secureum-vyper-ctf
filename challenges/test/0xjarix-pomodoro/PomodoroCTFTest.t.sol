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

        pomodoro.setPomodoroNFTAddress(address(pomodoroNFT));
        address user1 = makeAddr("USER1");
        vm.deal(user1, 1e17);
        vm.prank(user1);
        (bool succ,) = address(pomodoroNFT).call{value: 1e17}(abi.encodeWithSignature("mint(address)", user1));
        require(succ, "mint failed");
        address user2 = makeAddr("USER2");
        vm.deal(user2, 1e17);
        vm.prank(user2);
        (succ,) = address(pomodoroNFT).call{value: 1e17}(abi.encodeWithSignature("mint(address)", user2));
        require(succ, "mint failed");
        address user3 = makeAddr("USER3");
        vm.deal(user3, 1e17);
        vm.prank(user3);
        (succ,) = address(pomodoroNFT).call{value: 1e17}(abi.encodeWithSignature("mint(address)", user3));
        require(succ, "mint failed");
        address user4 = makeAddr("USER4");
        vm.deal(user4, 1e17);
        vm.prank(user4);
        (succ,) = address(pomodoroNFT).call{value: 1e17}(abi.encodeWithSignature("mint(address)", user4));
        require(succ, "mint failed");
    }

    function test_pomodoroUnsolved() external {
        assertFalse(pomodoro.isSolved());
    }

    function test_pomodoroSolved() external {
        // attacker starts with 1e17 and can't deal ETH anymore
        address attacker = makeAddr("ATTACKER");
        vm.deal(attacker, 1e17);
        vm.startPrank(attacker);
        /*//////////////////////////////////////
        //     Write your solution here       //
        //////////////////////////////////////*/
        Exploiter exploiter = new Exploiter(address(pomodoro), address(pomodoroNFT));
        exploiter.mintAndStartWorkSession{value: 0.1 ether}();
        vm.warp(25 minutes + 1);
        exploiter.attack();

        assertTrue(pomodoro.isSolved());
    }
}

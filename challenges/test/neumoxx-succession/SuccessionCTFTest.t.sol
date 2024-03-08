// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {SuccessionCTFDeployer} from "script/neumoxx-succession/SuccessionCTFDeployer.s.sol";
import {ISuccessionCTFVy} from "src/neumoxx-succession/interfaces/ISuccessionCTFVy.sol";

/*///////////////////////////////////////////////
// Import dependencies for your solution here! //
//             (if you need any)               //
///////////////////////////////////////////////*/
import {ExploiterNoReentrancy} from "test/neumoxx-succession/ExploiterNoReentrancy.sol";
import {ExploiterReentrancy} from "test/neumoxx-succession/ExploiterReentrancy.sol";

contract SuccessionCTFTest is Test, SuccessionCTFDeployer {
    ISuccessionCTFVy public successionCTF;

    function setUp() public override(SuccessionCTFDeployer) {
        SuccessionCTFDeployer.setUp();

        successionCTF = ISuccessionCTFVy(deploySuccessionCTF());

        vm.deal(address(successionCTF), 1 ether);
    }

    function test_successionUnsolved() external {
        assertFalse(successionCTF.isSolved());
    }

    function test_successionSolved_noreentrancy() external {
        /*//////////////////////////////////////
        //     Write your solution here       //
        //////////////////////////////////////*/
        ExploiterNoReentrancy exploiter = new ExploiterNoReentrancy(address(successionCTF));
        exploiter.attack();

        assertTrue(successionCTF.isSolved());
    }

    function test_successionSolved_reentrancy() external {
        /*//////////////////////////////////////
        //     Write your solution here       //
        //////////////////////////////////////*/
        ExploiterReentrancy exploiter = new ExploiterReentrancy(address(successionCTF));
        exploiter.attack();

        assertTrue(successionCTF.isSolved());
    }
}

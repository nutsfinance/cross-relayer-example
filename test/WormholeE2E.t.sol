// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {IERC20} from "@openzeppelin/token/ERC20/IERC20.sol";
import {SlimRelayer} from "../src/SlimRelayer.sol";
import {IWormholeRelayer} from "../src/interfaces/IWormholeRelayer.sol";
import {CrossChainSender} from "../src/CrossChainSender.sol";
import {CrossChainReceiver, Target} from "../src/CrossChainReceiver.sol";
import {Token} from "../src/token/Token.sol";

contract WormholeE2E is Test {
    SlimRelayer slimRelayer;
    Token token;
    Target target;

    CrossChainSender sender;
    CrossChainReceiver receiver;

    uint16 immutable sourceChainId = 10_002; // Sepolia
    uint16 immutable targetChainId = 30; // Base
    address alice = address(12_345_678);

    function setUp() public {
        /// @dev Infrastructure
        slimRelayer = new SlimRelayer();
        token = new Token("Token", "TKN", targetChainId);
        target = new Target();

        /// @dev Actors
        sender = new CrossChainSender(address(slimRelayer), address(token));
        receiver = new CrossChainReceiver(address(target));
    }

    function testFuzzDeposit(uint256 deposit) public {
        (uint256 fee,) = sender.estimateDepositCosts(targetChainId);
        deposit = bound(deposit, fee + 1, 10_000 ether);

        vm.deal(alice, 10_000 ether);

        vm.prank(alice);
        sender.deposit{value: deposit}(targetChainId, address(receiver));

        /// @dev Turning the crank manually
        slimRelayer.performRecordedDeliveries();

        /// @dev Assertions
        assertEq(IERC20(token).balanceOf(alice), deposit - fee);
        assertEq(target.accountTokens(alice, sourceChainId), deposit - fee);
    }

    function testDeposit() public {
        (uint256 fee,) = sender.estimateDepositCosts(targetChainId);
        vm.deal(alice, 10_000 ether);

        console.log("Alice on TARGET chain");
        console.log("---------------------");
        console.log(
            "Balance BEFORE:", target.accountTokens(alice, sourceChainId)
        );
        assertEq(IERC20(token).balanceOf(alice), 0);
        assertEq(
            target.accountTokens(alice, sourceChainId),
            IERC20(token).balanceOf(alice)
        );

        vm.prank(alice);
        sender.deposit{value: 2.25 ether}(targetChainId, address(receiver));
        slimRelayer.performRecordedDeliveries();

        console.log(
            "Balance  AFTER:", target.accountTokens(alice, sourceChainId)
        );
        assertEq(IERC20(token).balanceOf(alice), 2.25 ether - fee);
        assertEq(
            target.accountTokens(alice, sourceChainId),
            IERC20(token).balanceOf(alice)
        );
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {IWormholeRelayer} from "./interfaces/IWormholeRelayer.sol";
import {DataTypes} from "./types/DataTypes.sol";
import {Token} from "./token/Token.sol";
import {IERC20} from "@openzeppelin/token/ERC20/IERC20.sol";

contract CrossChainSender {
    IWormholeRelayer public relayer;
    Token public token;

    mapping(uint16 => address) internal markets;

    constructor(address relayerAddress, address tokenAddress) {
        relayer = IWormholeRelayer(relayerAddress);
        token = Token(tokenAddress);
        markets[token.chainId()] = tokenAddress;
    }

    function deposit(
        uint16 targetChainId,
        address receiverAddress
    )
        external
        payable
    {
        require(msg.value > 0, "Zero collateral provided");

        (uint256 fee,) = estimateDepositCosts(targetChainId);
        require(msg.value > fee, "Not enough collateral provided");

        address marketAddress = markets[targetChainId];
        uint256 depositAmount = msg.value - fee;
        bytes memory payload = abi.encode(
            DataTypes.HubDeposit({
                action: DataTypes.Action.HUB_DEPOSIT,
                user: msg.sender,
                market: marketAddress,
                previousAmount: IERC20(token).balanceOf(msg.sender),
                amountIncreased: depositAmount
            })
        );
        (uint64 sequence) = relayer.sendPayloadToEvm{value: fee}(
            targetChainId, receiverAddress, payload, 0, 100_000
        );
        token.mint{value: depositAmount}(depositAmount, msg.sender);
        emit DepositInitiated(sequence);
    }

    function estimateDepositCosts(uint16 targetChainId)
        public
        view
        returns (uint256 price, uint256 refund)
    {
        (price, refund) =
            relayer.quoteEVMDeliveryPrice(targetChainId, 0, 100_000);
    }

    event DepositInitiated(uint64 sequence);
}

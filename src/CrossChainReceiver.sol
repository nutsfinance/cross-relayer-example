// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {ERC20} from "@openzeppelin/token/ERC20/ERC20.sol";
import {IWormholeReceiver} from "./interfaces/IWormholeReceiver.sol";
import {IGateway} from "./interfaces/IGateway.sol";
import {DataTypes} from "./types/DataTypes.sol";
import {Token} from "./token/Token.sol";

contract CrossChainReceiver is IWormholeReceiver {
    Target internal target;

    constructor(address _target) {
        target = Target(_target);
    }

    function receiveWormholeMessages(
        bytes memory payload,
        bytes[] memory, // skipping additionalVaas
        bytes32, // skipping sourceAddress
        uint16 sourceChainId,
        bytes32 // skipping deliveryHash
    )
        public
        payable
        override
    {
        DataTypes.HubDeposit memory params;
        assembly {
            mstore(add(params, 0), mload(add(payload, 0x20)))
            mstore(add(params, 0x20), mload(add(payload, 0x40)))
            mstore(add(params, 0x40), mload(add(payload, 0x60)))
            mstore(add(params, 0x60), mload(add(payload, 0x80)))
            mstore(add(params, 0x80), mload(add(payload, 0xa0)))
        }
        target.hubDeposit(params, sourceChainId);
    }
}

abstract contract State {
    /// @notice User's assets
    /// @dev user => chain => balance
    mapping(address => mapping(uint16 => uint256)) public accountTokens;
}

contract Target is State {
    function hubDeposit(
        DataTypes.HubDeposit memory params,
        uint16 sourceChainId
    )
        external
    {
        accountTokens[params.user][sourceChainId] += params.amountIncreased;
        emit DepositMade(sourceChainId, params.amountIncreased);
    }

    event DepositMade(uint16 sourceChainId, uint256 amountIncreased);
}

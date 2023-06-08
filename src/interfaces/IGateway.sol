// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

interface IGateway {
    function pike_send(
        uint256 targetChainId,
        bytes memory payload,
        address payable refundAddress,
        address fallbackAddress
    )
        external
        payable;

    function pike_receive(
        uint256 sourceChainId,
        bytes memory payload
    )
        external;
}

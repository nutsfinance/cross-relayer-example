// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {IERC20} from "@openzeppelin/token/ERC20/IERC20.sol";

interface IToken is IERC20 {
    /**
     * Allows minting
     * @param amount The amount deposited and to be minted
     * @param to The address of the user
     */
    function mint(uint256 amount, address to) external payable;
}

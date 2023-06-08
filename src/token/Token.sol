// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {ERC20} from "@openzeppelin/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/access/Ownable.sol";
import {IToken} from "../interfaces/IToken.sol";

contract Token is IToken, ERC20, Ownable {
    event CrossChainDeposit(address from, address to, uint256 amount);

    uint16 public immutable chainId;

    constructor(
        string memory _name,
        string memory _symbol,
        uint16 _chainId
    )
        ERC20(_name, _symbol)
    {
        chainId = _chainId;
    }

    /// @inheritdoc IToken
    function mint(uint256 amount, address to) external payable {
        _mint(to, amount);
    }

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    )
        internal
        virtual
        override
    {
        emit CrossChainDeposit(from, to, amount);
    }
}

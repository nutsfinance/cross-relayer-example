// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

library DataTypes {
    struct HubDeposit {
        Action action;
        address user;
        address market;
        uint256 previousAmount;
        uint256 amountIncreased;
    }

    enum Action {
        HUB_BORROW,
        HUB_DEPOSIT,
        HUB_REPAY,
        HUB_REDEEM
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IKeyringChecker} from "../../src/interfaces/IKeyringChecker.sol";

contract MockKeyringChecker is IKeyringChecker {
    bool public hasPermission = false;

    function checkCredential(uint256, address) external view returns (bool) {
        return hasPermission;
    }

    function setHasPermission(bool _hasPermission) external {
        hasPermission = _hasPermission;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IKeyringChecker} from "../../src/interfaces/IKeyringChecker.sol";

contract MockKeyringChecker is IKeyringChecker {
    mapping(uint256 => mapping(address => bool)) public credentials;

    function setCredential(uint256 policyId, address account, bool value) external {
        credentials[policyId][account] = value;
    }

    function checkCredential(uint256 policyId, address account) external view returns (bool) {
        return credentials[policyId][account];
    }
}

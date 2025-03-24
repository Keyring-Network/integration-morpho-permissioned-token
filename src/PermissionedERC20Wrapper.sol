// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;
import {IKeyringChecker} from "./interfaces/IKeyringChecker.sol";
import {Ownable} from "@openzeppelin-contracts/access/Ownable.sol";
import {ERC20PermissionedBase, IERC20} from "./base/ERC20PermissionedBase.sol";

/// @title  PermissionedERC20Wrapper
/// @notice Derived from the Centrifuge ERC20Wrapper contract (see https://github.com/centrifuge/morpho-market/blob/main/src/PermissionedERC20Wrapper.sol)
/// @dev    Extension of the ERC-20 token contract to support token wrapping and transferring for permissioned addresses.
///         Permissioned addresses are those with a credential from the keyring checker.
/// @author Modified from OpenZeppelin Contracts v5.0.0 (token/ERC20/extensions/ERC20Wrapper.sol)
contract PermissionedERC20Wrapper is ERC20PermissionedBase, Ownable {
    
    /// @notice The keyring checker contract.
    IKeyringChecker public keyringChecker;

    /// @notice The keyring policy ID.
    uint256 public keyringPolicyId;

    /// @notice Emitted when a new keyring checker and policy ID are set.
    event KeyringConfigUpdated(IKeyringChecker indexed newKeyringChecker, uint256 newKeyringPolicyId);

    /// @notice Constructor.
    /// @param _name The name of the token.
    /// @param _symbol The symbol of the token.
    /// @param _underlyingToken The underlying token.
    /// @param _morpho The morpho contract.
    /// @param _bundler The bundler contract.
    /// @param _keyringChecker The keyring checker contract.
    /// @param _keyringPolicyId The keyring policy ID.
    constructor(
        string memory _name,
        string memory _symbol,
        IERC20 _underlyingToken,
        address _morpho,
        address _bundler,
        IKeyringChecker _keyringChecker,
        uint256 _keyringPolicyId
    ) ERC20PermissionedBase(_name, _symbol, _underlyingToken, _morpho, _bundler) Ownable(msg.sender) {
        _transferOwnership(msg.sender);
        setKeyringConfig(_keyringChecker, _keyringPolicyId);
    }


    /// @inheritdoc ERC20PermissionedBase
    function hasPermission(address account) public view override returns (bool attested) {
        return account == address(0) || account == MORPHO || account == BUNDLER || (address(keyringChecker) == address(0) || keyringChecker.checkCredential(keyringPolicyId, account));
    }

    /// @notice Sets the keyring config.
    /// @param newKeyringChecker The new keyring checker.
    /// @param newKeyringPolicyId The new keyring policy ID.
    function setKeyringConfig(IKeyringChecker newKeyringChecker, uint256 newKeyringPolicyId) public onlyOwner {
        keyringChecker = IKeyringChecker(newKeyringChecker);
        keyringPolicyId = newKeyringPolicyId;

        emit KeyringConfigUpdated(newKeyringChecker, newKeyringPolicyId);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {PermissionedERC20Wrapper} from "../src/PermissionedERC20Wrapper.sol";
import {IKeyringChecker} from "../src/interfaces/IKeyringChecker.sol";
import {IERC20} from "@openzeppelin-contracts/token/ERC20/IERC20.sol";
import {MockKeyringChecker} from "./mock/MockKeyringChecker.sol";
import {MockERC20} from "./mock/MockERC20.sol";

contract PermissionedERC20WrapperTest is Test {
    PermissionedERC20Wrapper public wrapper;
    MockKeyringChecker public keyringChecker;
    MockERC20 public underlyingToken;
    address public owner;
    address public user1;
    address public user2;
    address public morpho;
    address public bundler;
    uint256 public constant POLICY_ID = 1;

    event KeyringConfigUpdated(IKeyringChecker indexed newKeyringChecker, uint256 newKeyringPolicyId);

    function setUp() public {
        owner = address(this);
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");
        morpho = makeAddr("morpho");
        bundler = makeAddr("bundler");

        keyringChecker = new MockKeyringChecker();
        underlyingToken = new MockERC20();
        wrapper = new PermissionedERC20Wrapper(
            "Wrapped Token", "wTKN", underlyingToken, morpho, bundler, keyringChecker, POLICY_ID
        );

        // Setup initial state
        underlyingToken.mint(user1, 1000e18);
        underlyingToken.mint(user2, 1000e18);
        vm.prank(user1);
        underlyingToken.approve(address(wrapper), type(uint256).max);
        vm.prank(user2);
        underlyingToken.approve(address(wrapper), type(uint256).max);
    }

    function test_InitialState() public {
        assertEq(address(wrapper.keyringChecker()), address(keyringChecker));
        assertEq(wrapper.keyringPolicyId(), POLICY_ID);
        assertEq(wrapper.owner(), owner);
    }

    function test_SetKeyringConfig() public {
        MockKeyringChecker newChecker = new MockKeyringChecker();
        uint256 newPolicyId = 2;

        vm.expectEmit(true, false, false, true);
        emit KeyringConfigUpdated(newChecker, newPolicyId);
        wrapper.setKeyringConfig(newChecker, newPolicyId);

        assertEq(address(wrapper.keyringChecker()), address(newChecker));
        assertEq(wrapper.keyringPolicyId(), newPolicyId);
    }

    function test_SetKeyringConfig_RevertWhen_NotOwner() public {
        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSelector(bytes4(keccak256("OwnableUnauthorizedAccount(address)")), user1));
        wrapper.setKeyringConfig(IKeyringChecker(address(0)), 0);
    }

    function test_HasPermission_WhenNoChecker() public {
        wrapper.setKeyringConfig(IKeyringChecker(address(0)), 0);
        assertTrue(wrapper.hasPermission(user1));
    }

    function test_HasPermission_WhenCheckerEnabled() public {
        keyringChecker.setCredential(POLICY_ID, user1, true);
        keyringChecker.setCredential(POLICY_ID, user2, false);

        assertTrue(wrapper.hasPermission(user1));
        assertFalse(wrapper.hasPermission(user2));
    }

    function test_Deposit_WhenPermitted() public {
        keyringChecker.setCredential(POLICY_ID, user1, true);
        uint256 amount = 100e18;

        vm.prank(user1);
        bool success = wrapper.depositFor(user1, amount);

        assertTrue(success);
        assertEq(wrapper.balanceOf(user1), amount);
        assertEq(underlyingToken.balanceOf(address(wrapper)), amount);
        assertEq(underlyingToken.balanceOf(user1), 900e18);
    }

    function test_Deposit_RevertWhen_NotPermitted() public {
        keyringChecker.setCredential(POLICY_ID, user1, false);
        uint256 amount = 100e18;

        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSelector(bytes4(keccak256("NoPermission(address)")), user1));
        wrapper.depositFor(user1, amount);
    }

    function test_Deposit_RevertWhen_InvalidReceiver() public {
        keyringChecker.setCredential(POLICY_ID, user1, true);
        uint256 amount = 100e18;

        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSelector(bytes4(keccak256("ERC20InvalidReceiver(address)")), address(wrapper)));
        wrapper.depositFor(address(wrapper), amount);
    }

    function test_Withdraw_WhenPermitted() public {
        keyringChecker.setCredential(POLICY_ID, user1, true);
        uint256 amount = 100e18;

        // First deposit
        vm.prank(user1);
        wrapper.depositFor(user1, amount);

        // Then withdraw
        vm.prank(user1);
        bool success = wrapper.withdrawTo(user1, amount);

        assertTrue(success);
        assertEq(wrapper.balanceOf(user1), 0);
        assertEq(underlyingToken.balanceOf(address(wrapper)), 0);
        assertEq(underlyingToken.balanceOf(user1), 1000e18);
    }

    function test_Withdraw_RevertWhen_NotPermitted() public {
        keyringChecker.setCredential(POLICY_ID, user1, false);
        uint256 amount = 100e18;

        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSelector(bytes4(keccak256("NoPermission(address)")), user1));
        wrapper.withdrawTo(user1, amount);
    }

    function test_Withdraw_RevertWhen_InvalidReceiver() public {
        keyringChecker.setCredential(POLICY_ID, user1, true);
        uint256 amount = 100e18;

        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSelector(bytes4(keccak256("ERC20InvalidReceiver(address)")), address(wrapper)));
        wrapper.withdrawTo(address(wrapper), amount);
    }

    function test_Transfer_WhenPermitted() public {
        keyringChecker.setCredential(POLICY_ID, user1, true);
        keyringChecker.setCredential(POLICY_ID, user2, true);
        uint256 amount = 100e18;

        // First deposit
        vm.prank(user1);
        wrapper.depositFor(user1, amount);

        // Then transfer
        vm.prank(user1);
        bool success = wrapper.transfer(user2, amount);

        assertTrue(success);
        assertEq(wrapper.balanceOf(user1), 0);
        assertEq(wrapper.balanceOf(user2), amount);
    }

    function test_Transfer_RevertWhen_NotPermitted() public {
        keyringChecker.setCredential(POLICY_ID, user1, true);
        keyringChecker.setCredential(POLICY_ID, user2, false);
        uint256 amount = 100e18;

        // First deposit
        vm.prank(user1);
        wrapper.depositFor(user1, amount);

        // Then transfer
        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSelector(bytes4(keccak256("NoPermission(address)")), user2));
        wrapper.transfer(user2, amount);
    }

    function test_Transfer_RevertWhen_InvalidReceiver() public {
        keyringChecker.setCredential(POLICY_ID, user1, true);
        uint256 amount = 100e18;

        // First deposit
        vm.prank(user1);
        wrapper.depositFor(user1, amount);

        // Then transfer
        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSelector(bytes4(keccak256("NoPermission(address)")), address(wrapper)));
        wrapper.transfer(address(wrapper), amount);
    }
}

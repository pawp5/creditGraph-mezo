// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console2} from "forge-std/Script.sol";

import {AccessController} from "../src/governance/AccessController.sol";
import {Roles} from "../src/libraries/Roles.sol";

/// @title GrantAllRoles
/// @notice Grants every protocol role to a single OPERATOR address.
/// @dev Must be broadcast by an account holding DEFAULT_ADMIN_ROLE (deployer).
///
/// Usage:
///   OPERATOR=0x2aD61279aec6c38229cC1DeFcE4b586f8abF9Ece \
///   PRIVATE_KEY=$PRIVATE_KEY \
///   forge script script/GrantAllRoles.s.sol:GrantAllRoles \
///     --rpc-url $ELYSIUM_TESTNET_RPC_URL --broadcast
///
/// Env:
///   PRIVATE_KEY        admin/deployer key (required for broadcast)
///   OPERATOR           address receiving all roles (defaults to 0x2aD6...F9Ece)
///   ACCESS_CONTROLLER  AccessController address (defaults to Elysium deployment)
contract GrantAllRoles is Script {
    // Elysium testnet (chain 99801) deployment from broadcast/Deploy.s.sol/99801/run-latest.json
    address internal constant DEFAULT_ACCESS =
        0x8B22193E104Da3A651A560E34573e77D5Da4192C;
    address internal constant DEFAULT_OPERATOR =
        0x2aD61279aec6c38229cC1DeFcE4b586f8abF9Ece;

    function run() external {
        uint256 pk = vm.envUint("PRIVATE_KEY");
        address accessAddr = vm.envOr("ACCESS_CONTROLLER", DEFAULT_ACCESS);
        address operator = vm.envOr("OPERATOR", DEFAULT_OPERATOR);

        require(operator != address(0), "GrantAllRoles: zero operator");
        require(accessAddr != address(0), "GrantAllRoles: zero access");

        AccessController access = AccessController(accessAddr);

        // 1 DEFAULT_ADMIN_ROLE (0x00) + 9 Roles-library roles = 10 total.
        bytes32[] memory roles = new bytes32[](10);
        address[] memory accounts = new address[](10);

        roles[0] = 0x00; // DEFAULT_ADMIN_ROLE
        roles[1] = Roles.PAUSER_ROLE;
        roles[2] = Roles.SCORE_UPDATER_ROLE;
        roles[3] = Roles.SLASHER_ROLE;
        roles[4] = Roles.POOL_MANAGER_ROLE;
        roles[5] = Roles.MINTER_ROLE;
        roles[6] = Roles.CLAIM_RECORDER_ROLE;
        roles[7] = Roles.INSURANCE_SPENDER_ROLE;
        roles[8] = Roles.BRIDGE_ROLE;
        roles[9] = Roles.CONFIG_ROLE;

        for (uint256 i; i < accounts.length; ++i) {
            accounts[i] = operator;
        }

        vm.startBroadcast(pk);
        access.grantRoles(roles, accounts);
        vm.stopBroadcast();

        for (uint256 i; i < roles.length; ++i) {
            console2.log("granted role:");
            console2.logBytes32(roles[i]);
            console2.log("  hasRole:", access.hasRole(roles[i], operator));
        }
        console2.log("OPERATOR ", operator);
        console2.log("ACCESS   ", accessAddr);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/// @title MockMUSD
/// @notice An 18-decimal stand-in for Mezo USD (MUSD) for local (Anvil) runs and
///         unit tests. Mirrors the real MUSD decimals so local behaviour matches
///         the Mezo testnet deployment.
/// @dev There is no faucet on the real MUSD token — on testnet you borrow it
///      against test BTC in the Mezo dApp. This mock exists so the protocol can
///      be exercised without a network; never deploy it to mainnet.
contract MockMUSD is ERC20 {
    constructor() ERC20("Mock Mezo USD", "MUSD") {}

    function decimals() public pure override returns (uint8) {
        return 18;
    }

    /// @notice Open faucet for demos: mint yourself test MUSD.
    function faucet(uint256 amount) external {
        _mint(msg.sender, amount);
    }

    /// @notice Mint to an arbitrary address (demo seeding).
    function mintTo(address to, uint256 amount) external {
        _mint(to, amount);
    }
}

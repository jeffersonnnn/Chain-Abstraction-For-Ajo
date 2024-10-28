# SavingsGroupPoC

**A Proof of Concept for Cross-Chain Savings Groups Using LayerZero and OpenZeppelin**

---

## Table of Contents

- [Overview](#overview)
- [Problem Statement](#problem-statement)
- [Solution](#solution)
- [Installation](#installation)
- [Usage](#usage)
- [Code Structure](#code-structure)
- [Example](#example)
- [Further Reading](#further-reading)
- [References](#references)
- [Additional Resources](#additional-resources)

---

## Overview

SavingsGroupPoC is a decentralized application (DApp) designed to facilitate cross-chain savings groups leveraging LayerZero's omnichain interoperability protocol and OpenZeppelin's robust contract standards. This Proof of Concept addresses and resolves compatibility issues between LayerZero's `NonblockingLzApp` and OpenZeppelin's `Ownable` contracts, ensuring seamless and secure cross-chain communications.

---

## Problem Statement

Integrating LayerZero's `NonblockingLzApp` with OpenZeppelin's latest `Ownable` contract (v5.0) introduces a critical inheritance compatibility issue:

```
Ownable <- LzApp <- NonblockingLzApp <- SavingsGroupPoC
```

- **OpenZeppelin's `Ownable` (v5.0):** Requires explicit owner initialization via its constructor.
- **LayerZero's `LzApp`:** Inherits from `Ownable` without passing an initial owner, resulting in a constructor initialization gap.

This mismatch prevents proper ownership initialization, compromising the contract's security and administrative controls.

---

## Solution

### Adapter Pattern Implementation

To resolve the inheritance compatibility issue, we introduce the `LzAppAdapter.sol` contract. This adapter acts as an intermediary between LayerZero's `NonblockingLzApp` and the user-facing `SavingsGroupPoC.sol`, ensuring proper initialization of both the LayerZero endpoint and ownership without modifying LayerZero's core contracts.

**Key Features of `LzAppAdapter.sol`:**

- **Inheritance Bridging:** Extends `NonblockingLzApp` and integrates `Ownable` to ensure proper ownership initialization.
- **Security Enhancements:** Restricts administrative functions to the contract owner using OpenZeppelin's `Ownable`.
- **Maintainability:** Preserves LayerZero's functionalities while enabling seamless integration with OpenZeppelin's ownership model.

```solidity:src/LzAppAdapter.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@layerzerolabs/solidity-examples/contracts/lzApp/NonblockingLzApp.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title LzAppAdapter
 * @dev An adapter contract that extends NonblockingLzApp to enhance error handling and ownership management.
 */
abstract contract LzAppAdapter is NonblockingLzApp, Ownable {
    constructor(address _endpoint) NonblockingLzApp(_endpoint) Ownable(msg.sender) {}
}
```

---

## Installation

### Prerequisites

- **Node.js & npm:** Ensure you have Node.js and npm installed.
- **Foundry:** A fast, portable, and modular toolkit for Ethereum application development.

### Clone Repository

```shell
git clone https://github.com/yourusername/SavingsGroupPoC.git
cd SavingsGroupPoC
```

### Install Dependencies

Install Foundry and other necessary dependencies:

```shell
curl -L https://foundry.paradigm.xyz | bash
foundryup
forge install
```

---

## Usage

### Build

Compile the smart contracts:

```shell
forge build
```

### Test

Run the test suite:

```shell
forge test
```

### Deploy

Deploy the contracts using Foundry scripts:

```shell
forge script script/Deploy.s.sol --rpc-url <your_rpc_url> --private-key <your_private_key>
```

---

## Code Structure

### `LzAppAdapter.sol`

An abstract contract that bridges LayerZero's `NonblockingLzApp` with OpenZeppelin's `Ownable`, ensuring proper ownership initialization and enhanced error handling.

```solidity:src/LzAppAdapter.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@layerzerolabs/solidity-examples/contracts/lzApp/NonblockingLzApp.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title LzAppAdapter
 * @dev An adapter contract that extends NonblockingLzApp to enhance error handling and ownership management.
 */
abstract contract LzAppAdapter is NonblockingLzApp, Ownable {
    constructor(address _endpoint) NonblockingLzApp(_endpoint) Ownable(msg.sender) {}
}
```

### `SavingsGroupPoC.sol`

The main contract implementing the savings group functionality with cross-chain capabilities using LayerZero.

```solidity:src/SavingsGroupPoC.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./LzAppAdapter.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title SavingsGroupPoC
 * @dev A Proof of Concept contract for Savings Groups utilizing LayerZero for cross-chain interactions.
 */
contract SavingsGroupPoC is LzAppAdapter {
    IERC20 public stablecoin;
    
    struct Group {
        uint256 contributionAmount;
        uint256 cycleLength;
        uint256 maxMembers;
        mapping(address => bool) members;
        uint256 memberCount;
    }
    
    mapping(uint256 => Group) public groups;
    uint256 public nextGroupId;

    uint16 constant MSG_CONTRIBUTE = 1;
    uint16 constant MSG_PAYOUT = 2;

    /**
     * @notice Constructor for SavingsGroupPoC
     * @param _lzEndpoint Address of the LayerZero endpoint
     * @param _stablecoin Address of the stablecoin ERC20 token
     */
    constructor(
        address _lzEndpoint,
        address _stablecoin
    ) LzAppAdapter(_lzEndpoint) {
        stablecoin = IERC20(_stablecoin);
    }
}
```

---

## Example

Here's a brief example of how to interact with the `SavingsGroupPoC` contract:

1. **Create a Savings Group:**

```solidity
uint256 groupId = savingsGroup.createGroup(100 * 10**18, 30 days, 10);
```

2. **Contribute to a Group:**

```solidity
savingsGroup.contribute(groupId, destinationChainId, { value: msg.value });
```

3. **Retrieve Group Details:**

```solidity
(uint256 contribution, uint256 cycle, uint256 maxMembers, uint256 currentMembers) = savingsGroup.getGroup(groupId);
```

---

## Further Reading

For an in-depth explanation of solving the inheritance compatibility issues and the thought process behind the `CustomLzApp` solution, please refer to my [blog post](https://dev.to/jeffersonnnn/solving-inheritance-compatibility-issues-between-layerzeros-nonblockinglzapp-and-openzeppelins-ownable-24lc-temp-slug-3582628?preview=6307afc987a4c6db110659af21ab972b1498224e31b412ca5a6a63504e5ecea0221a00c7e8a66109576893cae1fec130f3e76672bc118392a4a28789).

---

## References

- [Solving Inheritance Compatibility Issues Between LayerZero's NonblockingLzApp and OpenZeppelin's Ownable](https://dev.to/jeffersonnnn/solving-inheritance-compatibility-issues-between-layerzeros-nonblockinglzapp-and-openzeppelins-ownable-24lc-temp-slug-3582628?preview=6307afc987a4c6db110659af21ab972b1498224e31b412ca5a6a63504e5ecea0221a00c7e8a66109576893cae1fec130f3e76672bc118392a4a28789)
- [LayerZero V2 Integration Checklist](https://docs.layerzero.network/v2/developers/evm/technical-reference/integration-checklist)
- [LayerZero Overview](https://docs.layerzero.network/v2/developers/evm/overview)
- [LayerZero V1 Solidity Examples](https://github.com/LayerZero-Labs/solidity-examples)

---

## Additional Resources

- [Foundry Documentation](https://book.getfoundry.sh/)
- [LayerZero V2 Protocol Repository](https://github.com/LayerZero-Labs/LayerZero-v2)
- [OpenZeppelin Contracts](https://github.com/OpenZeppelin/openzeppelin-contracts)
- [LayerZero GitHub Repositories](https://github.com/LayerZero-Labs)
- [SavingsGroupPoC Repository](https://github.com/yourusername/SavingsGroupPoC)

---

Feel free to explore these resources to deepen your understanding and contribute to enhancing LayerZero's robust ecosystem.
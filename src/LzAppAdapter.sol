// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@layerzerolabs/solidity-examples/contracts/lzApp/NonblockingLzApp.sol";

abstract contract LzAppAdapter is NonblockingLzApp {
    constructor(address _endpoint) NonblockingLzApp(_endpoint) Ownable(msg.sender) {}
}
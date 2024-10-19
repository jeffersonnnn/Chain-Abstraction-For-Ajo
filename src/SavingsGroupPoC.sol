// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@layerzerolabs/solidity-examples/contracts/lzApp/NonblockingLzApp.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract SavingsGroupPoC is NonblockingLzApp {
    IERC20 public stablecoin;
    
    // Group storage
    struct Group {
        uint256 contributionAmount;
        uint256 cycleLength;
        uint256 maxMembers;
        mapping(address => bool) members;
        uint256 memberCount;
    }
    
    mapping(uint256 => Group) public groups;
    uint256 public nextGroupId;

    // Cross-chain message types
    uint16 constant MSG_CONTRIBUTE = 1;
    uint16 constant MSG_PAYOUT = 2;

    constructor(
        address _lzEndpoint,
        address _stablecoin
    ) NonblockingLzApp(_lzEndpoint) {
        stablecoin = IERC20(_stablecoin);
    }

    // Local chain functions
    function createGroup(
        uint256 _contributionAmount,
        uint256 _cycleLength,
        uint256 _maxMembers
    ) external returns (uint256) {
        uint256 groupId = nextGroupId++;
        Group storage group = groups[groupId];
        group.contributionAmount = _contributionAmount;
        group.cycleLength = _cycleLength;
        group.maxMembers = _maxMembers;
        group.members[msg.sender] = true;
        group.memberCount = 1;
        return groupId;
    }

    function contribute(uint256 _groupId, uint16 _dstChainId) external payable {
        Group storage group = groups[_groupId];
        require(group.members[msg.sender], "Not a member");
        
        // Transfer stablecoins to this contract
        stablecoin.transferFrom(msg.sender, address(this), group.contributionAmount);

        // Prepare cross-chain message
        bytes memory payload = abi.encode(
            MSG_CONTRIBUTE,
            _groupId,
            msg.sender,
            group.contributionAmount
        );

        // Send message to destination chain
        _lzSend(
            _dstChainId,
            payload,
            payable(msg.sender),
            address(0x0),
            bytes(""),
            msg.value
        );
    }

    // Cross-chain message handling
    function _nonblockingLzReceive(
        uint16 _srcChainId,
        bytes memory _srcAddress,
        uint64 _nonce,
        bytes memory _payload
    ) internal override {
        (uint16 messageType, uint256 groupId, address member, uint256 amount) = 
            abi.decode(_payload, (uint16, uint256, address, uint256));

        if (messageType == MSG_CONTRIBUTE) {
            // Handle contribution received from another chain
            // Update local state, trigger events, etc.
        } else if (messageType == MSG_PAYOUT) {
            // Handle payout request from another chain
            stablecoin.transfer(member, amount);
        }
    }

    // View functions
    function getGroup(uint256 _groupId) external view returns (
        uint256 contributionAmount,
        uint256 cycleLength,
        uint256 maxMembers,
        uint256 memberCount
    ) {
        Group storage group = groups[_groupId];
        return (
            group.contributionAmount,
            group.cycleLength,
            group.maxMembers,
            group.memberCount
        );
    }
}
// test/SavingsGroup.t.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/SavingsGroupPoC.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract SavingsGroupTest is Test {
    SavingsGroupPoC public savingsGroup;
    IERC20 public usdc;
    address public lzEndpoint;
    
    function setUp() public {
        // Use Sepolia fork for testing
        vm.createSelectFork(vm.envString("SEPOLIA_RPC_URL"));
        
        lzEndpoint = 0x6edce65403992e310a62460808c4b910d972f10f;
        usdc = IERC20(0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238);
        
        savingsGroup = new SavingsGroupPoC(lzEndpoint, address(usdc));
    }

    function testGroupCreation() public {
        uint256 contributionAmount = 100 * 1e6; // 100 USDC
        uint256 cycleLength = 30 days;
        uint256 maxMembers = 5;

        uint256 groupId = savingsGroup.createGroup(
            contributionAmount,
            cycleLength,
            maxMembers
        );

        (
            uint256 retContributionAmount,
            uint256 retCycleLength,
            uint256 retMaxMembers,
            uint256 retMemberCount
        ) = savingsGroup.getGroup(groupId);

        assertEq(retContributionAmount, contributionAmount);
        assertEq(retCycleLength, cycleLength);
        assertEq(retMaxMembers, maxMembers);
        assertEq(retMemberCount, 1); // Creator is first member
    }

    function testCrossChainContribution() public {
        // Setup group
        uint256 groupId = savingsGroup.createGroup(
            100 * 1e6,
            30 days,
            5
        );

        // Mock USDC balance
        deal(address(usdc), address(this), 1000 * 1e6);
        usdc.approve(address(savingsGroup), 100 * 1e6);

        // Get quote for cross-chain message
        (uint256 nativeFee,) = savingsGroup.quote(
            40232, // Optimism Sepolia EID
            abi.encode(1, groupId, address(this), 100 * 1e6),
            hex"0003010011010000000000000000000000000000c350",
            false
        );

        // Contribute
        vm.deal(address(this), nativeFee);
        savingsGroup.contribute{value: nativeFee}(groupId, 40232);
    }
}
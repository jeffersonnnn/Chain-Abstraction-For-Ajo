// script/Deploy.s.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/SavingsGroupPoC.sol";

contract DeployScript is Script {
    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // Deploy to the first chain
        SavingsGroupPoC savingsGroup = new SavingsGroupPoC(
            getLZEndpoint(),
            getStablecoin()
        );

        // If this is second chain deployment, set up peer
        if (block.chainid == getOptimismChainId()) {
            savingsGroup.setPeer(
                getSepoliaEid(),
                addressToBytes32(getSepoliaDeployment())
            );
        }

        vm.stopBroadcast();
    }

    function getLZEndpoint() internal view returns (address) {
        if (block.chainid == getSepoliaChainId()) {
            return 0x6edce65403992e310a62460808c4b910d972f10f; // Sepolia
        } else if (block.chainid == getOptimismChainId()) {
            return 0x6edce65403992e310a62460808c4b910d972f10f; // Optimism Sepolia
        }
        revert("Unsupported chain");
    }

    function getStablecoin() internal view returns (address) {
        if (block.chainid == getSepoliaChainId()) {
            return 0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238; // Sepolia USDC
        } else if (block.chainid == getOptimismChainId()) {
            return 0x5fd84259d66Cd46123540766Be93DFE6D43130D7; // Optimism Sepolia USDC
        }
        revert("Unsupported chain");
    }

    function getSepoliaChainId() internal pure returns (uint256) {
        return 11155111;
    }

    function getOptimismChainId() internal pure returns (uint256) {
        return 11155420;
    }

    function getSepoliaEid() internal pure returns (uint32) {
        return 40161;
    }

    function getOptimismEid() internal pure returns (uint32) {
        return 40232;
    }

    function getSepoliaDeployment() internal view returns (address) {
        return vm.envAddress("SEPOLIA_DEPLOYMENT");
    }

    function addressToBytes32(address addr) internal pure returns (bytes32) {
        return bytes32(uint256(uint160(addr)));
    }
}
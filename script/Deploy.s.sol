// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/SavingsGroupPoC.sol";

contract DeployScript is Script {
    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);
        vm.startBroadcast(deployerPrivateKey);

        // Deploy to the current chain
        SavingsGroupPoC savingsGroup = new SavingsGroupPoC(
            getLZEndpoint(),
            getStablecoin()
        );

        // If this is second chain deployment, configure trusted remote
        if (block.chainid == getOptimismChainId()) {
            bytes memory path = abi.encodePacked(getSepoliaDeployment(), address(savingsGroup));
            savingsGroup.setTrustedRemote(uint16(getSepoliaEid()), path);
        }

        // Transfer ownership to the deployer
        savingsGroup.transferOwnership(deployer);

        vm.stopBroadcast();
    }

    function getLZEndpoint() internal view returns (address) {
        if (block.chainid == getSepoliaChainId()) {
            return 0x6EDCE65403992e310A62460808c4b910D972f10f; // Sepolia
        } else if (block.chainid == getOptimismChainId()) {
            return 0x6EDCE65403992e310A62460808c4b910D972f10f; // Optimism Sepolia
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
}

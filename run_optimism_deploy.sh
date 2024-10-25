#!/bin/bash

# Load environment variables
source .env

# Run forge script
forge script script/Deploy.s.sol:DeployScript \
    --rpc-url "$OPTIMISM_SEPOLIA_RPC_URL" \
    --broadcast \
    --verify \
    --etherscan-api-key "$OPTIMISM_ETHERSCAN_API_KEY"

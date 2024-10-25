#!/bin/bash

# Load environment variables
source .env

# Run forge script
forge script script/Deploy.s.sol:DeployScript \
    --rpc-url "$SEPOLIA_RPC_URL" \
    --broadcast \
    --verify
#!/bin/bash

# Check if Azure CLI is installed
if ! command -v az &> /dev/null; then
    echo "Error: Azure CLI is not installed."
    exit 1
fi

# Check if tenant ID is provided as an argument
if [ $# -ne 1 ]; then
    echo "Usage: $0 TENANT_ID"
    exit 1
fi

TENANT_ID="$1"

# Authenticate with Azure CLI using specified tenant ID
az login --tenant "$TENANT_ID"

# Check if authentication was successful
if [ $? -ne 0 ]; then
    echo "Error: Failed to authenticate with Azure CLI."
    exit 1
fi

echo "Successfully authenticated with Azure CLI using specified tenant ID."
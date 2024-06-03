#!/bin/bash

#PREREQUISITI:
# azcli installed

######################################################
# enable strict mode
set -euo pipefail
trap 'echo -e "${RED}Error: Command failed with exit code $?${NC}" >&2' ERR
######################################################
# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

DATE=$(date +'%d/%m/%Y %H:%M')
# Get the name of the script
SCRIPT_NAME=$(basename "$0" .sh)
#LOG_FILE="$SCRIPT_NAME.log"

log_message() {
    echo "$DATE $1"
}

# Function to log error messages with color
log_error() {
    echo -e "$DATE ${RED}Error:${NC} $1"
}

# Function to log success messages with color
log_success() {
    echo -e "$DATE ${GREEN}Success:${NC} $1"
}

##################################################
# MAIN
##################################################
log_message "Starting script"

# VARIABLES:
TENANT_ID="$1"
SP_NAME="$2"
SUBSCRIPTION_ID=$(az account show --query 'id' -o tsv)

# Check if Azure CLI is installed
if ! command -v az &> /dev/null; then
    log_error "Error: Azure CLI is not installed."
fi

# Check if tenant ID is provided as an argument
if [ $# -ne 2 ]; then
    log_error "Usage: $0 <TENANT_ID> <SP_NAME>"
fi

# Authenticate with Azure CLI using specified tenant ID
az login --tenant "$TENANT_ID"

# Check if authentication was successful
if [ $? -ne 0 ]; then
    log_error "Error: Failed to authenticate with Azure CLI."
fi

log_success "Successfully authenticated with Azure CLI using specified tenant ID."

SP_OUTPUT=$(az ad sp create-for-rbac --name="$SP_NAME" --role="Contributor" --scopes="/subscriptions/$SUBSCRIPTION_ID")

# Check if authentication was successful
if [ $? -ne 0 ]; then
    log_error "Error: Failed to create sp with Azure CLI."
fi

log_success "SP creato correttamente"

CLIENT_ID=$(echo "$SP_OUTPUT" | jq -r '.appId')
TENANT_ID=$(echo "$SP_OUTPUT" | jq -r '.tenant')
SECRET_ID=$(echo "$SP_OUTPUT" | jq -r '.password')

SP_ENCRYPTED_FILE="SP_$SP_NAME.encrypted"
echo "CLIENT_ID=\"$CLIENT_ID\"" | base64 > $SP_ENCRYPTED_FILE
echo "TENANT_ID=\"$TENANT_ID\"" | base64 >> $SP_ENCRYPTED_FILE
echo "SECRET_ID=\"$SECRET_ID\"" | base64 >> $SP_ENCRYPTED_FILE

# Print the extracted values
echo "CLIENT_ID=\"$CLIENT_ID\""
echo "TENANT_ID=\"$TENANT_ID\""
echo "SECRET_ID=\"$SECRET_ID\""
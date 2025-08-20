#!/bin/bash

# Bootstrap State Upload Script
# Uploads the local bootstrap terraform.tfstate to the Azure Storage Account
# for team access and redundancy

set -e  # Exit on any error

echo "🔄 Starting bootstrap state upload..."

# Check if terraform.tfstate exists
if [ ! -f "terraform.tfstate" ]; then
    echo "❌ Error: terraform.tfstate not found in current directory"
    echo "   Make sure you're in the bootstrap directory and have run 'tofu apply'"
    exit 1
fi

# Get storage account details from terraform outputs
echo "📋 Getting storage account details from terraform outputs..."
STORAGE_ACCOUNT_NAME=$(tofu output -raw name 2>/dev/null)
RESOURCE_GROUP_NAME=$(tofu output -raw resource_group_name 2>/dev/null)

if [ -z "$STORAGE_ACCOUNT_NAME" ] || [ -z "$RESOURCE_GROUP_NAME" ]; then
    echo "❌ Error: Could not retrieve storage account details from terraform outputs"
    echo "   Make sure terraform has been applied successfully"
    exit 1
fi

echo "   Storage Account: $STORAGE_ACCOUNT_NAME"
echo "   Resource Group: $RESOURCE_GROUP_NAME"

# Check if Azure CLI is logged in
if ! az account show &>/dev/null; then
    echo "❌ Error: Not logged into Azure CLI"
    echo "   Run 'az login' first"
    exit 1
fi

# Upload the state file
echo "📤 Uploading bootstrap state to Azure Storage..."
az storage blob upload \
    --account-name "$STORAGE_ACCOUNT_NAME" \
    --container-name tfstate \
    --name bootstrap/terraform.tfstate \
    --file terraform.tfstate \
    --overwrite

if [ $? -eq 0 ]; then
    echo "✅ Successfully uploaded bootstrap state!"
    echo ""
    echo "📋 Verification - listing tfstate container contents:"
    az storage blob list \
        --account-name "$STORAGE_ACCOUNT_NAME" \
        --container-name tfstate \
        --prefix bootstrap/ \
        --output table
else
    echo "❌ Failed to upload bootstrap state"
    exit 1
fi

echo ""
echo "🎉 Bootstrap state backup complete!"
echo "   Team members can now download this state file using 'state-download.sh'"
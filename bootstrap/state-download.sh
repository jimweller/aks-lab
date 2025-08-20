#!/bin/bash

# Bootstrap State Download Script
# Downloads the bootstrap terraform.tfstate from Azure Storage Account
# for team members to restore local state

set -e  # Exit on any error

echo "🔄 Starting bootstrap state download..."

# Check if we need storage account name as parameter
if [ $# -eq 0 ]; then
    echo "❌ Error: Storage account name required"
    echo ""
    echo "Usage: $0 <storage-account-name>"
    echo ""
    echo "Example: $0 jimakslabtfstatezz176"
    echo ""
    echo "💡 Tip: Get the storage account name from a team member or from:"
    echo "   - Azure Portal"
    echo "   - The person who ran the bootstrap"
    exit 1
fi

STORAGE_ACCOUNT_NAME="$1"

echo "   Storage Account: $STORAGE_ACCOUNT_NAME"

# Check if terraform.tfstate already exists
if [ -f "terraform.tfstate" ]; then
    echo "⚠️  Warning: terraform.tfstate already exists in current directory"
    read -p "   Do you want to overwrite it? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "❌ Cancelled by user"
        exit 1
    fi
fi

# Check if Azure CLI is logged in
if ! az account show &>/dev/null; then
    echo "❌ Error: Not logged into Azure CLI"
    echo "   Run 'az login' first"
    exit 1
fi

# Download the state file
echo "📥 Downloading bootstrap state from Azure Storage..."
az storage blob download \
    --account-name "$STORAGE_ACCOUNT_NAME" \
    --container-name tfstate \
    --name bootstrap/terraform.tfstate \
    --file terraform.tfstate

if [ $? -eq 0 ]; then
    echo "✅ Successfully downloaded bootstrap state!"
    echo ""
    echo "📋 State file info:"
    ls -la terraform.tfstate
    echo ""
    echo "🔍 You can now run 'tofu plan' to verify the state"
else
    echo "❌ Failed to download bootstrap state"
    echo "   Check that:"
    echo "   - Storage account name is correct"
    echo "   - You have read access to the storage account"
    echo "   - The bootstrap state file exists in the container"
    exit 1
fi

echo ""
echo "🎉 Bootstrap state download complete!"
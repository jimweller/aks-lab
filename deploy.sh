#!/bin/bash

# AKS Lab Deployment Script
set -e

echo "AKS Lab Deployment Script"
echo "========================="

# Check if we're in the right directory
if [[ ! -f "terragrunt.hcl" ]]; then
    echo "Error: Please run this script from the aks-lab root directory"
    exit 1
fi

# Check prerequisites
echo "Checking prerequisites..."

# Check Azure CLI
if ! command -v az &> /dev/null; then
    echo "Azure CLI is not installed. Please install it first."
    exit 1
fi

# Check if logged in to Azure
if ! az account show &> /dev/null; then
    echo "Please login to Azure first: az login"
    exit 1
fi

# Check Terragrunt
if ! command -v terragrunt &> /dev/null; then
    echo "Terragrunt is not installed. Please install it first."
    exit 1
fi

# Check Terraform
if ! command -v terraform &> /dev/null; then
    echo "Terraform is not installed. Please install it first."
    exit 1
fi

echo "Prerequisites check passed"

# Get current subscription
SUBSCRIPTION_ID=$(az account show --query id -o tsv)
echo "Using subscription: $SUBSCRIPTION_ID"

# Create Terraform state storage if it doesn't exist
echo "Setting up Terraform state storage..."

RESOURCE_GROUP="rg-aks-lab-tfstate"
STORAGE_ACCOUNT="stakslabakstfstate"
CONTAINER_NAME="tfstate"
LOCATION="East US"

# Check if resource group exists
if ! az group show --name $RESOURCE_GROUP &> /dev/null; then
    echo "Creating resource group: $RESOURCE_GROUP"
    az group create --name $RESOURCE_GROUP --location "$LOCATION"
else
    echo "Resource group $RESOURCE_GROUP already exists"
fi

# Check if storage account exists
if ! az storage account show --name $STORAGE_ACCOUNT --resource-group $RESOURCE_GROUP &> /dev/null; then
    echo "Creating storage account: $STORAGE_ACCOUNT"
    az storage account create \
        --name $STORAGE_ACCOUNT \
        --resource-group $RESOURCE_GROUP \
        --location "$LOCATION" \
        --sku Standard_LRS
else
    echo "Storage account $STORAGE_ACCOUNT already exists"
fi

# Check if container exists
if ! az storage container show --name $CONTAINER_NAME --account-name $STORAGE_ACCOUNT &> /dev/null; then
    echo "Creating storage container: $CONTAINER_NAME"
    az storage container create \
        --name $CONTAINER_NAME \
        --account-name $STORAGE_ACCOUNT
else
    echo "Storage container $CONTAINER_NAME already exists"
fi

echo "Terraform state storage ready"

# Deploy infrastructure
echo "Deploying infrastructure..."

cd live/dev

# Plan all components
echo "Planning deployment..."
terragrunt run-all plan

# Ask for confirmation
echo ""
read -p "Do you want to apply the changes? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Applying changes..."
    terragrunt run-all apply --terragrunt-non-interactive
    
    echo ""
    echo "Deployment completed successfully!"
    echo ""
    echo "Next steps:"
    echo "1. Get AKS credentials: az aks get-credentials --resource-group rg-dev-aks-lab --name dev-aks-cluster"
    echo "2. Verify cluster: kubectl get nodes"
    echo "3. Deploy workloads: kubectl apply -f ../../workloads/helloworld/deployment.yaml"
    echo ""
else
    echo "Deployment cancelled by user"
fi
#! /bin/bash

unset surname
unset RESOURCE_GROUP
unset LOCATION
unset STORAGE_ACCOUNT_NAME
unset STORAGE_CONTAINER_NAME
unset COGNITIVE_SEARCH_SERVICE_NAME
unset SUBSCRIPTION_ID
# establish variables
export surname="SyedDemo"
export RESOURCE_GROUP="$surname-cognitive-search"
export LOCATION="westus"
export STORAGE_ACCOUNT_NAME="cognitivestorage$RANDOM"
export STORAGE_CONTAINER_NAME="$surname-cognitivecontainer"
export COGNITIVE_SEARCH_SERVICE_NAME="$surname-searchservice"

az login --use-device-code

export SUBSCRIPTION_ID=$(az account show --query id -o tsv)

# Create a resource group
echo "Creating resource group $RESOURCE_GROUP in $LOCATION ... "
echo
az group create --name $RESOURCE_GROUP --location $LOCATION

# Create a storage account
echo "Creating storage account $STORAGE_ACCOUNT_NAME in $LOCATION ... "
az storage account create --name $STORAGE_ACCOUNT_NAME --resource-group $RESOURCE_GROUP --location $LOCATION --sku Standard_LRS

echo "Creating Role to Use Storage Account"
az ad signed-in-user show --query id -o tsv | az role assignment create \
    --role "Storage Blob Data Contributor" \
    --assignee @- \
    --scope "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Storage/storageAccounts/$STORAGE_ACCOUNT_NAME"

echo "Creating Storage Container $STORAGE_CONTAINER_NAME in Storage Account $STORAGE_ACCOUNT_NAME"

az storage container create \
    --account-name $STORAGE_ACCOUNT_NAME \
    --name $STORAGE_CONTAINER_NAME \
    --auth-mode login

echo "Uploading PDFs to storage account $STORAGE_ACCOUNT_NAME in container $STORAGE_CONTAINER_NAME ... "

az storage blob upload \
    --account-name $STORAGE_ACCOUNT_NAME \
    --container-name $STORAGE_CONTAINER_NAME \
    --name AKS-Book.pdf \
    --file AKS-Book.pdf \
    --auth-mode login

az storage blob upload \
    --account-name $STORAGE_ACCOUNT_NAME \
    --container-name $STORAGE_CONTAINER_NAME \
    --name Modernize-Existing-.NET-applications-with-Azure-cloud-and-Windows-Containers.pdf \
    --file Modernize-Existing-.NET-applications-with-Azure-cloud-and-Windows-Containers.pdf \
    --auth-mode login

# Create a cognitive search service
echo "Creating cognitive search service $COGNITIVE_SEARCH_SERVICE_NAME in $LOCATION ... "
az search service create --name $COGNITIVE_SEARCH_SERVICE_NAME --resource-group $RESOURCE_GROUP --location $LOCATION --sku Standard --partition-count 1 --replica-count 1

echo "Ready to manually create Azure AI Service in Resource Group $RESOURCE_GROUP"
echo "We will do this as a group in the lab..."

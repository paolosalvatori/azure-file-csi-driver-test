#!/bin/bash

# Variables
source ./00-variables.sh

# Check if the resource group already exists
echo "Checking if [$resourceGroupName] resource group actually exists in the [$subscriptionName] subscription..."

az group show --name $resourceGroupName &>/dev/null

if [[ $? != 0 ]]; then
    echo "No [$resourceGroupName] resource group actually exists in the [$subscriptionName] subscription"
    echo "Creating [$resourceGroupName] resource group in the [$subscriptionName] subscription..."

    # Create the resource group
    az group create \
        --name $resourceGroupName \
        --location $location 1>/dev/null

    if [[ $? == 0 ]]; then
        echo "[$resourceGroupName] resource group was successfully created in the [$subscriptionName] subscription"
    else
        echo "Failed to create the [$resourceGroupName] resource group in the [$subscriptionName] subscription"
        exit
    fi
else
    echo "[$resourceGroupName] resource group already exists in the [$subscriptionName] subscription"
fi

# Check if the storage account already exists
echo "Checking if [$storageAccountName] storage account actually exists in the [$subscriptionName] subscription..."

az storage account show \
    --name $storageAccountName \
    --resource-group $resourceGroupName &>/dev/null

if [[ $? != 0 ]]; then
    echo "No [$storageAccountName] storage account actually exists in the [$subscriptionName] subscription"
    echo "Creating [$storageAccountName] storage account in the [$subscriptionName] subscription..."

    # Create the storage account
    az storage account create \
        --name $storageAccountName \
        --resource-group $resourceGroupName \
        --location $location \
        --enable-large-file-share \
        --sku $storageAccountSku 1>/dev/null

    if [[ $? == 0 ]]; then
        echo "[$storageAccountName] storage account was successfully created in the [$subscriptionName] subscription"
    else
        echo "Failed to create the [$storageAccountName] storage account in the [$subscriptionName] subscription"
        exit
    fi
else
    echo "[$storageAccountName] storage account already exists in the [$subscriptionName] subscription"
fi

# Get the connection string
echo "Retrieving the connection string of the [$storageAccountName] storage account..."
storageAccountConnectionString=$(az storage account show-connection-string -n $storageAccountName -g $resourceGroupName -o tsv)

if [[ -n $storageAccountConnectionString ]]; then
    echo "The connection string of the [$storageAccountName] storage account was successfully retrieved"
else
    echo "Failed to retrieve the connection string of the [$storageAccountName] storage account"
    exit
fi

# Check if the file share already exists
echo "Checking if [$fileShareName] file share actually exists in the [$storageAccountName] storage account..."

az storage share show \
    --name $fileShareName \
    --connection-string $storageAccountConnectionString &>/dev/null

if [[ $? != 0 ]]; then
    echo "No [$fileShareName] file share actually exists in the [$storageAccountName] storage account"
    echo "Creating [$fileShareName] file share in the [$storageAccountName] storage account..."

    # Create the file share
    az storage share create \
        --name $fileShareName \
        --connection-string $storageAccountConnectionString 1>/dev/null

    if [[ $? == 0 ]]; then
        echo "[$fileShareName] file share was successfully created in the [$storageAccountName] storage account"
    else
        echo "Failed to create the [$fileShareName] file share in the [$storageAccountName] storage account"
        exit
    fi
else
    echo "[$fileShareName] file share already exists in the [$storageAccountName] storage account"
fi

# Get storage account key
echo "Retrieving the key of the [$storageAccountName] storage account..."
storageAccountKey=$(az storage account keys list --resource-group $resourceGroupName --account-name $storageAccountName --query "[0].value" -o tsv)

if [[ -n $storageAccountKey ]]; then
    echo "The key of the [$storageAccountName] storage account was successfully retrieved"
else
    echo "Failed to retrieve the key of the [$storageAccountName] storage account"
    exit
fi

# Echo storage account name and key
echo "Storage account name: $storageAccountName"
echo "Storage account key: $storageAccountKey"

# Check if the namespace already exists in the cluster
result=$(kubectl get namespace -o jsonpath="{.items[?(@.metadata.name=='$namespace')].metadata.name}")

if [[ -n $result ]]; then
    echo "[$namespace] namespace already exists in the cluster"
else
    echo "[$namespace] namespace does not exist in the cluster"
    echo "creating [$namespace] namespace in the cluster..."
    kubectl create namespace $namespace
fi

# Check if the secret already exists in the cluster
result=$(kubectl get secret -n $namespace -o 'jsonpath={.items[?(@.metadata.name=="'$secretName'")].metadata.name'})

if [[ -n $result ]]; then
    echo "[$secretName] secret already exists in the cluster"
else
    # Create the secret for your ingress resources
    echo "[$secretName] secret does not exist in the cluster"
    echo "Creating [$secretName] secret in the cluster..."
    kubectl create secret generic $secretName \
        -n $namespace \
        --from-literal=azurestorageaccountname=$storageAccountName \
        --from-literal=azurestorageaccountkey=$storageAccountKey
fi

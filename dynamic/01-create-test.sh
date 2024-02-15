#!/bin/bash

# Variables
namespace="dynamic-azure-file"

# Check if the namespace already exists in the cluster
result=$(kubectl get namespace -o jsonpath="{.items[?(@.metadata.name=='$namespace')].metadata.name}")

if [[ -n $result ]]; then
    echo "[$namespace] namespace already exists in the cluster"
else
    echo "[$namespace] namespace does not exist in the cluster"
    echo "creating [$namespace] namespace in the cluster..."
    kubectl create namespace $namespace
fi

# Create storage class
kubectl apply -f azure-file-sc.yml

# Create persistent volume claim
kubectl apply -f azure-file-pvc.yml -n $namespace

# Create deployment
kubectl apply -f azure-file-test.yml -n $namespace
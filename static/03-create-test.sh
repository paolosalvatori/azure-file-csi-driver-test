#!/bin/bash

# variables
source ./00-variables.sh

# Check if the namespace already exists in the cluster
result=$(kubectl get namespace -o jsonpath="{.items[?(@.metadata.name=='$namespace')].metadata.name}")

if [[ -n $result ]]; then
    echo "[$namespace] namespace already exists in the cluster"
else
    echo "[$namespace] namespace does not exist in the cluster"
    echo "creating [$namespace] namespace in the cluster..."
    kubectl create namespace $namespace
fi

# Check if the deployment already exists in the cluster
result=$(kubectl get deployment -n $namespace -o jsonpath="{.items[?(@.metadata.name=='$deploymentName')].metadata.name}")

if [[ -n $result ]]; then
    echo "[$deploymentName] deployment already exists in the cluster"
else
    echo "[$deploymentName] deployment does not exist in the cluster"
    echo "creating [$deploymentName] namespace in the cluster..."
    kubectl apply -f $templateName -n $namespace
fi
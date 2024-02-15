#!/bin/bash

# Variables
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

# Check if the persistent volume already exists in the cluster
result=$(kubectl get pv -n $namespace -o 'jsonpath={.items[?(@.metadata.name=="'$persistentVolumeName'")].metadata.name'})

if [[ -n $result ]]; then
    echo "[$persistentVolumeName] persistent volume already exists in the cluster"
else
    # Create the persistent volume for your ingress resources
    echo "[$persistentVolumeName] persistent volume does not exist in the cluster"
    echo "Creating [$persistentVolumeName] persistent volume in the cluster..."
    cat $persistentVolumeTemplate | 
    yq "(.spec.csi.nodeStageSecretRef.name)|="\""$secretName"\" |
    yq "(.spec.csi.nodeStageSecretRef.namespace)|="\""$namespace"\" |
    yq "(.spec.csi.volumeHandle)|="\""$volumeHandle"\" |
    yq "(.spec.csi.volumeAttributes.resourceGroup)|="\""$resourceGroupName"\" |
    yq "(.spec.csi.volumeAttributes.shareName)|="\""$fileShareName"\" |
    kubectl apply -n $namespace -f -
fi

# Check if the persistent volume claim already exists in the cluster
result=$(kubectl get pvc -n $namespace -o 'jsonpath={.items[?(@.metadata.name=="'$persistentVolumeClaimName'")].metadata.name'})

if [[ -n $result ]]; then
    echo "[$persistentVolumeName] persistent volume claim already exists in the cluster"
else
    # Create the persistent volume claim for your ingress resources
    echo "[$persistentVolumeName] persistent volume claim does not exist in the cluster"
    echo "Creating [$persistentVolumeName] persistent volume claim in the cluster..."
    kubectl apply -n $namespace -f $persistentVolumeClaimTemplate
fi
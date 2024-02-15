# Azure File CSI Driver Test

This repository contains a simple test with the Azure File CSI Driver. Azure Files supports the following redundancy SKUs:

- Standard_LRS: Standard  locally redundant storage
- Standard_GRS: Standard  geo-redundant storage
- Standard_ZRS: Standard  zone-redundant storage
- Standard_RAGRS: Standard  read-access geo-redundant storage
- Standard_RAGZRS: Standard  read-access geo-zone-redundant storage
- Premium_LRS: Premium locally  redundant storage
- Premium_ZRS: Premium  zone-redundant storage

Azure Files supports Azure Premium file shares. The minimum file share capacity is 100 GiB. We recommend using Azure Premium file shares instead of Standard file shares because Premium file shares offers higher performance, low-latency disk support for I/O-intensive workloads.
Azure File Premium storage only supports locally and zone-redundant storage, not geo-zone-redundant storage.
The reclaim policy of the azure-csi and azure-csi-premium  built-in storage classes ensures that the underlying Azure files share is deleted when the respective PV is deleted. The storage classes also configure the file shares to be expandable, you just need to edit the [persistent  volume claim](https://learn.microsoft.com/en-us/azure/aks/concepts-storage#persistent-volume-claims) (PVC) with the new size.
The Azure Files CSI driver supports creating [snapshots of  persistent volumes](https://kubernetes-csi.github.io/docs/snapshot-restore-feature.html) and the underlying file shares.
If your Azure Files resources are protected with a private endpoint, you must create your own storage class. Make sure that you've [configured  your DNS settings to resolve the private endpoint IP address to the FQDN  of the connection string](https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-dns#azure-services-dns-zone-configuration). For more information, see [Use a persistent volume with  private Azure Files storage (private endpoint)](https://learn.microsoft.com/en-us/azure/aks/azure-files-csi#use-a-persistent-volume-with-private-azure-files-storage-private-endpoint).
Azure Files supports [dynamically](https://learn.microsoft.com/en-us/azure/aks/azure-files-csi) creating Azure Files PVs by using the built-in storage classes or [statically](https://learn.microsoft.com/en-us/azure/aks/azure-csi-files-storage-provision#statically-provision-a-volume) provisioning one or more persistent volumes that include details of an existing Azure Files share to use with a workload.

## Static

When using a static persistent volume, you can create the storage account wherever you like and specify the name of the storage account, key, and resource group name in the persistent volume. For more information, see [Statically provision a volume](https://learn.microsoft.com/en-us/azure/aks/azure-csi-files-storage-provision#statically-provision-a-volume).

## Dynamic

When you let Kubernetes to create the storage account and file share for you, the storage account name will be a GUID and by default it gets created in the node resource group. If you want to create in a separate resource group, you can create a custom storage class, like in my sample, and specify an alternative resource group. However, you need to make sure that the resource group exists and that the AKS identity as Contributor role on that resource group to be able to create a storage account. For more information, see [Dynamically provision a volume](https://learn.microsoft.com/en-us/azure/aks/azure-csi-files-storage-provision#dynamically-provision-a-volume).

## Links

- [Concepts - Storage in Azure Kubernetes Services (AKS) - Azure Kubernetes Service | Microsoft Learn](https://learn.microsoft.com/en-us/azure/aks/concepts-storage)
- [Storage considerations for AKS - Cloud Adoption Framework | Microsoft Learn](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/scenarios/app-platform/aks/storage)
- [Compare NFS access to Azure Files, Blob Storage, and Azure NetApp Files | Microsoft Learn](https://learn.microsoft.com/en-us/azure/storage/common/nfs-comparison)
- [Introduction to Azure Container Storage Preview | Microsoft Learn](https://learn.microsoft.com/en-us/azure/storage/container-storage/container-storage-introduction)
- [Azure Disk CSI Driver Paramaters](https://github.com/kubernetes-sigs/azuredisk-csi-driver/blob/master/docs/driver-parameters.md)
- [Azure File CSI Driver Parameters](https://github.com/kubernetes-sigs/azurefile-csi-driver/blob/master/docs/driver-parameters.md)
- [A Practical Guide to Zone Redundant AKS Clusters and Storage - Microsoft Community Hub](https://techcommunity.microsoft.com/t5/fasttrack-for-azure/a-practical-guide-to-zone-redundant-aks-clusters-and-storage/ba-p/4036254)
- [Use Container Storage Interface (CSI) driver for Azure Files on Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn](https://learn.microsoft.com/en-us/azure/aks/azure-files-csi)
- [Create a persistent volume with Azure Files in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn](https://learn.microsoft.com/en-us/azure/aks/azure-csi-files-storage-provision)
- [Recommended and useful mountOptions settings on Azure Files - Azure | Microsoft Learn](https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/mountoptions-settings-azure-files)
- [Unable to mount Azure file share - Azure | Microsoft Learn](https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/fail-to-mount-azure-file-share)

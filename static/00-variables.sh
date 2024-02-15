# Azure variables
storageAccountName="mikifilestorage"
storageAccountSku="Standard_LRS"
resourceGroupName="MikiRG"
location="eastus2"
fileShareName="documents"
volumeHandle="$storageAccountName-$fileShareName"
subscriptionName=$(az account show --query name --output tsv)

# Kubernetes variables
secretName="azure-secret"
namespace="azure-file"

persistentVolumeName="azure-file"
persistentVolumeClaimName="azure-file-pvc"
persistentVolumeTemplate="azure-file-pv.yml"
persistentVolumeClaimTemplate="azure-file-pvc.yml"

deploymentName="azure-file"
templateName="azure-file-test.yml"
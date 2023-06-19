. ./.env/test.variables.ps1


# Create a resource group if it doesn't exist
az group create --name $resourceGroup --location $location

# Generate a random name for the ACI deployment
$deploymentName = "aci-deployment-" + [System.Guid]::NewGuid().ToString()

# Create a volume mount for the first storage share
$volumeMount1 = @{
    "name" = "share1";
    "azureFile" = @{
        "shareName" = "share1";
        "storageAccountName" = "mystorageaccount";
        "storageAccountKey" = $env:STORAGE_ACCOUNT_KEY1;
    }
}

# Create a volume mount for the second storage share
$volumeMount2 = @{
    "name" = "share2";
    "azureFile" = @{
        "shareName" = "share2";
        "storageAccountName" = "mystorageaccount";
        "storageAccountKey" = $env:STORAGE_ACCOUNT_KEY2;
    }
}

# Convert the volume mount objects to JSON strings
$volumeMount1Json = $volumeMount1 | ConvertTo-Json -Depth 10
$volumeMount2Json = $volumeMount2 | ConvertTo-Json -Depth 10

# Create ACI with Docker Compose and volume mounts
az container create --resource-group $resourceGroup --name $aciName --location $location `
    --image "docker/compose:1.29.2" --restart-policy OnFailure `
    --ports 80 --command-line "docker-compose up" --environment-variables "KEY1=value1" "KEY2=value2" `
    --registry-login-server "myregistry.azurecr.io" --registry-username $env:ACR_USERNAME --registry-password $env:ACR_PASSWORD `
    --dns-name-label $aciName --ip-address Public --secure-environment-variables "SECRET1=$env:SECRET1" "SECRET2=$env:SECRET2" `
    --secrets "SECRET1"="mysecret1" "SECRET2"="mysecret2" `
    --azure-file-volume-mounts $volumeMount1Json $volumeMount2Json

# Monitor the deployment
az container show --resource-group $resourceGroup --name $aciName --query "provisioningState"

# Get the ACI logs
az container logs --resource-group $resourceGroup --name $aciName

. ./.env/test.variables.ps1

#Get all resources in the resource group
$resources = az resource list --resource-group $resourceGroup --query "[].id" -o tsv

#Loop through the resources and delete each one
foreach ($resource in $resources)
{
    Write-Host "Deleting resource: $resource"
    az resource delete --ids $resource
}

az containerapp compose create `
    --environment "managedEnvironment-programmingdev-93a5" `
    -g "programming-dev" `
    -f "./scripts/docker-compose.yml"
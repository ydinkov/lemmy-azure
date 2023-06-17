. ./.env/test.variables.ps1

$dockerComposeFilePath = "./scripts/docker-compose.yml"

az storage account create `
    --name $storageAccountName `
    --rersource-group $resourceGroup `
    -l $location `
    --sku $storageSku

# Create a file share
az storage share create `
  --name $shareNameNginx `
  --account-name $storageAccountName `
  --account-key $storageAccountKey `

# Create a file share
az storage share create `
  --name $shareNameLemmy `
  --account-name $storageAccountName `
  --account-key $storageAccountKey


# Get the storage account key
$storageAccountKey = az storage account keys list `
    --resource-group $resourceGroup `
    --account-name $storageAccountName `
    --query "[0].value" `
    --output tsv

Write-Host Creating Postgres
# Create Azure Database for PostgreSQL
az postgres flexible-server create `
    --resource-group $resourceGroup `
    --name $dbServerName `
    --location $location `
    --admin-user $dbUsername `
    --admin-password $dbPassword `
    --sku-name $dbComputeSKU `
    --storage-size $dbStorageSize

# Prepare connection string
$dbConnectionString = "postgres://${dbUsername}:$dbPassword@${dbHost}:$dbPort/$dbName"
$dbHostName = az postgres flexible-server show --resource-group $resourceGroup --name $dbServerName --query fullyQualifiedDomainName -o tsv

# Web APP Front-End, Back-End + Proxy
az webapp create --name $lemmyAppName --plan $appServicePlanName --resource-group $resourceGroupName --multicontainer-config-type COMPOSE

# Set Docker Compose configuration from file
$dockerComposeConfig = Get-Content $dockerComposeFilePath | Out-String
az webapp config container set --name $lemmyAppName --resource-group $resourceGroupName --multicontainer-config-type COMPOSE --multicontainer-config-file $dockerComposeConfig


az webapp config storage-account add `
    --name $lemmyAppName `
    --resource-group $resourceGroup `
    --custom-id $shareNameNginx `
    --storage-type AzureFiles `
    --account-name $storageAccountName `
    --share-name $shareNameNginx `
    --access-key $storageAccountAccessKey `
    --mount-path /etc/nginx/nginx.conf

az webapp config storage-account add `
    --name $lemmyAppName `
    --resource-group $resourceGroup `
    --custom-id $shareNameLemmy `
    --storage-type AzureFiles `
    --account-name $storageAccountName `
    --share-name $shareNameLemmy `
    --access-key $storageAccountAccessKey `
    --mount-path /config/config.hjson


$webAppHost = az webapp show --name  $lemmyAppName --resource-group $resourceGroupName --query defaultHostName --output tsv



# Pictrs
Write-Host Creating Pictrs instance
az container create `
    --resource-group $resourceGroup `
    --name $pictrsName `
    --image $pictrsImage `
    --dns-name-label $pictrsName `
    --environment-variables PICTRS_OPENTELEMETRY_URL="http://otel:4137" PICTRS__API_KEY=$pctrsApiKey RUST_LOG="debug" RUST_BACKTRACE="full" PICTRS__MEDIA__VIDEO_CODEC="vp9" PICTRS__MEDIA__GIF__MAX_WIDTH="256" PICTRS__MEDIA__GIF__MAX_HEIGHT="256" PICTRS__MEDIA__GIF__MAX_AREA="65536" PICTRS__MEDIA__GIF__MAX_FRAME_COUNT="400" `
    --azure-file-volume-account-name $storageAccountName `
    --azure-file-volume-account-key $storageAccountKey `
    --azure-file-volume-share-name $shareName `
    --azure-file-volume-mount-path /mnt

$pictrsHost = az container show -n $pictrsName -g $resourceGroup --query ipAddress.fqdn --output tsv

$Config = Get-Content scripts/config_template.hjson
$Config -replace "<LEMMY_DATABASE_USER>", $dbUsername `
        -replace "<LEMMY_DATABASE_PASSWORD>", $dbPassword `
        -replace "<LEMMY_DATABASE_HOST>", $dbHostName `
        -replace "<LEMMY_PICTRS_URL>", $pictrsHost `
        -replace "<LEMMY_PICTRS_API_KEY>", $pctrsApiKey `
        -replace "<LEMMY_API_ADMIN_USERNAME>", $lemmyApiAdminUser `
        -replace "<LEMMY_API_ADMIN_PASSWORD>", $lemmyApiAdminPassword `
        -replace "<LEMMY_API_ADMIN_EMAIL>", $lemmyApiAdminEmail `
        -replace "<LEMMY_SITE_NAME>", $lemmyAppName `
        -replace "<LEMMY_HOSTNAME>", $webAppHost > ./temp/config.hjson

az storage file upload --account-name $storageAccountName --account-key $storageAccountKey --share-name $shareNameLemmy --source ./temp/config.hjson
az storage file upload --account-name $storageAccountName --account-key $storageAccountKey --share-name $shareNameNginx --source ./scripts/ngnx.conf


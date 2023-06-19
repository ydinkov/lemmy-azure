. ./.env/test.variables.ps1

#Write-Host creating ASP
#az appservice plan create `
#    --name $appServicePlan `
#    --resource-group $resourceGroup `
#    --sku $aspSku `
#    --is-linux `
#    --output none
#
#Write-Host creating storage account
#az storage account create `
#    --name $storageAccountName `
#    --resource-group $resourceGroup `
#    -l $location `
#    --sku $storageSku `
#    --output none
#
#Write-Host creating storage share 1
## Create a file share
#az storage share create `
#    --name $shareNameNginx `
#    --account-name $storageAccountName `
#    --account-key $storageAccountKey `
#    --output none
#
#
#Write-Host creating storage share 2
## Create a file share
#az storage share create `
#    --name $shareNameLemmy `
#    --account-name $storageAccountName `
#    --account-key $storageAccountKey `
#    --output none
#
#Write-Host creating storage container
## Create a file share
#az storage share create `
#    --name $containerNamePictrs `
#    --account-name $storageAccountName `
#    --account-key $storageAccountKey `
#    --output none
#
#
## Get the storage account key
#$storageAccountKey = az storage account keys list `
#    --resource-group $resourceGroup `
#    --account-name $storageAccountName `
#    --query "[0].value" `
#    --output tsv

Write-Host Creating Postgres
# Create Azure Database for PostgreSQL
az postgres flexible-server create `
    --resource-group $resourceGroup `
    --name $dbServerName `
    --location $location `
    --admin-user $dbUsername `
    --admin-password $dbPassword `
    --version 15 `
    --sku-name $dbComputeSKU `
    --tier Burstable `
    --storage-size $dbStorageSize `
    --output none `
    -y

az postgres flexible-server db create `
    -g $resourceGroup `
    -s $dbServerName `
    -d $dbName `

# Prepare connection string
$dbConnectionString = "postgres://${dbUsername}:$dbPassword@${dbHost}:$dbPort/$dbName"
$dbHostName = az postgres flexible-server show --resource-group $resourceGroup --name $dbServerName --query fullyQualifiedDomainName -o tsv

#
#Write-Host Creating Web App
## Web APP Front-End, Back-End + Proxy
#az webapp create `
#    --name $lemmyAppName `
#    --plan $appServicePlan `
#    --resource-group $resourceGroup `
#    --multicontainer-config-type COMPOSE `
#    --multicontainer-config-file "./scripts/docker-compose.yml" `
#    --output none
#
#Write-Host Mounting Nginx Share
#az webapp config storage-account add `
#    --name $lemmyAppName `
#    --resource-group $resourceGroup `
#    --custom-id $shareNameNginx `
#    --storage-type AzureFiles `
#    --account-name $storageAccountName `
#    --share-name $shareNameNginx `
#    --access-key $storageAccountKey `
#    --mount-path /etc/nginx
#    
#Write-Host Mounting Api Config Share
#az webapp config storage-account add `
#    --name $lemmyAppName `
#    --resource-group $resourceGroup `
#    --custom-id $shareNameLemmy `
#    --storage-type AzureFiles `
#    --account-name $storageAccountName `
#    --share-name $shareNameLemmy `
#    --access-key $storageAccountKey `
#    --mount-path /config
#
#$webAppHost = az webapp show `
#    --name  $lemmyAppName `
#    -p $appServicePlan `
#    --resource-group $resourceGroup `
#    --query defaultHostName `
#    --output tsv
#
#Write-Host Creating Pictrs instance
#az container create `
#    --resource-group $resourceGroup `
#    --name $pictrsName `
#    --image $pictrsImage `
#    -l WestEurope `
#    --ip-address public `
#    --cpu 1.0 `
#    --os-type linux `
#    --ports 8080 `
#    --memory 2.0 `
#    --dns-name-label $pictrsName `
#    --environment-variables PICTRS_OPENTELEMETRY_URL="http://otel:4137" PICTRS__API_KEY=$pctrsApiKey RUST_LOG="debug" RUST_BACKTRACE="full" PICTRS__MEDIA__VIDEO_CODEC="vp9" PICTRS__MEDIA__GIF__MAX_WIDTH="256" PICTRS__MEDIA__GIF__MAX_HEIGHT="256" PICTRS__MEDIA__GIF__MAX_AREA="65536" PICTRS__MEDIA__GIF__MAX_FRAME_COUNT="400" `
#    --azure-file-volume-account-name $storageAccountName `
#    --azure-file-volume-account-key $storageAccountKey `
#    --azure-file-volume-share-name $containerNamePictrs `
#    --azure-file-volume-mount-path /mnt `
#    --output none
#
#
#
#Write-Host Uploading Configs
#$Config = Get-Content scripts/config_template.hjson
#$Config -replace "<LEMMY_DATABASE_USER>", $dbUsername `
#        -replace "<LEMMY_DATABASE_PASSWORD>", $dbPassword `
#        -replace "<LEMMY_DATABASE_HOST>", $dbHost `
#        -replace "<LEMMY_DATABASE_HOST>", $dbName `
#        -replace "<LEMMY_PICTRS_URL>", $pictrsHost `
#        -replace "<LEMMY_PICTRS_API_KEY>", $pctrsApiKey `
#        -replace "<LEMMY_API_ADMIN_USERNAME>", $lemmyApiAdminUser `
#        -replace "<LEMMY_API_ADMIN_PASSWORD>", $lemmyApiAdminPassword `
#        -replace "<LEMMY_API_ADMIN_EMAIL>", $lemmyApiAdminEmail `
#        -replace "<LEMMY_SITE_NAME>", $lemmyAppName `
#        -replace "<LEMMY_HOSTNAME>", " $lemmyAppName.westeurope.azurecontainer.io" > ./temp/config.hjson
#
#az storage file upload --account-name $storageAccountName --account-key $storageAccountKey --share-name $shareNameLemmy --source ./temp/config.hjson --output none
#az storage file upload --account-name $storageAccountName --account-key $storageAccountKey --share-name $shareNameNginx --source ./scripts/nginx.conf --output none

#az container create `
#    --resource-group $resourceGroup `
#    --file scripts/deploy-aci.yml `
#    --dns-name-label $lemmyAppName
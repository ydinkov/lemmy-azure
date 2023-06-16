. ./.env/test.variables.ps1

# Create a file share
az storage share create `
  --name $shareName `
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

Write-Host Creating Lemmy
# Lemmy
az webapp create `
    --resource-group $resourceGroup `
    --plan $appServicePlan `
    --name $apiAppName `
    --deployment-container-image-name $lemmyImage

az webapp config appsettings set `
    --resource-group $resourceGroup `
    --name $apiAppName `
    --settings RUST_LOG="warn,lemmy_server=debug,lemmy_api=debug,lemmy_api_common=debug,lemmy_api_crud=debug,lemmy_apub=debug,lemmy_db_schema=debug,lemmy_db_views=debug,lemmy_db_views_actor=debug,lemmy_db_views_moderator=debug,lemmy_routes=debug,lemmy_utils=debug,lemmy_websocket=debug" RUST_BACKTRACE=full LEMMY_DATABASE_URL=$dbConnectionString `
    --azure-file-volume-account-name $storageAccountName `
    --azure-file-volume-account-key $storageAccountKey `
    --azure-file-volume-share-name $shareName2 `
    --azure-file-volume-mount-path /config

# Get Lemmy's URL
$lemmyUrl = az webapp show `
    --resource-group $resourceGroup `
    --name $apiAppName `
    --query defaultHostName `
    --output tsv

# Lemmy-UI
Write-Host Creating Lemmy-UI
az webapp create `
    --resource-group $resourceGroup `
    --plan $appServicePlan `
    --name $uiAppName `
    --deployment-container-image-name $lemmyUiImage

az webapp config appsettings set `
    --resource-group $resourceGroup `
    --name $uiAppName `
    --settings LEMMY_UI_LEMMY_INTERNAL_HOST="lemmy:8536" LEMMY_UI_LEMMY_EXTERNAL_HOST=$lemmyUrl LEMMY_HTTPS="true" LEMMY_UI_DEBUG="false"


# Pictrs
Write-Host Creating Pictrs instance
az container create `
    --resource-group $resourceGroup `
    --name $pictrsName `
    --image $pictrsImage `
    --dns-name-label pictrs `
    --environment-variables PICTRS_OPENTELEMETRY_URL="http://otel:4137" PICTRS__API_KEY="API_KEY" RUST_LOG="debug" RUST_BACKTRACE="full" PICTRS__MEDIA__VIDEO_CODEC="vp9" PICTRS__MEDIA__GIF__MAX_WIDTH="256" PICTRS__MEDIA__GIF__MAX_HEIGHT="256" PICTRS__MEDIA__GIF__MAX_AREA="65536" PICTRS__MEDIA__GIF__MAX_FRAME_COUNT="400" `
    --azure-file-volume-account-name $storageAccountName `
    --azure-file-volume-account-key $storageAccountKey `
    --azure-file-volume-share-name $shareName `
    --azure-file-volume-mount-path /mnt

Write-Host DONE!
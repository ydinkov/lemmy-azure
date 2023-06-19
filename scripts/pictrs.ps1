. ./.env/test.variables.ps1

$storageAccountKey = az storage account keys list `
    --resource-group $resourceGroup `
    --account-name $storageAccountName `
    --query "[0].value" `
    --output tsv


az container create `
    --resource-group $resourceGroup `
    --name $pictrsName `
    --image $pictrsImage `
    -l WestEurope `
    --ip-address public `
    --cpu 1.0 `
    --os-type linux `
    --ports 8080 `
    --memory 2.0 `
    --dns-name-label $pictrsName `
    --environment-variables PICTRS_OPENTELEMETRY_URL="http://otel:4137" PICTRS__API_KEY=$pctrsApiKey RUST_LOG="debug" RUST_BACKTRACE="full" PICTRS__MEDIA__VIDEO_CODEC="vp9" PICTRS__MEDIA__GIF__MAX_WIDTH="256" PICTRS__MEDIA__GIF__MAX_HEIGHT="256" PICTRS__MEDIA__GIF__MAX_AREA="65536" PICTRS__MEDIA__GIF__MAX_FRAME_COUNT="400" `
    --azure-file-volume-account-name $storageAccountName `
    --azure-file-volume-account-key $storageAccountKey `
    --azure-file-volume-share-name $containerNamePictrs `
    --azure-file-volume-mount-path /mnt `
    --output none



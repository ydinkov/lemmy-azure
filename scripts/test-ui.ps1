az container create `
    -g programming-dev `
    -n lemmy-ui-aci `
    -l WestEurope `
    --ip-address public `
    --cpu 1.0 `
    --os-type linux `
    --ports 1236 `
    --memory 2.0 `
    --image dessalines/lemmy-ui:latest `
    --environment-variables `
        LEMMY_UI_LEMMY_INTERNAL_HOST=pd-lemmy-ui.westeurope.azurecontainer.io:1236 `
        LEMMY_UI_LEMMY_EXTERNAL_HOST=pd-lemmy-api-2.westeurope.azurecontainer.io:8536 `
        LEMMY_HTTPS=true `
        LEMMY_UI_DEBUG=true `
    --dns-name-label "pd-lemmy-ui" `
    --debug 

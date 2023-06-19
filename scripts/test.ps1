az container create `
    -g programming-dev `
    -n lemmy-aci-4 `
    -l WestEurope `
    --cpu 1.0 `
    --os-type linux `
    --ports 8536 `
    --memory 2.0 `
    --image dessalines/lemmy:0.17.4 `
    --environment-variables `
        RUST_LOG=warn,lemmy_server=debug,lemmy_api=debug,lemmy_api_common=debug,lemmy_api_crud=debug,lemmy_apub=debug,lemmy_db_schema=debug,lemmy_db_views=debug,lemmy_db_views_actor=debug,lemmy_db_views_moderator=debug,lemmy_routes=debug,lemmy_utils=debug,lemmy_websocket=debug `
        RUST_BACKTRACE=full `
    --dns-name-label "pd-lemmy-api-2" `
    --azure-file-volume-account-name "lemmysa" `
    --azure-file-volume-account-key "7o6BWAY3VqfTXj5m3zkUepi80IsMlymetU/fqXSTVAX4RSLr56xLUhrJ84Bp1rCX0BGFUawsaxAd+AStNv8uJQ==" `
    --azure-file-volume-share-name "lemmy" `
    --azure-file-volume-mount-path "/config/" `
    --debug 



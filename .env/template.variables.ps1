#Global Variables
$resourceGroup = "<RESOURCE GROUP"
$localtion = "<LOCATION>"

#ASP
$appServicePlan = "<ASP NAME>"
$aspSku = "<ASP SIZE>"

#StorageAcount
$storageAccountName = "STORAGE ACCOUNT NAME"
$shareName = "lemmy"
$storageSku = "Standard_LRS"

#API
$apiAppName = "<API WEB APP NAME>"
$lemmyApiImage = "dessalines/lemmy:latest"

#UI
$uiAppName = "<UI WEB APP NAME>"
$lemmyUiImage = "dessalines/lemmy-ui:latest"


#PostgresDB
$dbServerName = "<DB_SERVER NAME>"
$dbName = "lemmydb"
$dbUsername = "<DB ADMIN USER NAME>"
$dbPassword = "<DB ADMIN USER PASSWORD>"
$dbHost = "$dbServerName.postgres.database.azure.com"
$dbPort = "5432"
$dbComputeSKU = "Standard_B1ms"
$dbStorageSize = "32"

#Pictrs
$pictrsName = "<PICTRS CONTAINER NAME>"
$pictrsImage = "asonix/pictrs:0.4.0-beta.19"
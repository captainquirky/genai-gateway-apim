// Deploys the following:
// - An API Management service
// - An Azure Cognitive Services account

var APIM_NAME = 'APIM8'

var serviceName = 'service${uniqueString(resourceGroup().id)}-${APIM_NAME}'

var cognitiveServicesAccountName1 = '${uniqueString(resourceGroup().id)}-${APIM_NAME}-AOAI1'

var cognitiveServicesAccountName2 = '${uniqueString(resourceGroup().id)}-${APIM_NAME}-AOAI2'

resource apimService 'Microsoft.ApiManagement/service@2023-09-01-preview' existing = {
  name: serviceName
}

resource cognitiveServicesAccount1 'Microsoft.CognitiveServices/accounts@2023-10-01-preview' existing = {
  name: cognitiveServicesAccountName1
}

resource cognitiveServicesAccount2 'Microsoft.CognitiveServices/accounts@2023-10-01-preview' existing = {
  name: cognitiveServicesAccountName2
}

// adding Managed Identity connection between APIM and Azure Open AI by adding a role assignment

// TODO Cognitive Services API Management Contributor role ID 
param roleDefinitionId string = '5e0bd9bd-7b93-4f28-af87-19fc36ad61bd'


output subscriptionId string = subscription().subscriptionId

output principalId string = apimService.identity.principalId

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(cognitiveServicesAccount1.id, resourceGroup().id, APIM_NAME)
  scope: cognitiveServicesAccount1
  properties: {
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionId)
    principalType: 'ServicePrincipal'
    principalId: apimService.identity.principalId
  }
}

resource roleAssignment2 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(cognitiveServicesAccount2.id, resourceGroup().id, APIM_NAME)
  scope: cognitiveServicesAccount2
  properties: {
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionId)
    principalType: 'ServicePrincipal'
    principalId: apimService.identity.principalId
  }
}


// az role assignment list --scope /subscriptions/<subscription-id>/resourceGroups/<resource-group-name>/providers/Microsoft.ApiManagement/service/<apim-service-name>

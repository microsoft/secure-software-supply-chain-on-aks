#!/bin/bash

# Access granted under MIT Open Source License: https://en.wikipedia.org/wiki/MIT_License
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
# documentation files (the "Software"), to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense, # and/or sell copies of the Software,
# and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions
# of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED
# TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
# CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

#######################################################
# Creates Azure DevOps Azure Service Connections
#######################################################

#########################
# ENV VARIABLES:
# for details on environment variables see ./config/environment.md
# ADO_ORGANIZATION_URL
# ADO_PROJECT_NAME
# ADO_AZURE_SERVICE_CONNECTION
# AZURE_APP_CLIENT_ID
#########################

set -o errexit
set -o pipefail
set -o nounset

# For debugging
# set -o xtrace 

# used for working with the env file
. ./scripts/helper/env.sh

# used for pretty printing to terminal
. ./scripts/helper/common.sh

print_style "Creating ADO service connection and federated credentials" info

# Setup Azure service connection
az_sub=$(az account show --output json)
az_sub_id=$(echo "$az_sub" | jq -r '.id')
az_sub_name=$(echo "$az_sub" | jq -r '.name')
az_sp_tenant_id=$(echo "$az_sub" | jq -r '.tenantId')
ado_proj_id=$(az devops project list --org $ADO_ORGANIZATION_URL --query "value[?name=='$ADO_PROJECT_NAME']".id -o tsv)

# Create Azure Service connection in Azure DevOps
if sc_id=$(az devops service-endpoint list -o tsv | grep "$ADO_AZURE_SERVICE_CONNECTION" | awk '{print $3}'); then
    print_style "Service connection: $ADO_AZURE_SERVICE_CONNECTION already exists. Deleting..." info
    az devops service-endpoint delete --id "$sc_id" -y
fi

# create ado service connection
print_style "Updating service connection configuration file" info
cp ./config/sc_azurerm.template ./config/sc_azurerm.json

jq \
    --arg proj_id "$ado_proj_id" \
    --arg tenant "$az_sp_tenant_id" \
    --arg azure_app_client_id "$AZURE_APP_CLIENT_ID" \
    --arg ado_project_name "$ADO_PROJECT_NAME" \
    --arg ado_sc_name "$ADO_AZURE_SERVICE_CONNECTION" \
    --arg subscriptionId "$az_sub_id" \
    --arg subscriptionName "$az_sub_name" \
    '.serviceEndpointProjectReferences[0].projectReference.id = $proj_id |
    .data.subscriptionId = $subscriptionId |
    .data.subscriptionName = $subscriptionName |
    .name = $ado_sc_name |
    .serviceEndpointProjectReferences[0].name = $ado_sc_name |
    .authorization.parameters.serviceprincipalid = $azure_app_client_id |
    .authorization.parameters.tenantid = $tenant' \
    ./config/sc_azurerm.json > ./config/sc_azurerm.bak && mv ./config/sc_azurerm.bak ./config/sc_azurerm.json

print_style "Creating service connection Azure DevOps" info
sc_json_output=$(az devops service-endpoint create --service-endpoint-configuration ./config/sc_azurerm.json -o json)

sc_id=$(echo $sc_json_output | jq -r '.id')
issuer=$(echo $sc_json_output | jq -r '.authorization.parameters.workloadIdentityFederationIssuer')
subject=$(echo $sc_json_output | jq -r '.authorization.parameters.workloadIdentityFederationSubject')

az devops service-endpoint update \
    --id "$sc_id" \
    --enable-for-all "true"

# create federated credential for the app using the service connection details
print_style "Adding federated credential to Microsoft Entra ID App" info
az ad app federated-credential create --id $AZURE_APP_CLIENT_ID --parameters \
    '{
        "name": "azure-devops-credential",
        "issuer": "'"$issuer"'",
        "subject": "'"$subject"'",
        "description": "Allow Azure DevOps to provision resources in Azure",
        "audiences": [
            "api://AzureADTokenExchange"
        ]
    }'
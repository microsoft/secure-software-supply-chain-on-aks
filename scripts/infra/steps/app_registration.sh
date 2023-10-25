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
# Create an app registration used for OIDC to allow for GitHub and ADO resource provisioning
#######################################################

#########################
# ENV VARIABLES:
# for details on environment variables see ./config/environment.md
# AZURE_APP_CLIENT_ID
# SERVICE_PRINCIPAL_ID
# PROJECT_NAME
# AZURE_SUBSCRIPTION_ID
# RESOURCE_GROUP_NAME
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

###########################
# Create Microsoft Entra ID
###########################

print_block_header "Creating Microsoft Entra ID App registration and Service Principal" warning

AZURE_APP_CLIENT_ID=${AZURE_APP_CLIENT_ID:-}
SERVICE_PRINCIPAL_ID=${SERVICE_PRINCIPAL_ID:-}
if [ -z $AZURE_APP_CLIENT_ID ]; then
    print_style "Creating Microsoft Entra ID App registration" info
    azure_app_client_id=$(az ad app create --display-name $PROJECT_NAME --sign-in-audience AzureADMyOrg --query appId -o tsv)

    print_style "Creating SP and assigning to Microsoft Entra ID App" info
    service_principal_id=$(az ad sp create --id $azure_app_client_id --query id -o tsv)
    write_env "AZURE_APP_CLIENT_ID" $azure_app_client_id
    write_env "SERVICE_PRINCIPAL_ID" $service_principal_id
else
    print_style "Using existing resource: $AZURE_APP_CLIENT_ID" info
fi

#############################
# Configure Role Assignment #
#############################

print_block_header "Configuring role assignments" warning
## assign ownership of RG to SP (aka AAD App)
print_style "Assigning ownership of resource group to Microsoft Entra ID App" info
az role assignment create \
    --role owner \
    --assignee-object-id $SERVICE_PRINCIPAL_ID \
    --assignee-principal-type ServicePrincipal \
    --scope /subscriptions/$AZURE_SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP_NAME

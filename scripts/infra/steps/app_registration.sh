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
# ENTRA_APP_ID
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

ENTRA_APP_ID=${ENTRA_APP_ID:-}
SERVICE_PRINCIPAL_ID=${SERVICE_PRINCIPAL_ID:-}
if [ -z $ENTRA_APP_ID ]; then
    print_style "Creating Microsoft Entra ID App registration" info
    ENTRA_APP_ID=$(az ad app create --display-name $PROJECT_NAME --sign-in-audience AzureADMyOrg --query appId -o tsv)

    print_style "Creating SP and assigning to Microsoft Entra ID App" info
    service_principal_id=$(az ad sp create --id $ENTRA_APP_ID --query id -o tsv)
    write_env "ENTRA_APP_ID" $ENTRA_APP_ID
    write_env "SERVICE_PRINCIPAL_ID" $service_principal_id
elif [ -z $SERVICE_PRINCIPAL_ID ]; then
    print_style "Creating SP and assigning to Microsoft Entra ID App" info
    service_principal_id=$(az ad sp create --id $ENTRA_APP_ID --query id -o tsv)
    write_env "SERVICE_PRINCIPAL_ID" $service_principal_id
else
    print_style "Using existing resource: $ENTRA_APP_ID" info
fi

#############################
# Configure Role Assignment #
#############################

print_block_header "Configuring Entra ID App role assignments" warning

print_style "Assigning ownership of resource group to Microsoft Entra ID App" info
az role assignment create \
        --role owner \
        --assignee-object-id $SERVICE_PRINCIPAL_ID \
        --assignee-principal-type ServicePrincipal \
        --scope /subscriptions/$AZURE_SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP_NAME


NOTATION_ROLE_ID=${NOTATION_ROLE_ID:-}
if [ -z $NOTATION_ROLE_ID ]; then

    role_name="Notation AKV Signer $DEPLOYMENT_ID"

    if az role definition list --custom-role-only true --name "$role_name" --resource-group "$RESOURCE_GROUP_NAME" --output json --query "[].{id:id}" | jq '. == []'; then
        role_definition=$(cat <<EOF
{
    "Name": "${role_name}",
    "Description": "Sign OCI Artifacts using Notation and Azure Key Vault",
    "DataActions": [
        "Microsoft.KeyVault/vaults/secrets/getSecret/action",
        "Microsoft.KeyVault/vaults/secrets/readMetadata/action",
        "Microsoft.KeyVault/vaults/keys/sign/action",
        "Microsoft.KeyVault/vaults/*/read"
    ],
    "AssignableScopes": [ "/subscriptions/${AZURE_SUBSCRIPTION_ID}/resourcegroups/${RESOURCE_GROUP_NAME}" ],
}
EOF
)
        print_style "Creating custom role \"$role_name\" for signing with Notation" info
        role_id=$(az role definition create --role-definition "$role_definition" --output tsv --query "id")
        write_env "NOTATION_ROLE_ID" "$role_id"
        
    else
        print_style "Custom role \"$role_name\" for signing with Notation exists for this resource group. Skipping creation" info


        role_list=$(az role definition list --custom-role-only true --name "$role_name" --resource-group "$RESOURCE_GROUP_NAME" --output json --query "[].{id:id}")
        
        id=$(echo "$role_list" | jq ".[0].id")
        write_env "NOTATION_ROLE_ID" "$id"
    fi
fi

print_style "Assigning custom Notation signing role to Microsoft Entra ID App" info
az role assignment create \
        --role $NOTATION_ROLE_ID \
        --assignee-object-id $SERVICE_PRINCIPAL_ID \
        --assignee-principal-type ServicePrincipal \
        --scope /subscriptions/$AZURE_SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP_NAME

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
# Provision key vault used to hold certs for signing and verification
#######################################################

#########################
# ENV VARIABLES:
# for details on environment variables see ./config/environment.md
# KEY_VAULT_NAME
# RESOURCE_PREFIX
# RESOURCE_GROUP_NAME
# AZURE_SUBSCRIPTION_ID
# KEY_VAULT_NAME
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

print_block_header "Configuring Key Vault" warning

KEY_VAULT_NAME=${KEY_VAULT_NAME:-}
if [ -z $KEY_VAULT_NAME ]; then
    key_vault_name="${RESOURCE_PREFIX}kv"

    print_style "Deploying Azure Key Vault ${key_vault_name}" info

    key_vault_id=$(az keyvault create \
            --name $key_vault_name \
            --resource-group $RESOURCE_GROUP_NAME \
            --enable-rbac-authorization true \
            --sku standard \
            --tags $TAGS \
            --query id)

    print_style "Assigning secrets user, crypto user and key vault reader roles to pipeline service principal" info

    secrets_role=$(az role assignment create \
        --role "Key Vault Secrets User" \
        --assignee $SERVICE_PRINCIPAL_ID \
        --scope /subscriptions/$AZURE_SUBSCRIPTION_ID/resourcegroups/$RESOURCE_GROUP_NAME/providers/Microsoft.KeyVault/vaults/$key_vault_name)

    crypto_role=$(az role assignment create \
        --role "Key Vault Crypto User" \
        --assignee $SERVICE_PRINCIPAL_ID \
        --scope /subscriptions/$AZURE_SUBSCRIPTION_ID/resourcegroups/$RESOURCE_GROUP_NAME/providers/Microsoft.KeyVault/vaults/$key_vault_name)

    reader_role=$(az role assignment create \
        --role "Key Vault Reader" \
        --assignee $SERVICE_PRINCIPAL_ID \
        --scope /subscriptions/$AZURE_SUBSCRIPTION_ID/resourcegroups/$RESOURCE_GROUP_NAME/providers/Microsoft.KeyVault/vaults/$key_vault_name)

    # handle signed in user

    print_style "Assigning Key Vault admin role to you - the currently signed in user" info
    
    signed_in_user=$(az ad signed-in-user show --query id -o tsv)
    user_admin=$(az role assignment create \
        --role "Key Vault Administrator" \
        --assignee $signed_in_user \
        --scope /subscriptions/$AZURE_SUBSCRIPTION_ID/resourcegroups/$RESOURCE_GROUP_NAME)

    print_style "Completed deploying Azure resources $RESOURCE_GROUP_NAME" success

    write_env "KEY_VAULT_NAME" $key_vault_name
else
    print_style "Using existing resource: $KEY_VAULT_NAME" info
fi
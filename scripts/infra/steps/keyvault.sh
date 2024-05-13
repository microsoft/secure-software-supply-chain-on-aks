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

###################################################################
# Provision Azure Key Vault to hold x509 certificates for signing #
###################################################################

####################################################################
# ENV VARIABLES:
# KEY_VAULT_NAME
# RESOURCE_PREFIX
# RESOURCE_GROUP_NAME
# AZURE_SUBSCRIPTION_ID
# KEY_VAULT_NAME
# (for details on environment variables see ./config/environment.md)
####################################################################

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
    az keyvault create \
        --name $key_vault_name \
        --resource-group $RESOURCE_GROUP_NAME \
        --enable-rbac-authorization true \
        --sku standard \
        --tags $TAGS \
        --only-show-errors

    write_env "KEY_VAULT_NAME" $key_vault_name
else
    print_style "Using existing resource: $KEY_VAULT_NAME" info
fi

print_style "Assigning Key Vault Admin role to you - the currently signed in user" info

signed_in_user=$(az ad signed-in-user show --query id -o tsv)
az role assignment create \
    --role "Key Vault Administrator" \
    --assignee $signed_in_user \
    --scope /subscriptions/$AZURE_SUBSCRIPTION_ID/resourcegroups/$RESOURCE_GROUP_NAME
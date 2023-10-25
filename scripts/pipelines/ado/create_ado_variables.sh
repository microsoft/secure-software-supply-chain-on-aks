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
# Deploys Azure DevOps Variable Groups
#######################################################

#########################
# ENV VARIABLES:
# for details on environment variables see ./config/environment.md
# ADO_VARIABLE_GROUP_NAME
# AKS_NAME
# ACR_LOGIN_SERVER
# RESOURCE_GROUP_NAME
# ADO_AZURE_SERVICE_CONNECTION
# SIGNING_KEY_ID
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

# Create vargroup
if vargroup_id=$(az pipelines variable-group list -o tsv | grep "$ADO_VARIABLE_GROUP_NAME" | awk '{print $3}'); then
    print_style "Variable group: $ADO_VARIABLE_GROUP_NAME already exists. Deleting..." info
    az pipelines variable-group delete --id "$vargroup_id" -y
fi

print_style "Creating variable group: $ADO_VARIABLE_GROUP_NAME" info
az pipelines variable-group create \
    --name "$ADO_VARIABLE_GROUP_NAME" \
    --authorize "true" \
    --variables \
        ACR_NAME="$ACR_NAME" \
        ACR_LOGIN_SERVER="$ACR_LOGIN_SERVER" \
        AKS_NAME="$AKS_NAME" \
        RESOURCE_GROUP="$RESOURCE_GROUP_NAME" \
        AZURE_SERVICE_CONNECTION="$ADO_AZURE_SERVICE_CONNECTION" \
        SIGNING_KEY_ID="$SIGNING_KEY_ID" \
    --output json
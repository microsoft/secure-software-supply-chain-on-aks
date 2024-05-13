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
# Provision Azure Container Registry used for storing images and security artifacts
#######################################################

#########################
# ENV VARIABLES:
# for details on environment variables see ./config/environment.md
# ACR_NAME
# RESOURCE_PREFIX
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

##############
# Create ACR #
##############

print_block_header "Configuring ACR" warning

ACR_NAME=${ACR_NAME:-}
if [ -z $ACR_NAME ]; then
    acr_name="${RESOURCE_PREFIX}acr"
    print_style "Creating container registry $acr_name" info

    acr_login_server=$(az acr create \
        --resource-group $RESOURCE_GROUP_NAME \
        --name $acr_name \
        --sku Standard \
        --tags $TAGS \
        --query loginServer \
        --output tsv)

    write_env "ACR_NAME" $acr_name
    write_env "ACR_LOGIN_SERVER" $acr_login_server
else
    print_style "Using existing resource: $ACR_NAME" info

    ACR_LOGIN_SERVER=${ACR_LOGIN_SERVER:-}
    if [ -z $ACR_LOGIN_SERVER ]; then 
        write_env "ACR_LOGIN_SERVER" "${ACR_NAME}.azurecr.io"
    fi
fi

write_env "TRIPS_APP" "${ACR_LOGIN_SERVER}/trips:v1"
write_env "USER_PROFILE_APP" "${ACR_LOGIN_SERVER}/userprofile:v1"
write_env "POI_APP" "${ACR_LOGIN_SERVER}/poi:v1"
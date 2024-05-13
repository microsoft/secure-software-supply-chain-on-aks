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
# Provision resource group for all resource to be provisioned to
#######################################################

#########################
# ENV VARIABLES:
# for details on environment variables see ./config/environment.md
# RESOURCE_GROUP_NAME
# PROJECT_NAME
# AZURE_LOCATION
# TAGS
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

#########################
# Create Resource Group #
#########################

print_block_header "Configuring resource group" warning

RESOURCE_GROUP_NAME=${RESOURCE_GROUP_NAME:-}
if [ -z $RESOURCE_GROUP_NAME ]; then
    resource_group_name="${PROJECT_NAME}-rg"
    print_style "Creating resource group: $resource_group_name" info
    az group create --name $resource_group_name --location $AZURE_LOCATION --tags $TAGS
    write_env "RESOURCE_GROUP_NAME" $resource_group_name
else
    print_style "Using existing resource: $RESOURCE_GROUP_NAME" info
fi
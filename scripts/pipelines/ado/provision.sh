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
# Create the required Azure DevOps Pipelines, connections, and variable groups
#######################################################

#########################
# ENV VARIABLES:
# for details on environment variables see ./config/environment.md
# PROJECT_NAME
# ADO_PROJECT_NAME
# ADO_ORGANIZATION_URL
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

print_block_header "Configuring Deployments" warning
print_style "Configuring an variables, secrets, and federated credentials for ADO" info
write_env "ADO_VARIABLE_GROUP_NAME" $PROJECT_NAME
write_env "ADO_AZURE_SERVICE_CONNECTION" "${PROJECT_NAME}-asc"

# Add extension if not already present
[[ -n $(az extension list -o tsv | grep "azure-devops" | awk '{print $3}' 2> /dev/null) ]] || {  az extension add --name azure-devops; }
    az devops configure --defaults organization="$(sed "s/\"//g" <<<"$ADO_ORGANIZATION_URL")" project="$(sed "s/\"//g" <<<"$ADO_PROJECT_NAME")"

# The required GitHub service connection must be created as a prereq.

# Create ADO pipeline Service Connection -- required only once for the entire deployment
# This allows ADO create resources in Azure
print_style "Creating ADO Service Connection" info
./scripts/pipelines/ado/create_ado_service_connection_azure.sh

# Create ADO pipelines
print_style "Creating ADO Pipeline" info
./scripts/pipelines/ado/create_ado_pipeline.sh

print_style "Creating ADO variables" info    
./scripts/pipelines/ado/create_ado_variables.sh

print_style "Finished configuring Azure Pipelines" success
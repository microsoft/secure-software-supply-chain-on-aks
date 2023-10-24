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
# Provision all Azure resources
#######################################################

#########################
# ENV VARIABLES:
# for details on environment variables see ./config/environment.md
# GITHUB_REPO
# PROJECT
# DEPLOYMENT_ID
# AZURE_SUBSCRIPTION_ID
#########################

set -o errexit
set -o pipefail
set -o nounset

# For debugging
# set -o xtrace

# used for pretty printing to terminal
. ./scripts/helper/common.sh

# used for working with the env file
. ./scripts/helper/env.sh

####################
# DISCLAIMER #
####################
print_block_header "IMPORTANT NOTE" warning
print_style "As with all Azure deployments, this will incur associated costs.
Remember to teardown all related resources after use to avoid unnecessary costs.
Please review ./docs/provisioned-resources.md and ./docs/teardown.md" info

####################
# Naming Variables #
####################
project_name="${PROJECT}-${DEPLOYMENT_ID}"

write_env "PROJECT_NAME" $project_name
write_env "RESOURCE_PREFIX" "sssc${DEPLOYMENT_ID}"
write_env "SIGNING_CERT_NAME" "${project_name}-pipeline-cert"
write_env "GITHUB_REPO_URL" "https://github.com/$GITHUB_REPO"

####################
# Set Subscription #
####################
print_block_header "Configuring az account" warning
print_style "Deploying to Subscription: $AZURE_SUBSCRIPTION_ID" info
az account set --subscription "$AZURE_SUBSCRIPTION_ID"

#########
# Steps #
#########

# Preview Features
scripts/infra/steps/preview_features.sh

# Create Resource Group
./scripts/infra/steps/resource_group.sh

# Create ACR 
./scripts/infra/steps/acr.sh

# App Registration
./scripts/infra/steps/app_registration.sh

# Create AKS
./scripts/infra/steps/aks.sh

# Azure Key Vault
./scripts/infra/steps/keyvault.sh

# Signing Certificates
./scripts/infra/steps/certs.sh

# Helm Charts
./scripts/infra/steps/helm_charts.sh

# Summary Info
print_block_header "Summary Information" warning
print_style "Finished deploying infrastructure. Please proceed to next steps." info
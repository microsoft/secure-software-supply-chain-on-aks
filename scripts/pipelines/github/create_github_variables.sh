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
# Deploys Github environment with variables and secrets
#######################################################

#########################
# ENV VARIABLES:
# for details on environment variables see ./config/environment.md
# GITHUB_DEPLOYMENT_ENV_NAME
# GITHUB_REPO
# RESOURCE_GROUP_NAME
# SIGNING_KEY_ID
#########################

set -o errexit
set -o pipefail
set -o nounset

# For debugging
# set -o xtrace 

. ./scripts/helper/common.sh

# create environment for variables and secrets
print_style "Creating GitHub environment for variables $GITHUB_DEPLOYMENT_ENV_NAME" info
gh api --method PUT -H "Accept: application/vnd.github+json" "repos/$GITHUB_REPO/environments/$GITHUB_DEPLOYMENT_ENV_NAME" --silent

# get current users tenant
azure_tenant_id=$(az account show --query tenantId -o tsv)

# set secrets and variables
print_style "Creating GitHub variables" info
gh variable set RESOURCE_GROUP --body "$RESOURCE_GROUP_NAME" -R $GITHUB_REPO -e $GITHUB_DEPLOYMENT_ENV_NAME
gh variable set ACR_NAME --body "$ACR_NAME" -R $GITHUB_REPO -e $GITHUB_DEPLOYMENT_ENV_NAME
gh variable set ACR_LOGIN_SERVER --body "$ACR_LOGIN_SERVER" -R $GITHUB_REPO -e $GITHUB_DEPLOYMENT_ENV_NAME
gh variable set AKS_NAME --body "$AKS_NAME" -R $GITHUB_REPO -e $GITHUB_DEPLOYMENT_ENV_NAME
gh variable set SIGNING_KEY_ID --body "$SIGNING_KEY_ID" -R $GITHUB_REPO -e $GITHUB_DEPLOYMENT_ENV_NAME

print_style "Creating GitHub secrets" info
gh secret set AZURE_CLIENT_ID --body "$AZURE_APP_CLIENT_ID" -a actions -R $GITHUB_REPO -e $GITHUB_DEPLOYMENT_ENV_NAME
gh secret set AZURE_SUBSCRIPTION_ID --body "$AZURE_SUBSCRIPTION_ID" -a actions -R $GITHUB_REPO -e $GITHUB_DEPLOYMENT_ENV_NAME
gh secret set AZURE_TENANT_ID --body "$azure_tenant_id" -a actions -R $GITHUB_REPO -e $GITHUB_DEPLOYMENT_ENV_NAME
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
# Deploys Azure DevOps Azure Service Connections
#######################################################

#########################
# ENV VARIABLES:
# for details on environment variables see ./config/environment.md
# ENTRA_APP_ID
# PROJECT_NAME
# GITHUB_REPO
# GITHUB_DEPLOYMENT_ENV_NAME
#########################

set -o errexit
set -o pipefail
set -o nounset

. ./scripts/helper/common.sh

print_style "Creating Microsoft Entra ID federated credential for GitHub" info

environment_subject="repo:$GITHUB_REPO:environment:$GITHUB_DEPLOYMENT_ENV_NAME"

# Check if credential already exists
if az ad app federated-credential list --id $ENTRA_APP_ID --query "[].{Subject:subject}" | grep -q $environment_subject; then
    print_style "Credential already exists. Skipping creation." info
    exit 0
fi

# Create Github federated credential
az ad app federated-credential create --id $ENTRA_APP_ID --parameters \
    '{
        "name": "github-'${PROJECT_NAME}'",
        "issuer": "https://token.actions.githubusercontent.com",
        "subject": "'${environment_subject}'",
        "description": "Provision resources in Azure",
        "audiences": [
            "api://AzureADTokenExchange"
        ]
    }'
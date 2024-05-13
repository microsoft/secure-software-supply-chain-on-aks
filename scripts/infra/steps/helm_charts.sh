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

###################################################
# Deploy Gatekeeper and Ratify to the AKS cluster #
###################################################

####################################################################
# ENV VARIABLES:
# RESOURCE_GROUP_NAME
# AKS_NAME
# GATEKEEPER_VERSION
# RATIFY_VERSION
# RATIFY_CLIENT_ID
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

###############
# Helm Charts #
###############

print_block_header "Installing Helm Charts" warning

# Get access credentials for a managed Kubernetes cluster. By default, the credentials are merged into the .kube/config file so kubectl can use them.
az aks get-credentials \
  --resource-group $RESOURCE_GROUP_NAME \
  --name $AKS_NAME

if ! helm status -n gatekeeper-system gatekeeper 2>/dev/null; then
    print_style "Installing Gatekeeper on the cluster" info

    helm repo add gatekeeper https://open-policy-agent.github.io/gatekeeper/charts
    helm repo update gatekeeper

    helm install gatekeeper/gatekeeper  \
      --version $GATEKEEPER_VERSION \
      --name-template=gatekeeper \
      --namespace gatekeeper-system --create-namespace \
      --set enableExternalData=true \
      --set validatingWebhookTimeoutSeconds=5 \
      --set mutatingWebhookTimeoutSeconds=2 \
      --set externaldataProviderResponseCacheTTL=10s

else
    print_style "Using existing resource: Gatekeeper" info
fi

if ! helm status -n gatekeeper-system ratify 2>/dev/null; then
    print_style "Installing Ratify on the cluster" info

    helm repo add ratify https://deislabs.github.io/ratify
    helm repo update ratify

    helm install ratify ratify/ratify --atomic \
    --namespace gatekeeper-system --create-namespace \
    --version=$RATIFY_VERSION \
    --set gatekeeper.version=$GATEKEEPER_VERSION \
    --set featureFlags.RATIFY_CERT_ROTATION=true \
    --set azureWorkloadIdentity.clientId=$RATIFY_CLIENT_ID \
    --set oras.authProviders.azureWorkloadIdentityEnabled=true \
    --set policy.useRego=true # even though we'll be overwriting it, this ensures Ratify expects to use rego and not config-driven policy

else
    print_style "Using existing resource: Ratify" info
fi
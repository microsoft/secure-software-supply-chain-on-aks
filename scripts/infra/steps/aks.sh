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
# Provisions Azure Kunernetes Service instance used for workload deployments
#######################################################

#########################
# ENV VARIABLES:
# for details on environment variables see ./config/environment.md
# AKS_NAME
# RESOURCE_PREFIX
# RESOURCE_GROUP_NAME
# KUBERNETES_VERSION
# ACR_NAME
# TAGS
# RATIFY_CLIENT_ID
# AKS_OIDC_ISSUER
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
# Create AKS #
#############

print_block_header "Configuring AKS" warning

AKS_NAME=${AKS_NAME:-}
if [ -z $AKS_NAME ]; then
    cluster_name="${RESOURCE_PREFIX}aks"

    print_style "Creating AKS cluster $cluster_name" info

    aks_oidc_issuer=$(az aks create \
        --name $cluster_name \
        --resource-group $RESOURCE_GROUP_NAME \
        --kubernetes-version $KUBERNETES_VERSION \
        --enable-oidc-issuer \
        --enable-workload-identity \
        --attach-acr $ACR_NAME \
        --tier free \
        --node-count 2 \
        --node-vm-size Standard_DS2_v2 \
        --os-sku AzureLinux \
        --generate-ssh-keys \
        -y \
        --tags $TAGS \
        --nodepool-tags $TAGS \
        --query "oidcIssuerProfile.issuerUrl" \
        -o tsv)

    aks_name=$cluster_name

    write_env "AKS_NAME" $aks_name
    write_env "AKS_OIDC_ISSUER" $aks_oidc_issuer
else
    print_style "Using existing resource: $AKS_NAME" info
fi

#######################
# Identity for Ratify #
#######################

print_block_header "Configuring Ratify Identity" warning

RATIFY_CLIENT_ID=${RATIFY_CLIENT_ID:-}
if [ -z $RATIFY_CLIENT_ID ];then
    print_style "Creating Ratify's federated credentials for workload identity" info

    ## create user-assigned managed identity
    ratify_identity_name="${RESOURCE_PREFIX}RatifyAksIdentity"

    ratify_identity=$(az identity create \
        --name $ratify_identity_name \
        --resource-group $RESOURCE_GROUP_NAME \
        --location $AZURE_LOCATION)

    ratify_object_id=$(echo "$ratify_identity" | jq -r '.principalId')
    ratify_client_id=$(echo "$ratify_identity" | jq -r '.clientId')

    ratify_federated_identity="${RESOURCE_PREFIX}RatifyFederatedIdentityCredentials"
    
    ## create federated creds
    federated_ratify=$(az identity federated-credential create \
        --name $ratify_federated_identity \
        --identity-name $ratify_identity_name \
        --resource-group $RESOURCE_GROUP_NAME \
        --issuer $AKS_OIDC_ISSUER \
        --subject system:serviceaccount:gatekeeper-system:ratify-admin \
        --audience api://AzureADTokenExchange)

    # Ratify ACR pull role

    print_style "Granting Ratify acrPull role" info

    ratify_acrpull=$(az role assignment create \
        --assignee-object-id $ratify_object_id \
        --assignee-principal-type ServicePrincipal \
        --role acrpull \
        --scope subscriptions/$AZURE_SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP_NAME/providers/Microsoft.ContainerRegistry/registries/$ACR_NAME)

    write_env "RATIFY_CLIENT_ID" $ratify_client_id
else
    print_style "Using existing resource: $RATIFY_CLIENT_ID" info
fi
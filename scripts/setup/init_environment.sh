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
# Ensure all required env variables have been set
#######################################################

#########################
# ENV VARIABLES: NONE (they are all set and exported in this script)
#########################

# used for pretty printing to terminal
. ./scripts/helper/common.sh

# used to set up config and env file creation
. ./scripts/helper/config.sh

# used for working with the env file
. ./scripts/helper/env.sh

missing_variable_message="Please specify a value in the file ./config/sssc.config for the variable:"

DEPLOYMENT_ID=${DEPLOYMENT_ID:-}
if [ -n "$DEPLOYMENT_ID" ]
then
    # this script has been already due to the presence of the DEPLOYMENT_ID env var
    # deleting the sssc.env file will run from scratch
    print_style "Found DEPLOYMENT_ID [${DEPLOYMENT_ID}] which will be used. To generate a new deployment id and run everything from scratch, delete the file ./config/sssc.env before running again." info
else
    # Missing DEPLOYMENT_ID so this is the first time its been run    
    print_style "Creating new ./config/sssc.env environment file from ./config/sssc.config base values." info
    create_env_file
    
    DEPLOYMENT_ID="$(random_str 5)"
    write_env "DEPLOYMENT_ID" $DEPLOYMENT_ID
    print_style "[DEPLOYMENT_ID] set to $DEPLOYMENT_ID" info
fi

# check required variables are specified.
GITHUB_REPO=${GITHUB_REPO:-}
GITHUB_REPO="$(sed "s/\"//g" <<<"$GITHUB_REPO")"
if [ -z "$GITHUB_REPO" ]
then
    print_style "${missing_variable_message} GITHUB_REPO using the format: <my_github_handle_or_org>/<repo>. (e.g. microsoft/secure-software-supply-chain-on-aks)" danger
    delete_env_file
    exit 1
fi

# initialize optional variables.
PROJECT=${PROJECT:-}
if [ -z "$PROJECT" ]
then    
    write_env "PROJECT" "ssscsample"
    print_style "No project name [PROJECT] specified, Defaulting to $PROJECT" info
elif ! [[ "$PROJECT" =~ ^[a-z0-9]{1,10}$ ]]
then
    current_project=$PROJECT
    PROJECT=$(echo "$current_project" | tr '[:upper:]' '[:lower:]')
    PROJECT=$(echo "$PROJECT" | tr -dc 'a-z0-9' )
    PROJECT="${PROJECT:0:10}"
    write_env "PROJECT" $PROJECT
    print_style "[PROJECT] must be no more than 10 lowercase alphanumeric characters. Current value is $current_project. This has been modified to $PROJECT. Update the config file if this isn't acceptable." danger
fi

AZURE_SUBSCRIPTION_ID=${AZURE_SUBSCRIPTION_ID:-}
if [ -z "$AZURE_SUBSCRIPTION_ID" ]
then
    AZURE_SUBSCRIPTION_ID=$(az account show --output json | jq -r '.id')
    write_env "AZURE_SUBSCRIPTION_ID" $AZURE_SUBSCRIPTION_ID
    print_style "No Azure subscription id [AZURE_SUBSCRIPTION_ID] specified. Using default subscription id." info
fi

AZURE_LOCATION=${AZURE_LOCATION:-}
if [ -z "$AZURE_LOCATION" ]
then
    AZURE_LOCATION="eastus"
    write_env "AZURE_LOCATION" $AZURE_LOCATION
    print_style "No resource group location [AZURE_LOCATION] specified, Defaulting to $AZURE_LOCATION" info
fi

GATEKEEPER_VERSION=${GATEKEEPER_VERSION:-}
if [ -z "$GATEKEEPER_VERSION" ]
then
    GATEKEEPER_VERSION="3.14.0"
    write_env "GATEKEEPER_VERSION" $GATEKEEPER_VERSION
    print_style "No Gatekeeper version in [GATEKEEPER_VERSION] specified. Defaulting to $GATEKEEPER_VERSION" info
fi

RATIFY_VERSION=${RATIFY_VERSION:-}
if [ -z "$RATIFY_VERSION" ]
then
    RATIFY_VERSION="1.12.0"
    write_env "RATIFY_VERSION" $RATIFY_VERSION
    print_style "No Ratify version in [RATIFY_VERSION] specified. Defaulting to $RATIFY_VERSION" info
fi

KUBERNETES_VERSION=${KUBERNETES_VERSION:-}
if [ -z "$KUBERNETES_VERSION" ]
then
    KUBERNETES_VERSION="1.27.7"
    write_env "KUBERNETES_VERSION" $KUBERNETES_VERSION
    print_style "No Kubernetes version in [KUBERNETES_VERSION] specified. Defaulting to $KUBERNETES_VERSION" info
fi

GIT_BRANCH=${GIT_BRANCH:-}
if [ -z "$GIT_BRANCH" ]
then
    GIT_BRANCH="main"
    write_env "GIT_BRANCH" $GIT_BRANCH
    print_style "No Git branch name in [GIT_BRANCH] specified. Defaulting to $GIT_BRANCH" info
fi

TAGS=${TAGS:-}

CI_CD_PLATFORM=${CI_CD_PLATFORM:-}

# check required ADO variables are specified
if [ "$CI_CD_PLATFORM" = "ado" ]
then
    ADO_PROJECT_NAME=${ADO_PROJECT_NAME:-}
    ADO_PROJECT_NAME="$(sed "s/\"//g" <<<"$ADO_PROJECT_NAME")"
    ADO_ORGANIZATION_URL=${ADO_ORGANIZATION_URL:-}
    ADO_ORGANIZATION_URL="$(sed "s/\"//g" <<<"$ADO_ORGANIZATION_URL")"
    ADO_GITHUB_SERVICE_CONNECTION=${ADO_GITHUB_SERVICE_CONNECTION:-}
    
    if [ -z "$ADO_PROJECT_NAME" ]
    then
        print_style "${missing_variable_message} ADO_PROJECT_NAME" danger
        delete_env_file
        exit 1
    fi

    if [ -z "$ADO_ORGANIZATION_URL" ]
    then
        print_style "${missing_variable_message} ADO_ORGANIZATION_URL" danger
        delete_env_file
        exit 1
    fi

    if [ -z "$ADO_GITHUB_SERVICE_CONNECTION" ]
    then
        print_style "${missing_variable_message} ADO_GITHUB_SERVICE_CONNECTION" danger
        delete_env_file
        exit 1
    fi
fi
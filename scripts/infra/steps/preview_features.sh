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
# Install preview features used for workload identity in AKS
#######################################################

#########################
# ENV VARIABLES: NONE
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

# Enable `EnableWorkloadIdentityPreview` feature. It may take ~10 minutes to register.
if [ $(az feature list -o tsv --query "[?contains(name, 'Microsoft.ContainerService/EnableWorkloadIdentityPreview')].properties.state") != "Registered" ]
then
    print_block_header "Registering preview features" info
    az feature register --namespace "Microsoft.ContainerService" --name "EnableWorkloadIdentityPreview"

    # Check registration status for the feature `EnableWorkloadIdentityPreview` and wait until registration is complete
    while [ $(az feature list -o tsv --query "[?contains(name, 'Microsoft.ContainerService/EnableWorkloadIdentityPreview')].properties.state") != "Registered" ]
    do
        echo "Waiting for Workload Identity feature registration..."
        sleep 20
    done

    az provider register --namespace "Microsoft.ContainerService"
fi
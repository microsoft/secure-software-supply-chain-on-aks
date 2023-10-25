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
# Create the required GitHub environment, variables, and secrets
#######################################################

#########################
# ENV VARIABLES:
# for details on environment variables see ./config/environment.md
# PROJECT_NAME
#########################

set -o errexit
set -o pipefail
set -o nounset

# For debugging
# set -o xtrace 

. ./scripts/helper/common.sh
. ./scripts/helper/env.sh

##################
# GitHub Actions #
##################

print_style "Configuring an environment, variables, secrets, and federated credentials for GitHub Actions" info
write_env "GITHUB_DEPLOYMENT_ENV_NAME" $PROJECT_NAME

# Create Github federated credential
./scripts/pipelines/github/create_github_federated_credential.sh

# Create variables for GitHub Actions    
./scripts/pipelines/github/create_github_variables.sh

print_style "Finished configuring GitHub Actions" success

workflow_file=sssc.linux.notation.yaml

write_env "WORKFLOW_FILE" "$workflow_file"
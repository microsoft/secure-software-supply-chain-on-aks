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
# Creates Azure DevOps Pipeline
#######################################################

#########################
# ENV VARIABLES:
# for details on environment variables see ./config/environment.md
# GITHUB_REPO_URL
# ADO_GITHUB_SERVICE_CONNECTION
# PROJECT_NAME
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

# Retrieve Github Service Connection Id
github_sc_id=$(az devops service-endpoint list --output json |
    jq -r --arg NAME "$ADO_GITHUB_SERVICE_CONNECTION" '.[] | select(.name==$NAME) | .id')

createPipeline () {
    declare pipeline_yml_file=$1
    declare pipeline_description=$2
    full_pipeline_name=$PROJECT_NAME-$pipeline_yml_file
    pipeline_id=$(az pipelines create \
        --name "$full_pipeline_name" \
        --description "$pipeline_description" \
        --repository "$GITHUB_REPO_URL" \
        --branch "$GIT_BRANCH" \
        --yaml-path ".azdevops/$pipeline_yml_file" \
        --service-connection "$github_sc_id" \
        --skip-first-run true \
        --output json | jq -r '.id')
    
    write_env "PIPELINE_ID" $pipeline_id
    write_env "PIPELINE_NAME" $full_pipeline_name

    print_style "Created $full_pipeline_name with id $pipeline_id" info
}

# Pipelines
createPipeline "sssc.linux.notation.yaml" "SSSC - Linux workloads signed with Notation"
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
# Execute the GitHub workflow
#######################################################

#########################
# ENV VARIABLES:
# for details on environment variables see ./config/environment.md
# WORKFLOW_FILE
# GIT_BRANCH
# GITHUB_DEPLOYMENT_ENV_NAME
#########################

. ./scripts/helper/common.sh
. ./config/sssc.env

set -o errexit
set -o pipefail
set -o nounset

# For debugging
# set -o xtrace 

print_style "Running GitHub Actions Workflow ${WORKFLOW_FILE} on branch ${GIT_BRANCH}" info 

gh workflow run $WORKFLOW_FILE -f environment_name=$GITHUB_DEPLOYMENT_ENV_NAME --ref $GIT_BRANCH

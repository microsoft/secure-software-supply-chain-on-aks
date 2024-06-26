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
# Apply Gatekeeper CRDs, templates, and template definitions
#######################################################

#########################
# ENV VARIABLES: NONE
#########################

set -o errexit
set -o pipefail
set -o nounset

# For debugging
# set -o xtrace 

# used for pretty printing to terminal
. ./scripts/helper/common.sh

# all controls configured within Ratify must pass

print_style "Deploy template and constraint: External data call to Ratify must return success" info

kubectl apply -f ./policy/gatekeeper/ratifyverification/constraint-template.yaml
kubectl apply -f ./policy/gatekeeper/ratifyverification/constraint.yaml
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
# Verify all of the required tools are installed
#######################################################

#########################
# ENV VARIABLES: NONE
#########################

# Check if required utilities are installed
command -v jq >/dev/null 2>&1 || { echo >&2 "jq is required but not installed. See https://stedolan.github.io/jq/.  Aborting."; exit 1; }
command -v az >/dev/null 2>&1 || { echo >&2 "The Azure CLI is required but not installed. See https://bit.ly/2Gc8IsS. Aborting."; exit 1; }
command -v helm >/dev/null 2>&1 || { echo >&2 "The Helm CLI is required but not installed. See https://helm.sh/docs/intro/install/. Aborting."; exit 1; }
command -v oras >/dev/null 2>&1 || { echo >&2 "ORAS CLI is required but not installed. See https://oras.land/docs/installation. Aborting."; exit 1; }
command -v kubectl >/dev/null 2>&1 || { echo >&2 "The Kubernetes command line tool, kubectl, is required but not installed. See https://kubernetes.io/docs/tasks/tools/#kubectl. Aborting."; exit 1; }
command -v gh >/dev/null 2>&1 || { echo >&2 "The GitHub CLI is required but not installed. See https://cli.github.com/. Aborting."; exit 1; }

# Check if user is logged in to Azure CLI
[[ -n $(az account show 2> /dev/null) ]] || { echo "Please login via the Azure CLI and set the correct subscription."; exit 1; }
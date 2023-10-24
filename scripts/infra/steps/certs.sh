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
# Generate all certs need to sign and verify artifacts
#######################################################

#########################
# ENV VARIABLES:
# for details on environment variables see ./config/environment.md
# SIGNING_CERT_NAME
# KEY_VAULT_NAME
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

print_block_header "Configuring Certificates" warning

SIGNING_KEY_ID=${SIGNING_KEY_ID:-}
if [ -z $SIGNING_KEY_ID ];then
    ./scripts/certs/create_ca.sh
    ./scripts/certs/create_signing_cert_kv.sh

    signing_key_id=$(az keyvault certificate show --vault-name "${KEY_VAULT_NAME}" --name "${SIGNING_CERT_NAME}" --query kid -o tsv)

    write_env "SIGNING_KEY_ID" $signing_key_id
else
    print_style "Using existing resource: $SIGNING_KEY_ID" info
fi
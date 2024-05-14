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

####################################################################
# ENV VARIABLES:
# PROJECT_NAME
# KEY_VAULT_NAME
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

print_block_header "Configuring Certificates" warning

CA_CERT_SUBJECT=${CA_CERT_SUBJECT:-}

if [[ -z "$CA_CERT_SUBJECT" ]]; then
    echo "CA_CERT_SUBJECT=\"/C=US/ST=WA/L=Redmond/O=Company ${PROJECT_NAME}/CN=${PROJECT_NAME} Certificate Authority\"" >> $env_file
    export CA_CERT_SUBJECT="/C=US/ST=WA/L=Redmond/O=Company ${PROJECT_NAME}/CN=${PROJECT_NAME} Certificate Authority"
fi

ca_cert_file="./scripts/certs/ca.crt"

if [ ! -f "$ca_cert_file" ]; then 
    ./scripts/certs/create_ca.sh
fi

SIGN_CERT_SUBJECT=${SIGN_CERT_SUBJECT:-}

if [[ -z "$SIGN_CERT_SUBJECT" ]]; then
    echo "SIGN_CERT_SUBJECT=\"C=US, ST=WA, L=Redmond, O=Company ${PROJECT_NAME}, OU=Org A, CN=pipeline.example.com\"" >> $env_file
    export SIGN_CERT_SUBJECT="C=US, ST=WA, L=Redmond, O=Company ${PROJECT_NAME}, OU=Org A, CN=pipeline.example.com"
fi

SIGNING_KEY_ID=${SIGNING_KEY_ID:-}

if [ -z $SIGNING_KEY_ID ]; then

    write_env "SIGNING_CERT_NAME" "${PROJECT_NAME}-pipeline-cert"
    ./scripts/certs/create_signing_cert_kv.sh

else
    print_style "Using existing id: $SIGNING_KEY_ID" info
fi


ALT_CERT_SUBJECT=${ALT_CERT_SUBJECT:-}

if [[ -z "$ALT_CERT_SUBJECT" ]]; then
    echo "ALT_CERT_SUBJECT=\"C=US, ST=WA, L=Seattle, O=Company ${PROJECT_NAME}, OU=Org B, CN=alt.example.com\"" >> $env_file
    export ALT_CERT_SUBJECT="C=US, ST=WA, L=Seattle, O=Company ${PROJECT_NAME}, OU=Org B, CN=alt.example.com"
fi

ALT_SIGNING_KEY_ID=${ALT_SIGNING_KEY_ID:-}

if [ -z $ALT_SIGNING_KEY_ID ]; then

    write_env "ALT_SIGNING_CERT_NAME" "${PROJECT_NAME}-pipeline-cert-alt"
    ./scripts/certs/create_alt_signing_cert_kv.sh

else
    print_style "Using existing id: $ALT_SIGNING_KEY_ID" info
fi
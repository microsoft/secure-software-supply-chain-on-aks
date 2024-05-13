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

#####################################################
# Create a the Notation verifier                    #
# with the trusted identities scoped to the subject #
# of the SIGNING_KEY_ID used by Trips               #
#####################################################

####################################
# ENV VARIABLES: SIGN_CERT_SUBJECT #
####################################

set -o errexit
set -o nounset

# For debugging
# set -o xtrace 

# used for working with the env file
. ./scripts/helper/env.sh

# used for pretty printing to terminal
. ./scripts/helper/common.sh

print_block_header "Creating configuration for Notation signature verification" warning

print_style "Trusted Identities limited to $SIGN_CERT_SUBJECT" info

export notation_verifier_yaml="./policy/ratify/verifier-signature.notation.yaml"

rm -f $notation_verifier_yaml

sign_cert_subject="$(sed "s/\"//g" <<<"$SIGN_CERT_SUBJECT")"

cat <<EOF > $notation_verifier_yaml
apiVersion: config.ratify.deislabs.io/v1beta1
kind: Verifier
metadata:
  name: verifier-notation
  annotations:
    helm.sh/hook: pre-install,pre-upgrade
    helm.sh/hook-weight: "5"
spec:
  name: notation
  artifactTypes: application/vnd.cncf.notary.signature
  parameters:
    verificationCertStores:
      certs:
        - certstore-inline
    trustPolicyDoc:
      version: "1.0"
      trustPolicies:
        - name: default
          registryScopes:
            - "*"
          signatureVerification:
            level: strict
          trustStores:
            - ca:certs
          trustedIdentities:
            - "x509.subject:$sign_cert_subject"
EOF

print_style "$notation_verifier_yaml created" info
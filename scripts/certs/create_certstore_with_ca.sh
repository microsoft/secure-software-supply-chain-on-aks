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

#####################################################################
# Create a certificate store CRD with the contents of the ca.crt file
#####################################################################

#########################
# ENV VARIABLES: NONE
#########################

set -o errexit
set -o nounset

# For debugging
# set -o xtrace 

export certstore_yaml="./policy/ratify/notation-certificatestore.yaml"

cat <<EOF > $certstore_yaml
apiVersion: config.ratify.deislabs.io/v1beta1
kind: CertificateStore
metadata:
  name: certstore-inline
  namespace: gatekeeper-system
spec:
  provider: inline
  parameters:
    value: |
$(while IFS= read -r line; do
    echo "      $line" 
done < "./scripts/certs/ca.crt")
EOF
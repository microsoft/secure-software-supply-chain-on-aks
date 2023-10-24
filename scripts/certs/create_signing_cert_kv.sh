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
# Creates a certificate signing request with Azure KV, signs it with the local CA and merges the request into a signing cert in KV
#######################################################

###################
# ENV VARIABLES:
# for details on environment variables see ./config/environment.md
# SIGNING_CERT_NAME
# KEY_VAULT_NAME
###############

set -o errexit
set -o pipefail
set -o nounset

# For debugging
# set -o xtrace 

script_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# This script creates a certificate for use with notation using a openssl as a local certificate authority

# https://github.com/notaryproject/notaryproject/blob/main/specs/signature-specification.md#certificate-requirements
# IMPORTANT: cert chains must be stored in Key Vault in PEM format
policy=$(cat <<EOF
{
  "issuerParameters": {
    "certificateTransparency": null,
    "name": "Unknown"
  },
  "keyProperties": {
    "exportable": false
  },
  "secretProperties": {
    "contentType": "application/x-pem-file"
  },
  "x509CertificateProperties": {
    "ekus": [
      "1.3.6.1.5.5.7.3.3"
    ],
    "keyUsage": [
      "digitalSignature"
    ],
    "subject": "C=US, ST=WA, L=Redmond, O=My Company, OU=My Org, CN=pipeline.example.com",
    "validityInMonths": 12
  }
}
EOF
)

# create a certificate signing request via keyvault
# the response doesn't contain the necessary header/footer to the certificate signing request so we add it here
echo '-----BEGIN CERTIFICATE REQUEST-----' > "${script_dir}/${SIGNING_CERT_NAME}.csr"
az keyvault certificate create --vault-name "${KEY_VAULT_NAME}" --name "${SIGNING_CERT_NAME}" --policy "${policy}" --query csr -o tsv >> "${script_dir}/${SIGNING_CERT_NAME}.csr"
echo '-----END CERTIFICATE REQUEST-----' >> "${script_dir}/${SIGNING_CERT_NAME}.csr"

# complete the certificate signing request using the local CA
openssl x509 -req -in "${script_dir}/${SIGNING_CERT_NAME}.csr" -CA "${script_dir}/ca.crt" -CAkey "${script_dir}/ca.key" -CAcreateserial -out "${script_dir}/${SIGNING_CERT_NAME}.crt" -days 365 -sha256 -extensions 'notation_cert' -extfile "${script_dir}/openssl.cnf"

# append the CA cert to create a certificate bundle
cat "${script_dir}/ca.crt" >> "${script_dir}/${SIGNING_CERT_NAME}.crt"

# complete the signing request and push the cert to Key Vault
az keyvault certificate pending merge --vault-name "${KEY_VAULT_NAME}" --name "${SIGNING_CERT_NAME}" -f "${script_dir}/${SIGNING_CERT_NAME}.crt"
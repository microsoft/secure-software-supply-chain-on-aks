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
# Creates a local certificate authority (CA) with OpenSSL.
#######################################################

#########################
# ENV VARIABLES: NONE
#########################

set -euo pipefail

script_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# This script creates a local certificate authority using openssl for use with notation
# usage: create-ca.sh

# https://github.com/notaryproject/notaryproject/blob/main/specs/signature-specification.md#certificate-requirements
# define extensions to create certs that comply with notation
cp /usr/lib/ssl/openssl.cnf "${script_dir}/openssl.cnf"
cat <<EOF >> "${script_dir}/openssl.cnf"
[ notation_ca ]
# Extensions for a typical CA
subjectKeyIdentifier=hash
authorityKeyIdentifier=keyid:always,issuer
basicConstraints = critical,CA:true
keyUsage = critical,cRLSign, keyCertSign

[ notation_cert ]
keyUsage = critical,digitalSignature
EOF

# create root CA key
openssl genpkey -algorithm RSA -out "${script_dir}/ca.key" -pkeyopt rsa_keygen_bits:4096 -quiet

# create root CA certificate
openssl req -x509 -new -nodes -key "${script_dir}/ca.key" -sha256 -days 3650 -extensions 'notation_ca' -config "${script_dir}/openssl.cnf" -out "${script_dir}/ca.crt" -subj "/C=US/ST=WA/L=Redmond/O=My Company/OU=My Org/CN=ca.example.com"

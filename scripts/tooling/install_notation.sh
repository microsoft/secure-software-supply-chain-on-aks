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
# <SCRIPT PURPOSE>
#
# Prerequisites:
# - 
#######################################################

#########################
# ENV VARIABLES: NONE
#########################

set -euo pipefail

NOTATION_TOOLING_PATH=/usr/local/bin
ARCH=linux_amd64
AKV_PLUGIN_VERSION=1.0.2
NOTATION_VERSION=1.1.0

# download Notation CLI
NOTATION_TAR_FILE=notation_$NOTATION_VERSION\_$ARCH.tar.gz
NOTATION_CHECKSUM_FILE=notation_$NOTATION_VERSION\_checksums.txt
curl -LO https://github.com/notaryproject/notation/releases/download/v$NOTATION_VERSION/$NOTATION_TAR_FILE
curl -LO https://github.com/notaryproject/notation/releases/download/v$NOTATION_VERSION/notation_$NOTATION_VERSION\_checksums.txt

# validate & install notation CLI
if shasum --check --ignore-missing $NOTATION_CHECKSUM_FILE | grep "$NOTATION_TAR_FILE: OK"; then
    tar -zxf $NOTATION_TAR_FILE -C $NOTATION_TOOLING_PATH notation
    rm -rf $NOTATION_TAR_FILE
    rm -rf $NOTATION_CHECKSUM_FILE
else
    echo "existing notation CLI installation due to checksums not matching"
    exit 1
fi


AKV_CHECKSUM=f2b2e131a435b6a9742c202237b9aceda81859e6d4bd6242c2568ba556cee20e
plugin_url="https://github.com/Azure/notation-azure-kv/releases/download/v${AKV_PLUGIN_VERSION}/notation-azure-kv_${AKV_PLUGIN_VERSION}_${ARCH}.tar.gz"

notation plugin install --url $plugin_url --sha256sum $AKV_CHECKSUM
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

set -uo pipefail

ORAS_TOOLING_PATH=/usr/local/bin
ARCH=linux_amd64
ORAS_VERSION=1.0.0

# download oras CLI
ORAS_TAR_FILE=oras_$ORAS_VERSION\_$ARCH.tar.gz
ORAS_CHECKSUM_FILE=oras_$ORAS_VERSION\_checksums.txt
curl -LO https://github.com/oras-project/oras/releases/download/v$ORAS_VERSION/$ORAS_TAR_FILE
curl -LO https://github.com/oras-project/oras/releases/download/v$ORAS_VERSION/$ORAS_CHECKSUM_FILE

# validate & install oras CLI
if shasum --check --ignore-missing $ORAS_CHECKSUM_FILE | grep "$ORAS_TAR_FILE: OK"; then
    tar -zxf $ORAS_TAR_FILE -C $ORAS_TOOLING_PATH oras
    rm -rf $ORAS_TAR_FILE
    rm -rf $ORAS_CHECKSUM_FILE
else
    echo "exititing oras CLI installation due to checksums not matching"
    exit 1
fi
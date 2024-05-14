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

TRIVY_TOOLING_PATH=/usr/local/bin
ARCH=Linux-64bit
TRIVY_VERSION=0.42.1

# download trivy CLI
TRIVY_TAR_FILE=trivy_$TRIVY_VERSION\_$ARCH.tar.gz
TRIVY_CHECKSUM_FILE=trivy_$TRIVY_VERSION\_checksums.txt
curl -LO https://github.com/aquasecurity/trivy/releases/download/v$TRIVY_VERSION/$TRIVY_TAR_FILE
curl -LO https://github.com/aquasecurity/trivy/releases/download/v$TRIVY_VERSION/$TRIVY_CHECKSUM_FILE

# validate & install TRIVY CLI
if shasum --check --ignore-missing $TRIVY_CHECKSUM_FILE | grep "$TRIVY_TAR_FILE: OK"; then
    tar -zxf $TRIVY_TAR_FILE -C $TRIVY_TOOLING_PATH trivy
    rm -rf $TRIVY_TAR_FILE
    rm -rf $TRIVY_CHECKSUM_FILE
else
    echo "exititing TRIVY CLI installation due to checksums not matching"
    exit 1
fi
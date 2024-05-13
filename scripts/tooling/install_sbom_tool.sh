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
# Download and install Microsoft's sbom-tool
#
# Prerequisites:
# - 
#######################################################

#########################
# ENV VARIABLES: NONE
#########################

set -uo pipefail

SBOM_TOOLING_PATH=/usr/local/bin
ARCH=linux-x64
SBOM_TOOL_VERSION=2.2.4

# download SBOM Tool
SBOM_DL_FILE=sbom-tool-$ARCH
curl -Lo sbom-tool https://github.com/microsoft/sbom-tool/releases/download/v$SBOM_TOOL_VERSION/$SBOM_DL_FILE

# Install SBOM tool
chmod +x sbom-tool
mv sbom-tool $SBOM_TOOLING_PATH
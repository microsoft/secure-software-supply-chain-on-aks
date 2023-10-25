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
# Exports all values from ./config/sssc.env on load.
# Function for writing values to ./config/sssc.env and exporting them
#######################################################

#########################
# ENV VARIABLES: NONE
#########################

# For debugging
# set -o xtrace

env_file="./config/sssc.env"

main() {
    # If there is an env file, load it so this shell and subshells can use it
    if [ -f $env_file ]; then
        # Read the .env file line by line
        while IFS= read -r line || [[ -n "$line" ]]; do
            # Skip lines that are comments or empty
            if [[ $line =~ ^[[:space:]]*# || -z $line ]]; then
                continue
            fi
            export "$line"
        done < $env_file
    fi
}

write_env() {
    value=${2:-""}
    # # Replace the environment variable if exists
    if grep -qE "\b$1=" "$env_file"; then        
        sed -i "s|\\b$1=.*|$1=$value|" "$env_file"
    else
        echo "$1=$value" >> $env_file
    fi    
    export "$1=$value"
}

main
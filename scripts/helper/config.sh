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
# Used for the management of an env file
#######################################################

#########################
# ENV VARIABLES: NONE
#########################

# For debugging
# set -o xtrace 

env_file="./config/sssc.env"
config_file="./config/sssc.config"

create_env_file() {
    delete_env_file

    if [ -f $config_file ]; then
        # Read the config file line by line
        while IFS= read -r line || [[ -n "$line" ]]; do
            # Skip lines that are comments or empty
            if [[ $line =~ ^[[:space:]]*# || -z $line ]]; then
                continue
            fi
            # write to env file
            echo "$line" >> $env_file
            export "$line"
        done < $config_file
    else
        print_style "$config_file file not found. Please make sure all of the configuration steps have been met from the the 'Create configuration file' section of the README." danger
        exit 1
    fi
}

delete_env_file() {
    rm -f $env_file
}
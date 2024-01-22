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
# Teardown all resources provisioned in this walkthrough
#######################################################

#########################
# ENV VARIABLES:
# for details on environment variables see ./config/environment.md
# CI_CD_PLATFORM
# PROJECT_NAME
# GITHUB_REPO
#########################

set -o errexit
set -o pipefail
set -o nounset

# For debugging
#set -o xtrace 

# used for working with the env file
. ./scripts/helper/env.sh

# used for pretty printing to terminal
. ./scripts/helper/common.sh

if [ -z "$PROJECT_NAME" ]
then
    print_style "Please specify a value for the 'PROJECT_NAME' environment variable which is used to delete resources." danger
    exit 1
fi

print_block_header "!! WARNING: !!" danger
print_style "THIS SCRIPT WILL DELETE THE FOLLOWING RESOURCES PREFIXED WITH '$PROJECT_NAME'" danger

if [[ -n $PROJECT_NAME ]]; then
    if [ "$CI_CD_PLATFORM" = "ado" ]; then
        print_style "\nPIPELINES:\n" warning
        az pipelines list -o tsv --only-show-errors | { grep "$PROJECT_NAME" || true; } | awk 'BEGIN{FS="\t"; OFS=FS}{print $9}'

        print_style "\nVARIABLE GROUPS:\n" warning
        az pipelines variable-group list -o tsv --only-show-errors | { grep "$PROJECT_NAME" || true; } | awk '{print $6}'

        print_style "\nSERVICE CONNECTIONS:\n" warning
        az devops service-endpoint list -o tsv --only-show-errors | { grep "$PROJECT_NAME" || true; } | awk '{print $7}'
    elif [ "$CI_CD_PLATFORM" == "github" ]; then
        print_style "\nGitHub ENVIRONMENTS:\n" warning
        gh api -H "Accept: application/vnd.github+json" -H \
            "X-GitHub-Api-Version: 2022-11-28" "/repos/$GITHUB_REPO/environments" | \
            jq -r '.environments[] | select(.name | startswith('\"$PROJECT_NAME\"')) | .name' | while read name ; do
                echo $name
            done
    fi

    print_style "\nRESOURCE GROUPS:\n" warning
    az group list --query "[?contains(name,'$PROJECT_NAME') && !contains(name,'MC_')].name" -o tsv

    print_style "\nSERVICE PRINCIPALS:\n" warning
    az ad sp list --query "[?contains(appDisplayName,'$PROJECT_NAME')].displayName" -o tsv --show-mine

    print_style "\nAAD APP REGISTRATIONS:\n" warning
    az ad app list --filter "startswith(displayName,'$PROJECT_NAME')" --query '[].displayName'

    print_style "\nEND OF SUMMARY\n" danger

    read -r -p "Do you wish to DELETE above? [y/N] " response
    case "$response" in
        [yY][eE][sS]|[yY])
             if [ "$CI_CD_PLATFORM" == "ado" ]; then
                print_style "Deleting pipelines that start with '$PROJECT_NAME' in name..." warning
                [[ -n $PROJECT_NAME ]] &&
                    az pipelines list -o tsv | { grep "$PROJECT_NAME" || true; } | awk '{print $4}' | xargs -r -I % az pipelines delete --id % --yes

                print_style "Deleting variable groups that start with '$PROJECT_NAME' in name..." warning
                [[ -n $PROJECT_NAME ]] &&
                    az pipelines variable-group list -o tsv | { grep "$PROJECT_NAME" || true; } | awk '{print $3}' | xargs -r -I % az pipelines variable-group delete --id % --yes

                print_style "Delete service connections that start with '$PROJECT_NAME' in name..." warning
                [[ -n $PROJECT_NAME ]] &&
                    az devops service-endpoint list -o tsv | { grep "$PROJECT_NAME" || true; } | awk '{print $3}' | xargs -r -I % az devops service-endpoint delete --id % --yes
            elif [ "$CI_CD_PLATFORM" == "github" ]; then
                [[ -n $PROJECT_NAME ]] &&
                    gh api -H "Accept: application/vnd.github+json" -H \
                        "X-GitHub-Api-Version: 2022-11-28" "/repos/$GITHUB_REPO/environments" | \
                        jq -r '.environments[] | select(.name | startswith('\"$PROJECT_NAME\"')) | .name' | while read name ; do
                            gh api --method DELETE -H "Accept: application/vnd.github+json" -H "X-GitHub-Api-Version: 2022-11-28" "/repos/$GITHUB_REPO/environments/$name" --silent
                        done
            fi

            print_style "Deleting resource group that start with '$PROJECT_NAME' in name" warning
            [[ -n $PROJECT_NAME ]] &&
                az group list --query "[?contains(name,'$PROJECT_NAME') && !contains(name,'MC_')].name" -o tsv |
                xargs -I % az group delete --verbose --name % -y --no-wait

            print_style "Delete service principal that start with '$PROJECT_NAME' in name, created by yourself..." warning
            [[ -n $PROJECT_NAME ]] &&
                    az ad sp list --query "[?contains(appDisplayName,'$PROJECT_NAME')].appId" -o tsv --show-mine |
                    xargs -r -I % az ad sp delete --id %

            print_style "Delete Microsoft Entra ID Apps that start with '$PROJECT_NAME' in name" warning
            [[ -n $PROJECT_NAME ]] &&
                az ad app list --filter "startswith(displayName,'$PROJECT_NAME')" -o tsv --query '[].appId' |
                xargs -r -I % az ad app delete --id %
            ;;
        *)
            exit
            ;;
    esac
fi
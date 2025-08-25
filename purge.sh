#!/usr/bin/env bash

set -e

# DELETE cached content by CP codes (one or many) from both Akamai STAGING and PRODUCTION networks
# using Akamai Fast Purge API (via Akamai CLI for Purge https://github.com/akamai/cli-purge)

# usage: ./purge.sh cpCode1 cpCode2 ... cpCodeN

# To get a list of all available CP codes:
# a) Use Control Panel: https://control.akamai.com/apps/cpcontract/#/cpcodes
# b) Use Akamai CLI with Property Manager CLI installed (https://github.com/akamai/cli-property-manager)
#    akamai --section default property-manager list-contracts
#    akamai --section default property-manager list-groups
#    akamai --section default property-manager list-cpcodes -c contractId -g groupId

while [[ -n $1 ]]; do
	echo "purging CP code $1 STAGING"
    akamai purge --section default delete --staging --cpcode "$1"
    echo "purging CP code $1 PRODUCTION"
    akamai purge --section default delete --production --cpcode "$1"
    shift
done

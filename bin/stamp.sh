#!/bin/bash

#
# Creates a timestamp.
#

export $(cat .env | xargs)

set -e

gas="${SUI_GAS}"
auth="${SUI_TIMEORACLE_AUTH}"
pkg="${SUI_TIMEORACLE_PACKAGE}"
# defaults to system time if flag --unix-ms is not provided
unix_ms=""

while test $# -gt 0; do
    case "$1" in
    --gas)
        shift
        gas="${1}"
        ;;
    --auth)
        shift
        auth="${1}"
        ;;
    --pkg)
        shift
        pkg="${1}"
        ;;
    --unix-ms)
        shift
        unix_ms="${1}"
        ;;
    *)
        break
        ;;
    esac
done

if [ -z "${gas}" ]; then
    echo "Provide gas object with --gas or with SUI_GAS env"
    exit 1
fi

if [ -z "${auth}" ]; then
    echo "Provide authority object with --auth or with SUI_TIMEORACLE_AUTH env"
    exit 1
fi

if [ -z "${pkg}" ]; then
    echo "Provide package with --pkg or with SUI_TIMEORACLE_PACKAGE env"
    exit 1
fi

if [ -z "${unix_ms}" ]; then
    echo "Unix ms not provided as input with --unix-ms, using system time"
    # https://serverfault.com/a/151112
    unix_ms=$(date +%s%N | cut -b1-13)
fi

echo
sui client call --package "${pkg}" \
    --module timeoracle \
    --function stamp \
    --args "${unix_ms}" "${auth}" \
    --gas "${gas}" \
    --gas-budget 1000

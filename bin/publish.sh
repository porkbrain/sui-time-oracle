#!/bin/bash

#
# Publishes a new package.
#

export $(cat .env | xargs)

gas="${SUI_GAS}"

while test $# -gt 0; do
    case "$1" in
    --gas)
        shift
        gas="${1}"
        ;;
    *)
        break
        ;;
    esac
done

if [ -z "${gas}" ]; then
    echo "Provide gas object either with --gas or with SUI_GAS env"
    exit 1
fi

sui client publish --path . --gas "${gas}" --gas-budget 30000

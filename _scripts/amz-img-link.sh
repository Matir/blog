#!/bin/bash

read linkdata

HREF=$(echo "${linkdata}" | cut -d '"' -f 2)
IMG=$(echo "${linkdata}" | tr '><' '\n' \
    | grep '^img' | head -1 | tr ' ' '\n' \
    | grep src | cut -d '"' -f 2)

echo "[![](${IMG}){:.amzimg}](${HREF})"

#!/bin/bash

ROOTDIR="$(dirname $0)/.."

if [ ! -f ${ROOTDIR}/_config.yml ] ; then
  echo "ROOTDIR not found" >&2
  exit 1
fi

grep -lr '^permalink: /blog/' ${ROOTDIR}/_posts/ | while read file ; do
  PL=$(grep '^permalink: ' ${file}|cut -d ' ' -f 2)
  SLUG=$(echo ${PL} | cut -d/ -f 3)
  DATE=$(echo ${file} | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}' | tr -- '-' '/')
  echo "${PL} /${DATE}/${SLUG}/;"
  sed -i "s|^permalink: .*|permalink: /${DATE}/${SLUG}/|" ${file}
done

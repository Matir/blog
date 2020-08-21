#!/bin/bash

ROOT="$(git rev-parse --show-toplevel)"

while read -ra entry ; do
  if [ "${entry[1]}" == "" ] ; then
    continue
  fi
  fname=${ROOT}/tags/${entry[1]}.html
  if test -f ${fname} ; then
    continue
  fi
  echo $fname
  cat <<-EOF >${fname}
---
layout: tag_page
tag: ${entry[1]}
title: ${entry[@]:2}
---
EOF
done < "${ROOT}/_site/tags/tags.txt"

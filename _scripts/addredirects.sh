#!/bin/bash

set -ue

shopt -s nullglob

DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd $DIR

get_front_matter() {
  awk 'BEGIN{flag=0};/^---$/{if(flag==0){flag=1;next}else{exit}}flag' ${1}
}

has_redirect_from() {
  get_front_matter $1 | grep -q '^redirect_from:$'
}

add_redirect_from_key() {
  sed -i $'2,/^---$/{/^---$/i redirect_from:\n}' $1
}

add_redirect_from_path() {
  # filename path
  sed -i '2,/^---$/{/^redirect_from:/a \  - '"${2}"$'\n}' $1
}

while read line ; do
  line="${line%/;}"
  DESTNAME="${line#* /}"  # Without leading or trailing slashes
  LINKNAME="${line% *}"
  FILENAME="_posts/${DESTNAME//\//-}"
  FNAMES=(${FILENAME}.*)
  printf "%s->/%s\n" $LINKNAME $DESTNAME
  if [ "${#FNAMES[@]}" -ne "1" ] ; then
    echo "Could not find a source for ${FILENAME}" >&2
    false
  fi
  printf "${FNAMES[@]}\n"
  FNAME="${FNAMES[0]}"
  if ! has_redirect_from ${FNAME} ; then
    add_redirect_from_key ${FNAME}
  fi
  add_redirect_from_path ${FNAME} ${LINKNAME}
done < ./_conf/rewrite.map

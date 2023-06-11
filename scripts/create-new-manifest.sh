#!/bin/sh

source ./scripts/colours.inc

printf ">> ${YELLOW}CREATING NEW MANIFEST${NC}\n"

pushd sys-devel/gcc
rm Manifest
ebuild $(ls *.ebuild|head -n1) manifest
popd

# There should only be one file.
FILE=$(git status | grep -w modified | grep -w Manifest | awk '{ print $2 }')

if [ -z ${FILE} ]; then
    printf ">> ${RED}None Found${NC}.\n"
else
    echo ${FILE}

    git commit -m "Updated sys-devel/gcc/Manifest." -v ${FILE}
fi

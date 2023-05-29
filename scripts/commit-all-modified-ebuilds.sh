#!/bin/sh

source ./scripts/colours.inc

printf ">> ${YELLOW}COMMITTING ALL MODIFIED EBUILDS${NC}\n"

EBUILDS=$(git status | grep ebuild | grep modified | awk '{ print $2 }')

if [ -z ${EBUILDS} ]; then
    printf ">> ${RED}None Found${NC}.\n"
else
    echo ${EBUILDS}

    git commit -m "Update existing ebuilds." -v ${EBUILDS}
fi

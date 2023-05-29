#!/bin/sh

source ./scripts/colours.inc

printf ">> ${YELLOW}REMOVING ALL DELETED EBUILDS${NC}\n"

EBUILDS=$(git status |grep ebuild |grep deleted|awk '{ print $2 }')

if [ -z ${EBUILDS} ]; then
    printf ">> ${RED}None Found${NC}.\n"
else
    echo ${EBUILDS}

    git rm ${EBUILDS}
    git commit -m "Remove all old ebuilds." -v ${EBUILDS}
fi

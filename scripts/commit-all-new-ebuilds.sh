#!/bin/sh

source ./scripts/colours.inc

printf ">> ${YELLOW}COMMITTING ALL NEW EBUILDS${NC}\n"

EBUILDS=$(git ls-files --others --exclude-standard | grep sys-devel/gcc/gcc- | grep \.ebuild | awk '{ print $1 }')

if [ -z ${EBUILDS} ]; then
    printf ">> ${RED}None Found${NC}.\n"
else
    echo ${EBUILDS}

    git add ${EBUILDS}
    git commit -m "Add new ebuilds." -v ${EBUILDS}
fi

#!/bin/sh

source ./scripts/colours.inc

printf ">> ${YELLOW}COMMITTING ALL NEW FILES${NC}\n"

FILES=$(git ls-files --others --exclude-standard | grep sys-devel/gcc/files/ | awk '{ print $1 }')

if [ -z ${EBUILDS} ]; then
    printf ">> ${RED}None Found${NC}.\n"
else
    echo ${FILES}

    git add ${FILES}
    git commit -m "Add new files." -v ${FILES}
fi

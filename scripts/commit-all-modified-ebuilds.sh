#!/bin/sh

EBUILDS=$(git status | grep ebuild | grep modified | awk '{ print $2 }')

echo ${EBUILDS}

git rm ${EBUILDS}
git commit -m "Update existing ebuilds." -v ${EBUILDS}

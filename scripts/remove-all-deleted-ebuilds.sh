#!/bin/sh

EBUILDS=$(git status |grep ebuild |grep deleted|awk '{ print $2 }')

echo ${EBUILDS}

git rm ${EBUILDS}
git commit -m "Remove all old ebuilds." -v ${EBUILDS}

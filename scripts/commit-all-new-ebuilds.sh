#!/bin/sh

EBUILDS=$(git ls-files --others --exclude-standard | grep sys-devel/gcc/gcc- | grep \.ebuild | awk '{ print $1 }')

echo ${EBUILDS}

git add ${EBUILDS}
git commit -m "Add new ebuilds." -v ${EBUILDS}

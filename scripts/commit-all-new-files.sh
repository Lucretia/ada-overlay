#!/bin/sh

FILES=$(git ls-files --others --exclude-standard | grep sys-devel/gcc/files/ | awk '{ print $1 }')

echo ${FILES}

git add ${FILES}
git commit -m "Add new files." -v ${FILES}

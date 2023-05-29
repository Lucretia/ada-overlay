#!/bin/sh

source ./scripts/colours.inc

printf ">> ${YELLOW}CREATING NEW MANIFEST${NC}\n"

pushd sys-devel/gcc
rm Manifest
ebuild $(ls *.ebuild|head -n1) manifest
popd

git status

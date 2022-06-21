#!/bin/sh

# Requires your local repository has gentoo portage as a remote.

git fetch gentoo

./scripts/diff_eclass.sh
./scripts/compare.sh

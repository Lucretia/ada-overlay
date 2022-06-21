#!/bin/sh

# Requires your local repository has gentoo portage as a remote.

# START=$(cat .last-cherry-pick-commit.txt)
# STOP=$(git rev-parse gentoo/master)

git log -p gentoo/master -- eclass/toolchain.eclass

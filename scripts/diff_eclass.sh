#!/bin/sh

# Requires your local repository has gentoo portage as a remote.

git diff gentoo/master -- eclass/toolchain.eclass

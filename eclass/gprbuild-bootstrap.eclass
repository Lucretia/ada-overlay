# Copyright 2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: gprbuild-bootstrap.eclass
# @MAINTAINER:
# Ada team <ada@gentoo.org>
# @AUTHOR:
# Luke A. Guest
# @SUPPORTED_EAPIS: 7 8
# @BLURB: An eclass for determining thish gprbuild/etc. tools to use.
# @DESCRIPTION:
#
# This eclass sets the PATH for building with gprbuild during early install of
# the Ada toolchain.
#
# Mostly copied from ada.eclass

case ${EAPI} in
	7|8) ;;
	*) die "${ECLASS}: EAPI ${EAPI:-0} not supported" ;;
esac

if [[ -z ${_GPRBUILD_BOOTSTRAP_ECLASS} ]]; then
_GPRBUILD_BOOTSTRAP_ECLASS=1

# @FUNCTION: gprbuild_env_export
# @USAGE: [<impl>]
# @DESCRIPTION:
# Detect whether the dev-ada/gprbuild has been installed making
# dev-ada/gprbuild-bootstrap redundant, otherwise set the PATH to the bootstrap
# so that the early build packages can be installed properly.
gprbuild_env_export() {
	if [ -z $(builtin type -P gprbuild) ]; then
        local GPRBUILD_BOOTSTRAP_DIR="/opt/gprbuild-bootstrap"

		if [ -d "${GPRBUILD_BOOTSTRAP_DIR}" ] ; then
			einfo "Selecting Ada bootstrap to get GPR tools."

			export PATH=$PATH:${GPRBUILD_BOOTSTRAP_DIR}/bin
		fi
	else
		einfo "Using installed gprbuild."
	fi
}

fi

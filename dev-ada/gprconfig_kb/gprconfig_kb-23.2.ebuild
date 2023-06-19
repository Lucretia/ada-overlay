# Copyright 2020-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit toolchain-funcs multiprocessing git-r3

DESCRIPTION="GPRbuild is an advanced build system designed to help automate the construction of multi-language systems."
HOMEPAGE="https://github.com/AdaCore/gprconfig_kb"
#BOOTSTRAP_
EGIT_REPO_URI="https://github.com/AdaCore/gprconfig_kb.git"
EGIT_BRANCH="${PV}"

LICENSE="GPL-3+ LGPL-3+"
SLOT="0"
KEYWORDS="-* amd64"
IUSE="ada-bootstrap"
#RESTRICT=""

src_install() {
	# dodir /opt/ada-bootstrap-${PV}
	# mv ada-bootstrap-${PV} "${ED}/opt/" || die

	insinto /usr/share/gprconfig
	doins db/*.xml
}

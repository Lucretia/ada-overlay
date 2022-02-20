# Copyright 2020-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Bootstrap package for sys-devel/gcc +ada"
HOMEPAGE="https://gcc.gnu.org"
BOOTSTRAP_DIST="https://www.dropbox.com/s/83v6ukxryglb88a/ada-bootstrap-9.4.0-x86_64.tar.xz?dl=0"
SRC_URI="
	amd64? ( ${BOOTSTRAP_DIST} -> ada-bootstrap-${PV}-x86_64.tar.xz )
"

LICENSE="GPL"
SLOT="9"
KEYWORDS="-* amd64" # arm arm64 ppc64 ~riscv ~s390 x86 ~amd64-linux ~x86-linux ~x64-macos ~x64-solaris"
# IUSE="big-endian"
RESTRICT="primaryuri mirror strip"
QA_PREBUILT="*"

S="${WORKDIR}"

src_install() {
	dodir /opt/ada-bootstrap-${PV}
	mv ada-bootstrap-${PV} "${ED}/opt/" || die
}
# Copyright 2020-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit toolchain-funcs multiprocessing git-r3

DESCRIPTION="GPRbuild is an advanced build system designed to help automate the construction of multi-language systems."
HOMEPAGE="https://github.com/AdaCore/gprbuild"
EGIT_REPO_URI="https://github.com/AdaCore/gprbuild.git"
EGIT_BRANCH="${PV}"

LICENSE="GPL-3+ LGPL-3+"
SLOT="0"
KEYWORDS="-* amd64"
IUSE=""
#RESTRICT=""

# TODO: Test on gcc-13/4
BDEPEND="(
	>=sys-devel/gcc-11[ada]
	<=sys-devel/gcc-12[ada]
)"

DEPEND=${BDEPEND}

	# "${FILESDIR}"/0001-Add-R-flag-to-gprbuild-20.2-Gentoo-needs-it-for-some.patch
PATCHES=(
	"${FILESDIR}"/relocatable-build.patch
	"${FILESDIR}"/0001-Fix-the-installer-should-be-calling-the-system-gprin.patch
)

src_unpack() {
	# Get the main source.
	git-r3_fetch
	git-r3_checkout

	local XMLADA_URI="https://github.com/AdaCore/xmlada.git"
	local GPRCONFIG_KB="https://github.com/AdaCore/gprconfig_kb.git"

	git-r3_fetch ${XMLADA_URI}
	git-r3_checkout ${XMLADA_URI} "${WORKDIR}"/xmlada

	git-r3_fetch ${GPRCONFIG_KB}
	git-r3_checkout ${GPRCONFIG_KB} "${WORKDIR}"/gprconfig_kb
}

src_compile() {
	./bootstrap.sh --build --with-xmlada=../xmlada --with-kb=../gprconfig_kb || die
}

src_install() {
	DESTDIR=${ED} ./bootstrap.sh --install --with-xmlada=../xmlada --with-kb=../gprconfig_kb --prefix=/opt/${PN} || die
}

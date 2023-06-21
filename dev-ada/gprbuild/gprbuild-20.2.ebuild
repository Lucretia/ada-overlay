# Copyright 2020-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit toolchain-funcs multiprocessing git-r3 gprbuild-bootstrap

DESCRIPTION="GPRbuild is an advanced build system designed to help automate the construction of multi-language systems."
HOMEPAGE="https://github.com/AdaCore/gprbuild"
#BOOTSTRAP_
EGIT_REPO_URI="https://github.com/AdaCore/gprbuild.git"
EGIT_BRANCH="${PV}"

LICENSE="GPL-3+ LGPL-3+"
SLOT="0"
KEYWORDS="-* amd64"
IUSE=""
#RESTRICT=""

BDEPEND="(
	>=sys-devel/gcc-9.5.0[ada]
	<sys-devel/gcc-12[ada]
)"

DEPEND="${BDEPEND}
		=dev-ada/xmlada-${PV}
		!dev-ada/gprconfig_kb"

#	"${FILESDIR}"/0001-Add-R-flag-to-gprbuild-20.2-Gentoo-needs-it-for-some.patch
PATCHES=(
	"${FILESDIR}"/relocatable-build.patch
	"${FILESDIR}"/0001-Fix-the-installer-should-be-calling-the-system-gprin.patch
)

src_configure() {
	gprbuild_env_export

	emake prefix=/usr setup
}

src_compile() {
	einfo "PATH = ${PATH}"

	emake prefix=${ED}/usr
	# emake prefix=${ED}/usr libgpr.build.shared
}

src_install() {
	# dodir /opt/ada-bootstrap-${PV}
	# mv ada-bootstrap-${PV} "${ED}/opt/" || die

	emake prefix=${ED}/usr libgpr.install.shared
	emake prefix=${ED}/usr install

	rm ${ED}/usr/doinstall
	rm -r ${ED}/usr/share/gpr/manifests
}

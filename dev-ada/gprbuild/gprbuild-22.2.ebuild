# Copyright 2020-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit toolchain-funcs multiprocessing git-r3

DESCRIPTION="GPRbuild is an advanced build system designed to help automate the construction of multi-language systems."
HOMEPAGE="https://github.com/AdaCore/gprbuild"
#BOOTSTRAP_
EGIT_REPO_URI="https://github.com/AdaCore/gprbuild.git"
EGIT_BRANCH="${PV}"

LICENSE="GPL-3+ LGPL-3+"
SLOT="0"
KEYWORDS="-* amd64"
IUSE="ada-bootstrap"
#RESTRICT=""

DEPEND=">=sys-devel/gcc-9.5.0
		=dev-ada/gprconfig_kb-22.2
		>=dev-ada/xmlada-23.2"

PATCHES=(
	"${FILESDIR}"/relocatable-build.patch
	"${FILESDIR}"/0001-Add-R-flag-to-gprbuild-Gentoo-needs-it-for-some-reas.patch
)

src_configure() {
	if use ada-bootstrap; then
		einfo "Selecting Ada bootstrap to get GPR tools."

		# This should be slot, but the 9.x bootstrap is 9.5.0.
		# export PATH=$PATH:/opt/ada-bootstrap-${SLOT}/bin
		local GCC_MAJOR=$(gcc-major-version)

		if [ "${GCC_MAJOR}" -lt "10" ]; then
			export PATH=$PATH:/opt/ada-bootstrap-9.5.0/bin
		else
			export PATH=$PATH:/opt/ada-bootstrap-${GCC_MAJOR}/bin
		fi

		einfo "gprbuild : $(which gprbuild) - $(gprbuild --version)"
	else
		gprbuild 2>/dev/null || die "No gprbuild found, enable USE=ada-bootstrap to build."
	fi

	emake prefix=/usr setup
}

src_compile() {
	emake prefix=${ED}/usr
	emake prefix=${ED}/usr libgpr.build.shared
}

src_install() {
	# dodir /opt/ada-bootstrap-${PV}
	# mv ada-bootstrap-${PV} "${ED}/opt/" || die

	emake prefix=${ED}/usr install
	emake prefix=${ED}/usr libgpr.install.shared

	rm ${ED}/usr/doinstall
	rm -r ${ED}/usr/share/gpr/manifests
}

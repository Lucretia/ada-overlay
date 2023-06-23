# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit multiprocessing git-r3

DESCRIPTION="Ada library to handle GPRbuild project files"
HOMEPAGE="https://github.com/AdaCore/gprbuild"
EGIT_REPO_URI="https://github.com/AdaCore/gprbuild.git"
EGIT_BRANCH="${PV}"

SLOT="0/${PV}"
KEYWORDS="amd64 x86"
IUSE="+shared static-libs static-pic"

RDEPEND="dev-ada/xmlada:=[shared?,static-libs?,static-pic?]"
DEPEND="${RDEPEND}
	dev-ada/gprbuild"
REQUIRED_USE="
	|| ( shared static-libs static-pic )"

# TODO: Is this really required??
# PATCHES=( "${FILESDIR}"/${PN}-2020-gentoo.patch )

src_prepare() {
	default
	sed -i -e '/Library_Name/s|gpr|gnatgpr|' gpr/gpr.gpr || die
}

src_configure() {
	emake setup
}

src_compile() {
	build () {
		gprbuild -p -m -j$(makeopts_jobs) -XBUILD=production -v \
			-XLIBRARY_TYPE=$1 -XXMLADA_BUILD=$1 \
			gpr/gpr.gpr -cargs:C ${CFLAGS} -cargs:Ada ${ADAFLAGS} || die
	}
	if use shared; then
		build relocatable
	fi
	if use static-libs; then
		build static
	fi
	if use static-pic; then
		build static-pic
	fi
}

src_install() {
	if use static-libs; then
		emake prefix="${D}"/usr libgpr.install.static
	fi
	for kind in shared static-pic; do
		if use ${kind}; then
			emake prefix="${D}"/usr libgpr.install.${kind}
		fi
	done
	rm -r "${D}"/usr/share/gpr/manifests || die
	einstalldocs
}

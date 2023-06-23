# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# ADA_COMPAT=( gnat_2021 gcc_12 )
# inherit ada multiprocessing
inherit multiprocessing git-r3

DESCRIPTION="Set of modules that provide a simple manipulation of XML streams"
HOMEPAGE="https://github.com/AdaCore/xmlada"
# SRC_URI="https://github.com/AdaCore/${PN}/archive/refs/tags/v${PV}.tar.gz
# 	-> ${P}.tar.gz"
EGIT_REPO_URI="https://github.com/AdaCore/${PN}.git"
EGIT_BRANCH="${PV}"

LICENSE="GPL-3+ LGPL-3+"
SLOT="0/${PV}"
KEYWORDS="amd64 x86"
IUSE="+shared static-libs static-pic"
REQUIRED_USE="|| ( shared static-libs static-pic )"
	# ${ADA_REQUIRED_USE}"

# RDEPEND="${ADA_DEPS}"
# DEPEND="${RDEPEND}
# 	dev-ada/gprbuild[${ADA_USEDEP}]"

PATCHES=( "${FILESDIR}"/${PN}-20.2-gentoo.patch )

BDEPEND="
	=dev-ada/gprbuild-${PV}
"

DEPEND="${BDEPEND}"

src_compile() {
	build () {
		gprbuild -j$(makeopts_jobs) -m -p -v -XLIBRARY_TYPE=$1 \
			-XBUILD=Production -XPROCESSORS=$(makeopts_jobs) xmlada.gpr \
			-largs ${LDFLAGS} \
			-cargs ${ADAFLAGS} || die "gprbuild failed"
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

src_test() {
	GPR_PROJECT_PATH=schema:input_sources:dom:sax:unicode \
	gprbuild -j$(makeopts_jobs) -m -p -v -XLIBRARY_TYPE=static \
		-XBUILD=Production -XPROCESSORS=$(makeopts_jobs) xmlada.gpr \
		-XTESTS_ACTIVATED=Only \
		-largs ${LDFLAGS} \
		-cargs ${ADAFLAGS} || die "gprbuild failed"
	emake --no-print-directory -C tests tests | tee xmlada.testLog
	grep -q DIFF xmlada.testLog && die
}

src_install() {
	build () {
		gprinstall -XLIBRARY_TYPE=$1 -f -p -XBUILD=Production \
			-XPROCESSORS=$(makeopts_jobs) --prefix="${D}"/usr \
			--install-name=xmlada --build-var=LIBRARY_TYPE \
			--build-var=XMLADA_BUILD \
			--build-name=$1 xmlada.gpr || die "gprinstall failed"
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

	einstalldocs
	dodoc xmlada-roadmap.txt
	rm -rf "${D}"/usr/share/gpr/manifests
	rm -f "${D}"/usr/share/examples/xmlada/*/b__*
	rm -f "${D}"/usr/share/examples/xmlada/*/*.adb.std*
	rm -f "${D}"/usr/share/examples/xmlada/*/*.ali
	rm -f "${D}"/usr/share/examples/xmlada/*/*.bexch
	rm -f "${D}"/usr/share/examples/xmlada/*/*.o
	rm -f "${D}"/usr/share/examples/xmlada/*/*example
	rm -f "${D}"/usr/share/examples/xmlada/dom/domexample2
	rm -f "${D}"/usr/share/examples/xmlada/sax/saxexample_main
	mv "${D}"/usr/share/examples/xmlada "${D}"/usr/share/doc/"${PF}"/examples || die
}

# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# ADA_COMPAT=( gnat_2021 gcc_12 )

# inherit ada multiprocessing
inherit multiprocessing git-r3

DESCRIPTION="Multi-Language Management"
HOMEPAGE="http://libre.adacore.com/"
# SRC_URI="
# 	https://github.com/AdaCore/${PN}/archive/refs/tags/v${PV}.tar.gz
# 		-> ${P}.tar.gz
# 	https://github.com/AdaCore/xmlada/archive/refs/tags/v${PV}.tar.gz
# 		-> ${XMLADA}.tar.gz"
EGIT_REPO_URI="https://github.com/AdaCore/gprbuild.git"
EGIT_BRANCH="${PV}"

LICENSE="GPL-3+ LGPL-3+"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

# DEPEND="${ADA_DEPS}
# 	dev-ada/gprconfig_kb[${ADA_USEDEP}]"
# RDEPEND="${DEPEND}"

# REQUIRED_USE="${ADA_REQUIRED_USE}"
# PATCHES=( "${FILESDIR}"/${PN}-22.0.0-gentoo.patch )

# TODO: Test on gcc-13/4
BDEPEND="(
	>=sys-devel/gcc-9.5.0[ada]
	<sys-devel/gcc-12[ada]
)"

DEPEND="
	${BDEPEND}

	=dev-ada/gprconfig_kb-${PV}
"

	# "${FILESDIR}"/0001-Add-R-flag-to-gprbuild-20.2-Gentoo-needs-it-for-some.patch
PATCHES=(
	"${FILESDIR}"/relocatable-build.patch
)

src_unpack() {

	default
	# Get the main source.
	git-r3_fetch
	git-r3_checkout

	local XMLADA_URI="https://github.com/AdaCore/xmlada.git"
	# local GPRCONFIG_KB_URI="https://github.com/AdaCore/gprconfig_kb.git"

	git-r3_fetch ${XMLADA_URI}
	git-r3_checkout ${XMLADA_URI} "${WORKDIR}"/xmlada

	# git-r3_fetch ${GPRCONFIG_KB_URI}
	# git-r3_checkout ${GPRCONFIG_KB_URI} "${WORKDIR}"/gprconfig_kb
}

src_prepare() {
	default
	# sed -i \
	# 	-e "s:@GNATBIND@:${GNATBIND}:g" \
	# 	src/gprlib.adb \
	# 	|| die
	cd gpr/src || die
	ln -s gpr-util-put_resource_usage__unix.adb \
		gpr-util-put_resource_usage.adb
}

bin_progs="gprbuild gprconfig gprclean gprinstall gprname gprls"
lib_progs="gprlib gprbind"

src_compile() {
	local xmlada_src="../xmlada"
	local inc_flags="-Isrc -Igpr/src -I${xmlada_src}/sax -I${xmlada_src}/dom \
		-I${xmlada_src}/schema -I${xmlada_src}/unicode \
		-I${xmlada_src}/input_sources"

	gcc -c ${CFLAGS} gpr/src/gpr_imports.c -o gpr_imports.o || die

	for bin in ${bin_progs}; do
		gnatmake -j$(makeopts_jobs) ${inc_flags} $ADAFLAGS ${bin}-main \
			-o ${bin} -largs ${LDFLAGS} gpr_imports.o || die
	done

	for lib in $lib_progs; do
		gnatmake -j$(makeopts_jobs) ${inc_flags} ${lib} $ADAFLAGS \
			-largs ${LDFLAGS} gpr_imports.o || die
	done
}

src_install() {
	dobin ${bin_progs}
	exeinto /usr/libexec/gprbuild
	doexe ${lib_progs}
	insinto /usr/share/gpr
	doins share/_default.gpr
	einstalldocs
}

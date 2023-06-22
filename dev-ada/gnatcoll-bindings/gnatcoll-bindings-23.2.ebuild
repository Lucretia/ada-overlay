# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{9..12} )

inherit multiprocessing python-single-r1 git-r3

DESCRIPTION="GNAT Component Collection"
HOMEPAGE="http://libre.adacore.com"
EGIT_REPO_URI="https://github.com/AdaCore/gnatcoll-bindings.git"
EGIT_BRANCH="${PV}"

LICENSE="GPL-3+ LGPL-3+"
SLOT="0/${PV}"
KEYWORDS="amd64 x86"
IUSE="doc gmp iconv lzma openmp python readline syslog"
REQUIRED_USE="
	|| ( gmp iconv lzma openmp python readline syslog )
	${PYTHON_REQUIRED_USE}"

RDEPEND="${PYTHON_DEPS}
	dev-ada/gnatcoll-core
	gmp? ( dev-libs/gmp:* )
	lzma? ( app-arch/xz-utils )
	openmp? ( sys-devel/gcc:=[ada,openmp] )
	"
DEPEND="${RDEPEND}
	dev-ada/gprbuild"

QA_EXECSTACK=usr/lib/gnatcoll_readline.*/libgnatcoll_readline.*

# TODO: Don't know if we need this yet.
PATCHES=( "${FILESDIR}"/${PN}-23.0.0-py_3_11.patch )

pkg_setup() {
	python-single-r1_pkg_setup
}

src_prepare() {
	rm -r python || die
	mv python3 python || die
	default
}

src_compile() {
	build () {
		gprbuild -j$(makeopts_jobs) -m -p -v \
			-XGPR_BUILD=$2 -XGNATCOLL_CORE_BUILD=$2 \
			-XLIBRARY_TYPE=$2 -P $1/gnatcoll_$1.gpr -XBUILD="PROD" \
			-XGNATCOLL_VERSION=${PV} \
			-XGNATCOLL_ICONV_OPT= -XGNATCOLL_PYTHON_CFLAGS="-I$(python_get_includedir)" \
			-XGNATCOLL_PYTHON_LIBS=$(python_get_library_path) \
			-cargs:C ${CFLAGS} || die "gprbuild failed"
	}
	for kind in shared ; do #static-libs static-pic ; do
		# if use $kind; then
			lib=${kind%-libs}
			lib=${lib/shared/relocatable}
			for dir in gmp iconv lzma python readline syslog ; do
				if use $dir; then
					build $dir $lib
				fi
			done
			if use openmp; then
				build omp $lib
			fi
		# fi
	done
}

src_install() {
	build () {
		gprinstall -p -f -XBUILD=PROD --prefix="${D}"/usr -XLIBRARY_TYPE=$2 \
			-XGPR_BUILD=$2 -XGNATCOLL_CORE_BUILD=$2 \
			-XGNATCOLL_VERSION=${PV} --build-var=LIBRARY_TYPE \
			-XGNATCOLL_ICONV_OPT= -P $1/gnatcoll_$1.gpr --build-name=$2
	}
	for kind in shared ; do #static-libs static-pic ; do
		# if use $kind; then
			lib=${kind%-libs}
			lib=${lib/shared/relocatable}
			for dir in gmp iconv lzma python readline syslog ; do
				if use $dir; then
					build $dir $lib
				fi
			done
			if use openmp; then
				build omp $lib
			fi
		# fi
	done

	rm -rf "${D}"/usr/share/gpr/manifests

	if use doc ; then
		einstalldocs
	fi
}

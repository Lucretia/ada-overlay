# Copyright 2020-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# Disclaimer: This is a mess. AdaCore's build scripts are different for every project.

EAPI=8

inherit toolchain-funcs multiprocessing git-r3

DESCRIPTION="The XML/Ada toolkit. "
HOMEPAGE="https://github.com/AdaCore/${PN}"
#BOOTSTRAP_
EGIT_REPO_URI="https://github.com/AdaCore/${PN}.git"
EGIT_BRANCH="${PV}"

LICENSE="GPL-3+ LGPL-3+"
SLOT="0"
KEYWORDS="-* amd64"
IUSE="ada-bootstrap"
#RESTRICT=""

DEPEND=">=sys-devel/gcc-9.5.0[ada]"

src_configure() {
	default

	# Force which compiler we are using here.
	# export GCC_DIR="/usr/${CHOST}/gcc-bin/${SLOT}"
	# export LIBEXEC_DIR="/usr/libexec/gcc/${CHOST}/${SLOT}"

	export GPROPTS="-XBUILD=Production -XPROCESSORS=$(makeopts_jobs)"

	# export ADA_BUILDS=("static" "relocatable" "static-pic")
	export ADA_BUILDS=("relocatable")

	# export PATH=${GCC_DIR}:$PATH

	if use ada-bootstrap; then
		einfo "Selecting Ada bootstrap to get GPR tools."

		# This should be slot, but the 9.x bootstrap is 9.4.0.
		# export PATH=$PATH:/opt/ada-bootstrap-${SLOT}/bin
		local GCC_MAJOR=$(gcc-major-version)

		if [ "${GCC_MAJOR}" < "10" ]; then
			export PATH=$PATH:/opt/ada-bootstrap-9.4.0/bin
		else
			export PATH=$PATH:/opt/ada-bootstrap-${GCC_MAJOR}/bin
		fi
	else
		gprbuild 2>/dev/null || die "No gprbuild found, enable USE=ada-bootstrap to build."
	fi

	einfo "PWD           : $(pwd)"
	einfo "S             : ${S}"
	einfo "P             : ${P}"
	einfo "D             : ${D}"
	einfo "ED            : ${ED}"
	einfo "EPREFIX       : ${EPREFIX}"
	einfo "CTARGET       : ${CTARGET}"
	einfo "GCC_CONFIG_VER: ${GCC_CONFIG_VER} -" $(gcc-fullversion)
	einfo "PREFIX        : ${PREFIX}"
	einfo "CHOST         : ${CHOST}"
	einfo "LDFLAGS       : ${LDFLAGS}"
	einfo "GPROPTS       : ${GPROPTS}"
	einfo "gprbuild      : $(which gprbuild)"

	# The following two do nothing.
				# --includedir=${GCC_DIR}/include/gnat-${SLOT} \
				# --datarootdir=${GCC_DIR}/share/${PF}/gnat-${SLOT} \
	# ./configure --prefix=${GCC_DIR} \
	# 			--libexecdir=${LIBEXEC_DIR} \
	# 			--enable-shared \
	# 			--enable-build=Production || die "Couldn't configure XMLAda."
	./configure --prefix=/usr \
				--libexecdir=/usr/libexec \
				--enable-shared \
				--enable-build=Production || die "Couldn't configure XMLAda."
}

src_compile() {
	einfo "PWD           : $(pwd)"
	einfo "S             : ${S}"
	einfo "P             : ${P}"
	einfo "D             : ${D}"
	einfo "ED            : ${ED}"
	einfo "EPREFIX       : ${EPREFIX}"
	einfo "CTARGET       : ${CTARGET}"
	einfo "GCC_CONFIG_VER: ${GCC_CONFIG_VER} -" $(gcc-fullversion)
	einfo "PREFIX        : ${PREFIX}"
	einfo "CHOST         : ${CHOST}"
	einfo "LDFLAGS       : ${LDFLAGS}"
	einfo "GPROPTS       : ${GPROPTS}"
	einfo "gprbuild      : $(which gprbuild)"

	# The -R flag disables the path to the libgnat and libgcc_s libraries in the libs.
	# emake -j1 # GPRBUILD_OPTIONS=-R
	for b in ${ADA_BUILDS[@]}; do
		gprbuild -j$(makeopts_jobs) -m -p -XLIBRARY_TYPE=${b} -R \
			${GPROPTS} ${PN}.gpr -largs ${LDFLAGS} || die "gprbuild failed."
	done
}

src_install() {
	# local GPRINST_OPTS="-f -p ${GPROPTS} --prefix=${D}/usr --install-name=${PF} \
	# 	--lib-subdir=lib/gcc/${CHOST}/${SLOT} --link-lib-subdir=lib/gcc/${CHOST}/${SLOT} \
    #     --build-var=LIBRARY_TYPE --build-var=XMLADA_BUILD"
	local GPRINST_OPTS="-f -p ${GPROPTS} --prefix=${D}/usr --install-name=${PF} \
        --build-var=LIBRARY_TYPE --build-var=XMLADA_BUILD"

	einfo "PWD           : $(pwd)"
	einfo "S             : ${S}"
	einfo "P             : ${P}"
	einfo "D             : ${D}"
	einfo "ED            : ${ED}"
	einfo "EPREFIX       : ${EPREFIX}"
	einfo "CTARGET       : ${CTARGET}"
	einfo "GCC_CONFIG_VER: ${GCC_CONFIG_VER} -" $(gcc-fullversion)
	einfo "PREFIX        : ${PREFIX}"
	einfo "CHOST         : ${CHOST}"
	einfo "LDFLAGS       : ${LDFLAGS}"
	einfo "GPROPTS       : ${GPROPTS}"
	einfo "GPRINST_OPTS  : ${GPRINST_OPTS}"
	einfo "gprbuild      : $(which gprbuild)"

	# emake -j1 prefix=${D} install
	# local GPRDIR="${D}/usr/share/gcc-data/${CHOST}/${SLOT}/gpr"

	for b in ${ADA_BUILDS[@]}; do
		# gprinstall --project-subdir=${GPRDIR} \
		gprinstall -XLIBRARY_TYPE=${b} --build-name=${b} ${GPRINST_OPTS} ${PN}.gpr || die "gprinstall failed."
	done

	# We don't need this, gprinstall is not used to remove the package.
	# rm -r ${GPRDIR}/manifests
	rm -r ${ED}/usr/share/gpr/manifests

	# Fix the header files location.
	# local GNATSLOT="gnat-${SLOT}"
	# local PFGNATSLOT="${PN}/${PV}/${GNATSLOT}"
	# local FROMPATH="include/${PF}"
	# local TOPATH="include/${PFGNATSLOT}"
	# local FROMDIR="/usr/${FROMPATH}"
	# local TODIR="/usr/${TOPATH}"

	# mkdir -p ${D}/${TODIR}
	# mv ${D}/${FROMDIR}/${PN}_* ${D}/${TODIR}
	# rmdir ${D}/${FROMDIR}

	# Fix include dirs in gpr files.
	# local GPRS=(xmlada_dom.gpr xmlada_input.gpr xmlada_sax.gpr xmlada_schema.gpr xmlada_unicode.gpr)
	# for g in ${GPRS[@]}; do
	# 	einfo 's,'${FROMPATH}','${TOPATH}'/'${PF}',' ${GPRDIR}/${g}
	# 	sed -i 's,'${FROMPATH}','${TOPATH}'/'${PF}',' ${GPRDIR}/${g}

	# 	# Remove the extraneous
	# 	sed -i 's,'${PF}'/'${PN}'_,'${PN}'_,' ${GPRDIR}/${g}
	# done

	# Fix the gpr files location.
	# local SHAREDIR="${D}/usr/share"

	# mv ${SHAREDIR}/gpr/${PN}.gpr ${GPRDIR}/
	# rmdir ${SHAREDIR}/gpr

	# Fix examples location.
	# TODIR="${SHAREDIR}/${PF}/${GNATSLOT}/examples"

	# mkdir -p ${TODIR}
	# mv ${D}/usr/share/examples/${PN}/* ${TODIR}/
	# rm -r ${D}/usr/share/examples
}

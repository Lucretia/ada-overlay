#!/bin/bash

# Run by calling the script with the following:
#
# GCC_MAJOR=10 ./scripts/build-bootstrap.sh
#
# GCC_MAJOR can be set to 9, 10, 11, 12 does not work as it's from git not archive.

# TODO: Add clean up.

# $1 = Filename to create using touch, used in successive steps to test
#      if the previous step was completed.
function check_error()
{
    if [ $? != 0 ]; then
        echo "  ERROR: Something went wrong!"
        exit 2;
    else
        touch $1
    fi
}

# TODO: Add check of gcc version to build the version you want.
# TODO: Add check to test if gnat is available.

CPU_CORES="5"
DISTFILES="/usr/portage/distfiles"

GPRBUILD_GIT="https://github.com/AdaCore/gprbuild.git"
XMLADA_GIT="https://github.com/AdaCore/xmlada.git"
GPRCONFIG_KB_GIT="https://github.com/AdaCore/gprconfig_kb.git"

# WARNING: Clean out your portage/distfiles directory as this can become cluttered.
# TODO: Need a better way of matching up the patches archive.
case ${GCC_MAJOR} in
	9)
		GCC_VER="9.4.0"
		GCC_ARC="gcc-9.4.0.tar.xz"
		GCC_PATCHES_PATTERN="gcc-9.4.0-patches*"
		# GCC_PATCHES=$(ls ${DISTFILES}/${GCC_PATCHES_PATTERN})
		GCC_DIR=$(echo "${GCC_ARC}" | awk -F\. '{ print $1"."$2"."$3 }')
		ADACORE_BRANCH="21.0"
	;;

	10)
		GCC_VER="10"
		GCC_ARC="gcc-10-20211126.tar.xz"
		# GCC_ARC="gcc-10.3.0.tar.xz"
		GCC_PATCHES_PATTERN="gcc-10.4.0-patches*"
		# GCC_PATCHES=$(ls ${DISTFILES}/gcc-10.3.0-patches*)
		# GCC_DIR=$(echo "${GCC_ARC}" | awk -F\. '{ print $1"."$2"."$3 }')
		GCC_DIR=$(echo "${GCC_ARC}" | awk -F\. '{ print $1 }')
		ADACORE_BRANCH="21.2"
	;;

	11)
		# echo "hello"
		GCC_VER="11"
		GCC_ARC="gcc-11-20220115.tar.xz"
		GCC_PATCHES_PATTERN="gcc-11.3.0-patches*"
		# GCC_PATCHES=$(ls ${DISTFILES}/gcc-11.3.0-patches*)
		GCC_DIR=$(echo "${GCC_ARC}" | awk -F\. '{ print $1 }')
		ADACORE_BRANCH="22.2"
		# echo ">> GCC_PATCHES: $GCC_PATCHES"
	;;

	12)
		GCC_VER="12"
		GCC_ARC="gcc-11.3.0.tar.xz"
		GCC_PATCHES_PATTERN="gcc-11.3.0-patches*"
		# GCC_PATCHES=$(ls ${DISTFILES}/gcc-11.3.0-patches*)
		ADACORE_BRANCH=""
	;;
esac

if [[ ! -f ${DISTFILES}/${GCC_ARC} ]]; then
	emerge -f sys-devel/gcc:${GCC_VER}
fi

GCC_PATCHES=$(ls ${DISTFILES}/${GCC_PATCHES_PATTERN})

pushd /tmp

# echo ${DISTFILES}/${GCC_ARC}
# echo ${GCC_PATCHES}

if [ ! -f .gcc-unpacked-${GCC_MAJOR} ]; then
	echo ">> Unpacking ${GCC_ARC}..."

	tar -xJpf ${DISTFILES}/${GCC_ARC}

	check_error .gcc-unpacked-${GCC_MAJOR}
fi

if [ ! -f .gcc-unpacked-patches-${GCC_MAJOR} ]; then
	echo ">> Unpacking ${GCC_PATCHES}..."

	tar -xjpf ${GCC_PATCHES}

	check_error .gcc-unpacked-patches-${GCC_MAJOR}
fi

cd ${GCC_DIR}

if [ ! -f .gcc-patched-${GCC_MAJOR} ]; then
	echo ">> Patching ${GCC_ARC}..."

	for f in $(ls ../patch/[0-9]*_all_*.patch); do
		patch -p1 < $f
	done

	check_error .gcc-patched-${GCC_MAJOR}
fi

# TODO: Get base dir from archive.
BUILD_DIR="build-${GCC_VER}"
INSTALL_DIR="ada-bootstrap-${GCC_VER}"

if [ ! -d ../${BUILD_DIR} ]; then
	mkdir ../${BUILD_DIR}
fi

cd ../${BUILD_DIR}

ARCH="x86_64"

echo ">> Configuring GCC..."

if [ ! -f .gcc-configured-${GCC_MAJOR} ]; then
	../${GCC_DIR}/configure \
		--host=${ARCH}-pc-linux-gnu \
		--build=${ARCH}-pc-linux-gnu \
		--target=${ARCH}-pc-linux-gnu \
		--prefix=/opt/${INSTALL_DIR} \
		--enable-languages=c,ada,c++ \
		--disable-nls \
		--without-included-gettext \
		--with-system-zlib \
		--disable-checking \
		--disable-werror \
		--disable-libmudflap \
		--disable-libssp \
		--disable-libunwind-exceptions \
		--enable-libada \
		--enable-threads=posix \
		--enable-shared \
		--disable-static \
		--enable-multilib \
		--enable-__cxa_atexit \
		--enable-clocale=gnu \
		--disable-altivec \
		--disable-fixed-point \
		--disable-libgcj \
		--disable-libcilkrts \
		--disable-libsanitizer \
		--disable-libquadmath \
		--disable-libvtv \
		--disable-libgomp \
		--without-ppl \
		--without-cloog \
		--without-isl \
			&> log.configure.txt

	check_error .gcc-configured-${GCC_MAJOR}
fi

if [ ! -f .gcc-built-${GCC_MAJOR} ]; then
	echo ">> Building GCC..."

	make -j${CPU_CORES} all &> log.build.txt

	check_error .gcc-built-${GCC_MAJOR}
fi

if [ ! -f .gcc-installed-${GCC_MAJOR} ]; then
	echo ">> Staging GCC..."

	DESTDIR="/tmp" make install-strip &> log.build.install.txt

	check_error .gcc-installed-${GCC_MAJOR}
fi

cd /tmp

## GPRBuild

GPRBUILD_SRC_DIR="gprbuild-${GCC_MAJOR}"
XMLADA_SRC_DIR="xmlada-${GCC_MAJOR}"
GPRCONFIG_KB_SRC_DIR="gprconfig_kb-${GCC_MAJOR}"

if [ ! -f .gprbuild-downloaded-${GCC_MAJOR} ]; then
	git clone -b ${ADACORE_BRANCH} ${GPRBUILD_GIT} ${GPRBUILD_SRC_DIR}

	check_error .gprbuild-downloaded-${GCC_MAJOR}
fi

if [ ! -f .xmlada-downloaded-${GCC_MAJOR} ]; then
	git clone -b ${ADACORE_BRANCH} ${XMLADA_GIT} ${XMLADA_SRC_DIR}

	check_error .xmlada-downloaded-${GCC_MAJOR}
fi

if [ ! -f .gprconfig_kb-downloaded-${GCC_MAJOR} ]; then
	git clone -b ${ADACORE_BRANCH} ${GPRCONFIG_KB_GIT} ${GPRCONFIG_KB_SRC_DIR}

	check_error .gprconfig_kb-downloaded-${GCC_MAJOR}
fi

if [ ! -f .gprbuild-built-${GCC_MAJOR} ]; then
	cd ${GPRBUILD_SRC_DIR}

	echo ">> Building / Staging GPRBuild..."

	DESTDIR=/tmp ./bootstrap.sh --with-xmlada=../${XMLADA_SRC_DIR} --with-kb=../${GPRCONFIG_KB_SRC_DIR} --prefix=/opt/${INSTALL_DIR} &> log.build.txt

	check_error .gprbuild-built-${GCC_MAJOR}
fi

## Installation

cd /tmp

echo ">> Archiving..."

if [ ! -f .gcc-archived-${GCC_MAJOR} ]; then
	tar -cJpf ${INSTALL_DIR}-${ARCH}.tar.xz -C ./opt ${INSTALL_DIR}

	check_error .gcc-archived-${GCC_MAJOR}
fi

## Clean up

echo ">> Cleaning up..."

rm -rf ./opt ./${BUILD_DIR} ./${GCC_DIR} ./patch ${GPRBUILD_SRC_DIR} ${GPRCONFIG_KB_SRC_DIR} ${XMLADA_SRC_DIR} .gpr* .gcc* .xmlada*

popd

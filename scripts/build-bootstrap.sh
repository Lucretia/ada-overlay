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

case ${GCC_MAJOR} in
	9)
		GCC_VER="9.4.0"
		GCC_ARC="gcc-9.4.0.tar.xz"
		GCC_PATCHES=$(ls ${DISTFILES}/gcc-9.4.0-patches*)
		GCC_DIR=$(echo "${GCC_ARC}" | awk -F\. '{ print $1"."$2"."$3 }')
	;;

	10)
		GCC_VER="10.3.0"
		GCC_ARC="gcc-10.3.0.tar.xz"
		GCC_PATCHES=$(ls ${DISTFILES}/gcc-10.3.0-patches*)
		GCC_DIR=$(echo "${GCC_ARC}" | awk -F\. '{ print $1"."$2"."$3 }')
	;;

	11)
		echo "hello"
		GCC_VER="11"
		GCC_ARC="gcc-11-20220115.tar.xz"
		GCC_PATCHES=$(ls ${DISTFILES}/gcc-11.3.0-patches*)
		GCC_DIR=$(echo "${GCC_ARC}" | awk -F\. '{ print $1 }')
		echo ">> GCC_PATCHES: $GCC_PATCHES"
	;;

	12)
		GCC_VER="12"
		GCC_ARC="gcc-11.3.0.tar.xz"
		GCC_PATCHES=$(ls ${DISTFILES}/gcc-11.3.0-patches*)
	;;
esac

if [[ ! -f ${DISTFILES}/${GCC_ARC} ]]; then
	emerge -f sys-devel/gcc:${GCC_VER}
fi

pushd /tmp

# echo ${DISTFILES}/${GCC_ARC}
# echo ${GCC_PATCHES}

if [ ! -f .gcc-unpacked ]; then
	tar -xJpf ${DISTFILES}/${GCC_ARC}

	check_error .gcc-unpacked
fi

if [ ! -f .gcc-unpacked-patches ]; then
	tar -xjpf ${GCC_PATCHES}

	check_error .gcc-unpacked-patches
fi

cd ${GCC_DIR}

if [ ! -f .gcc-patched ]; then
	for f in $(ls ../patch/[0-9]*_all_*.patch); do
		patch -p1 < $f
	done

	check_error .gcc-patched
fi

# TODO: Get base dir from archive.
BUILD_DIR="build-${GCC_VER}"
INSTALL_DIR="ada-bootstrap-${GCC_VER}"

if [ ! -d ../${BUILD_DIR} ]; then
	mkdir ../${BUILD_DIR}
fi

cd ../${BUILD_DIR}

ARCH="x86_64"

if [ ! -f .gcc-configured ]; then
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

	check_error .gcc-configured
fi

if [ ! -f .gcc-built ]; then
	make -j${CPU_CORES} all &> log.build.txt

	check_error .gcc-built
fi

if [ ! -f .gcc-installed ]; then
	DESTDIR="/tmp" make install-strip &> log.build.install.txt

	check_error .gcc-installed
fi

cd /tmp

if [ ! -f .gcc-archived ]; then
	tar -cJpf ${INSTALL_DIR}-${ARCH}.tar.xz -C ./opt ${INSTALL_DIR}

	check_error .gcc-archived
fi
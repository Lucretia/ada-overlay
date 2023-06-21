# Copyright 2020-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Meta Ada package"
HOMEPAGE="https://github.com/Lucretia/ada-overlay"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="-* amd64" # arm arm64 ppc64 ~riscv ~s390 x86 ~amd64-linux ~x86-linux ~x64-macos ~x64-solaris"
IUSE=""

DEPEND="
    =dev-ada/gprbuild-20.2
"

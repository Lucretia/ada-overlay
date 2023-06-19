# Copyright 2020-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Virtual Ada bootstrap package"
HOMEPAGE="https://github.com/Lucretia/ada-overlay"

LICENSE="GPL-2+"
SLOT="10"
KEYWORDS="-* amd64" # arm arm64 ppc64 ~riscv ~s390 x86 ~amd64-linux ~x86-linux ~x64-macos ~x64-solaris"
IUSE="ada-bootstrap"

DEPEND="
    dev-lang/ada-bootstrap:10
    >=dev-ada/gprbuild-23.2[ada-bootstrap=]
"

pkg_postinst() {
    einfo "You have installed a bootstrapped Ada compiler, you now need to install it again."
    einfo "Disable the 'ada-bootstrap' USE flag from make.conf or wherever you set it."
    einfo "Then execute the following commands:"
    einfo
    einfo "  emerge -aC virtual/ada-bootstrap && emerge -av dev-ada/ada-meta"
}
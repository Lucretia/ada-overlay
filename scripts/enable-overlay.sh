#!/bin/sh

disable_gentoo() {
    echo "-ada" >> /etc/portage/profile/use.mask
    echo 'ADA_TARGET=""' >> /etc/portage/make.conf

    local DEV_ADA_MASK="dev-ada/*::gentoo"
    local GNAT_GPL_MASK="dev-lang/gnat-gpl::gentoo"
    local PATH="/etc/portage/package.mask"

    if [ -d ${PATH} ]; then
        echo ${DEV_ADA_MASK} >> ${PATH}/ada.mask
        echo ${GNAT_GPL_MASK} >> ${PATH}/ada.mask
    else
        echo ${DEV_ADA_MASK} >> ${PATH}
        echo ${GNAT_GPL_MASK} >> ${PATH}
    fi
}

update_package_use() {
    local STR="sys-devel/gcc ada"
    local PATH="/etc/portage/package.use"

    if [ -d ${PATH} ]; then
        echo ${STR} >> ${PATH}/gcc.use
    else
        echo ${STR} >> ${PATH}
    fi
}

disable_gentoo
update_package_use

#!/bin/sh

echo "-ada" >> /etc/portage/profile/use.mask
echo 'ADA_TARGET=""' >> /etc/portage/make.conf

if [ -d /etc/portage/package.mask ]; then
    echo "dev-ada/*::gentoo" >> /etc/portage/package.mask/ada.mask
    echo "dev-lang/gnat-gpl::gentoo" >> /etc/portage/package.mask/ada.mask
else
    echo "dev-ada/*::gentoo" >> /etc/portage/package.mask
    echo "dev-lang/gnat-gpl::gentoo" >> /etc/portage/package.mask
fi

if [ -d /etc/portage/package.use ]; then
    echo "sys-devel/gcc ada" >> /etc/portage/package.use/gcc.use
else
    echo "sys-devel/gcc ada" >> /etc/portage/package.use
fi

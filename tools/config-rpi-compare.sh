#!/bin/sh -e

DIR=$PWD

. "${DIR}/version.sh"
unset CC
. "${DIR}/.CC"

grab_rpi_branch () {
	cd ~/linux-rpi/
	git fetch --tags
	if [ ! "x${backport_tag}" = "x" ] ; then
		echo "git checkout ${backport_tag} -f"
		git checkout ${backport_tag} -f

		if [ -f arch/arm64/configs/bcm2712_defconfig ] ; then
			cp -v arch/arm64/configs/bcm2712_defconfig "${DIR}/patches/bcm2712.config"
		fi

		git checkout master -f
	fi
	cd -
}

if [ -f ${DIR}/KERNEL/Makefile ] ; then
	backport_tag="rpi-6.12.y" ; grab_rpi_branch

	cd ${DIR}/KERNEL/

	cp -v "${DIR}/patches/bcm2712.config" .config
	make ARCH=${KERNEL_ARCH} CROSS_COMPILE="${CC}" olddefconfig
	cp -v .config "${DIR}/patches/bcm2712.config"

	cd ${DIR}/
fi

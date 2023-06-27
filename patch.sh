#!/bin/bash -e
#
# Copyright (c) 2009-2023 Robert Nelson <robertcnelson@gmail.com>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

# Split out, so build_kernel.sh and build_deb.sh can share..

shopt -s nullglob

. ${DIR}/version.sh
if [ -f ${DIR}/system.sh ] ; then
	. ${DIR}/system.sh
fi
git_bin=$(which git)
#git hard requirements:
#git: --no-edit

git="${git_bin} am"
#git_patchset="git://git.ti.com/ti-linux-kernel/ti-linux-kernel.git"
git_patchset="https://github.com/RobertCNelson/ti-linux-kernel.git"
#git_opts

if [ "${RUN_BISECT}" ] ; then
	git="${git_bin} apply"
fi

echo "Starting patch.sh"

git_add () {
	${git_bin} add .
	${git_bin} commit -a -m 'testing patchset'
}

start_cleanup () {
	git="${git_bin} am --whitespace=fix"
}

cleanup () {
	if [ "${number}" ] ; then
		if [ "x${wdir}" = "x" ] ; then
			${git_bin} format-patch -${number} -o ${DIR}/patches/
		else
			if [ ! -d ${DIR}/patches/${wdir}/ ] ; then
				mkdir -p ${DIR}/patches/${wdir}/
			fi
			${git_bin} format-patch -${number} -o ${DIR}/patches/${wdir}/
			unset wdir
		fi
	fi
	exit 2
}

dir () {
	wdir="$1"
	if [ -d "${DIR}/patches/$wdir" ]; then
		echo "dir: $wdir"

		if [ "x${regenerate}" = "xenable" ] ; then
			start_cleanup
		fi

		number=
		for p in "${DIR}/patches/$wdir/"*.patch; do
			${git} "$p"
			number=$(( $number + 1 ))
		done

		if [ "x${regenerate}" = "xenable" ] ; then
			cleanup
		fi
	fi
	unset wdir
}

cherrypick () {
	if [ ! -d ../patches/${cherrypick_dir} ] ; then
		mkdir -p ../patches/${cherrypick_dir}
	fi
	${git_bin} format-patch -1 ${SHA} --start-number ${num} -o ../patches/${cherrypick_dir}
	num=$(($num+1))
}

external_git () {
	git_tag="ti-linux-${KERNEL_REL}.y"
	echo "pulling: [${git_patchset} ${git_tag}]"
	${git_bin} pull --no-edit ${git_patchset} ${git_tag}
	top_of_branch=$(${git_bin} describe)
	if [ ! "x${ti_git_new_release}" = "x" ] ; then
		${git_bin} checkout master -f
		test_for_branch=$(${git_bin} branch --list "v${KERNEL_TAG}${BUILD}")
		if [ "x${test_for_branch}" != "x" ] ; then
			${git_bin} branch "v${KERNEL_TAG}${BUILD}" -D
		fi
		${git_bin} checkout ${ti_git_new_release} -b v${KERNEL_TAG}${BUILD} -f
		current_git=$(${git_bin} describe)
		echo "${current_git}"

		if [ ! "x${top_of_branch}" = "x${current_git}" ] ; then
			echo "INFO: external git repo has updates..."
		fi
	else
		echo "${top_of_branch}"
	fi
	#exit 2
}

aufs_fail () {
	echo "aufs failed"
	exit 2
}

aufs () {
	#https://github.com/sfjro/aufs4-standalone/tree/aufs4.19.63+
	aufs_prefix="aufs4-"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		KERNEL_REL=4.19.63+
		wget https://raw.githubusercontent.com/sfjro/${aufs_prefix}standalone/aufs${KERNEL_REL}/${aufs_prefix}kbuild.patch
		patch -p1 < ${aufs_prefix}kbuild.patch || aufs_fail
		rm -rf ${aufs_prefix}kbuild.patch
		${git_bin} add .
		${git_bin} commit -a -m 'merge: aufs-kbuild' -s

		wget https://raw.githubusercontent.com/sfjro/${aufs_prefix}standalone/aufs${KERNEL_REL}/${aufs_prefix}base.patch
		patch -p1 < ${aufs_prefix}base.patch || aufs_fail
		rm -rf ${aufs_prefix}base.patch
		${git_bin} add .
		${git_bin} commit -a -m 'merge: aufs-base' -s

		wget https://raw.githubusercontent.com/sfjro/${aufs_prefix}standalone/aufs${KERNEL_REL}/${aufs_prefix}mmap.patch
		patch -p1 < ${aufs_prefix}mmap.patch || aufs_fail
		rm -rf ${aufs_prefix}mmap.patch
		${git_bin} add .
		${git_bin} commit -a -m 'merge: aufs-mmap' -s

		wget https://raw.githubusercontent.com/sfjro/${aufs_prefix}standalone/aufs${KERNEL_REL}/${aufs_prefix}standalone.patch
		patch -p1 < ${aufs_prefix}standalone.patch || aufs_fail
		rm -rf ${aufs_prefix}standalone.patch
		${git_bin} add .
		${git_bin} commit -a -m 'merge: aufs-standalone' -s

		${git_bin} format-patch -4 -o ../patches/aufs/

		cd ../
		if [ ! -d ./${aufs_prefix}standalone ] ; then
			${git_bin} clone -b aufs${KERNEL_REL} https://github.com/sfjro/${aufs_prefix}standalone --depth=1
			cd ./${aufs_prefix}standalone/
				aufs_hash=$(git rev-parse HEAD)
			cd -
		else
			rm -rf ./${aufs_prefix}standalone || true
			${git_bin} clone -b aufs${KERNEL_REL} https://github.com/sfjro/${aufs_prefix}standalone --depth=1
			cd ./${aufs_prefix}standalone/
				aufs_hash=$(git rev-parse HEAD)
			cd -
		fi
		cd ./KERNEL/
		KERNEL_REL=4.19

		cp -v ../${aufs_prefix}standalone/Documentation/ABI/testing/*aufs ./Documentation/ABI/testing/
		mkdir -p ./Documentation/filesystems/aufs/
		cp -rv ../${aufs_prefix}standalone/Documentation/filesystems/aufs/* ./Documentation/filesystems/aufs/
		mkdir -p ./fs/aufs/
		cp -v ../${aufs_prefix}standalone/fs/aufs/* ./fs/aufs/
		cp -v ../${aufs_prefix}standalone/include/uapi/linux/aufs_type.h ./include/uapi/linux/

		${git_bin} add .
		${git_bin} commit -a -m 'merge: aufs' -m "https://github.com/sfjro/${aufs_prefix}standalone/commit/${aufs_hash}" -s
		${git_bin} format-patch -5 -o ../patches/aufs/
		echo "AUFS: https://github.com/sfjro/${aufs_prefix}standalone/commit/${aufs_hash}" > ../patches/git/AUFS

		rm -rf ../${aufs_prefix}standalone/ || true

		${git_bin} reset --hard HEAD~5

		start_cleanup

		${git} "${DIR}/patches/aufs/0001-merge-aufs-kbuild.patch"
		${git} "${DIR}/patches/aufs/0002-merge-aufs-base.patch"
		${git} "${DIR}/patches/aufs/0003-merge-aufs-mmap.patch"
		${git} "${DIR}/patches/aufs/0004-merge-aufs-standalone.patch"
		${git} "${DIR}/patches/aufs/0005-merge-aufs.patch"

		wdir="aufs"
		number=5
		cleanup
	fi

	dir 'aufs'
}

can_isotp () {
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		cd ../
		if [ ! -d ./can-isotp ] ; then
			${git_bin} clone https://github.com/hartkopp/can-isotp --depth=1
			cd ./can-isotp
				isotp_hash=$(git rev-parse HEAD)
			cd -
		else
			rm -rf ./can-isotp || true
			${git_bin} clone https://github.com/hartkopp/can-isotp --depth=1
			cd ./can-isotp
				isotp_hash=$(git rev-parse HEAD)
			cd -
		fi

		cd ./KERNEL/

		cp -v ../can-isotp/include/uapi/linux/can/isotp.h  include/uapi/linux/can/
		cp -v ../can-isotp/net/can/isotp.c net/can/

		${git_bin} add .
		${git_bin} commit -a -m 'merge: can-isotp: https://github.com/hartkopp/can-isotp' -m "https://github.com/hartkopp/can-isotp/commit/${isotp_hash}" -s
		${git_bin} format-patch -1 -o ../patches/can_isotp/
		echo "CAN-ISOTP: https://github.com/hartkopp/can-isotp/commit/${isotp_hash}" > ../patches/git/CAN-ISOTP

		rm -rf ../can-isotp/ || true

		${git_bin} reset --hard HEAD~1

		start_cleanup

		${git} "${DIR}/patches/can_isotp/0001-merge-can-isotp-https-github.com-hartkopp-can-isotp.patch"

		wdir="can_isotp"
		number=1
		cleanup

		exit 2
	fi
	dir 'can_isotp'
}

rt_cleanup () {
	echo "rt: needs fixup"
	exit 2
}

rt () {
	rt_patch="${KERNEL_REL}${kernel_rt}"

	#${git_bin} revert --no-edit xyz

	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		wget -c https://www.kernel.org/pub/linux/kernel/projects/rt/${KERNEL_REL}/older/patch-${rt_patch}.patch.xz
		xzcat patch-${rt_patch}.patch.xz | patch -p1 || rt_cleanup
		rm -f patch-${rt_patch}.patch.xz
		rm -f localversion-rt
		${git_bin} add .
		${git_bin} commit -a -m 'merge: CONFIG_PREEMPT_RT Patch Set' -m "patch-${rt_patch}.patch.xz" -s
		${git_bin} format-patch -1 -o ../patches/rt/
		echo "RT: patch-${rt_patch}.patch.xz" > ../patches/git/RT

		exit 2
	fi

	dir 'rt'
}

wireguard_fail () {
	echo "WireGuard failed"
	exit 2
}

wireguard () {
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		cd ../
		if [ ! -d ./WireGuard ] ; then
			${git_bin} clone https://git.zx2c4.com/WireGuard --depth=1
			cd ./WireGuard
				wireguard_hash=$(git rev-parse HEAD)
			cd -
		else
			rm -rf ./WireGuard || true
			${git_bin} clone https://git.zx2c4.com/WireGuard --depth=1
			cd ./WireGuard
				wireguard_hash=$(git rev-parse HEAD)
			cd -
		fi

		#cd ./WireGuard/
		#${git_bin}  revert --no-edit xyz
		#cd ../

		cd ./KERNEL/

		../WireGuard/contrib/kernel-tree/create-patch.sh | patch -p1 || wireguard_fail

		${git_bin} add .
		${git_bin} commit -a -m 'merge: WireGuard' -m "https://git.zx2c4.com/WireGuard/commit/${wireguard_hash}" -s
		${git_bin} format-patch -1 -o ../patches/WireGuard/
		echo "WIREGUARD: https://git.zx2c4.com/WireGuard/commit/${wireguard_hash}" > ../patches/git/WIREGUARD

		rm -rf ../WireGuard/ || true

		${git_bin} reset --hard HEAD^

		start_cleanup

		${git} "${DIR}/patches/WireGuard/0001-merge-WireGuard.patch"

		wdir="WireGuard"
		number=1
		cleanup
	fi

	dir 'WireGuard'
}

wireless_regdb () {
	#https://git.kernel.org/pub/scm/linux/kernel/git/sforshee/wireless-regdb.git/
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then

		cd ../
		if [ ! -d ./wireless-regdb ] ; then
			${git_bin} clone git://git.kernel.org/pub/scm/linux/kernel/git/sforshee/wireless-regdb.git --depth=1
			cd ./wireless-regdb
				wireless_regdb_hash=$(git rev-parse HEAD)
			cd -
		else
			rm -rf ./wireless-regdb || true
			${git_bin} clone git://git.kernel.org/pub/scm/linux/kernel/git/sforshee/wireless-regdb.git --depth=1
			cd ./wireless-regdb
				wireless_regdb_hash=$(git rev-parse HEAD)
			cd -
		fi
		cd ./KERNEL/

		mkdir -p ./firmware/ || true
		cp -v ../wireless-regdb/regulatory.db ./firmware/
		cp -v ../wireless-regdb/regulatory.db.p7s ./firmware/
		${git_bin} add -f ./firmware/regulatory.*
		${git_bin} commit -a -m 'Add wireless-regdb regulatory database file' -m "https://git.kernel.org/pub/scm/linux/kernel/git/sforshee/wireless-regdb.git/commit/?id=${wireless_regdb_hash}" -s

		${git_bin} format-patch -1 -o ../patches/wireless_regdb/
		echo "WIRELESS_REGDB: https://git.kernel.org/pub/scm/linux/kernel/git/sforshee/wireless-regdb.git/commit/?id=${wireless_regdb_hash}" > ../patches/git/WIRELESS_REGDB

		rm -rf ../wireless-regdb/ || true

		${git_bin} reset --hard HEAD^

		start_cleanup

		${git} "${DIR}/patches/wireless_regdb/0001-Add-wireless-regdb-regulatory-database-file.patch"

		wdir="wireless_regdb"
		number=1
		cleanup
	fi

	dir 'wireless_regdb'
}

ti_pm_firmware () {
	#https://git.ti.com/gitweb?p=processor-firmware/ti-amx3-cm3-pm-firmware.git;a=shortlog;h=refs/heads/ti-v4.1.y
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then

		cd ../
		if [ ! -d ./ti-amx3-cm3-pm-firmware ] ; then
			${git_bin} clone -b ti-v4.1.y git://git.ti.com/processor-firmware/ti-amx3-cm3-pm-firmware.git --depth=1
			cd ./ti-amx3-cm3-pm-firmware
				ti_amx3_cm3_hash=$(git rev-parse HEAD)
			cd -
		else
			rm -rf ./ti-amx3-cm3-pm-firmware || true
			${git_bin} clone -b ti-v4.1.y git://git.ti.com/processor-firmware/ti-amx3-cm3-pm-firmware.git --depth=1
			cd ./ti-amx3-cm3-pm-firmware
				ti_amx3_cm3_hash=$(git rev-parse HEAD)
			cd -
		fi
		cd ./KERNEL/

		mkdir -p ./firmware/ || true
		cp -v ../ti-amx3-cm3-pm-firmware/bin/am* ./firmware/

		${git_bin} add -f ./firmware/am*
		${git_bin} commit -a -m 'Add AM335x CM3 Power Managment Firmware' -m "http://git.ti.com/gitweb/?p=processor-firmware/ti-amx3-cm3-pm-firmware.git;a=commit;h=${ti_amx3_cm3_hash}" -s
		${git_bin} format-patch -1 -o ../patches/drivers/ti/firmware/
		echo "TI_AMX3_CM3: http://git.ti.com/gitweb/?p=processor-firmware/ti-amx3-cm3-pm-firmware.git;a=commit;h=${ti_amx3_cm3_hash}" > ../patches/git/TI_AMX3_CM3

		rm -rf ../ti-amx3-cm3-pm-firmware/ || true

		${git_bin} reset --hard HEAD^

		start_cleanup

		${git} "${DIR}/patches/drivers/ti/firmware/0001-Add-AM335x-CM3-Power-Managment-Firmware.patch"

		wdir="drivers/ti/firmware"
		number=1
		cleanup
	fi

	dir 'drivers/ti/firmware'
}

cleanup_dts_builds () {
	rm -rf arch/arm/boot/dts/modules.order || true
	rm -rf arch/arm/boot/dts/.*cmd || true
	rm -rf arch/arm/boot/dts/.*tmp || true
	rm -rf arch/arm/boot/dts/*dtb || true
}

dtb_makefile_append_am5 () {
	sed -i -e 's:am57xx-beagle-x15.dtb \\:am57xx-beagle-x15.dtb \\\n\t'$device' \\:g' arch/arm/boot/dts/Makefile
}

dtb_makefile_append () {
	sed -i -e 's:am335x-boneblack.dtb \\:am335x-boneblack.dtb \\\n\t'$device' \\:g' arch/arm/boot/dts/Makefile
}

beagleboard_dtbs () {
	branch="v4.19.x-ti-overlays"
	https_repo="https://git.beagleboard.org/beagleboard/BeagleBoard-DeviceTrees.git"
	work_dir="BeagleBoard-DeviceTrees"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		cd ../
		if [ -d ./${work_dir} ] ; then
			rm -rf ./${work_dir} || true
		fi

		${git_bin} clone -b ${branch} ${https_repo} --depth=1
		cd ./${work_dir}
			git_hash=$(git rev-parse HEAD)
		cd -

		cd ./KERNEL/

		cleanup_dts_builds
		rm -rf arch/arm/boot/dts/overlays/ || true

		mkdir -p arch/arm/boot/dts/overlays/
		cp -vr ../${work_dir}/src/arm/* arch/arm/boot/dts/
		if [ -f ./arch/arm/boot/dts/overlays/README.MD ] ; then
			rm -rf ./arch/arm/boot/dts/overlays/README.MD
		fi
		cp -vr ../${work_dir}/include/dt-bindings/* ./include/dt-bindings/

		device="am335x-abbbi.dtb" ; dtb_makefile_append
		device="am335x-osd3358-sm-red-v4.dtb" ; dtb_makefile_append

		device="am335x-boneblack-wl1835mod.dtb" ; dtb_makefile_append
		device="am335x-boneblack-bbbmini.dtb" ; dtb_makefile_append
		device="am335x-boneblack-bbb-exp-c.dtb" ; dtb_makefile_append
		device="am335x-boneblack-bbb-exp-r.dtb" ; dtb_makefile_append
		device="am335x-boneblack-audio.dtb" ; dtb_makefile_append

		device="am335x-bone-uboot-univ.dtb" ; dtb_makefile_append
		device="am335x-boneblack-uboot.dtb" ; dtb_makefile_append
		device="am335x-boneblack-uboot-univ.dtb" ; dtb_makefile_append
		device="am335x-bonegreen-wireless-uboot-univ.dtb" ; dtb_makefile_append
		device="am335x-bonegreen-gateway.dtb" ; dtb_makefile_append

		device="am5729-beagleboneai-roboticscape.dtb" ; dtb_makefile_append_am5

		device="am335x-boneblack-roboticscape.dtb" ; dtb_makefile_append
		device="am335x-boneblack-wireless-roboticscape.dtb" ; dtb_makefile_append

		device="am335x-sancloud-bbe-uboot.dtb" ; dtb_makefile_append
		device="am335x-sancloud-bbe-uboot-univ.dtb" ; dtb_makefile_append

		${git_bin} add -f arch/arm/boot/dts/
		${git_bin} add -f include/dt-bindings/
		${git_bin} commit -a -m "Add BeagleBoard.org Device Tree Changes" -m "https://git.beagleboard.org/beagleboard/BeagleBoard-DeviceTrees/-/tree/${branch}" -m "https://git.beagleboard.org/beagleboard/BeagleBoard-DeviceTrees/-/commit/${git_hash}" -s
		${git_bin} format-patch -1 -o ../patches/soc/ti/beagleboard_dtbs/
		echo "BBDTBS: https://git.beagleboard.org/beagleboard/BeagleBoard-DeviceTrees/-/commit/${git_hash}" > ../patches/external/git/BBDTBS

		rm -rf ../${work_dir}/ || true

		${git_bin} reset --hard HEAD^

		start_cleanup

		${git} "${DIR}/patches/soc/ti/beagleboard_dtbs/0001-Add-BeagleBoard.org-Device-Tree-Changes.patch"

		wdir="soc/ti/beagleboard_dtbs"
		number=1
		cleanup
	fi
	dir 'soc/ti/beagleboard_dtbs'
}

local_patch () {
	echo "dir: dir"
	${git} "${DIR}/patches/dir/0001-patch.patch"
}

external_git
aufs
can_isotp
#rt
wireguard
wireless_regdb
ti_pm_firmware
beagleboard_dtbs
#local_patch

pre_backports () {
	echo "dir: backports/${subsystem}"

	cd ~/linux-src/
	${git_bin} pull --no-edit https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git master
	${git_bin} pull --no-edit https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git master --tags
	${git_bin} pull --no-edit https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master --tags
	if [ ! "x${backport_tag}" = "x" ] ; then
		${git_bin} checkout ${backport_tag} -b tmp
	fi
	cd -
}

post_backports () {
	if [ ! "x${backport_tag}" = "x" ] ; then
		cd ~/linux-src/
		${git_bin} checkout master -f ; ${git_bin} branch -D tmp
		cd -
	fi

	rm -f arch/arm/boot/dts/overlays/*.dtbo || true
	${git_bin} add .
	${git_bin} commit -a -m "backports: ${subsystem}: from: linux.git" -m "Reference: ${backport_tag}" -s
	if [ ! -d ../patches/backports/${subsystem}/ ] ; then
		mkdir -p ../patches/backports/${subsystem}/
	fi
	${git_bin} format-patch -1 -o ../patches/backports/${subsystem}/
}

patch_backports (){
	echo "dir: backports/${subsystem}"
	${git} "${DIR}/patches/backports/${subsystem}/0001-backports-${subsystem}-from-linux.git.patch"
}

backports () {
	backport_tag="v4.19.238"

	subsystem="greybus"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		pre_backports

		cp -rv ~/linux-src/drivers/staging/greybus/* ./drivers/staging/greybus/

		post_backports
		exit 2
	else
		patch_backports
	fi

	backport_tag="v4.19.238"

	subsystem="wlcore"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		pre_backports

		cp -rv ~/linux-src/drivers/net/wireless/ti/* ./drivers/net/wireless/ti/

		post_backports
		exit 2
	else
		patch_backports
	fi

	backport_tag="v4.19.238"

	subsystem="iio"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		pre_backports

		cp -rv ~/linux-src/include/linux/iio/* ./include/linux/iio/
		cp -rv ~/linux-src/include/uapi/linux/iio/* ./include/uapi/linux/iio/
		cp -rv ~/linux-src/drivers/iio/* ./drivers/iio/
		cp -rv ~/linux-src/drivers/staging/iio/* ./drivers/staging/iio/

		post_backports
		exit 2
	else
		patch_backports
	fi

	backport_tag="v5.4.189"

	subsystem="wiznet"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		pre_backports

		cp -v ~/linux-src/drivers/net/ethernet/wiznet/* ./drivers/net/ethernet/wiznet/

		post_backports
		exit 2
	else
		patch_backports
	fi

	backport_tag="v5.0.21"

	subsystem="typec"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		pre_backports

		rm -rf ./drivers/usb/typec/
		mkdir -p ./drivers/usb/typec/
		cp -rv ~/linux-src/drivers/usb/typec/* ./drivers/usb/typec/
		cp -v ~/linux-src/include/linux/usb/typec*.h ./include/linux/usb/

		post_backports
		exit 2
	else
		patch_backports
	fi

	backport_tag="v5.3.18"

	subsystem="stmpe"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		pre_backports

		cp -v ~/linux-src/drivers/iio/adc/stmpe-adc.c ./drivers/iio/adc/
		cp -v ~/linux-src/drivers/mfd/stmpe.c ./drivers/mfd/
		cp -v ~/linux-src/include/linux/mfd/stmpe.h ./include/linux/mfd/

		post_backports
		exit 2
	else
		patch_backports
	fi

	${git} "${DIR}/patches/backports/stmpe/0002-stmpe-wire-up-adc-Kconfig-Makefile.patch"

	backport_tag="v5.0.21"

	subsystem="vl53l0x"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		pre_backports

		cp -v ~/linux-src/drivers/iio/proximity/vl53l0x-i2c.c ./drivers/iio/proximity/vl53l0x-i2c.c

		post_backports
		exit 2
	else
		patch_backports
	fi

	${git} "${DIR}/patches/backports/vl53l0x/0002-wire-up-VL53L0X_I2C.patch"

	backport_tag="v4.14.77"
	subsystem="brcm80211"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		pre_backports

		cp -rv ~/linux-src/drivers/net/wireless/broadcom/brcm80211/* ./drivers/net/wireless/broadcom/brcm80211/

		post_backports
		exit 2
	else
		patch_backports
		${git} "${DIR}/patches/backports/brcm80211/0002-drivers-net-brcm80211-use-setup_timer-helper.patch"
		${git} "${DIR}/patches/backports/brcm80211/0003-brcmfmac-use-setup_timer-helper.patch"
		${git} "${DIR}/patches/backports/brcm80211/0004-treewide-setup_timer-timer_setup.patch"
		${git} "${DIR}/patches/backports/brcm80211/0005-Revert-compiler.h-Remove-ACCESS_ONCE.patch"
	fi

	#regenerate="enable"
	dir 'cypress/brcmfmac'
}

reverts () {
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		start_cleanup
	fi

	## notes
	##git revert --no-edit xyz -s

	#dir 'reverts'

	if [ "x${regenerate}" = "xenable" ] ; then
		wdir="reverts"
		number=1
		cleanup
	fi
}

drivers () {
	#https://github.com/raspberrypi/linux/branches
	#exit 2
	dir 'RPi'
	dir 'drivers/ar1021_i2c'
	dir 'drivers/btrfs'
	dir 'drivers/pwm'
	dir 'drivers/sound'
	dir 'drivers/spi'
	dir 'drivers/ssd1306'
	dir 'drivers/tps65217'
	dir 'drivers/opp'
	dir 'drivers/ctag'

	dir 'drivers/ti/cpsw'
	dir 'drivers/ti/etnaviv'
	dir 'drivers/ti/eqep'
	dir 'drivers/ti/rpmsg'
	dir 'drivers/ti/serial'
	dir 'drivers/ti/tsc'
	dir 'drivers/ti/gpio'

	dir 'drivers/uio_pruss_shmem'
	dir 'drivers/greybus'
	dir 'gsoc'
	dir 'fixes'
	dir 'bluetooth'
	dir 'drivers/red'
}

soc () {
#pruss:
	#dir 'drivers/ti/uio_pruss'

	${git} "${DIR}/patches/drivers/ti/uio_pruss/0001-uio-pruss-cleanups-and-pruss-v2-pru-icss-support.patch"
	#${git} "${DIR}/patches/drivers/ti/uio_pruss/0002-ARM-DRA7-hwmod_data-Add-PRU-ICSS-data-for-AM57xx-var.patch"
	${git} "${DIR}/patches/drivers/ti/uio_pruss/0003-ARM-omap2-support-deasserting-reset-from-dts.patch"
	#${git} "${DIR}/patches/drivers/ti/uio_pruss/0004-ARM-dts-dra7-am335x-add-outline-definitions-for-prus.patch"
	#${git} "${DIR}/patches/drivers/ti/uio_pruss/0005-ARM-dts-dra7-am335x-dtsi-files-for-enabling-uio-prus.patch"
	#${git} "${DIR}/patches/drivers/ti/uio_pruss/0006-ARM-dts-beagle-x15-enable-uio-pruss-by-default.patch"

	dir 'pru_rproc_gnu_binutils'
	dir 'bootup_hacks'
}

fixes () {
	dir 'fixes/gcc'
}

###
backports
#reverts
drivers
soc
fixes

packaging () {
	do_backport="enable"
	if [ "x${do_backport}" = "xenable" ] ; then
		backport_tag="v5.2.21"

		subsystem="bindeb-pkg"
		#regenerate="enable"
		if [ "x${regenerate}" = "xenable" ] ; then
			pre_backports

			cp -v ~/linux-src/scripts/package/* ./scripts/package/

			post_backports
			exit 2
		else
			patch_backports
		fi
	fi

	${git} "${DIR}/patches/backports/bindeb-pkg/0002-builddeb-Install-our-dtbs-under-boot-dtbs-version.patch"
}

readme () {
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		cp -v "${DIR}/3rdparty/readme/README.md" "${DIR}/KERNEL/README.md"
		cp -v "${DIR}/3rdparty/readme/.gitlab-ci.yml" "${DIR}/KERNEL/.gitlab-ci.yml"

		mkdir -p "${DIR}/KERNEL/.github/ISSUE_TEMPLATE/"
		cp -v "${DIR}/3rdparty/readme/bug_report.md" "${DIR}/KERNEL/.github/ISSUE_TEMPLATE/"
		cp -v "${DIR}/3rdparty/readme/FUNDING.yml" "${DIR}/KERNEL/.github/"

		git add -f README.md
		git add -f .gitlab-ci.yml

		git add -f .github/ISSUE_TEMPLATE/bug_report.md
		git add -f .github/FUNDING.yml

		git commit -a -m 'enable: gitlab-ci' -s
		git format-patch -1 -o "${DIR}/patches/readme"
		exit 2
	else
		dir 'readme'
	fi
}

packaging
readme
echo "patch.sh ran successfully"
#

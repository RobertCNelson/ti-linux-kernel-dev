#!/bin/bash -e
#
# Copyright (c) 2009-2021 Robert Nelson <robertcnelson@gmail.com>
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
			#echo "$p"
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
	if [ ! "x${ti_git_post}" = "x" ] ; then
		${git_bin} checkout master -f
		test_for_branch=$(${git_bin} branch --list "v${KERNEL_TAG}${BUILD}")
		if [ "x${test_for_branch}" != "x" ] ; then
			${git_bin} branch "v${KERNEL_TAG}${BUILD}" -D
		fi
		${git_bin} checkout ${ti_git_post} -b v${KERNEL_TAG}${BUILD} -f
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
	#https://github.com/sfjro/aufs4-standalone/tree/aufs4.14.73+
	aufs_prefix="aufs4-"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		KERNEL_REL=4.14.73+
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
		KERNEL_REL=4.14

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

	#revert this from ti's branch...
	${git_bin} revert --no-edit 2f6872da466b6f35b3c0a94aa01629da7ae9b72b

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
	echo "dir: WireGuard"

	#[    3.315290] NOHZ: local_softirq_pending 242
	#[    3.319504] NOHZ: local_softirq_pending 242
	${git_bin} revert --no-edit 2d898915ccf4838c04531c51a598469e921a5eb5

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

dtb_makefile_append_omap4 () {
	sed -i -e 's:omap4-panda.dtb \\:omap4-panda.dtb \\\n\t'$device' \\:g' arch/arm/boot/dts/Makefile
}

dtb_makefile_append_am5 () {
	sed -i -e 's:am57xx-beagle-x15.dtb \\:am57xx-beagle-x15.dtb \\\n\t'$device' \\:g' arch/arm/boot/dts/Makefile
}

dtb_makefile_append () {
	sed -i -e 's:am335x-boneblack.dtb \\:am335x-boneblack.dtb \\\n\t'$device' \\:g' arch/arm/boot/dts/Makefile
}

beagleboard_dtbs () {
	branch="v4.14.x-ti"
	https_repo="https://github.com/beagleboard/BeagleBoard-DeviceTrees"
	work_dir="BeagleBoard-DeviceTrees"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		cd ../
		if [ ! -d ./${work_dir} ] ; then
			${git_bin} clone -b ${branch} ${https_repo} --depth=1
			cd ./${work_dir}
				git_hash=$(git rev-parse HEAD)
			cd -
		else
			rm -rf ./${work_dir} || true
			${git_bin} clone -b ${branch} ${https_repo} --depth=1
			cd ./${work_dir}
				git_hash=$(git rev-parse HEAD)
			cd -
		fi
		cd ./KERNEL/

		cp -vr ../${work_dir}/src/arm/* arch/arm/boot/dts/
		cp -vr ../${work_dir}/include/dt-bindings/* ./include/dt-bindings/

		device="am335x-abbbi.dtb" ; dtb_makefile_append

		device="am335x-sancloud-bbe.dtb" ; dtb_makefile_append
		device="am335x-olimex-som.dtb" ; dtb_makefile_append

		device="am335x-boneblack-wl1835mod.dtb" ; dtb_makefile_append
		device="am335x-boneblack-bbbmini.dtb" ; dtb_makefile_append
		device="am335x-boneblack-bbb-exp-c.dtb" ; dtb_makefile_append
		device="am335x-boneblack-bbb-exp-r.dtb" ; dtb_makefile_append
		device="am335x-boneblack-audio.dtb" ; dtb_makefile_append

		device="am335x-pocketbeagle.dtb" ; dtb_makefile_append
		device="am335x-pocketbeagle-gamepup.dtb" ; dtb_makefile_append
		device="am335x-pocketbeagle-techlab.dtb" ; dtb_makefile_append

		device="am335x-boneblack-roboticscape.dtb" ; dtb_makefile_append
		device="am335x-boneblack-wireless-roboticscape.dtb" ; dtb_makefile_append

		device="am335x-bone-uboot-univ.dtb" ; dtb_makefile_append
		device="am335x-boneblack-uboot.dtb" ; dtb_makefile_append
		device="am335x-boneblack-uboot-univ.dtb" ; dtb_makefile_append
		device="am335x-bonegreen-wireless-uboot-univ.dtb" ; dtb_makefile_append
		device="am335x-bonegreen-gateway.dtb" ; dtb_makefile_append
		device="am335x-sancloud-bbe-uboot.dtb" ; dtb_makefile_append
		device="am335x-sancloud-bbe-uboot-univ.dtb" ; dtb_makefile_append

		device="am57xx-evm.dtb" ; dtb_makefile_append_am5
		device="am57xx-evm-reva3.dtb" ; dtb_makefile_append_am5
		device="am57xx-beagle-x15-gssi.dtb" ; dtb_makefile_append_am5

		device="am5729-beagleboneai.dtb" ; dtb_makefile_append_am5
		device="am5729-beagleboneai-roboticscape.dtb" ; dtb_makefile_append_am5

		${git_bin} add -f arch/arm/boot/dts/
		${git_bin} add -f include/dt-bindings/
		${git_bin} commit -a -m "Add BeagleBoard.org DTBS: $branch" -m "${https_repo}/tree/${branch}" -m "${https_repo}/commit/${git_hash}" -s
		${git_bin} format-patch -1 -o ../patches/soc/ti/beagleboard_dtbs/
		echo "BBDTBS: ${https_repo}/commit/${git_hash}" > ../patches/git/BBDTBS

		rm -rf ../${work_dir}/ || true

		${git_bin} reset --hard HEAD^

		start_cleanup

		${git} "${DIR}/patches/soc/ti/beagleboard_dtbs/0001-Add-BeagleBoard.org-DTBS-$branch.patch"

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
	backport_tag="v4.19.192"

	subsystem="greybus"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		pre_backports

		cp -rv ~/linux-src/drivers/staging/greybus/* ./drivers/staging/greybus/

		post_backports
		exit 2
	else
		patch_backports
		${git} "${DIR}/patches/backports/greybus/0002-greybus-drivers-staging-greybus-module.c-no-struct_s.patch"
	fi

	backport_tag="v4.14.234"

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

	backport_tag="v4.14.234"

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

	backport_tag="v5.4.122"

	subsystem="wiznet"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		pre_backports

		cp -rv ~/linux-src/drivers/net/ethernet/wiznet/* ./drivers/net/ethernet/wiznet/

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

		cp -v ~/linux-src/drivers/input/touchscreen/stmpe-ts.c ./drivers/input/touchscreen/
		cp -v ~/linux-src/drivers/iio/adc/stmpe-adc.c ./drivers/iio/adc/
		cp -v ~/linux-src/drivers/mfd/stmpe.c ./drivers/mfd/
		cp -v ~/linux-src/include/linux/mfd/stmpe.h ./include/linux/mfd/

		post_backports
		exit 2
	else
		patch_backports
	fi

	${git} "${DIR}/patches/backports/stmpe/0002-stmpe-wire-up-adc-Kconfig-Makefile.patch"
	${git} "${DIR}/patches/backports/stmpe/0003-stmpe-ts-add-invert-swap-options.patch"
	${git} "${DIR}/patches/backports/stmpe/0004-stmpe-ts.c-add-offsets.patch"

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

	backport_tag="v4.16.18"

	subsystem="led_trigger"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		pre_backports

		cp -rv ~/linux-src/drivers/leds/trigger/* ./drivers/leds/trigger/

		post_backports
		exit 2
	else
		patch_backports
	fi

	backport_tag="v4.14.77"

	subsystem="brcm80211"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		pre_backports

		cp -rv ~/linux-src/drivers/net/wireless/broadcom/brcm80211/* ./drivers/net/wireless/broadcom/brcm80211/
		cp -v ~/linux-src/include/linux/mmc/sdio_ids.h ./include/linux/mmc/sdio_ids.h
		#cp -v ~/linux-src/include/linux/firmware.h ./include/linux/firmware.h

		post_backports

		#v4.14.77-2020_0115
		patch -p1 < ../patches/cypress/brcmfmac/0001-brcmfmac-add-CLM-download-support.patch
		patch -p1 < ../patches/cypress/brcmfmac/0002-brcmfmac-Set-F2-blksz-and-Watermark-to-256-for-4373.patch
		patch -p1 < ../patches/cypress/brcmfmac/0003-brcmfmac-Add-sg-parameters-dts-parsing.patch
		patch -p1 < ../patches/cypress/brcmfmac/0004-brcmfmac-return-EPERM-when-getting-error-in-vendor-c.patch
		patch -p1 < ../patches/cypress/brcmfmac/0005-brcmfmac-Add-support-for-CYW43012-SDIO-chipset.patch
		patch -p1 < ../patches/cypress/brcmfmac/0006-brcmfmac-set-apsta-to-0-when-AP-starts-on-primary-in.patch
		patch -p1 < ../patches/cypress/brcmfmac/0007-brcmfmac-Saverestore-support-changes-for-43012.patch
		patch -p1 < ../patches/cypress/brcmfmac/0008-brcmfmac-Support-43455-save-restore-SR-feature-if-FW.patch
		patch -p1 < ../patches/cypress/brcmfmac/0009-brcmfmac-fix-CLM-load-error-for-legacy-chips-when-us.patch
		patch -p1 < ../patches/cypress/brcmfmac/0010-brcmfmac-enlarge-buffer-size-of-caps-to-512-bytes.patch
		patch -p1 < ../patches/cypress/brcmfmac/0011-brcmfmac-calling-skb_orphan-before-sending-skb-to-SD.patch
		patch -p1 < ../patches/cypress/brcmfmac/0012-brcmfmac-43012-Update-F2-Watermark-to-0x60-to-fix-DM.patch
		patch -p1 < ../patches/cypress/brcmfmac/0013-brcmfmac-DS1-Exit-should-re-download-the-firmware.patch
		patch -p1 < ../patches/cypress/brcmfmac/0014-brcmfmac-add-FT-based-AKMs-in-brcmf_set_key_mgmt-for.patch
		patch -p1 < ../patches/cypress/brcmfmac/0015-brcmfmac-support-AP-isolation.patch
		patch -p1 < ../patches/cypress/brcmfmac/0016-brcmfmac-do-not-print-ulp_sdioctrl-get-error.patch
		patch -p1 < ../patches/cypress/brcmfmac/0017-brcmfmac-fix-system-warning-message-during-wowl-susp.patch
		patch -p1 < ../patches/cypress/brcmfmac/0018-brcmfmac-add-a-module-parameter-to-set-scheduling-pr.patch
		patch -p1 < ../patches/cypress/brcmfmac/0019-brcmfmac-make-firmware-eap_restrict-a-module-paramet.patch
		patch -p1 < ../patches/cypress/brcmfmac/0020-brcmfmac-Support-wake-on-ping-packet.patch
		patch -p1 < ../patches/cypress/brcmfmac/0021-brcmfmac-Remove-WOWL-configuration-in-disconnect-sta.patch
		patch -p1 < ../patches/cypress/brcmfmac/0022-brcmfmac-add-CYW89342-PCIE-device.patch
		patch -p1 < ../patches/cypress/brcmfmac/0023-brcmfmac-handle-compressed-tx-status-signal.patch
		patch -p1 < ../patches/cypress/brcmfmac/0024-revert-brcmfmac-add-a-module-parameter-to-set-schedu.patch
		patch -p1 < ../patches/cypress/brcmfmac/0025-brcmfmac-make-setting-SDIO-workqueue-WQ_HIGHPRI-a-mo.patch
		patch -p1 < ../patches/cypress/brcmfmac/0026-brcmfmac-add-credit-map-updating-support.patch
		patch -p1 < ../patches/cypress/brcmfmac/0027-brcmfmac-add-4-way-handshake-offload-detection-for-F.patch
		patch -p1 < ../patches/cypress/brcmfmac/0028-brcmfmac-remove-arp_hostip_clear-from-brcmf_netdev_s.patch
		patch -p1 < ../patches/cypress/brcmfmac/0029-brcmfmac-fix-unused-variable-building-warning-messag.patch
		patch -p1 < ../patches/cypress/brcmfmac/0030-brcmfmac-disable-command-decode-in-sdio_aos-for-4339.patch
		patch -p1 < ../patches/cypress/brcmfmac/0031-Revert-brcmfmac-fix-CLM-load-error-for-legacy-chips-.patch
		patch -p1 < ../patches/cypress/brcmfmac/0032-brcmfmac-fix-CLM-load-error-for-legacy-chips-when-us.patch
		patch -p1 < ../patches/cypress/brcmfmac/0033-brcmfmac-set-WIPHY_FLAG_HAVE_AP_SME-flag.patch
		patch -p1 < ../patches/cypress/brcmfmac/0034-brcmfmac-P2P-CERT-6.1.9-Support-GOUT-handling-P2P-Pr.patch
		patch -p1 < ../patches/cypress/brcmfmac/0035-brcmfmac-only-generate-random-p2p-address-when-neede.patch
		patch -p1 < ../patches/cypress/brcmfmac/0036-brcmfmac-disable-command-decode-in-sdio_aos-for-4354.patch
		patch -p1 < ../patches/cypress/brcmfmac/0037-brcmfmac-increase-max-hanger-slots-from-1K-to-3K-in-.patch
		patch -p1 < ../patches/cypress/brcmfmac/0038-brcmfmac-reduce-timeout-for-action-frame-scan.patch
		patch -p1 < ../patches/cypress/brcmfmac/0039-brcmfmac-fix-full-timeout-waiting-for-action-frame-o.patch
		patch -p1 < ../patches/cypress/brcmfmac/0040-brcmfmac-4373-save-restore-support.patch
		patch -p1 < ../patches/cypress/brcmfmac/0041-brcmfmac-map-802.1d-priority-to-precedence-level-bas.patch
		patch -p1 < ../patches/cypress/brcmfmac/0042-brcmfmac-allow-GCI-core-enumuration.patch
		patch -p1 < ../patches/cypress/brcmfmac/0043-brcmfmac-make-firmware-frameburst-mode-a-module-para.patch
		patch -p1 < ../patches/cypress/brcmfmac/0044-brcmfmac-set-state-of-hanger-slot-to-FREE-when-flush.patch
		patch -p1 < ../patches/cypress/brcmfmac/0045-brcmfmac-add-creating-station-interface-support.patch
		patch -p1 < ../patches/cypress/brcmfmac/0046-brcmfmac-add-RSDB-condition-when-setting-interface-c.patch
		patch -p1 < ../patches/cypress/brcmfmac/0047-brcmfmac-not-set-mbss-in-vif-if-firmware-does-not-su.patch
		patch -p1 < ../patches/cypress/brcmfmac/0048-brcmfmac-support-the-second-p2p-connection.patch
		patch -p1 < ../patches/cypress/brcmfmac/0049-brcmfmac-Add-support-for-BCM4359-SDIO-chipset.patch
		patch -p1 < ../patches/cypress/brcmfmac/0050-cfg80211-nl80211-add-a-port-authorized-event.patch
		patch -p1 < ../patches/cypress/brcmfmac/0051-nl80211-add-NL80211_ATTR_IFINDEX-to-port-authorized-.patch
		patch -p1 < ../patches/cypress/brcmfmac/0052-brcmfmac-send-port-authorized-event-for-802.1X-4-way.patch
		patch -p1 < ../patches/cypress/brcmfmac/0053-brcmfmac-send-port-authorized-event-for-FT-802.1X.patch
		patch -p1 < ../patches/cypress/brcmfmac/0054-brcmfmac-Support-DS1-TX-Exit-in-FMAC.patch
		patch -p1 < ../patches/cypress/brcmfmac/0055-brcmfmac-disable-command-decode-in-sdio_aos-for-4373.patch
		patch -p1 < ../patches/cypress/brcmfmac/0056-brcmfmac-add-vendor-ie-for-association-responses.patch
		patch -p1 < ../patches/cypress/brcmfmac/0057-brcmfmac-fix-43012-insmod-after-rmmod-in-DS1-failure.patch
		patch -p1 < ../patches/cypress/brcmfmac/0058-brcmfmac-Set-SDIO-F1-MesBusyCtrl-for-CYW4373.patch
		patch -p1 < ../patches/cypress/brcmfmac/0059-brcmfmac-add-4354-raw-pcie-device-id.patch
		patch -p1 < ../patches/cypress/brcmfmac/0060-nl80211-Allow-SAE-Authentication-for-NL80211_CMD_CON.patch
		patch -p1 < ../patches/cypress/brcmfmac/0061-non-upstream-update-enum-nl80211_attrs-and-nl80211_e.patch
		patch -p1 < ../patches/cypress/brcmfmac/0062-nl80211-add-WPA3-definition-for-SAE-authentication.patch
		patch -p1 < ../patches/cypress/brcmfmac/0063-cfg80211-add-support-for-SAE-authentication-offload.patch
		patch -p1 < ../patches/cypress/brcmfmac/0064-brcmfmac-add-support-for-SAE-authentication-offload.patch
		patch -p1 < ../patches/cypress/brcmfmac/0065-brcmfmac-fix-4339-CRC-error-under-SDIO-3.0-SDR104-mo.patch
		patch -p1 < ../patches/cypress/brcmfmac/0066-brcmfmac-fix-the-incorrect-return-value-in-brcmf_inf.patch
		patch -p1 < ../patches/cypress/brcmfmac/0067-brcmfmac-Fix-double-freeing-in-the-fmac-usb-data-pat.patch
		patch -p1 < ../patches/cypress/brcmfmac/0068-brcmfmac-Fix-driver-crash-on-USB-control-transfer-ti.patch
		patch -p1 < ../patches/cypress/brcmfmac/0069-brcmfmac-avoid-network-disconnection-during-suspend-.patch
		patch -p1 < ../patches/cypress/brcmfmac/0070-brcmfmac-Allow-credit-borrowing-for-all-access-categ.patch
		patch -p1 < ../patches/cypress/brcmfmac/0071-non-upstream-Changes-to-improve-USB-Tx-throughput.patch
		patch -p1 < ../patches/cypress/brcmfmac/0072-non-upstream-reset-two-D11-cores-if-chip-has-two-D11.patch
		patch -p1 < ../patches/cypress/brcmfmac/0073-brcmfmac-reset-PMU-backplane-all-cores-in-CYW4373-du.patch
		patch -p1 < ../patches/cypress/brcmfmac/0074-brcmfmac-introduce-module-parameter-to-configure-def.patch
		patch -p1 < ../patches/cypress/brcmfmac/0075-brcmfmac-configure-wowl-parameters-in-suspend-functi.patch
		patch -p1 < ../patches/cypress/brcmfmac/0076-brcmfmac-discard-user-space-RSNE-for-SAE-authenticat.patch
		patch -p1 < ../patches/cypress/brcmfmac/0077-brcmfmac-keep-SDIO-watchdog-running-when-console_int.patch
		patch -p1 < ../patches/cypress/brcmfmac/0078-brcmfmac-To-fix-kernel-crash-on-out-of-boundary-acce.patch
		patch -p1 < ../patches/cypress/brcmfmac/0079-brcmfmac-reduce-maximum-station-interface-from-2-to-.patch
		patch -p1 < ../patches/cypress/brcmfmac/0080-Revert-brcmfmac-add-creating-station-interface-suppo.patch
		patch -p1 < ../patches/cypress/brcmfmac/0081-brcmfmac-validate-ifp-pointer-in-brcmf_txfinalize.patch
		patch -p1 < ../patches/cypress/brcmfmac/0082-brcmfmac-clean-up-iface-mac-descriptor-before-de-ini.patch
		patch -p1 < ../patches/cypress/brcmfmac/0083-brcmfmac-To-support-printing-USB-console-messages.patch
		patch -p1 < ../patches/cypress/brcmfmac/0084-brcmfmac-To-fix-Bss-Info-flag-definition-Bug.patch
		patch -p1 < ../patches/cypress/brcmfmac/0085-brcmfmac-disable-command-decode-in-sdio_aos-for-4356.patch
		patch -p1 < ../patches/cypress/brcmfmac/0086-brcmfmac-increase-default-max-WOWL-patterns-to-16.patch
		patch -p1 < ../patches/cypress/brcmfmac/0087-brcmfmac-Enable-Process-and-forward-PHY_TEMP-event.patch
		patch -p1 < ../patches/cypress/brcmfmac/0088-brcmfmac-add-USB-autosuspend-feature-support.patch
		patch -p1 < ../patches/cypress/brcmfmac/0089-non-upstream-workaround-for-4373-USB-WMM-5.2.27-test.patch
		patch -p1 < ../patches/cypress/brcmfmac/0090-brcmfmac-Fix-access-point-mode.patch
		patch -p1 < ../patches/cypress/brcmfmac/0091-brcmfmac-make-compatible-with-Fully-Preemptile-Kerne.patch
		patch -p1 < ../patches/cypress/brcmfmac/0092-brcmfmac-remove-the-duplicate-line-of-writing-BRCMF_.patch
		patch -p1 < ../patches/cypress/brcmfmac/0093-brcmfmac-43012-reloading-FAMC-driver-failure-on-BU-m.patch
		patch -p1 < ../patches/cypress/brcmfmac/0094-brcmfmac-handle-FWHALT-mailbox-indication.patch
		patch -p1 < ../patches/cypress/brcmfmac/0095-brcmfmac-validate-user-provided-data-for-memdump-bef.patch
		patch -p1 < ../patches/cypress/brcmfmac/0096-brcmfmac-Use-FW-priority-definition-to-initialize-WM.patch
		patch -p1 < ../patches/cypress/brcmfmac/0097-brcmfmac-Fix-P2P-Group-Formation-failure-via-Go-neg-.patch
		patch -p1 < ../patches/cypress/brcmfmac/0098-nl80211-add-authorized-flag-back-to-ROAM-event.patch
		patch -p1 < ../patches/cypress/brcmfmac/0099-brcmfmac-set-authorized-flag-in-ROAM-event-for-offlo.patch
		patch -p1 < ../patches/cypress/brcmfmac/0100-brcmfmac-allocate-msgbuf-pktid-from-1-to-size-of-pkt.patch
		patch -p1 < ../patches/cypress/brcmfmac/0101-brcmfmac-Add-P2P-Action-Frame-retry-delay-to-fix-GAS.patch
		patch -p1 < ../patches/cypress/brcmfmac/0102-brcmfmac-Use-default-FW-priority-when-EDCA-params-sa.patch
		patch -p1 < ../patches/cypress/brcmfmac/0103-brcmfmac-set-authorized-flag-in-ROAM-event-for-PMK-c.patch
		patch -p1 < ../patches/cypress/brcmfmac/0104-brcmfmac-fix-continuous-802.1x-tx-pending-timeout-er.patch
		patch -p1 < ../patches/cypress/brcmfmac/0105-brcmfmac-add-sleep-in-bus-suspend-and-cfg80211-resum.patch
		patch -p1 < ../patches/cypress/brcmfmac/0106-brcmfmac-fix-43455-CRC-error-under-SDIO-3.0-SDR104-m.patch
		patch -p1 < ../patches/cypress/brcmfmac/0107-brcmfmac-set-F2-blocksize-and-watermark-for-4359.patch
		patch -p1 < ../patches/cypress/brcmfmac/0108-brcmfmac-add-subtype-check-for-event-handling-in-dat.patch
		patch -p1 < ../patches/cypress/brcmfmac/0109-brcmfmac-assure-SSID-length-from-firmware-is-limited.patch
		patch -p1 < ../patches/cypress/brcmfmac/0110-nl80211-add-authorized-flag-to-CONNECT-event.patch
		patch -p1 < ../patches/cypress/brcmfmac/0111-brcmfmac-set-authorized-flag-in-CONNECT-event-for-PM.patch
		patch -p1 < ../patches/cypress/brcmfmac/0112-brcmfmac-add-support-for-Opportunistic-Key-Caching.patch
		patch -p1 < ../patches/cypress/brcmfmac/0113-brcmfmac-reserve-2-credits-for-host-tx-control-path.patch
		patch -p1 < ../patches/cypress/brcmfmac/0114-brcmfmac-update-tx-status-flags-to-sync-with-firmwar.patch
		patch -p1 < ../patches/cypress/brcmfmac/0115-brcmfmac-fix-credit-reserve-for-each-access-category.patch
		patch -p1 < ../patches/cypress/brcmfmac/0116-brcmfmac-fix-throughput-zero-stalls-on-PM-1-mode-due.patch
		patch -p1 < ../patches/cypress/brcmfmac/0117-brcmfmac-43012-Update-MES-Watermark.patch
		patch -p1 < ../patches/cypress/brcmfmac/0118-brcmfmac-add-support-for-CYW89359-SDIO-chipset.patch
		patch -p1 < ../patches/cypress/brcmfmac/0119-brcmfmac-add-CYW43570-PCIE-device.patch
		patch -p1 < ../patches/cypress/brcmfmac/0120-brcmfmac-Use-seq-seq_len-and-set-iv_initialize-when-.patch
		patch -p1 < ../patches/cypress/brcmfmac/0121-brcmfmac-use-actframe_abort-to-cancel-ongoing-action.patch
		patch -p1 < ../patches/cypress/brcmfmac/0122-brcmfmac-fix-scheduling-while-atomic-issue-when-dele.patch
		patch -p1 < ../patches/cypress/brcmfmac/0123-brcmfmac-Increase-message-buffer-packet-size.patch
		patch -p1 < ../patches/cypress/brcmfmac/0124-brcmfmac-coarse-support-for-PCIe-shared-structure-re.patch
		patch -p1 < ../patches/cypress/brcmfmac/0125-brcmfmac-Support-89459-pcie.patch
		patch -p1 < ../patches/cypress/brcmfmac/0126-brcmfmac-Fix-for-unable-to-return-to-visible-SSID.patch
		patch -p1 < ../patches/cypress/brcmfmac/0127-brcmfmac-Fix-for-wrong-disconnection-event-source-in.patch
		patch -p1 < ../patches/cypress/brcmfmac/0128-Revert-brcmfmac-discard-user-space-RSNE-for-SAE-auth.patch
		patch -p1 < ../patches/cypress/brcmfmac/0129-Revert-brcmfmac-add-support-for-SAE-authentication-o.patch
		patch -p1 < ../patches/cypress/brcmfmac/0130-Revert-cfg80211-add-support-for-SAE-authentication-o.patch
		patch -p1 < ../patches/cypress/brcmfmac/0131-non-upstream-update-enum-nl80211_attrs-and-nl80211_e.patch
		patch -p1 < ../patches/cypress/brcmfmac/0132-nl80211-add-support-for-SAE-authentication-offload.patch
		patch -p1 < ../patches/cypress/brcmfmac/0133-brcmfmac-add-support-for-SAE-authentication-offload.patch
		patch -p1 < ../patches/cypress/brcmfmac/0134-brcmfmac-Support-multiple-AP-interfaces-and-fix-STA-.patch
		patch -p1 < ../patches/cypress/brcmfmac/0135-brcmfmac-Support-custom-PCIE-BAR-window-size.patch
		patch -p1 < ../patches/cypress/brcmfmac/0136-brcmfmac-set-F2-blocksize-and-watermark-for-4354.patch
		patch -p1 < ../patches/cypress/brcmfmac/0137-brcmfmac-support-for-virtual-interface-creation-from.patch
		patch -p1 < ../patches/cypress/brcmfmac/0138-nl80211-support-4-way-handshake-offloading-for-WPA-W.patch
		patch -p1 < ../patches/cypress/brcmfmac/0139-brcmfmac-support-4-way-handshake-offloading-for-WPA-.patch
		patch -p1 < ../patches/cypress/brcmfmac/0140-nl80211-support-SAE-authentication-offload-in-AP-mod.patch
		patch -p1 < ../patches/cypress/brcmfmac/0141-brcmfmac-support-SAE-authentication-offload-in-AP-mo.patch
		patch -p1 < ../patches/cypress/brcmfmac/0142-brcmfmac-trigger-memory-dump-upon-firmware-halt-sign.patch
		patch -p1 < ../patches/cypress/brcmfmac/0143-brcmfmac-add-support-for-sysfs-initiated-coredump.patch
		patch -p1 < ../patches/cypress/brcmfmac/0144-brcmfmac-support-repeated-brcmf_fw_alloc_request-cal.patch
		patch -p1 < ../patches/cypress/brcmfmac/0145-brcmfmac-add-a-function-designated-for-handling-firm.patch
		patch -p1 < ../patches/cypress/brcmfmac/0146-brcmfmac-reset-PCIe-bus-on-a-firmware-crash.patch
		patch -p1 < ../patches/cypress/brcmfmac/0147-brcmfmac-add-stub-version-of-brcmf_debugfs_get_devdi.patch
		patch -p1 < ../patches/cypress/brcmfmac/0148-brcmfmac-add-reset-debugfs-entry-for-testing-reset.patch
		patch -p1 < ../patches/cypress/brcmfmac/0149-brcmfmac-reset-SDIO-bus-on-a-firmware-crash.patch
		patch -p1 < ../patches/cypress/brcmfmac/0150-brcmfmac-set-security-after-reiniting-interface.patch
		patch -p1 < ../patches/cypress/brcmfmac/0151-brcmfmac-increase-dcmd-maximum-buffer-size.patch
		patch -p1 < ../patches/cypress/brcmfmac/0152-brcmfmac-set-F2-blocksize-and-watermark-for-4356-SDI.patch
		patch -p1 < ../patches/cypress/brcmfmac/0153-brcmfmac-enable-credit-borrow-all-for-WFA-11n-certs-.patch
		patch -p1 < ../patches/cypress/brcmfmac/0154-brcmfmac-set-net-carrier-on-via-test-tool-for-AP-mod.patch

		#exit 2

		${git_bin} add .
		${git_bin} commit -a -m "cypress fmac patchset" -m "v4.14.77-2020_0115" -s
		${git_bin} format-patch -1 -o ../patches/cypress/

		exit 2
	else
		patch_backports
	fi

	dir 'cypress'
}

reverts () {
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		start_cleanup
	fi

	#https://github.com/torvalds/linux/commit/00f0ea70d2b82b7d7afeb1bdedc9169eb8ea6675
	#
	#Causes bone_capemgr to get stuck on slot 1 and just eventually exit "without" checking slot2/3/4...
	#
	#[    5.406775] bone_capemgr bone_capemgr: Baseboard: 'A335BNLT,00C0,2516BBBK2626'
	#[    5.414178] bone_capemgr bone_capemgr: compatible-baseboard=ti,beaglebone-black - #slots=4
	#[    5.422573] bone_capemgr bone_capemgr: Failed to add slot #1

	dir 'reverts'

	if [ "x${regenerate}" = "xenable" ] ; then
		wdir="reverts"
		number=2
		cleanup
	fi
}

drivers () {
	dir 'drivers/ar1021_i2c'
	dir 'drivers/btrfs'
	dir 'drivers/mcp23s08'
	dir 'drivers/pwm'
	dir 'drivers/snd_pwmsp'
	dir 'drivers/sound'
	dir 'drivers/spi'
	dir 'drivers/ssd1306'
	dir 'drivers/tps65217'
	dir 'drivers/opp'

	#https://github.com/pantoniou/linux-beagle-track-mainline/tree/bbb-overlays
	echo "dir: drivers/ti/bbb_overlays"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		start_cleanup
	fi

	${git} "${DIR}/patches/drivers/ti/bbb_overlays/0001-gitignore-Ignore-DTB-files.patch"

	if [ "x${regenerate}" = "xenable" ] ; then
	${git} "${DIR}/patches/drivers/ti/bbb_overlays/0002-add-PM-firmware.patch"
	${git} "${DIR}/patches/drivers/ti/bbb_overlays/0003-ARM-CUSTOM-Build-a-uImage-with-dtb-already-appended.patch"
	fi

	${git} "${DIR}/patches/drivers/ti/bbb_overlays/0004-omap-Fix-crash-when-omap-device-is-disabled.patch"
	${git} "${DIR}/patches/drivers/ti/bbb_overlays/0005-serial-omap-Fix-port-line-number-without-aliases.patch"
	${git} "${DIR}/patches/drivers/ti/bbb_overlays/0006-tty-omap-serial-Fix-up-platform-data-alloc.patch"
	${git} "${DIR}/patches/drivers/ti/bbb_overlays/0007-of-overlay-kobjectify-overlay-objects.patch"
	${git} "${DIR}/patches/drivers/ti/bbb_overlays/0008-of-overlay-global-sysfs-enable-attribute.patch"
	${git} "${DIR}/patches/drivers/ti/bbb_overlays/0009-Documentation-ABI-overlays-global-attributes.patch"
	${git} "${DIR}/patches/drivers/ti/bbb_overlays/0010-Documentation-document-of_overlay_disable-parameter.patch"
	${git} "${DIR}/patches/drivers/ti/bbb_overlays/0011-of-overlay-add-per-overlay-sysfs-attributes.patch"
	${git} "${DIR}/patches/drivers/ti/bbb_overlays/0012-Documentation-ABI-overlays-per-overlay-docs.patch"
	${git} "${DIR}/patches/drivers/ti/bbb_overlays/0013-of-dynamic-Add-__of_node_dupv.patch"
	${git} "${DIR}/patches/drivers/ti/bbb_overlays/0014-of-changesets-Introduce-changeset-helper-methods.patch"
	${git} "${DIR}/patches/drivers/ti/bbb_overlays/0015-of-changeset-Add-of_changeset_node_move-method.patch"
	${git} "${DIR}/patches/drivers/ti/bbb_overlays/0016-of-unittest-changeset-helpers.patch"
	${git} "${DIR}/patches/drivers/ti/bbb_overlays/0017-OF-DT-Overlay-configfs-interface-v7.patch"
	${git} "${DIR}/patches/drivers/ti/bbb_overlays/0018-ARM-DT-Enable-symbols-when-CONFIG_OF_OVERLAY-is-used.patch"
	${git} "${DIR}/patches/drivers/ti/bbb_overlays/0019-misc-Beaglebone-capemanager.patch"
	${git} "${DIR}/patches/drivers/ti/bbb_overlays/0020-doc-misc-Beaglebone-capemanager-documentation.patch"
	${git} "${DIR}/patches/drivers/ti/bbb_overlays/0021-doc-dt-beaglebone-cape-manager-bindings.patch"
	${git} "${DIR}/patches/drivers/ti/bbb_overlays/0022-doc-ABI-bone_capemgr-sysfs-API.patch"
	${git} "${DIR}/patches/drivers/ti/bbb_overlays/0023-MAINTAINERS-Beaglebone-capemanager-maintainer.patch"

	${git} "${DIR}/patches/drivers/ti/bbb_overlays/0025-of-overlay-Implement-target-index-support.patch"
	${git} "${DIR}/patches/drivers/ti/bbb_overlays/0026-of-unittest-Add-indirect-overlay-target-test.patch"
	${git} "${DIR}/patches/drivers/ti/bbb_overlays/0027-doc-dt-Document-the-indirect-overlay-method.patch"
	${git} "${DIR}/patches/drivers/ti/bbb_overlays/0028-of-overlay-Introduce-target-root-capability.patch"
	${git} "${DIR}/patches/drivers/ti/bbb_overlays/0029-of-unittest-Unit-tests-for-target-root-overlays.patch"
	${git} "${DIR}/patches/drivers/ti/bbb_overlays/0030-doc-dt-Document-the-target-root-overlay-method.patch"
	${git} "${DIR}/patches/drivers/ti/bbb_overlays/0031-RFC-Device-overlay-manager-PCI-USB-DT.patch"
	${git} "${DIR}/patches/drivers/ti/bbb_overlays/0032-of-rename-_node_sysfs-to-_node_post.patch"
	${git} "${DIR}/patches/drivers/ti/bbb_overlays/0033-of-Support-hashtable-lookups-for-phandles.patch"
	${git} "${DIR}/patches/drivers/ti/bbb_overlays/0034-of-unittest-hashed-phandles-unitest.patch"
	${git} "${DIR}/patches/drivers/ti/bbb_overlays/0035-of-overlay-Pick-up-label-symbols-from-overlays.patch"


	if [ "x${regenerate}" = "xenable" ] ; then
	${git} "${DIR}/patches/drivers/ti/bbb_overlays/0036-of-Portable-Device-Tree-connector.patch"
	${git} "${DIR}/patches/drivers/ti/bbb_overlays/0037-boneblack-defconfig.patch"
	fi

	${git} "${DIR}/patches/drivers/ti/bbb_overlays/0038-bone_capemgr-uboot_capemgr_enabled-flag.patch"
	${git} "${DIR}/patches/drivers/ti/bbb_overlays/0039-bone_capemgr-kill-with-uboot-flag.patch"
	${git} "${DIR}/patches/drivers/ti/bbb_overlays/0040-fix-include-linux-of.h-add-linux-slab.h-include.patch"

	if [ "x${regenerate}" = "xenable" ] ; then
		wdir="drivers/ti/bbb_overlays"
		number=40
		cleanup
	fi

	dir 'drivers/ti/cpsw'
	dir 'drivers/ti/etnaviv'
	dir 'drivers/ti/eqep'
	dir 'drivers/ti/rpmsg'
	dir 'drivers/ti/pru_rproc'
	dir 'drivers/ti/serial'
	dir 'drivers/ti/tsc'
	dir 'drivers/ti/uio'
	dir 'drivers/ti/gpio'
	dir 'drivers/uio_pruss_shmem'
	dir 'drivers/greybus'
}

soc () {
	dir 'soc/ti/abbbi'

	dir 'soc/gssi'
	dir 'soc/ti/beagleboneai'
	dir 'bootup_hacks'
	dir 'fixes'
}

###
backports
reverts
drivers
soc

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
		cp -v "${DIR}/3rdparty/readme/jenkins_build.sh" "${DIR}/KERNEL/jenkins_build.sh"
		cp -v "${DIR}/3rdparty/readme/Jenkinsfile" "${DIR}/KERNEL/Jenkinsfile"

		mkdir -p "${DIR}/KERNEL/.github/ISSUE_TEMPLATE/"
		cp -v "${DIR}/3rdparty/readme/bug_report.md" "${DIR}/KERNEL/.github/ISSUE_TEMPLATE/"
		cp -v "${DIR}/3rdparty/readme/FUNDING.yml" "${DIR}/KERNEL/.github/"

		git add -f README.md
		git add -f jenkins_build.sh
		git add -f Jenkinsfile

		git add -f .github/ISSUE_TEMPLATE/bug_report.md
		git add -f .github/FUNDING.yml

		git commit -a -m 'enable: Jenkins: http://gfnd.rcn-ee.org:8080' -s
		git format-patch -1 -o "${DIR}/patches/readme"
		exit 2
	else
		dir 'readme'
	fi
}

packaging
readme
echo "patch.sh ran successfully"

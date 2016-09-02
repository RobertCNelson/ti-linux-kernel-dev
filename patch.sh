#!/bin/sh -e
#
# Copyright (c) 2009-2016 Robert Nelson <robertcnelson@gmail.com>
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

. ${DIR}/version.sh
if [ -f ${DIR}/system.sh ] ; then
	. ${DIR}/system.sh
fi

#Debian 7 (Wheezy): git version 1.7.10.4 and later needs "--no-edit"
unset git_opts
git_no_edit=$(LC_ALL=C git help pull | grep -m 1 -e "--no-edit" || true)
if [ ! "x${git_no_edit}" = "x" ] ; then
	git_opts="--no-edit"
fi

git="git am"
#git_patchset="git://git.ti.com/ti-linux-kernel/ti-linux-kernel.git"
git_patchset="https://github.com/RobertCNelson/ti-linux-kernel.git"
#git_opts

if [ "${RUN_BISECT}" ] ; then
	git="git apply"
fi

echo "Starting patch.sh"

merged_in_4_5="enable"
#unset merged_in_4_5
merged_in_4_6="enable"
#unset merged_in_4_6

git_add () {
	git add .
	git commit -a -m 'testing patchset'
}

start_cleanup () {
	git="git am --whitespace=fix"
}

cleanup () {
	if [ "${number}" ] ; then
		if [ "x${wdir}" = "x" ] ; then
			git format-patch -${number} -o ${DIR}/patches/
		else
			git format-patch -${number} -o ${DIR}/patches/${wdir}/
			unset wdir
		fi
	fi
	exit 2
}

cherrypick () {
	if [ ! -d ../patches/${cherrypick_dir} ] ; then
		mkdir -p ../patches/${cherrypick_dir}
	fi
	git format-patch -1 ${SHA} --start-number ${num} -o ../patches/${cherrypick_dir}
	num=$(($num+1))
}

external_git () {
	git_tag="ti-rt-linux-4.4.y"
	echo "pulling: ${git_tag}"
	git pull ${git_opts} ${git_patchset} ${git_tag}
	#. ${DIR}/.CC
	#sed -i -e 's:linux-kernel:`pwd`/:g' ./ti_config_fragments/defconfig_merge.sh
	#./ti_config_fragments/defconfig_merge.sh -o /dev/null -f ti_config_fragments/defconfig_fragment -c ${CC}
	#git checkout -- ./ti_config_fragments/defconfig_merge.sh

	#make ARCH=arm CROSS_COMPILE="${CC}" appended_omap2plus_defconfig
	#mv -v .config ../patches/ti_omap2plus_defconfig

	#rm -f arch/arm/configs/appended_omap2plus_defconfig
	#rm -f ti_config_fragments/working_config/base_config
	#rm -f ti_config_fragments/working_config/final_config
	#rm -f ti_config_fragments/working_config/merged_omap2plus_defconfig
}

aufs_fail () {
	echo "aufs4 failed"
	exit 2
}

aufs4 () {
	echo "dir: aufs4"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		wget https://raw.githubusercontent.com/sfjro/aufs4-standalone/aufs${KERNEL_REL}/aufs4-kbuild.patch
		patch -p1 < aufs4-kbuild.patch || aufs_fail
		rm -rf aufs4-kbuild.patch
		git add .
		git commit -a -m 'merge: aufs4-kbuild' -s

		wget https://raw.githubusercontent.com/sfjro/aufs4-standalone/aufs${KERNEL_REL}/aufs4-base.patch
		patch -p1 < aufs4-base.patch || aufs_fail
		rm -rf aufs4-base.patch
		git add .
		git commit -a -m 'merge: aufs4-base' -s

		wget https://raw.githubusercontent.com/sfjro/aufs4-standalone/aufs${KERNEL_REL}/aufs4-mmap.patch
		patch -p1 < aufs4-mmap.patch || aufs_fail
		rm -rf aufs4-mmap.patch
		git add .
		git commit -a -m 'merge: aufs4-mmap' -s

		wget https://raw.githubusercontent.com/sfjro/aufs4-standalone/aufs${KERNEL_REL}/aufs4-standalone.patch
		patch -p1 < aufs4-standalone.patch || aufs_fail
		rm -rf aufs4-standalone.patch
		git add .
		git commit -a -m 'merge: aufs4-standalone' -s

		git format-patch -4 -o ../patches/aufs4/
		exit 2
	fi

	${git} "${DIR}/patches/aufs4/0001-merge-aufs4-kbuild.patch"
	${git} "${DIR}/patches/aufs4/0002-merge-aufs4-base.patch"
	${git} "${DIR}/patches/aufs4/0003-merge-aufs4-mmap.patch"
	${git} "${DIR}/patches/aufs4/0004-merge-aufs4-standalone.patch"

	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		echo "dir: aufs4"

		cd ../
		if [ ! -f ./aufs4-standalone ] ; then
			git clone https://github.com/sfjro/aufs4-standalone
			cd ./aufs4-standalone
			git checkout origin/aufs${KERNEL_REL} -b tmp
			cd ../
		fi
		cd ./KERNEL/

		cp -v ../aufs4-standalone/Documentation/ABI/testing/*aufs ./Documentation/ABI/testing/
		mkdir -p ./Documentation/filesystems/aufs/
		cp -rv ../aufs4-standalone/Documentation/filesystems/aufs/* ./Documentation/filesystems/aufs/
		mkdir -p ./fs/aufs/
		cp -v ../aufs4-standalone/fs/aufs/* ./fs/aufs/
		cp -v ../aufs4-standalone/include/uapi/linux/aufs_type.h ./include/uapi/linux/

		git add .
		git commit -a -m 'merge: aufs4' -s
		git format-patch -5 -o ../patches/aufs4/

		exit 2
	fi

	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		start_cleanup
	fi

	${git} "${DIR}/patches/aufs4/0005-merge-aufs4.patch"
	${git} "${DIR}/patches/aufs4/0006-aufs-call-mutex.owner-only-when-DEBUG_MUTEXES-or-MUT.patch"

	if [ "x${regenerate}" = "xenable" ] ; then
		git format-patch -6 -o ../patches/aufs4/
		exit 2
	fi
}

rt_cleanup () {
	echo "rt: needs fixup"
	exit 2
}

rt () {
	echo "dir: rt"
	rt_patch="${KERNEL_REL}${kernel_rt}"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		rm -f localversion-rt
		git add .
		git commit -a -m 'merge: CONFIG_PREEMPT_RT Patch Set' -s
		git format-patch -1 -o ../patches/rt/

		exit 2
	fi

	${git} "${DIR}/patches/rt/0001-merge-CONFIG_PREEMPT_RT-Patch-Set.patch"
}

local_patch () {
	echo "dir: dir"
	${git} "${DIR}/patches/dir/0001-patch.patch"
}

external_git
aufs4
rt
#local_patch

pre_backports () {
	echo "dir: backports/${subsystem}"

	cd ~/linux-src/
	git pull --no-edit https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git master
	git pull --no-edit https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git master --tags
	git pull --no-edit https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master --tags
	if [ ! "x${backport_tag}" = "x" ] ; then
		git checkout ${backport_tag} -b tmp
	fi
	cd -
}

pre_backports_tty () {
	echo "dir: backports/${subsystem}"

	cd ~/linux-src/
	git pull --no-edit https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git master
	git pull --no-edit https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git master --tags
	git pull --no-edit https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master --tags
	if [ ! "x${backport_tag}" = "x" ] ; then
		git checkout ${backport_tag} -b tmp
		git revert --no-edit be7635e7287e0e8013af3c89a6354a9e0182594c
		git revert --no-edit c74ba8b3480da6ddaea17df2263ec09b869ac496
	fi
	cd -
}

post_backports () {
	if [ ! "x${backport_tag}" = "x" ] ; then
		cd ~/linux-src/
		git checkout master -f ; git branch -D tmp
		cd -
	fi

	git add .
	git commit -a -m "backports: ${subsystem}: from: linux.git" -s
	if [ ! -d ../patches/backports/${subsystem}/ ] ; then
		mkdir -p ../patches/backports/${subsystem}/
	fi
	git format-patch -1 -o ../patches/backports/${subsystem}/

	exit 2
}

patch_backports (){
	echo "dir: backports/${subsystem}"
	${git} "${DIR}/patches/backports/${subsystem}/0001-backports-${subsystem}-from-linux.git.patch"
}

lts44_backports () {
	backport_tag="v4.6.7"

	subsystem="tty"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		pre_backports_tty

		rm -rf drivers/tty/serial/nwpserial.c
		rm -rf drivers/tty/serial/of_serial.c

		cp -v ~/linux-src/drivers/of/fdt.c ./drivers/of/fdt.c
		cp -v ~/linux-src/drivers/of/fdt_address.c ./drivers/of/fdt_address.c
		cp -v ~/linux-src/drivers/tty/serial/8250/8250.h ./drivers/tty/serial/8250/
		cp -v ~/linux-src/drivers/tty/serial/8250/8250_*.c ./drivers/tty/serial/8250/
		cp -v ~/linux-src/drivers/tty/serial/8250/Kconfig ./drivers/tty/serial/8250/
		cp -v ~/linux-src/drivers/tty/serial/8250/Makefile ./drivers/tty/serial/8250/
		cp -v ~/linux-src/drivers/tty/serial/8250/serial_cs.c ./drivers/tty/serial/8250/
		cp -v ~/linux-src/drivers/tty/serial/Kconfig ./drivers/tty/serial/
		cp -v ~/linux-src/drivers/tty/serial/Makefile ./drivers/tty/serial/
		cp -v ~/linux-src/drivers/tty/serial/earlycon.c ./drivers/tty/serial/
		cp -v ~/linux-src/include/asm-generic/vmlinux.lds.h ./include/asm-generic/
		cp -v ~/linux-src/include/linux/of_fdt.h ./include/linux/
		cp -v ~/linux-src/include/linux/serial_8250.h ./include/linux/
		cp -v ~/linux-src/include/linux/serial_core.h ./include/linux/
		cp -v ~/linux-src/include/uapi/linux/serial.h ./include/uapi/linux/

		post_backports
	fi
	patch_backports

	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		start_cleanup
	fi

	${git} "${DIR}/patches/backports/tty/0002-rt-Improve-the-serial-console-PASS_LIMIT.patch"

	if [ "x${regenerate}" = "xenable" ] ; then
		git format-patch -2 -o ../patches/backports/tty/
		exit 2
	fi

	backport_tag="v4.7.2"
	subsystem="fbtft"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		pre_backports

		cp -v ~/linux-src/drivers/staging/fbtft/* ./drivers/staging/fbtft/
		cp -v ~/linux-src/include/video/mipi_display.h ./include/video/mipi_display.h

		post_backports
	fi
	patch_backports

	subsystem="i2c"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		pre_backports

		cp -vr ~/linux-src/drivers/i2c/* ./drivers/i2c/
		cp -v  ~/linux-src/include/linux/i2c-mux.h ./include/linux/
		cp -v  ~/linux-src/include/linux/i2c.h ./include/linux/

		post_backports
	fi
	patch_backports

	subsystem="iio"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		pre_backports

		cp -vr ~/linux-src/drivers/iio/* ./drivers/iio/
		cp -vr ~/linux-src/drivers/staging/iio/* ./drivers/staging/iio/
		cp -vr ~/linux-src/include/linux/iio/* ./include/linux/iio/
		cp -v  ~/linux-src/include/linux/mfd/palmas.h ./include/linux/mfd/
		cp -v  ~/linux-src/include/linux/platform_data/ad5761.h ./include/linux/platform_data/
		cp -v  ~/linux-src/include/linux/platform_data/st_sensors_pdata.h ./include/linux/platform_data/
		cp -v  ~/linux-src/include/uapi/linux/iio/types.h ./include/uapi/linux/iio/types.h

		post_backports
	fi
	patch_backports

	subsystem="edt-ft5x06"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		pre_backports

		cp -v ~/linux-src/drivers/input/touchscreen/edt-ft5x06.c ./drivers/input/touchscreen/edt-ft5x06.c

		post_backports
	fi
	patch_backports
	${git} "${DIR}/patches/backports/edt-ft5x06/0002-edt-ft5x06-add-invert_x-invert_y-swap_xy.patch"

	echo "dir: lts44_backports"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		echo "dir: lts44_backports/dmtimer"
		cherrypick_dir="lts44_backports/dmtimer"
		SHA="6604c6556db9e41c85f2839f66bd9d617bcf9f87" ; num="1" ; cherrypick
		SHA="074726402b82f14ca377da0b4a4767674c3d1ff8" ; cherrypick
		SHA="20437f79f6627a31752f422688a6047c25cefcf1" ; cherrypick
		SHA="f8caa792261c0edded20eba2b8fcc899a1b91819" ; cherrypick
		SHA="cd378881426379a62a7fe67f34b8cbe738302022" ; cherrypick
		SHA="7b0883f33809ff0aeca9848193c31629a752bb77" ; cherrypick
		SHA="922201d129c8f9d0c3207dca90ea6ffd8e2242f0" ; cherrypick
		exit 2
	fi

	echo "dir: lts44_backports/dmtimer"
	if [ "x${merged_in_4_5}" = "xenable" ] ; then
		#4.5.0-rc0
		${git} "${DIR}/patches/lts44_backports/dmtimer/0001-pwm-Add-PWM-driver-for-OMAP-using-dual-mode-timers.patch"
		${git} "${DIR}/patches/lts44_backports/dmtimer/0002-pwm-omap-dmtimer-Potential-NULL-dereference-on-error.patch"
		${git} "${DIR}/patches/lts44_backports/dmtimer/0003-ARM-OMAP-Add-PWM-dmtimer-platform-data-quirks.patch"
	fi
	if [ "x${merged_in_4_6}" = "xenable" ] ; then
		#4.6.0-rc0
		${git} "${DIR}/patches/lts44_backports/dmtimer/0004-pwm-omap-dmtimer-Fix-inaccurate-period-and-duty-cycl.patch"
		${git} "${DIR}/patches/lts44_backports/dmtimer/0005-pwm-omap-dmtimer-Add-sanity-checking-for-load-and-ma.patch"
		${git} "${DIR}/patches/lts44_backports/dmtimer/0006-pwm-omap-dmtimer-Round-load-and-match-values-rather-.patch"
		${git} "${DIR}/patches/lts44_backports/dmtimer/0007-pwm-omap-dmtimer-Add-debug-message-for-effective-per.patch"
	fi
}

reverts () {
	echo "dir: reverts"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		start_cleanup
	fi

	${git} "${DIR}/patches/reverts/0001-Revert-spi-spidev-Warn-loudly-if-instantiated-from-D.patch"
	${git} "${DIR}/patches/reverts/0002-Revert-pwm-pwm-tipwmss-Remove-all-pm_runtime-gets-an.patch"
	${git} "${DIR}/patches/reverts/0003-Revert-pwms-pwm-ti-Remove-support-for-local-clock-ga.patch"

	if [ "x${regenerate}" = "xenable" ] ; then
		wdir="reverts"
		number=3
		cleanup
	fi
}

fixes () {
	echo "dir: fixes"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		start_cleanup
	fi

	${git} "${DIR}/patches/fixes/0001-fix-sleep33xx.S-for-thumb2.patch"
	${git} "${DIR}/patches/fixes/0002-fix-sleep43xx.S-for-thumb2.patch"
	${git} "${DIR}/patches/fixes/0003-fix-ti-emif-sram-pm.S-for-thumb2.patch"
	${git} "${DIR}/patches/fixes/0004-net-wireless-SanCloud-wifi-issue-when-associating-wi.patch"

	if [ "x${regenerate}" = "xenable" ] ; then
		wdir="fixes"
		number=4
		cleanup
	fi
}

ti () {
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		echo "dir: ti/iodelay"
		cherrypick_dir="ti/iodelay"
		SHA="d3fecebe6b63c6b49a890b6f70866e2ce6024ae3" ; num="1" ; cherrypick
		SHA="52a607e7c45e44e09f50233384cc352417556966" ; cherrypick
		SHA="7735321423eead6bffce89c8f635b6c66a3052a1" ; cherrypick

		exit 2
	fi

	#is_mainline="enable"
	if [ "x${is_mainline}" = "xenable" ] ; then
		echo "dir: ti/iodelay/"
		#regenerate="enable"
		if [ "x${regenerate}" = "xenable" ] ; then
			start_cleanup
		fi

		${git} "${DIR}/patches/ti/iodelay/0001-pinctrl-bindings-pinctrl-Add-support-for-TI-s-IODela.patch"
		${git} "${DIR}/patches/ti/iodelay/0002-pinctrl-Introduce-TI-IOdelay-configuration-driver.patch"
		${git} "${DIR}/patches/ti/iodelay/0003-ARM-dts-dra7-Add-iodelay-module.patch"

		if [ "x${regenerate}" = "xenable" ] ; then
			number=3
			cleanup
		fi
	fi
	unset is_mainline
}

pru_rpmsg () {
	echo "dir: pru_rpmsg"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		start_cleanup
	fi

	${git} "${DIR}/patches/pru_rpmsg/0001-Fix-remoteproc-to-work-with-the-PRU-GNU-Binutils-por.patch"
#http://git.ti.com/gitweb/?p=ti-linux-kernel/ti-linux-kernel.git;a=commit;h=c2e6cfbcf2aafc77e9c7c8f1a3d45b062bd21876
#	${git} "${DIR}/patches/pru_rpmsg/0002-Add-rpmsg_pru-support.patch"
	${git} "${DIR}/patches/pru_rpmsg/0003-ARM-samples-seccomp-no-m32.patch"

	if [ "x${regenerate}" = "xenable" ] ; then
		number=3
		cleanup
	fi
}

bbb_overlays () {
	echo "dir: bbb_overlays/dtc"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then

		cd ../
		if [ -d dtc ] ; then
			rm -rf dtc
		fi
		git clone https://git.kernel.org/pub/scm/utils/dtc/dtc.git
		cd dtc
		git pull --no-edit https://github.com/RobertCNelson/dtc bb.org-4.1-dt-overlays5-dtc-b06e55c88b9b

		cd ../KERNEL/
		sed -i -e 's:git commit:#git commit:g' ./scripts/dtc/update-dtc-source.sh
		./scripts/dtc/update-dtc-source.sh
		sed -i -e 's:#git commit:git commit:g' ./scripts/dtc/update-dtc-source.sh
		git commit -a -m "scripts/dtc: Update to upstream version overlays" -s
		git format-patch -1 -o ../patches/bbb_overlays/dtc/
		exit 2
	else
		#regenerate="enable"
		if [ "x${regenerate}" = "xenable" ] ; then
			start_cleanup
		fi

		#4.6.0-rc: https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=91feabc2e2240ee80dc8ac08103cb83f497e4d12
		${git} "${DIR}/patches/bbb_overlays/dtc/0001-scripts-dtc-Update-to-upstream-version-overlays.patch"

		if [ "x${regenerate}" = "xenable" ] ; then
			number=1
			cleanup
		fi
	fi

	echo "dir: bbb_overlays/nvmem"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		cherrypick_dir="bbb_overlays/nvmem"
		#merged in 4.6.0-rc0
		SHA="092462c2b52259edba80a6748acb3305f7f70423" ; num="1" ; cherrypick
		SHA="cb54ad6cddb606add2481b82901d69670b480d1b" ; cherrypick
		SHA="c074abe02e5e3479b2dfd109fa2620d22d351c34" ; cherrypick
		SHA="e1379b56e9e88653fcb58cbaa71cd6b1cc304918" ; cherrypick
		SHA="3ca9b1ac28398c6fe0bed335d2d71a35e1c5f7c9" ; cherrypick
		SHA="811b0d6538b9f26f3eb0f90fe4e6118f2480ec6f" ; cherrypick
		SHA="b6c217ab9be6895384cf0b284ace84ad79e5c53b" ; cherrypick
		SHA="57d155506dd5e8f8242d0310d3822c486f70dea7" ; cherrypick
		SHA="3ccea0e1fdf896645f8cccddcfcf60cb289fdf76" ; cherrypick
		SHA="5a99f570dab9f626d3b0b87a4ddf5de8c648aae8" ; cherrypick
		SHA="1c4b6e2c7534b9b193f440f77dd47e420a150288" ; cherrypick
		SHA="bec3c11bad0e7ac05fb90f204d0ab6f79945822b" ; cherrypick
		exit 2
	fi

	if [ "x${merged_in_4_6}" = "xenable" ] ; then
		#merged in 4.6.0-rc0
		${git} "${DIR}/patches/bbb_overlays/nvmem/0001-misc-eeprom-use-kobj_to_dev.patch"
		${git} "${DIR}/patches/bbb_overlays/nvmem/0002-misc-eeprom_93xx46-Fix-16-bit-read-and-write-accesse.patch"
		${git} "${DIR}/patches/bbb_overlays/nvmem/0003-misc-eeprom_93xx46-Implement-eeprom_93xx46-DT-bindin.patch"
		${git} "${DIR}/patches/bbb_overlays/nvmem/0004-misc-eeprom_93xx46-Add-quirks-to-support-Atmel-AT93C.patch"
		${git} "${DIR}/patches/bbb_overlays/nvmem/0005-misc-eeprom_93xx46-Add-support-for-a-GPIO-select-lin.patch"
		${git} "${DIR}/patches/bbb_overlays/nvmem/0006-nvmem-Add-flag-to-export-NVMEM-to-root-only.patch"
		${git} "${DIR}/patches/bbb_overlays/nvmem/0007-nvmem-Add-backwards-compatibility-support-for-older-.patch"
		${git} "${DIR}/patches/bbb_overlays/nvmem/0008-eeprom-at24-extend-driver-to-plug-into-the-NVMEM-fra.patch"
		${git} "${DIR}/patches/bbb_overlays/nvmem/0009-eeprom-at25-Remove-in-kernel-API-for-accessing-the-E.patch"
		${git} "${DIR}/patches/bbb_overlays/nvmem/0010-eeprom-at25-extend-driver-to-plug-into-the-NVMEM-fra.patch"
		${git} "${DIR}/patches/bbb_overlays/nvmem/0011-eeprom-93xx46-extend-driver-to-plug-into-the-NVMEM-f.patch"
		${git} "${DIR}/patches/bbb_overlays/nvmem/0012-misc-at24-replace-memory_accessor-with-nvmem_device_.patch"
	fi

	echo "dir: bbb_overlays/configfs"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		cherrypick_dir="bbb_overlays/configfs"
		#merged in 4.5.0-rc0
		SHA="03607ace807b414eab46323c794b6fb8fcc2d48c" ; num="1" ; cherrypick
		exit 2
	fi

	if [ "x${merged_in_4_5}" = "xenable" ] ; then
		#merged in 4.5.0-rc0
		${git} "${DIR}/patches/bbb_overlays/configfs/0001-configfs-implement-binary-attributes.patch"
	fi

	echo "dir: bbb_overlays/of"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		cherrypick_dir="bbb_overlays/of"
		#merged in 4.5.0-rc0
		SHA="183223770ae8625df8966ed15811d1b3ee8720aa" ; num="1" ; cherrypick
		exit 2
	fi

	if [ "x${merged_in_4_5}" = "xenable" ] ; then
		#merged in 4.5.0-rc0
		${git} "${DIR}/patches/bbb_overlays/of/0001-drivers-of-Export-OF-changeset-functions.patch"
	fi

	echo "dir: bbb_overlays/omap"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		cherrypick_dir="bbb_overlays/omap"
		#merged in 4.5.0-rc6?
		SHA="cf26f1137333251f3515dea31f95775b99df0fd5" ; num="1" ; cherrypick
		exit 2
	fi

	if [ "x${merged_in_4_5}" = "xenable" ] ; then
		#merged in 4.5.0-rc6?
		${git} "${DIR}/patches/bbb_overlays/omap/0001-Revert-ARM-OMAP2-omap_device-fix-crash-on-omap_devic.patch"
		${git} "${DIR}/patches/bbb_overlays/omap/0002-ARM-OMAP2-Fix-omap_device-for-module-reload-on-PM-ru.patch"
	fi

	echo "dir: bbb_overlays"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		start_cleanup
	fi

	${git} "${DIR}/patches/bbb_overlays/0001-OF-DT-Overlay-configfs-interface-v6.patch"
	${git} "${DIR}/patches/bbb_overlays/0002-gitignore-Ignore-DTB-files.patch"

	if [ "x${regenerate}" = "xenable" ] ; then
	${git} "${DIR}/patches/bbb_overlays/0003-add-PM-firmware.patch"
	${git} "${DIR}/patches/bbb_overlays/0004-ARM-CUSTOM-Build-a-uImage-with-dtb-already-appended.patch"
	fi

	#depends on: cf26f1137333251f3515dea31f95775b99df0fd5
	${git} "${DIR}/patches/bbb_overlays/0005-omap-Fix-crash-when-omap-device-is-disabled.patch"

	${git} "${DIR}/patches/bbb_overlays/0006-serial-omap-Fix-port-line-number-without-aliases.patch"
	${git} "${DIR}/patches/bbb_overlays/0007-tty-omap-serial-Fix-up-platform-data-alloc.patch"
	${git} "${DIR}/patches/bbb_overlays/0008-ARM-DT-Enable-symbols-when-CONFIG_OF_OVERLAY-is-used.patch"

	#v4.5.0-rc0 merge...
	#https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=33caf82acf4dc420bf0f0136b886f7b27ecf90c5
	${git} "${DIR}/patches/bbb_overlays/0009-of-Custom-printk-format-specifier-for-device-node.patch"

	#v4.5.0-rc0 (api change):183223770ae8625df8966ed15811d1b3ee8720aa
	${git} "${DIR}/patches/bbb_overlays/0010-of-overlay-kobjectify-overlay-objects.patch"

	${git} "${DIR}/patches/bbb_overlays/0011-of-overlay-global-sysfs-enable-attribute.patch"
	${git} "${DIR}/patches/bbb_overlays/0012-Documentation-ABI-overlays-global-attributes.patch"
	${git} "${DIR}/patches/bbb_overlays/0013-Documentation-document-of_overlay_disable-parameter.patch"

	#v4.5.0-rc0 (api change):183223770ae8625df8966ed15811d1b3ee8720aa
	${git} "${DIR}/patches/bbb_overlays/0014-of-overlay-add-per-overlay-sysfs-attributes.patch"

	${git} "${DIR}/patches/bbb_overlays/0015-Documentation-ABI-overlays-per-overlay-docs.patch"
	${git} "${DIR}/patches/bbb_overlays/0016-misc-Beaglebone-capemanager.patch"
	${git} "${DIR}/patches/bbb_overlays/0017-doc-misc-Beaglebone-capemanager-documentation.patch"
	${git} "${DIR}/patches/bbb_overlays/0018-doc-dt-beaglebone-cape-manager-bindings.patch"
	${git} "${DIR}/patches/bbb_overlays/0019-doc-ABI-bone_capemgr-sysfs-API.patch"
	${git} "${DIR}/patches/bbb_overlays/0020-MAINTAINERS-Beaglebone-capemanager-maintainer.patch"
	${git} "${DIR}/patches/bbb_overlays/0021-arm-dts-Enable-beaglebone-cape-manager.patch"
	${git} "${DIR}/patches/bbb_overlays/0022-of-overlay-Implement-indirect-target-support.patch"
	${git} "${DIR}/patches/bbb_overlays/0023-of-unittest-Add-indirect-overlay-target-test.patch"
	${git} "${DIR}/patches/bbb_overlays/0024-doc-dt-Document-the-indirect-overlay-method.patch"
	${git} "${DIR}/patches/bbb_overlays/0025-of-overlay-Introduce-target-root-capability.patch"
	${git} "${DIR}/patches/bbb_overlays/0026-of-unittest-Unit-tests-for-target-root-overlays.patch"
	${git} "${DIR}/patches/bbb_overlays/0027-doc-dt-Document-the-target-root-overlay-method.patch"
	${git} "${DIR}/patches/bbb_overlays/0028-of-dynamic-Add-__of_node_dupv.patch"

	#v4.5.0-rc0 (api change):183223770ae8625df8966ed15811d1b3ee8720aa
	${git} "${DIR}/patches/bbb_overlays/0029-of-changesets-Introduce-changeset-helper-methods.patch"

	#v4.5.0-rc0 (api change):183223770ae8625df8966ed15811d1b3ee8720aa
	${git} "${DIR}/patches/bbb_overlays/0030-RFC-Device-overlay-manager-PCI-USB-DT.patch"

	if [ "x${regenerate}" = "xenable" ] ; then
	${git} "${DIR}/patches/bbb_overlays/0031-boneblack-defconfig.patch"
	${git} "${DIR}/patches/bbb_overlays/0032-connector-wip.patch"
	fi

	${git} "${DIR}/patches/bbb_overlays/0033-of-remove-bogus-return-in-of_core_init.patch"
	${git} "${DIR}/patches/bbb_overlays/0034-of-Maintainer-fixes-for-dynamic.patch"

	#v4.5.0-rc0 (api change):183223770ae8625df8966ed15811d1b3ee8720aa
	${git} "${DIR}/patches/bbb_overlays/0035-of-unittest-changeset-helpers.patch"

	${git} "${DIR}/patches/bbb_overlays/0036-of-rename-_node_sysfs-to-_node_post.patch"
	${git} "${DIR}/patches/bbb_overlays/0037-of-Support-hashtable-lookups-for-phandles.patch"

	if [ "x${regenerate}" = "xenable" ] ; then
		number=37
		cleanup
	fi
}

dtb_makefile_append () {
	sed -i -e 's:am335x-boneblack.dtb \\:am335x-boneblack.dtb \\\n\t'$device' \\:g' arch/arm/boot/dts/Makefile
}

beaglebone () {
	echo "dir: beaglebone/dts"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		start_cleanup
	fi

	${git} "${DIR}/patches/beaglebone/dts/0001-dts-am335x-bone-common-fixup-leds-to-match-3.8.patch"
	${git} "${DIR}/patches/beaglebone/dts/0002-arm-dts-am335x-bone-common-add-collision-and-carrier.patch"
	${git} "${DIR}/patches/beaglebone/dts/0003-tps65217-Enable-KEY_POWER-press-on-AC-loss-PWR_BUT.patch"
	${git} "${DIR}/patches/beaglebone/dts/0004-am335x-bone-common-disable-default-clkout2_pin.patch"

	if [ "x${regenerate}" = "xenable" ] ; then
		number=4
		cleanup
	fi

	echo "dir: beaglebone/pinmux-helper"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		start_cleanup
	fi

	${git} "${DIR}/patches/beaglebone/pinmux-helper/0001-BeagleBone-pinmux-helper.patch"
	${git} "${DIR}/patches/beaglebone/pinmux-helper/0002-pinmux-helper-Add-runtime-configuration-capability.patch"
	${git} "${DIR}/patches/beaglebone/pinmux-helper/0003-pinmux-helper-Switch-to-using-kmalloc.patch"
	${git} "${DIR}/patches/beaglebone/pinmux-helper/0004-gpio-Introduce-GPIO-OF-helper.patch"
	${git} "${DIR}/patches/beaglebone/pinmux-helper/0005-Add-dir-changeable-property-to-gpio-of-helper.patch"
	${git} "${DIR}/patches/beaglebone/pinmux-helper/0006-am33xx.dtsi-add-ocp-label.patch"
	${git} "${DIR}/patches/beaglebone/pinmux-helper/0007-beaglebone-added-expansion-header-to-dtb.patch"
	${git} "${DIR}/patches/beaglebone/pinmux-helper/0008-bone-pinmux-helper-Add-support-for-mode-device-tree-.patch"
	${git} "${DIR}/patches/beaglebone/pinmux-helper/0009-pinmux-helper-add-P8_37_pinmux-P8_38_pinmux.patch"
	${git} "${DIR}/patches/beaglebone/pinmux-helper/0010-pinmux-helper-hdmi.patch"
	${git} "${DIR}/patches/beaglebone/pinmux-helper/0011-pinmux-helper-can1.patch"
	${git} "${DIR}/patches/beaglebone/pinmux-helper/0012-Remove-CONFIG_EXPERIMENTAL-dependency-on-CONFIG_GPIO.patch"
	${git} "${DIR}/patches/beaglebone/pinmux-helper/0013-pinmux-helper-add-P9_19_pinmux-P9_20_pinmux.patch"
	${git} "${DIR}/patches/beaglebone/pinmux-helper/0014-gpio-of-helper-idr_alloc.patch"

	if [ "x${regenerate}" = "xenable" ] ; then
		number=14
		cleanup
	fi

	echo "dir: beaglebone/eqep"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		start_cleanup
	fi

	${git} "${DIR}/patches/beaglebone/eqep/0001-Provides-a-sysfs-interface-to-the-eQEP-hardware-on-t.patch"
	${git} "${DIR}/patches/beaglebone/eqep/0002-tieqep.c-devres-remove-devm_request_and_ioremap.patch"
	${git} "${DIR}/patches/beaglebone/eqep/0003-tieqep-cleanup.patch"

	if [ "x${regenerate}" = "xenable" ] ; then
		number=3
		cleanup
	fi

	echo "dir: beaglebone/overlays"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		start_cleanup
	fi

	${git} "${DIR}/patches/beaglebone/overlays/0001-am335x-overlays.patch"

	if [ "x${regenerate}" = "xenable" ] ; then
		number=1
		cleanup
	fi

	echo "dir: beaglebone/abbbi"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		start_cleanup
	fi

	${git} "${DIR}/patches/beaglebone/abbbi/0001-gpu-drm-i2c-add-alternative-adv7511-driver-with-audi.patch"
	${git} "${DIR}/patches/beaglebone/abbbi/0002-gpu-drm-i2c-adihdmi-componentize-driver-and-huge-ref.patch"
	${git} "${DIR}/patches/beaglebone/abbbi/0003-adihdmi_drv-reg_default-reg_sequence.patch"
	${git} "${DIR}/patches/beaglebone/abbbi/0004-ARM-dts-add-Arrow-BeagleBone-Black-Industrial-dts.patch"

	if [ "x${regenerate}" = "xenable" ] ; then
		number=4
		cleanup
	fi

	echo "dir: beaglebone/am335x_olimex_som"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		start_cleanup
	fi

	${git} "${DIR}/patches/beaglebone/am335x_olimex_som/0001-ARM-dts-Add-support-for-Olimex-AM3352-SOM.patch"

	if [ "x${regenerate}" = "xenable" ] ; then
		number=1
		cleanup
	fi

	echo "dir: beaglebone/bbgw"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		start_cleanup
	fi

	${git} "${DIR}/patches/beaglebone/bbgw/0001-add-beaglebone-green-wireless.patch"
	${git} "${DIR}/patches/beaglebone/bbgw/0002-am335x-bonegreen-wl1835-bluetooth-audio.patch"

	if [ "x${regenerate}" = "xenable" ] ; then
		wdir="beaglebone/bbgw"
		number=2
		cleanup
	fi

	echo "dir: beaglebone/sancloud"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		start_cleanup
	fi

	${git} "${DIR}/patches/beaglebone/sancloud/0001-add-am335x-sancloud-bbe.patch"

	if [ "x${regenerate}" = "xenable" ] ; then
		number=1
		cleanup
	fi

	echo "dir: beaglebone/bbbw"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		start_cleanup
	fi

	${git} "${DIR}/patches/beaglebone/bbbw/0001-add-bbbw.patch"
	${git} "${DIR}/patches/beaglebone/bbbw/0002-dts-am335x-boneblack-wireless.dts-working.patch"

	if [ "x${regenerate}" = "xenable" ] ; then
		number=2
		cleanup
	fi

	echo "dir: beaglebone/tre"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		start_cleanup
	fi

	${git} "${DIR}/patches/beaglebone/tre/0001-add-am335x-arduino-tre.dts.patch"

	if [ "x${regenerate}" = "xenable" ] ; then
		number=1
		cleanup
	fi

	#echo "dir: beaglebone/CTAG"
	#regenerate="enable"
	#if [ "x${regenerate}" = "xenable" ] ; then
	#	start_cleanup
	#fi

	#${git} "${DIR}/patches/beaglebone/CTAG/0001-Added-driver-and-device-tree-for-CTAG-face2-4-Audio-.patch"
	#${git} "${DIR}/patches/beaglebone/CTAG/0002-Added-support-for-higher-sampling-rates-in-AD193X-dr.patch"
	#${git} "${DIR}/patches/beaglebone/CTAG/0003-Added-support-for-AD193X-and-CTAG-face2-4-Audio-Card.patch"
	#${git} "${DIR}/patches/beaglebone/CTAG/0004-Modified-ASOC-platform-driver-for-McASP-to-use-async.patch"
	#${git} "${DIR}/patches/beaglebone/CTAG/0005-Changed-descriptions-in-files-belonging-to-CTAG-face.patch"
	#${git} "${DIR}/patches/beaglebone/CTAG/0006-add-black-version-of-ctag-face-pass-uboot-cape-ctag-.patch"

	#if [ "x${regenerate}" = "xenable" ] ; then
	#	number=6
	#	cleanup
	#fi

	echo "dir: beaglebone/capes"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		start_cleanup
	fi

	${git} "${DIR}/patches/beaglebone/capes/0001-cape-Argus-UPS-cape-support.patch"
	${git} "${DIR}/patches/beaglebone/capes/0002-ARM-dts-am335x-boneblack-enable-wl1835mod-cape-suppo.patch"
	${git} "${DIR}/patches/beaglebone/capes/0003-am335x-boneblack-wl1835mod-fix-bluetooth.patch"
	${git} "${DIR}/patches/beaglebone/capes/0004-add-am335x-boneblack-bbbmini.dts.patch"
	${git} "${DIR}/patches/beaglebone/capes/0005-add-lcd-am335x-boneblack-bbb-exp-c.dtb-am335x-bonebl.patch"
	${git} "${DIR}/patches/beaglebone/capes/0006-bb-audio-cape.patch"

	if [ "x${regenerate}" = "xenable" ] ; then
		wdir="beaglebone/capes"
		number=6
		cleanup
	fi

	echo "dir: beaglebone/mctrl_gpio"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		start_cleanup
	fi
		${git} "${DIR}/patches/beaglebone/mctrl_gpio/0001-tty-serial-8250-make-UART_MCR-register-access-consis.patch"
		${git} "${DIR}/patches/beaglebone/mctrl_gpio/0002-serial-mctrl_gpio-add-modem-control-read-routine.patch"
		${git} "${DIR}/patches/beaglebone/mctrl_gpio/0003-serial-mctrl_gpio-add-IRQ-locking.patch"

	if [ "x${regenerate}" = "xenable" ] ; then
		wdir="beaglebone/mctrl_gpio"
		number=3
		cleanup
	fi

	echo "dir: beaglebone/jtag"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		start_cleanup
	fi

	${git} "${DIR}/patches/beaglebone/jtag/0001-add-jtag-clock-pinmux.patch"

	if [ "x${regenerate}" = "xenable" ] ; then
		number=1
		cleanup
	fi

	echo "dir: beaglebone/wl18xx"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		start_cleanup
	fi

	${git} "${DIR}/patches/beaglebone/wl18xx/0001-add-wilink8-bt.patch"
	${git} "${DIR}/patches/beaglebone/wl18xx/0002-wl18xx-forward-port-from-v4.1.x-ti.patch"

	if [ "x${regenerate}" = "xenable" ] ; then
		wdir="beaglebone/wl18xx"
		number=2
		cleanup
	fi

	echo "dir: beaglebone/pru"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		start_cleanup
	fi

	${git} "${DIR}/patches/beaglebone/pru/0001-pruss-choose-rproc-or-uio.patch"

	if [ "x${regenerate}" = "xenable" ] ; then
		wdir="beaglebone/pru"
		number=1
		cleanup
	fi

	echo "dir: beaglebone/vsc8531bbb"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		start_cleanup
	fi

	#https://git.kernel.org/cgit/linux/kernel/git/stable/linux-stable.git/log/net/core/ethtool.c?id=refs/tags/v4.4.15
	#https://git.kernel.org/cgit/linux/kernel/git/stable/linux-stable.git/log/net/core/ethtool.c?id=refs/tags/v4.5.7

	${git} "${DIR}/patches/beaglebone/vsc8531bbb/0001-sctp-Rename-NETIF_F_SCTP_CSUM-to-NETIF_F_SCTP_CRC.patch"
	${git} "${DIR}/patches/beaglebone/vsc8531bbb/0002-net-Rename-NETIF_F_ALL_CSUM-to-NETIF_F_CSUM_MASK.patch"
	${git} "${DIR}/patches/beaglebone/vsc8531bbb/0003-ethtool-Add-phy-statistics.patch"

	#https://git.kernel.org/cgit/linux/kernel/git/stable/linux-stable.git/log/net/core/ethtool.c?id=refs/tags/v4.6.4

	${git} "${DIR}/patches/beaglebone/vsc8531bbb/0004-ethtool-Declare-netdev_rss_key-as-__read_mostly.patch"
	${git} "${DIR}/patches/beaglebone/vsc8531bbb/0005-ethtool-correctly-ensure-GS-CHANNELS-doesn-t-conflic.patch"
	${git} "${DIR}/patches/beaglebone/vsc8531bbb/0006-ethtool-ensure-channel-counts-are-within-bounds-duri.patch"
	${git} "${DIR}/patches/beaglebone/vsc8531bbb/0007-net-add-tc-offload-feature-flag.patch"
	${git} "${DIR}/patches/beaglebone/vsc8531bbb/0008-net-ethtool-introduce-a-new-ioctl-for-per-queue-sett.patch"
	${git} "${DIR}/patches/beaglebone/vsc8531bbb/0009-net-ethtool-support-get-coalesce-per-queue.patch"
	${git} "${DIR}/patches/beaglebone/vsc8531bbb/0010-net-ethtool-support-set-coalesce-per-queue.patch"
	${git} "${DIR}/patches/beaglebone/vsc8531bbb/0011-net-ethtool-add-new-ETHTOOL_xLINKSETTINGS-API.patch"
	${git} "${DIR}/patches/beaglebone/vsc8531bbb/0012-ethtool-Set-cmd-field-in-ETHTOOL_GLINKSETTINGS-respo.patch"

	#board:

	${git} "${DIR}/patches/beaglebone/vsc8531bbb/0013-add-am335x-vsc8531bbb.patch"

	${git} "${DIR}/patches/beaglebone/vsc8531bbb/0014-lib-bitmap.c-conversion-routines-to-from-u32-array.patch"

	if [ "x${regenerate}" = "xenable" ] ; then
		wdir="beaglebone/vsc8531bbb"
		number=14
		cleanup
	fi

	#This has to be last...
	echo "dir: beaglebone/dtbs"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		patch -p1 < "${DIR}/patches/beaglebone/dtbs/0001-sync-am335x-peripheral-pinmux.patch"
		exit 2
	fi

	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		start_cleanup
	fi

	${git} "${DIR}/patches/beaglebone/dtbs/0001-sync-am335x-peripheral-pinmux.patch"

	if [ "x${regenerate}" = "xenable" ] ; then
		number=1
		cleanup
	fi

	####
	#dtb makefile
	echo "dir: beaglebone/generated"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then

		device="am335x-boneblack-emmc-overlay.dtb" ; dtb_makefile_append
		device="am335x-boneblack-hdmi-overlay.dtb" ; dtb_makefile_append
		device="am335x-boneblack-nhdmi-overlay.dtb" ; dtb_makefile_append
		device="am335x-boneblack-overlay.dtb" ; dtb_makefile_append
		device="am335x-bonegreen-overlay.dtb" ; dtb_makefile_append

		device="am335x-abbbi.dtb" ; dtb_makefile_append

		device="am335x-olimex-som.dtb" ; dtb_makefile_append

		device="am335x-bonegreen-wireless.dtb" ; dtb_makefile_append

		device="am335x-arduino-tre.dtb" ; dtb_makefile_append

		device="am335x-bone-cape-bone-argus.dtb" ; dtb_makefile_append
		device="am335x-boneblack-cape-bone-argus.dtb" ; dtb_makefile_append
		device="am335x-boneblack-wl1835mod.dtb" ; dtb_makefile_append
		device="am335x-boneblack-wireless.dtb" ; dtb_makefile_append
		device="am335x-boneblack-bbbmini.dtb" ; dtb_makefile_append
		device="am335x-boneblack-bbb-exp-c.dtb" ; dtb_makefile_append
		device="am335x-boneblack-bbb-exp-r.dtb" ; dtb_makefile_append
		device="am335x-boneblack-audio.dtb" ; dtb_makefile_append

		device="am335x-sancloud-bbe.dtb" ; dtb_makefile_append

		#device="am335x-boneblack-ctag-face.dtb" ; dtb_makefile_append
		#device="am335x-bonegreen-ctag-face.dtb" ; dtb_makefile_append

		device="am335x-vsc8531bbb.dtb" ; dtb_makefile_append

		git commit -a -m 'auto generated: capes: add dtbs to makefile' -s
		git format-patch -1 -o ../patches/beaglebone/generated/
		exit 2
	else
		${git} "${DIR}/patches/beaglebone/generated/0001-auto-generated-capes-add-dtbs-to-makefile.patch"
	fi

	echo "dir: beaglebone/phy"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		start_cleanup
	fi

	${git} "${DIR}/patches/beaglebone/phy/0001-cpsw-search-for-phy.patch"

	if [ "x${regenerate}" = "xenable" ] ; then
		number=1
		cleanup
	fi

	echo "dir: beaglebone/firmware"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		start_cleanup
	fi

	#http://git.ti.com/gitweb/?p=ti-cm3-pm-firmware/amx3-cm3.git;a=summary
	#git clone git://git.ti.com/ti-cm3-pm-firmware/amx3-cm3.git
	#cd amx3-cm3/
	#git checkout origin/ti-v4.1.y -b tmp

	#commit 730f0695ca2dda65abcff5763e8f108517bc0d43
	#Author: Dave Gerlach <d-gerlach@ti.com>
	#Date:   Wed Mar 4 21:34:54 2015 -0600
	#
	#    CM3: Bump firmware release to 0x191
	#    
	#    This version, 0x191, includes the following changes:
	#         - Add trace output on boot for kernel remoteproc driver
	#         - Fix resouce table as RSC_INTMEM is no longer used in kernel
	#         - Add header dependency checking
	#    
	#    Signed-off-by: Dave Gerlach <d-gerlach@ti.com>

	#cp -v bin/am* /opt/github/linux-dev/KERNEL/firmware/

	#git add -f ./firmware/am*

	${git} "${DIR}/patches/beaglebone/firmware/0001-add-am33x-firmware.patch"

	if [ "x${regenerate}" = "xenable" ] ; then
		number=1
		cleanup
	fi
}

x15 () {
	echo "dir: x15/fixes"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		start_cleanup
	fi

	${git} "${DIR}/patches/x15/fixes/0001-x15-mmc-cmem-debugss.patch"
	${git} "${DIR}/patches/x15/fixes/0002-x15-cmem-keep-this-formating.patch"
	${git} "${DIR}/patches/x15/fixes/0003-x15-add-eeprom.patch"
	${git} "${DIR}/patches/x15/fixes/0004-mmc-block-Use-the-mmc-host-device-index-as-the-mmcbl.patch"

	if [ "x${regenerate}" = "xenable" ] ; then
		number=4
		cleanup
	fi
}

quieter () {
	echo "dir: quieter"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		start_cleanup
	fi

	#quiet some hide obvious things...
	${git} "${DIR}/patches/quieter/0001-quiet-8250_omap.c-use-pr_info-over-pr_err.patch"
	${git} "${DIR}/patches/quieter/0002-quiet-wlcore.patch"

	if [ "x${regenerate}" = "xenable" ] ; then
		wdir="quieter"
		number=2
		cleanup
	fi
}

###
lts44_backports
reverts
fixes
ti
pru_rpmsg
bbb_overlays
beaglebone
x15
quieter

packaging () {
	echo "dir: packaging"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		cp -v "${DIR}/3rdparty/packaging/builddeb" "${DIR}/KERNEL/scripts/package"
		#v4.8.0-rc1+
		if [ ! -d "${DIR}/KERNEL/scripts/gcc-plugins/" ] ; then
			sed -i -e 's:(cd $objtree; find scripts/gcc-plugins:#(cd $objtree; find scripts/gcc-plugins:g' "${DIR}/KERNEL/scripts/package/builddeb"
		fi
		git commit -a -m 'packaging: sync builddeb changes' -s
		git format-patch -1 -o "${DIR}/patches/packaging"
		exit 2
	else
		${git} "${DIR}/patches/packaging/0001-packaging-sync-builddeb-changes.patch"
	fi
}

travis () {
	echo "dir: travis"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		cp -v "${DIR}/3rdparty/travis/.travis.yml" "${DIR}/KERNEL/.travis.yml"
		git add -f .travis.yml
		cp -v "${DIR}/3rdparty/travis/build_deb_in_arm_chroot.sh" "${DIR}/KERNEL/"
		git add  -f build_deb_in_arm_chroot.sh
		git commit -a -m 'enable: travis: https://travis-ci.org/beagleboard/linux' -s
		git format-patch -1 -o "${DIR}/patches/travis"
		exit 2
	else
		${git} "${DIR}/patches/travis/0001-enable-travis-https-travis-ci.org-beagleboard-linux.patch"
	fi
}

packaging
travis
echo "patch.sh ran successfully"

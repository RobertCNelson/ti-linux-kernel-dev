#!/bin/bash -e
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

merged_in_4_5="enable"
#unset merged_in_4_5
merged_in_4_6="enable"
#unset merged_in_4_6

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
	git_tag="ti-rt-linux-4.4.y"
	echo "pulling: ${git_tag}"
	${git_bin} pull --no-edit ${git_patchset} ${git_tag}
	if [ ! "x${ti_git_post}" = "x" ] ; then
		${git_bin} checkout master -f
		test_for_branch=$(${git_bin} branch --list "v${KERNEL_TAG}${BUILD}")
		if [ "x${test_for_branch}" != "x" ] ; then
			${git_bin} branch "v${KERNEL_TAG}${BUILD}" -D
		fi
		${git_bin} checkout ${ti_git_post} -b v${KERNEL_TAG}${BUILD} -f
	fi
	${git_bin} describe
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
		${git_bin} add .
		${git_bin} commit -a -m 'merge: aufs4-kbuild' -s

		wget https://raw.githubusercontent.com/sfjro/aufs4-standalone/aufs${KERNEL_REL}/aufs4-base.patch
		patch -p1 < aufs4-base.patch || aufs_fail
		rm -rf aufs4-base.patch
		${git_bin} add .
		${git_bin} commit -a -m 'merge: aufs4-base' -s

		wget https://raw.githubusercontent.com/sfjro/aufs4-standalone/aufs${KERNEL_REL}/aufs4-mmap.patch
		patch -p1 < aufs4-mmap.patch || aufs_fail
		rm -rf aufs4-mmap.patch
		${git_bin} add .
		${git_bin} commit -a -m 'merge: aufs4-mmap' -s

		wget https://raw.githubusercontent.com/sfjro/aufs4-standalone/aufs${KERNEL_REL}/aufs4-standalone.patch
		patch -p1 < aufs4-standalone.patch || aufs_fail
		rm -rf aufs4-standalone.patch
		${git_bin} add .
		${git_bin} commit -a -m 'merge: aufs4-standalone' -s

		${git_bin} format-patch -4 -o ../patches/aufs4/

		cd ../
		if [ ! -d ./aufs4-standalone ] ; then
			${git_bin} clone https://github.com/sfjro/aufs4-standalone
			cd ./aufs4-standalone
			${git_bin} checkout origin/aufs${KERNEL_REL} -b tmp
			cd ../
		else
			rm -rf ./aufs4-standalone || true
			${git_bin} clone https://github.com/sfjro/aufs4-standalone
			cd ./aufs4-standalone
			${git_bin} checkout origin/aufs${KERNEL_REL} -b tmp
			cd ../
		fi
		cd ./KERNEL/

		cp -v ../aufs4-standalone/Documentation/ABI/testing/*aufs ./Documentation/ABI/testing/
		mkdir -p ./Documentation/filesystems/aufs/
		cp -rv ../aufs4-standalone/Documentation/filesystems/aufs/* ./Documentation/filesystems/aufs/
		mkdir -p ./fs/aufs/
		cp -v ../aufs4-standalone/fs/aufs/* ./fs/aufs/
		cp -v ../aufs4-standalone/include/uapi/linux/aufs_type.h ./include/uapi/linux/

		${git_bin} add .
		${git_bin} commit -a -m 'merge: aufs4' -s
		${git_bin} format-patch -5 -o ../patches/aufs4/

		exit 2
	fi

	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		start_cleanup
	fi

	${git} "${DIR}/patches/aufs4/0001-merge-aufs4-kbuild.patch"
	${git} "${DIR}/patches/aufs4/0002-merge-aufs4-base.patch"
	${git} "${DIR}/patches/aufs4/0003-merge-aufs4-mmap.patch"
	${git} "${DIR}/patches/aufs4/0004-merge-aufs4-standalone.patch"
	${git} "${DIR}/patches/aufs4/0005-merge-aufs4.patch"
	${git} "${DIR}/patches/aufs4/0006-aufs-call-mutex.owner-only-when-DEBUG_MUTEXES-or-MUT.patch"

	if [ "x${regenerate}" = "xenable" ] ; then
		wdir="aufs4"
		number=6
		cleanup
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
		${git_bin} add .
		${git_bin} commit -a -m 'merge: CONFIG_PREEMPT_RT Patch Set' -s
		${git_bin} format-patch -1 -o ../patches/rt/

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
	${git_bin} pull --no-edit https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git master
	${git_bin} pull --no-edit https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git master --tags
	${git_bin} pull --no-edit https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master --tags
	if [ ! "x${backport_tag}" = "x" ] ; then
		${git_bin} checkout ${backport_tag} -b tmp
	fi
	cd -
}

pre_backports_tty () {
	echo "dir: backports/${subsystem}"

	cd ~/linux-src/
	${git_bin} pull --no-edit https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git master
	${git_bin} pull --no-edit https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git master --tags
	${git_bin} pull --no-edit https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master --tags
	if [ ! "x${backport_tag}" = "x" ] ; then
		${git_bin} checkout ${backport_tag} -b tmp
		${git_bin} revert --no-edit be7635e7287e0e8013af3c89a6354a9e0182594c
		${git_bin} revert --no-edit c74ba8b3480da6ddaea17df2263ec09b869ac496
	fi
	cd -
}

post_backports () {
	if [ ! "x${backport_tag}" = "x" ] ; then
		cd ~/linux-src/
		${git_bin} checkout master -f ; ${git_bin} branch -D tmp
		cd -
	fi

	${git_bin} add .
	${git_bin} commit -a -m "backports: ${subsystem}: from: linux.git" -s
	if [ ! -d ../patches/backports/${subsystem}/ ] ; then
		mkdir -p ../patches/backports/${subsystem}/
	fi
	${git_bin} format-patch -1 -o ../patches/backports/${subsystem}/

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
	${git} "${DIR}/patches/backports/tty/0003-serial-8250-omap-Enable-UART-module-wakeup-based-on-.patch"

	if [ "x${regenerate}" = "xenable" ] ; then
		wdir="backports/tty"
		number=3
		cleanup
	fi

	backport_tag="v4.7.10"
	subsystem="i2c"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		pre_backports

		cp -v  ~/linux-src/drivers/i2c/i2c-mux.c ./drivers/i2c/
		cp -v  ~/linux-src/drivers/i2c/i2c-core.c ./drivers/i2c/
		cp -v  ~/linux-src/drivers/i2c/busses/i2c-omap.c ./drivers/i2c/busses/
		cp -v  ~/linux-src/drivers/i2c/muxes/i2c-mux-pca954x.c ./drivers/i2c/muxes/
		cp -v  ~/linux-src/drivers/i2c/muxes/i2c-mux-pinctrl.c ./drivers/i2c/muxes/
		cp -v  ~/linux-src/drivers/i2c/muxes/i2c-arb-gpio-challenge.c ./drivers/i2c/muxes/
		cp -v  ~/linux-src/include/linux/i2c.h ./include/linux/
		cp -v  ~/linux-src/include/linux/i2c-mux.h ./include/linux/

		post_backports
	fi
	patch_backports

	backport_tag="v4.8.12"
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

		cp -v  ~/linux-src/include/linux/mfd/ti_am335x_tscadc.h ./include/linux/mfd/ti_am335x_tscadc.h
		cp -v  ~/linux-src/drivers/mfd/ti_am335x_tscadc.c ./drivers/mfd/ti_am335x_tscadc.c
		cp -v  ~/linux-src/drivers/input/touchscreen/ti_am335x_tsc.c ./drivers/input/touchscreen/ti_am335x_tsc.c

		post_backports
	fi
	patch_backports

	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		start_cleanup
	fi

#	${git} "${DIR}/patches/backports/iio/0002-mfd-ti_am335x_tscadc-store-physical-address.patch"
#	${git} "${DIR}/patches/backports/iio/0003-drivers-iio-ti_am335x_adc-add-dma-support.patch"
#	${git} "${DIR}/patches/backports/iio/0004-ARM-dts-am33xx-add-DMA-properties-for-tscadc.patch"
#	${git} "${DIR}/patches/backports/iio/0005-ARM-dts-am4372-add-DMA-properties-for-tscadc.patch"
	${git} "${DIR}/patches/backports/iio/0006-kernel-time-timekeeping.c-get_monotonic_coarse64.patch"

	if [ "x${regenerate}" = "xenable" ] ; then
		wdir="backports/iio"
		number=6
		cleanup
	fi

	backport_tag="v4.9-rc7"

	subsystem="fbtft"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		pre_backports

		cp -v ~/linux-src/drivers/staging/fbtft/* ./drivers/staging/fbtft/
		cp -v ~/linux-src/include/video/mipi_display.h ./include/video/mipi_display.h

		post_backports
	fi
	patch_backports

	subsystem="touchscreen"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		pre_backports

		cp -v ~/linux-src/drivers/input/touchscreen/edt-ft5x06.c ./drivers/input/touchscreen/
		cp -v ~/linux-src/drivers/input/touchscreen/of_touchscreen.c ./drivers/input/touchscreen/
		cp -v ~/linux-src/drivers/input/touchscreen/pixcir_i2c_ts.c ./drivers/input/touchscreen/
		cp -v ~/linux-src/drivers/input/touchscreen/tsc200x-core.c ./drivers/input/touchscreen/
		cp -v ~/linux-src/include/linux/input/touchscreen.h ./include/linux/input/

		post_backports
	fi
	patch_backports

	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		start_cleanup
	fi

	${git} "${DIR}/patches/backports/touchscreen/0002-edt-ft5x06-we-need-these-in-v4.4.x.patch"
	${git} "${DIR}/patches/backports/touchscreen/0003-ar1021_i2c-invert-swap.patch"

	if [ "x${regenerate}" = "xenable" ] ; then
		wdir="backports/touchscreen"
		number=3
		cleanup
	fi

	subsystem="etnaviv"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		pre_backports

		cp -vr ~/linux-src/drivers/gpu/drm/etnaviv/ ./drivers/gpu/drm/etnaviv/
		cp -v ~/linux-src/include/uapi/drm/etnaviv_drm.h ./include/uapi/drm/etnaviv_drm.h

		post_backports
	fi
	patch_backports

	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		start_cleanup
	fi

	${git} "${DIR}/patches/backports/etnaviv/0002-drm-etnaviv-add-initial-etnaviv-DRM-driver.patch"
	${git} "${DIR}/patches/backports/etnaviv/0003-etnaviv-enable-for-ARCH_OMAP2PLUS.patch"
	${git} "${DIR}/patches/backports/etnaviv/0004-drm-etnaviv-julbouln-diff.patch"

	if [ "x${regenerate}" = "xenable" ] ; then
		wdir="backports/etnaviv"
		number=4
		cleanup
	fi

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

	echo "dir: reverts/tilcdc"
#	regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		start_cleanup
	fi

	#https://github.com/RobertCNelson/ti-linux-kernel/compare/64796e7f597d7f17bbcfa18242dbf1a3da839131...5fac424a36a240576b5ac97fa6e282c36cb0d144
	#git revert --no-edit 4dc7dcabe8e570d2ffad688efbc3d97113ca55f8
	#git revert --no-edit 91931688a4340b0bc6464549acf098010ca9a0ad
	#git revert --no-edit 299676e72141eeefe92df628c0410ee08724f4cb
	#git revert --no-edit 76806845b80e027365e761d5e754e4d414467bcb
	#git revert --no-edit 0892292020aef30a0b30353a454ae2f2d7012b1e
	#git revert --no-edit 10ca4f3505f61d0308a31f77561f1eda6508f555
	#6

	#git revert --no-edit 984edb0692a9d66284e974a6faf9c5bf7bfab5d6
	#git revert --no-edit 9f6aed18943bec61859ea3d7550766850ba27473
	#git revert --no-edit e34e57aed8d958082e57c58c8a7dc1dcf704e3ff
	#git revert --no-edit dccd567228ca225afd99009b647a25a61234fa62
	#git revert --no-edit d8ff0c63fbcb702f9c95b33a9134164e70a781be
	#git revert --no-edit e462accdc4d2aa177ecc2a1cbcfee1eaa56f21b5
	#12

	#git revert --no-edit bcf7ab1c48206234412ec63c692b41507bbbe4e2
	#git revert --no-edit 76fb2b46e6ea135b9bc0a3cf643c5c7ed3a25a85
	#git revert --no-edit 6db644b05e317e094992273f1589be45990996aa
	#git revert --no-edit 91df99d4ec325265b882d4320349b6ffcd4a7b1d
	#git revert --no-edit 6b49c65a386fa82a8deb49cc18cd34c5137dd35b

	#git revert --no-edit f63f2c8187cc10f552bde1469ee6abeb8db3a9d0
	#git revert --no-edit 86928354e4501d1872d067b5dfd7a5bcb8add0dc
	#git revert --no-edit a4e7a1ef617d1bc4b37f8a297095abdf3f3589c3
	#git revert --no-edit 1757f7e91ea58229fee10e04d3a8c61267f6e625
	#git revert --no-edit db464d1548c794f5082e75245064341cac6d960e

	#git revert --no-edit ebbd1c9764a66f4eeb2ee327a03b96bcbeba6327
	#git revert --no-edit 83822fb79ea6bb6bbb4a5800e23752e6c6a781e2
	#git revert --no-edit 7262f5d93dbbeab26a55a57abf0ff753b91850d5
	#git revert --no-edit e8cb1f8fcd44c603811000e7bfcfccc72ed8ed07
	#git revert --no-edit 65eab9aed1883b65d71e7c6482644d3e767c1e47

	#git revert --no-edit e6cbc0437dbdb6a9cb63610d50b20a6313235c90
	#git revert --no-edit 8ff2aeb1b77b3e2ba614993c9e0bda69701fc821
	#git revert --no-edit 10986125f55ea3b7b7a6aabef99d775a741ea47a
	#git revert --no-edit c20b8aa249e0c75b3b028c80b2c7fdb716f19135
	#git revert --no-edit 29635ffbeacd06a4813fdcde54e996c1ad7e952e

	#git revert --no-edit d234b3a18ac6acc9a41fd5695008717080c55aab
	#git revert --no-edit 23534af4f90e0125f08fca1fe6a60fafd14291f1
	#git revert --no-edit 71c33d253f2a04fdf0f5e5e33c6b9a2444924d89

	#git format-patch -35 -o ../patches/compare

	${git} "${DIR}/patches/reverts/tilcdc/0001-Revert-drm-tilcdc-WARN-if-CRTC-is-touched-without-CR.patch"
	${git} "${DIR}/patches/reverts/tilcdc/0002-Revert-drm-tilcdc-Take-CRTC-lock-when-calling-tilcdc.patch"
	${git} "${DIR}/patches/reverts/tilcdc/0003-Revert-drm-tilcdc-Remove-unnecessary-tilcdc_crtc_dis.patch"
	${git} "${DIR}/patches/reverts/tilcdc/0004-Revert-drm-tilcdc-Flush-flip-work-workqueue-before-d.patch"
	${git} "${DIR}/patches/reverts/tilcdc/0005-Revert-drm-tilcdc-Clean-up-LCDC-functional-clock-rat.patch"
	${git} "${DIR}/patches/reverts/tilcdc/0006-Revert-drm-tilcdc-Take-crtc-modeset-lock-while-updat.patch"
	${git} "${DIR}/patches/reverts/tilcdc/0007-Revert-drm-tilcdc-Choose-console-BPP-that-supports-R.patch"
	${git} "${DIR}/patches/reverts/tilcdc/0008-Revert-drm-tilcdc-Add-blue-and-red-crossed-devicetre.patch"
	${git} "${DIR}/patches/reverts/tilcdc/0009-Revert-drm-tilcdc-Write-DMA-base-and-ceiling-address.patch"
	${git} "${DIR}/patches/reverts/tilcdc/0010-Revert-drm-tilcdc-Enable-EOF-interrupts-for-v1-LCDC.patch"
	${git} "${DIR}/patches/reverts/tilcdc/0011-Revert-drm-tilcdc-Adjust-the-FB_CEILING-address.patch"
	${git} "${DIR}/patches/reverts/tilcdc/0012-Revert-drm-tilcdc-Fix-check-for-remote-port-parent.patch"
	${git} "${DIR}/patches/reverts/tilcdc/0013-Revert-drm-tilcdc-Change-tilcdc_crtc_page_flip-to-ti.patch"
	${git} "${DIR}/patches/reverts/tilcdc/0014-Revert-drm-tilcdc-Remove-unnecessary-pm_runtime_get-.patch"
	${git} "${DIR}/patches/reverts/tilcdc/0015-Revert-drm-tilcdc-Get-rid-of-legacy-dpms-mechanism.patch"
	${git} "${DIR}/patches/reverts/tilcdc/0016-Revert-drm-tilcdc-Use-drm_atomic_helper_resume-suspe.patch"
	${git} "${DIR}/patches/reverts/tilcdc/0017-Revert-drm-tilcdc-Enable-and-disable-interrupts-in-c.patch"
	${git} "${DIR}/patches/reverts/tilcdc/0018-Revert-drm-tilcdc-tfp410-Add-atomic-modeset-helpers-.patch"
	${git} "${DIR}/patches/reverts/tilcdc/0019-Revert-drm-tilcdc-tfp410-Set-crtc-panel-info-at-init.patch"
	${git} "${DIR}/patches/reverts/tilcdc/0020-Revert-drm-tilcdc-panel-Add-atomic-modeset-helpers-t.patch"
	${git} "${DIR}/patches/reverts/tilcdc/0021-Revert-drm-tilcdc-panel-Set-crtc-panel-info-at-init-.patch"
	${git} "${DIR}/patches/reverts/tilcdc/0022-Revert-drm-tilcdc-Remove-tilcdc_verify_fb.patch"
	${git} "${DIR}/patches/reverts/tilcdc/0023-Revert-drm-tilcdc-Remove-obsolete-crtc-helper-functi.patch"
	${git} "${DIR}/patches/reverts/tilcdc/0024-Revert-drm-tilcdc-Set-DRIVER_ATOMIC-and-use-atomic-c.patch"
	${git} "${DIR}/patches/reverts/tilcdc/0025-Revert-drm-tilcdc-Add-drm_mode_config_reset-call-to-.patch"
	${git} "${DIR}/patches/reverts/tilcdc/0026-Revert-drm-tilcdc-Add-atomic-mode-config-funcs.patch"
	${git} "${DIR}/patches/reverts/tilcdc/0027-Revert-drm-tilcdc-Add-tilcdc_crtc_atomic_check.patch"
	${git} "${DIR}/patches/reverts/tilcdc/0028-Revert-drm-tilcdc-Add-tilcdc_crtc_mode_set_nofb.patch"
	${git} "${DIR}/patches/reverts/tilcdc/0029-Revert-drm-tilcdc-Initialize-dummy-primary-plane-fro.patch"
	${git} "${DIR}/patches/reverts/tilcdc/0030-Revert-drm-tilcdc-Add-dummy-primary-plane-implementa.patch"
	${git} "${DIR}/patches/reverts/tilcdc/0031-Revert-drm-tilcdc-Make-tilcdc_crtc_page_flip-work-if.patch"
	${git} "${DIR}/patches/reverts/tilcdc/0032-Revert-drm-tilcdc-Make-tilcdc_crtc_page_flip-public.patch"
	${git} "${DIR}/patches/reverts/tilcdc/0033-Revert-drm-tilcdc-Fix-tilcdc-component-master-unload.patch"
	${git} "${DIR}/patches/reverts/tilcdc/0034-Revert-drm-i2c-tda998x-Choose-between-atomic-or-non-.patch"
	${git} "${DIR}/patches/reverts/tilcdc/0035-Revert-drm-i2c-tda998x-Add-support-for-atomic-modese.patch"

	if [ "x${regenerate}" = "xenable" ] ; then
		wdir="reverts/tilcdc"
		number=35
		cleanup
	fi

	dir 'reverts/pwm'
}

drivers () {
	dir 'drivers/tsl2550'
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
	dir 'beaglebone/dts'
	dir 'beaglebone/pinmux-helper'
	dir 'beaglebone/eqep'
	dir 'beaglebone/overlays'
	dir 'beaglebone/abbbi'
	dir 'beaglebone/am335x_olimex_som'
	dir 'beaglebone/bbgw'
	dir 'beaglebone/sancloud'
	dir 'beaglebone/bbbw'
	dir 'beaglebone/blue'
	dir 'beaglebone/tre'
	dir 'beaglebone/sirius'
	dir 'beaglebone/ctag'
	dir 'beaglebone/capes'
	dir 'beaglebone/mctrl_gpio'
	dir 'beaglebone/jtag'
	dir 'beaglebone/wl18xx'
	dir 'beaglebone/pru'

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
	${git} "${DIR}/patches/beaglebone/vsc8531bbb/0015-ti-cpsw-priv-cpsw-slaves.patch"

	if [ "x${regenerate}" = "xenable" ] ; then
		wdir="beaglebone/vsc8531bbb"
		number=15
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
		wdir="beaglebone/dtbs"
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
		device="am335x-boneblack-wireless-emmc-overlay.dtb" ; dtb_makefile_append
		device="am335x-boneblack-bbbmini.dtb" ; dtb_makefile_append
		device="am335x-boneblack-bbb-exp-c.dtb" ; dtb_makefile_append
		device="am335x-boneblack-bbb-exp-r.dtb" ; dtb_makefile_append
		device="am335x-boneblack-audio.dtb" ; dtb_makefile_append

		device="am335x-boneblue.dtb" ; dtb_makefile_append
		device="am335x-boneblack-roboticscape.dtb" ; dtb_makefile_append
		device="am335x-boneblack-wireless-roboticscape.dtb" ; dtb_makefile_append

		device="am335x-sancloud-bbe.dtb" ; dtb_makefile_append

		device="am335x-boneblack-ctag-face.dtb" ; dtb_makefile_append
		device="am335x-bonegreen-ctag-face.dtb" ; dtb_makefile_append

		device="am335x-vsc8531bbb.dtb" ; dtb_makefile_append
		device="am335x-boneblack-lcd-ct43.dtb" ; dtb_makefile_append

		#already defined once...
		#device="am57xx-beagle-x15-ctag.dtb" ; dtb_makefile_append
		device="am57xx-beagle-x15-revb1-ctag.dtb" ; dtb_makefile_append

		device="am335x-siriusDEB.dtb" ; dtb_makefile_append

		git commit -a -m 'auto generated: capes: add dtbs to makefile' -s
		git format-patch -1 -o ../patches/beaglebone/generated/
		exit 2
	else
		${git} "${DIR}/patches/beaglebone/generated/0001-auto-generated-capes-add-dtbs-to-makefile.patch"
	fi

	dir 'beaglebone/phy'

	echo "dir: beaglebone/firmware"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		start_cleanup
	fi

	#http://git.ti.com/gitweb/?p=processor-firmware/ti-amx3-cm3-pm-firmware.git;a=summary
	#git clone git://git.ti.com/processor-firmware/ti-amx3-cm3-pm-firmware.git

	#cd ti-amx3-cm3-pm-firmware/
	#git checkout origin/ti-v4.1.y-next -b tmp

	#commit ee4acf427055d7e87d9d1d82296cbd05e388642e
	#Author: Dave Gerlach <d-gerlach@ti.com>
	#Date:   Tue Sep 6 14:33:11 2016 -0500
	#
	#    CM3: Firmware release 0x192
	#    
	#    This version, 0x192, includes the following changes:
	#         - Fix DDR IO CTRL handling during suspend so both am335x and am437x
	#           use optimal low power state and restore the exact previous
	#           configuration.
	#        - Explicitly configure PER state in standby, even though it is
	#           configured to ON state to ensure proper state.
	#         - Add new 'halt' flag in IPC_REG4 bit 11 to allow HLOS to configure
	#           the suspend path to wait immediately before suspending the system
	#           entirely to allow JTAG visiblity for debug.
	#         - Fix board voltage scaling binaries i2c speed configuration in
	#           order to properly configure 100khz operation.
	#    
	#    Signed-off-by: Dave Gerlach <d-gerlach@ti.com>

	#cp -v bin/am* /opt/github/bb.org/ti-4.4/normal/KERNEL/firmware/

	#git add -f ./firmware/am*

	${git} "${DIR}/patches/beaglebone/firmware/0001-add-am33x-firmware.patch"

	if [ "x${regenerate}" = "xenable" ] ; then
		number=1
		cleanup
	fi
}

###
lts44_backports
reverts
drivers
dir 'fixes'
ti
pru_rpmsg
bbb_overlays
beaglebone
dir 'x15/fixes'
dir 'brcmfmac'
dir 'quieter'

packaging () {
	echo "dir: packaging"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		cp -v "${DIR}/3rdparty/packaging/builddeb" "${DIR}/KERNEL/scripts/package"
		${git_bin} commit -a -m 'packaging: sync builddeb changes' -s
		${git_bin} format-patch -1 -o "${DIR}/patches/packaging"
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
		cp -v "${DIR}/3rdparty/travis/build_on_x86.sh" "${DIR}/KERNEL/"
		git add -f build_*.sh
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

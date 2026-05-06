#!/bin/bash -e

# SPDX-FileCopyrightText: 2009 Robert Nelson <robertcnelson@gmail.com>
#
# SPDX-License-Identifier: MIT

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
git_patchset="https://github.com/TexasInstruments/ti-linux-kernel.git"
if [ "${USE_LOCAL_GIT_MIRROR}" ] ; then
	git_patchset="http://forgejo.gfnd.rcn-ee.org:3000/TexasInstruments/ti-linux-kernel.git"
fi
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
	if [ ! "x${sdk_git_new_release}" = "x" ] ; then
		${git_bin} checkout master -f
		test_for_branch=$(${git_bin} branch --list "v${KERNEL_TAG}${BUILD}")
		if [ "x${test_for_branch}" != "x" ] ; then
			${git_bin} branch "v${KERNEL_TAG}${BUILD}" -D
		fi
		${git_bin} checkout ${sdk_git_new_release} -b v${KERNEL_TAG}${BUILD} -f
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

mainline_patches () {
	#exit 2
#	dir 'mainline/greybus'
	dir 'rfc/mainline'
	dir 'mainline/pocketbeagle2'
	#exit 2
}

wpanusb () {
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		cd ../
		if [ -d ./wpanusb ] ; then
			rm -rf ./wpanusb || true
		fi

		${git_bin} clone https://openbeagle.org/beagleconnect/linux/wpanusb.git --depth=1
		cd ./wpanusb
			wpanusb_hash=$(git rev-parse HEAD)
		cd -

		cd ./KERNEL/

		cp -v ../wpanusb/wpanusb.h drivers/net/ieee802154/
		cp -v ../wpanusb/wpanusb.c drivers/net/ieee802154/

		${git_bin} add .
		${git_bin} commit -a -m 'merge: wpanusb: https://git.beagleboard.org/beagleconnect/linux/wpanusb' -m "https://openbeagle.org/beagleconnect/linux/wpanusb/-/commit/${wpanusb_hash}" -s
		${git_bin} format-patch -1 -o ../patches/external/wpanusb/

		rm -rf ../wpanusb/ || true

		${git_bin} reset --hard HEAD~1

		start_cleanup

		${git} "${DIR}/patches/external/wpanusb/0001-merge-wpanusb-https-git.beagleboard.org-beagleconnec.patch"

		wdir="external/wpanusb"
		number=1
		cleanup
	fi
	dir 'external/wpanusb'
}

rt_cleanup () {
	echo "rt: needs fixup"
	exit 2
}

rt () {
	#rt_enable="enable"
	if [ "x${rt_enable}" = "xenable" ] ; then
		rt_patch="${KERNEL_REL}${kernel_rt}"

		#${git_bin} revert --no-edit xyz

		#regenerate="enable"
		if [ "x${regenerate}" = "xenable" ] ; then
			wget -c https://mirrors.edge.kernel.org/pub/linux/kernel/projects/rt/${KERNEL_REL}/older/patch-${rt_patch}.patch.xz
			xzcat patch-${rt_patch}.patch.xz | patch -p1 || rt_cleanup
			rm -f patch-${rt_patch}.patch.xz
			rm -f localversion-rt
 			rm -rf drivers/tty/serial/8250/8250_omap.c.orig || true
			rm -rf include/linux/netdevice.h.orig || true
			${git_bin} add .
			${git_bin} commit -a -m 'merge: CONFIG_PREEMPT_RT Patch Set' -m "patch-${rt_patch}.patch.xz" -s
			${git_bin} format-patch -1 -o ../patches/external/rt/
			#echo "RT: patch-${rt_patch}.patch.xz" > ../patches/external/git/RT

			exit 2
		fi
		dir 'external/rt'
	fi
}

wireless_regdb () {
	#https://git.kernel.org/pub/scm/linux/kernel/git/wens/wireless-regdb.git
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		cd ../
		if [ -d ./src ] ; then
			rm -rf ./src || true
		fi

		wget -c https://git.kernel.org/pub/scm/linux/kernel/git/wens/wireless-regdb.git/snapshot/wireless-regdb-master-${WIRELESS_REGDB}.tar.gz
		mkdir ./src/
		tar xf wireless-regdb-master-${WIRELESS_REGDB}.tar.gz -C ./src/
		sync
		rm -rf wireless-regdb-master-${WIRELESS_REGDB}.tar.gz

		cd ./KERNEL/

		mkdir -p ./firmware/ || true
		cp -v ../src/wireless-regdb-master-${WIRELESS_REGDB}/regulatory.db ./firmware/
		cp -v ../src/wireless-regdb-master-${WIRELESS_REGDB}/regulatory.db.p7s ./firmware/
		${git_bin} add -f ./firmware/regulatory.*

		${git_bin} commit -a -m 'Add wireless-regdb regulatory database file' -m "https://git.kernel.org/pub/scm/linux/kernel/git/wens/wireless-regdb.git/tag/?h=master-${WIRELESS_REGDB}" -s

		${git_bin} format-patch -1 -o ../patches/external/wireless_regdb/
		echo "WIRELESS_REGDB: https://git.kernel.org/pub/scm/linux/kernel/git/wens/wireless-regdb.git/tag/?h=master-${WIRELESS_REGDB}" > ../patches/external/git/WIRELESS_REGDB

		rm -rf ../src/ || true

		${git_bin} reset --hard HEAD^

		start_cleanup

		${git} "${DIR}/patches/external/wireless_regdb/0001-Add-wireless-regdb-regulatory-database-file.patch"

		wdir="external/wireless_regdb"
		number=1
		cleanup
	fi
	dir 'external/wireless_regdb'
}

cleanup_dts_builds () {
	rm -rf arch/arm/boot/dts/modules.order || true
	rm -rf arch/arm/boot/dts/.*cmd || true
	rm -rf arch/arm/boot/dts/.*tmp || true
	rm -rf arch/arm/boot/dts/*dtb || true
	rm -rf arch/arm/boot/dts/*dtbo || true
	rm -rf arch/arm64/boot/dts/ti/modules.order || true
	rm -rf arch/arm64/boot/dts/ti/.*cmd || true
	rm -rf arch/arm64/boot/dts/ti/.*tmp || true
	rm -rf arch/arm64/boot/dts/ti/*dtb || true
	rm -rf arch/arm64/boot/dts/ti/*dtbo || true
}

omap_makefile_patch_of_overlays () {
	cat arch/arm/boot/dts/ti/omap/Makefile  | grep -v '#'> arch/arm/boot/dts/ti/omap/Makefile.bak
	echo "# SPDX-License-Identifier: GPL-2.0" > arch/arm/boot/dts/ti/omap/Makefile
	echo "" >> arch/arm/boot/dts/ti/omap/Makefile
	echo "ifeq (\$(CONFIG_OF_OVERLAY),y)" >> arch/arm/boot/dts/ti/omap/Makefile
	echo "DTC_FLAGS += -@" >> arch/arm/boot/dts/ti/omap/Makefile
	echo "endif" >> arch/arm/boot/dts/ti/omap/Makefile
	echo "" >> arch/arm/boot/dts/ti/omap/Makefile
	cat arch/arm/boot/dts/ti/omap/Makefile.bak >> arch/arm/boot/dts/ti/omap/Makefile
	rm -rf arch/arm/boot/dts/ti/omap/Makefile.bak
}

arm_dtb_makefile_append () {
	sed -i -e 's:am335x-boneblack.dtb \\:am335x-boneblack.dtb \\\n\t'$device' \\:g' arch/arm/boot/dts/ti/omap/Makefile
}

arm_dtbo_makefile_append () {
	if [ -f ../${work_dir}/src/arm/overlays/${device}.dtso ] ; then
		sed -i -e 's:am335x-boneblack.dtb \\:am335x-boneblack.dtb \\\n\t'$device'.dtbo \\:g' arch/arm/boot/dts/ti/omap/Makefile
		cp -v ../${work_dir}/src/arm/overlays/${device}.dtso arch/arm/boot/dts/ti/omap/${device}.dtso
	else
		echo "Missing [${device}]"
	fi
}

k3_dtb_makefile_append () {
	echo "dtb-\$(CONFIG_ARCH_K3) += $device" >> arch/arm64/boot/dts/ti/Makefile
}

k3_dtbo_makefile_append () {
	if [ -f ../${work_dir}/src/arm64/overlays/${device}.dtso ] ; then
		echo "dtb-\$(CONFIG_ARCH_K3) += $device.dtbo" >> arch/arm64/boot/dts/ti/Makefile
		cp -v ../${work_dir}/src/arm64/overlays/${device}.dtso arch/arm64/boot/dts/ti/${device}.dtso
		sed -i -e 's:ti/k3-:k3-:g' arch/arm64/boot/dts/ti/${device}.dtso
	else
		echo "Missing [${device}]"
	fi
}

k3_makefile_patch_cleanup_overlays () {
	cat arch/arm64/boot/dts/ti/Makefile | grep -v 'DTC_FLAGS_k3' | grep -v '# Enable' > arch/arm64/boot/dts/ti/Makefile.bak
	cat arch/arm64/boot/dts/ti/Makefile | grep 'DTC_FLAGS_k3' > arch/arm64/boot/dts/ti/Makefile.dtc
	rm arch/arm64/boot/dts/ti/Makefile
	mv arch/arm64/boot/dts/ti/Makefile.bak arch/arm64/boot/dts/ti/Makefile
	echo "" >> arch/arm64/boot/dts/ti/Makefile
	echo "# Enable support for device-tree overlays" >> arch/arm64/boot/dts/ti/Makefile
	cat arch/arm64/boot/dts/ti/Makefile.dtc >> arch/arm64/boot/dts/ti/Makefile
	rm arch/arm64/boot/dts/ti/Makefile.dtc
	echo "DTC_FLAGS_k3-am62-pocketbeagle2 += -@" >> arch/arm64/boot/dts/ti/Makefile
	echo "DTC_FLAGS_k3-am6232-pocketbeagle2 += -@" >> arch/arm64/boot/dts/ti/Makefile
	echo "DTC_FLAGS_k3-am67a-beagley-ai += -@" >> arch/arm64/boot/dts/ti/Makefile
	echo "DTC_FLAGS_k3-j721e-beagleboneai64 += -@" >> arch/arm64/boot/dts/ti/Makefile
}

beagleboard_dtbs () {
	branch="v6.6.x-Beagle"
	https_repo="https://github.com/beagleboard/BeagleBoard-DeviceTrees.git"
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
		rm -rf arch/arm/boot/dts/ti/omap/overlays/ || true
		rm -rf arch/arm64/boot/dts/ti/overlays/ || true
		omap_makefile_patch_of_overlays

		cp -v ../${work_dir}/src/arm/ti/omap/*.dts arch/arm/boot/dts/ti/omap/
		cp -v ../${work_dir}/src/arm/ti/omap/*.dtsi arch/arm/boot/dts/ti/omap/
		cp -v ../${work_dir}/src/arm64/ti/*.dts arch/arm64/boot/dts/ti/
		cp -v ../${work_dir}/src/arm64/ti/*.dtsi arch/arm64/boot/dts/ti/
		cp -v ../${work_dir}/src/arm64/ti/*.h arch/arm64/boot/dts/ti/
		cp -vr ../${work_dir}/include/dt-bindings/* ./include/dt-bindings/

		#ls ../${work_dir}/src/arm/overlays/ | grep dtso
		#exit 2

		device="AM3359-PWM012" ; arm_dtbo_makefile_append
		device="AM335X-PRU-UIO-00A0" ; arm_dtbo_makefile_append
		device="BB-ADC-00A0" ; arm_dtbo_makefile_append
		device="BB-BBBW-WL1835-00A0" ; arm_dtbo_makefile_append
		device="BB-BBGG-WL1835-00A0" ; arm_dtbo_makefile_append
		device="BB-BBGW-WL1835-00A0" ; arm_dtbo_makefile_append
		device="BB-BONE-4D5R-01-00A1" ; arm_dtbo_makefile_append
		device="BB-BONE-LCD4-01-00A1" ; arm_dtbo_makefile_append
		device="BB-BONE-NH7C-01-A0" ; arm_dtbo_makefile_append
		device="BB-BONE-eMMC1-01-00A0" ; arm_dtbo_makefile_append
		device="BB-CAN0-00A0" ; arm_dtbo_makefile_append
		device="BB-CAN1-00A0" ; arm_dtbo_makefile_append
		device="BB-CAPE-DISP-CT4-00A0" ; arm_dtbo_makefile_append
		device="BB-EHRPWM0-P9_29-P9_31" ; arm_dtbo_makefile_append
		device="BB-EHRPWM1-P9_14-P9_16" ; arm_dtbo_makefile_append
		device="BB-EHRPWM2-P8_13-P8_19" ; arm_dtbo_makefile_append
		device="BB-EQEP0" ; arm_dtbo_makefile_append
		device="BB-EQEP1" ; arm_dtbo_makefile_append
		device="BB-EQEP2B" ; arm_dtbo_makefile_append
		device="BB-EQEP2" ; arm_dtbo_makefile_append
		device="BB-GREEN-HDMI-00A0" ; arm_dtbo_makefile_append
		device="BB-HDMI-IT66121-00A0" ; arm_dtbo_makefile_append
		device="BB-HDMI-IT66122-00A0" ; arm_dtbo_makefile_append
		device="BB-HDMI-TDA998x-00A0" ; arm_dtbo_makefile_append
		device="BB-I2C1-00A0" ; arm_dtbo_makefile_append
		device="BB-I2C1-FAST-00A0" ; arm_dtbo_makefile_append
		device="BB-I2C1-MCP7940X-00A0" ; arm_dtbo_makefile_append
		device="BB-I2C1-RTC-DS3231" ; arm_dtbo_makefile_append
		device="BB-I2C1-RTC-PCF8563" ; arm_dtbo_makefile_append
		device="BB-I2C2-00A0" ; arm_dtbo_makefile_append
		device="BB-I2C2-BME680" ; arm_dtbo_makefile_append
		device="BB-I2C2-FAST-00A0" ; arm_dtbo_makefile_append
		device="BB-I2C2-MCP7940X-00A0" ; arm_dtbo_makefile_append
		device="BB-I2C2-MPU6050" ; arm_dtbo_makefile_append
		device="BB-I2C2-RTC-DS3231" ; arm_dtbo_makefile_append
		device="BB-LCD-ADAFRUIT-24-SPI1-00A0" ; arm_dtbo_makefile_append
		device="BB-NHDMI-IT66121-00A0" ; arm_dtbo_makefile_append
		device="BB-NHDMI-IT66122-00A0" ; arm_dtbo_makefile_append
		device="BB-NHDMI-TDA998x-00A0" ; arm_dtbo_makefile_append
		device="BBORG_COMMS-00A2" ; arm_dtbo_makefile_append
		device="BBORG_FAN-A000" ; arm_dtbo_makefile_append
		device="BBORG_RELAY-00A2" ; arm_dtbo_makefile_append
		device="BB-SPIDEV0-00A0" ; arm_dtbo_makefile_append
		device="BB-SPIDEV1-00A0" ; arm_dtbo_makefile_append
		device="BB-UART1-00A0" ; arm_dtbo_makefile_append
		device="BB-UART2-00A0" ; arm_dtbo_makefile_append
		device="BB-UART4-00A0" ; arm_dtbo_makefile_append
		device="BB-UART5-00A0" ; arm_dtbo_makefile_append
		device="BB-W1-P9.12-00A0" ; arm_dtbo_makefile_append
		device="BONE-ADC" ; arm_dtbo_makefile_append
		device="BONE-LED-P8-37" ; arm_dtbo_makefile_append
		device="BONE-LED-P9-19" ; arm_dtbo_makefile_append
		device="BONE-LED-P9-42" ; arm_dtbo_makefile_append
		device="M-BB-BBG-00A0" ; arm_dtbo_makefile_append
		device="M-BB-BBGG-00A0" ; arm_dtbo_makefile_append
		device="PB-MIKROBUS-0" ; arm_dtbo_makefile_append
		device="PB-MIKROBUS-1" ; arm_dtbo_makefile_append

		device="am335x-boneblack-uboot.dtb" ; arm_dtb_makefile_append
		device="am335x-boneblack-revd.dtb" ; arm_dtb_makefile_append

		#device="am335x-sancloud-bbe-uboot.dtb" ; arm_dtb_makefile_append
		#device="am335x-sancloud-bbe-lite-uboot.dtb" ; arm_dtb_makefile_append
		#device="am335x-sancloud-bbe-extended-wifi-uboot.dtb" ; arm_dtb_makefile_append

		#device="k3-am625-beagleplay-cc33xx.dtb" ; k3_dtb_makefile_append
		#device="k3-j721e-beagleboneai64-no-shared-mem.dtb" ; k3_dtb_makefile_append

		device="k3-am6232-pocketbeagle2.dtb" ; k3_dtb_makefile_append

		#ls src/arm64/overlays/ | grep pocketbeagle2

		device="k3-am6232-pocketbeagle2-techlab-cape" ; k3_dtbo_makefile_append
		device="k3-am62-pocketbeagle2-ardupilot-cape" ; k3_dtbo_makefile_append
		device="k3-am62-pocketbeagle2-led-all" ; k3_dtbo_makefile_append
		device="k3-am62-pocketbeagle2-leds-off" ; k3_dtbo_makefile_append
		device="k3-am62-pocketbeagle2-mspm0swd" ; k3_dtbo_makefile_append
		device="k3-am62-pocketbeagle2-pru0-out" ; k3_dtbo_makefile_append
		device="k3-am62-pocketbeagle2-techlab-cape" ; k3_dtbo_makefile_append

		#ls src/arm64/overlays/ | grep beagleplay

		device="k3-am625-beagleplay-bcfserial-no-firmware" ; k3_dtbo_makefile_append

		#ls src/arm64/overlays/ | grep beaglemod

		device="k3-am625-beaglemod-audio" ; k3_dtbo_makefile_append
		device="k3-am625-beaglemod-can0" ; k3_dtbo_makefile_append
		device="k3-am625-beaglemod-can1" ; k3_dtbo_makefile_append
		device="k3-am625-beaglemod-csi0-ov5640" ; k3_dtbo_makefile_append
		device="k3-am625-beaglemod-eeprom" ; k3_dtbo_makefile_append
		device="k3-am625-beaglemod-eth" ; k3_dtbo_makefile_append
		device="k3-am625-beaglemod-hdmi" ; k3_dtbo_makefile_append
		device="k3-am625-beaglemod-io-expand" ; k3_dtbo_makefile_append
		device="k3-am625-beaglemod-lt-lcd185" ; k3_dtbo_makefile_append
		device="k3-am625-beaglemod-ospi-flash" ; k3_dtbo_makefile_append
		device="k3-am625-beaglemod-rs485-1" ; k3_dtbo_makefile_append
		device="k3-am625-beaglemod-rs485-2" ; k3_dtbo_makefile_append
		device="k3-am625-beaglemod-rtc" ; k3_dtbo_makefile_append
		device="k3-am625-beaglemod-wl1835" ; k3_dtbo_makefile_append

		device="k3-am67a-beagley-ai.dtb" ; k3_dtb_makefile_append

		#ls src/arm64/overlays/ | grep beagley

		device="k3-am67a-beagley-ai-csi0-imx219" ; k3_dtbo_makefile_append
		device="k3-am67a-beagley-ai-csi0-ov5640" ; k3_dtbo_makefile_append
		device="k3-am67a-beagley-ai-csi1-imx219" ; k3_dtbo_makefile_append
		device="k3-am67a-beagley-ai-dsi-rpi-7inch-panel" ; k3_dtbo_makefile_append
		device="k3-am67a-beagley-ai-hdmi-dss0-dpi1" ; k3_dtbo_makefile_append
		device="k3-am67a-beagley-ai-i2c1-400000" ; k3_dtbo_makefile_append
		device="k3-am67a-beagley-ai-i2c1-ads1115" ; k3_dtbo_makefile_append
		device="k3-am67a-beagley-ai-i2c1-rtc-rv3028" ; k3_dtbo_makefile_append
		device="k3-am67a-beagley-ai-i2c1-ssd1306" ; k3_dtbo_makefile_append
		device="k3-am67a-beagley-ai-lincolntech-185lcd-panel" ; k3_dtbo_makefile_append
		device="k3-am67a-beagley-ai-mikroe-eth" ; k3_dtbo_makefile_append
		device="k3-am67a-beagley-ai-mikroe-microsd" ; k3_dtbo_makefile_append
		device="k3-am67a-beagley-ai-pps-gpio18" ; k3_dtbo_makefile_append
		device="k3-am67a-beagley-ai-pwm-ecap0-gpio12" ; k3_dtbo_makefile_append
		device="k3-am67a-beagley-ai-pwm-ecap1-gpio16" ; k3_dtbo_makefile_append
		device="k3-am67a-beagley-ai-pwm-ecap1-gpio21" ; k3_dtbo_makefile_append
		device="k3-am67a-beagley-ai-pwm-ecap2-gpio17" ; k3_dtbo_makefile_append
		device="k3-am67a-beagley-ai-pwm-ecap2-gpio18" ; k3_dtbo_makefile_append
		device="k3-am67a-beagley-ai-pwm-epwm0-gpio12" ; k3_dtbo_makefile_append
		device="k3-am67a-beagley-ai-pwm-epwm0-gpio14" ; k3_dtbo_makefile_append
		device="k3-am67a-beagley-ai-pwm-epwm0-gpio15" ; k3_dtbo_makefile_append
		device="k3-am67a-beagley-ai-pwm-epwm0-gpio15-gpio12" ; k3_dtbo_makefile_append
		device="k3-am67a-beagley-ai-pwm-epwm0-gpio15-gpio14" ; k3_dtbo_makefile_append
		device="k3-am67a-beagley-ai-pwm-epwm0-gpio5" ; k3_dtbo_makefile_append
		device="k3-am67a-beagley-ai-pwm-epwm0-gpio5-gpio12" ; k3_dtbo_makefile_append
		device="k3-am67a-beagley-ai-pwm-epwm0-gpio5-gpio14" ; k3_dtbo_makefile_append
		device="k3-am67a-beagley-ai-pwm-epwm1-gpio13" ; k3_dtbo_makefile_append
		device="k3-am67a-beagley-ai-pwm-epwm1-gpio20" ; k3_dtbo_makefile_append
		device="k3-am67a-beagley-ai-pwm-epwm1-gpio21" ; k3_dtbo_makefile_append
		device="k3-am67a-beagley-ai-pwm-epwm1-gpio21-gpio13" ; k3_dtbo_makefile_append
		device="k3-am67a-beagley-ai-pwm-epwm1-gpio21-gpio20" ; k3_dtbo_makefile_append
		device="k3-am67a-beagley-ai-pwm-epwm1-gpio6" ; k3_dtbo_makefile_append
		device="k3-am67a-beagley-ai-pwm-epwm1-gpio6-gpio13" ; k3_dtbo_makefile_append
		device="k3-am67a-beagley-ai-pwm-epwm1-gpio6-gpio20" ; k3_dtbo_makefile_append
		device="k3-am67a-beagley-ai-spi0-1cs" ; k3_dtbo_makefile_append
		device="k3-am67a-beagley-ai-spi0-2cs" ; k3_dtbo_makefile_append
		device="k3-am67a-beagley-ai-spidev0" ; k3_dtbo_makefile_append
		device="k3-am67a-beagley-ai-uart-ttyama0" ; k3_dtbo_makefile_append

		#ls ../${work_dir}/src/arm64/overlays/ | grep beagleboneai64
		#exit 2

		device="k3-j721e-beagleboneai64-BBORG_MOTOR" ; k3_dtbo_makefile_append
		device="k3-j721e-beagleboneai64-ecap0" ; k3_dtbo_makefile_append
		device="k3-j721e-beagleboneai64-ecap1" ; k3_dtbo_makefile_append
		device="k3-j721e-beagleboneai64-ecap2" ; k3_dtbo_makefile_append
		device="k3-j721e-beagleboneai64-eqep0" ; k3_dtbo_makefile_append
		device="k3-j721e-beagleboneai64-eqep1" ; k3_dtbo_makefile_append
		device="k3-j721e-beagleboneai64-io-pins" ; k3_dtbo_makefile_append
		device="k3-j721e-beagleboneai64-pwm-epwm0-p8_13" ; k3_dtbo_makefile_append
		device="k3-j721e-beagleboneai64-pwm-epwm0-p8_13-p8_19" ; k3_dtbo_makefile_append
		device="k3-j721e-beagleboneai64-pwm-epwm0-p8_19" ; k3_dtbo_makefile_append
		device="k3-j721e-beagleboneai64-pwm-epwm2-p9_14" ; k3_dtbo_makefile_append
		device="k3-j721e-beagleboneai64-pwm-epwm2-p9_14-p9_16" ; k3_dtbo_makefile_append
		device="k3-j721e-beagleboneai64-pwm-epwm2-p9_16" ; k3_dtbo_makefile_append
		device="k3-j721e-beagleboneai64-pwm-epwm4-p9_25" ; k3_dtbo_makefile_append
		device="k3-j721e-beagleboneai64-rs485-uart8" ; k3_dtbo_makefile_append
		device="k3-j721e-beagleboneai64-spi-mcspi1-cs0" ; k3_dtbo_makefile_append
		device="k3-j721e-beagleboneai64-spi-mcspi1-cs0-no-miso" ; k3_dtbo_makefile_append
		device="k3-j721e-beagleboneai64-spi-mcspi2-cs0" ; k3_dtbo_makefile_append
		device="k3-j721e-beagleboneai64-spi-mcspi3-cs0-no-miso" ; k3_dtbo_makefile_append
		device="k3-j721e-beagleboneai64-spi-mcspi6-cs0-cs1" ; k3_dtbo_makefile_append
		device="k3-j721e-beagleboneai64-spi-mcspi6-cs0" ; k3_dtbo_makefile_append
		device="k3-j721e-beagleboneai64-spi-mcspi6-cs1-no-miso" ; k3_dtbo_makefile_append
		device="k3-j721e-beagleboneai64-spi-mcspi7-cs0" ; k3_dtbo_makefile_append

		device="k3-j721e-edgeai-apps" ; k3_dtbo_makefile_append
		device="k3-j721e-vision-apps" ; k3_dtbo_makefile_append
		device="k3-j722s-edgeai-apps" ; k3_dtbo_makefile_append
		device="k3-j722s-vision-apps" ; k3_dtbo_makefile_append
		k3_makefile_patch_cleanup_overlays

		${git_bin} add -f arch/arm/boot/dts/
		${git_bin} add -f arch/arm64/boot/dts/
		${git_bin} add -f include/dt-bindings/
		${git_bin} commit -a -m "Add BeagleBoard.org Device Tree Changes" -m "https://github.com/beagleboard/BeagleBoard-DeviceTrees/tree/${branch}" -m "https://github.com/beagleboard/BeagleBoard-DeviceTrees/commit/${git_hash}" -s
		${git_bin} format-patch -1 -o ../patches/external/bbb.io/
		echo "BBDTBS: https://github.com/beagleboard/BeagleBoard-DeviceTrees/commit/${git_hash}" > ../patches/external/git/BBDTBS

		rm -rf ../${work_dir}/ || true

		${git_bin} reset --hard HEAD^

		start_cleanup

		${git} "${DIR}/patches/external/bbb.io/0001-Add-BeagleBoard.org-Device-Tree-Changes.patch"

		wdir="external/bbb.io"
		number=1
		cleanup
	fi
	dir 'external/bbb.io'
}

local_patch () {
	echo "dir: dir"
	${git} "${DIR}/patches/dir/0001-patch.patch"
}

pre_backports () {
	echo "dir: backports/${subsystem}"

	cd ~/linux-src/
	${git_bin} pull --no-edit https://kernel.googlesource.com/pub/scm/linux/kernel/git/stable/linux.git master
	${git_bin} pull --no-edit https://kernel.googlesource.com/pub/scm/linux/kernel/git/stable/linux.git master --tags
	${git_bin} pull --no-edit https://kernel.googlesource.com/pub/scm/linux/kernel/git/torvalds/linux.git master --tags
	if [ ! "x${backport_tag}" = "x" ] ; then
		echo "${git_bin} checkout ${backport_tag} -f"
		${git_bin} checkout ${backport_tag} -f
	fi
	cd -
}

post_backports () {
	if [ ! "x${backport_tag}" = "x" ] ; then
		cd ~/linux-src/
		${git_bin} checkout master -f
		cd -
	fi

	${git_bin} add .
	${git_bin} commit -a -m "backports: ${subsystem}: from: linux.git" -m "Reference: ${backport_tag}" -s
	if [ ! -d ../patches/backports/${subsystem}/ ] ; then
		mkdir -p ../patches/backports/${subsystem}/
	fi
	${git_bin} format-patch -1 -o ../patches/backports/${subsystem}/
	exit 2
}

external_git
rt

patch_backports () {
	echo "dir: backports/${subsystem}"
	${git} "${DIR}/patches/backports/${subsystem}/0001-backports-${subsystem}-from-linux.git.patch"
}

linux_scripts () {
	echo "Update: package scripts"
	do_backport="enable"
	if [ "x${do_backport}" = "xenable" ] ; then
		backport_tag="v6.6.74"

		subsystem="scripts"
		#regenerate="enable"
		if [ "x${regenerate}" = "xenable" ] ; then
			pre_backports

			rsync -av ~/linux-src/scripts/* ./scripts/
			cp -v ~/linux-src/Makefile ./Makefile

			post_backports
		else
			patch_backports
			#exit 2
			${git} "${DIR}/patches/backports/${subsystem}/0002-fixup.patch"
		fi
	fi
}

linux_scripts
mainline_patches
wpanusb
wireless_regdb
beagleboard_dtbs
#local_patch

pre_rpibackports () {
	echo "dir: backports/${subsystem}"

	cd ~/linux-rpi/
	${git_bin} fetch --tags
	if [ ! "x${backport_tag}" = "x" ] ; then
		echo "${git_bin} checkout ${backport_tag} -f"
		${git_bin} checkout ${backport_tag} -f
	fi
	cd -
}

post_rpibackports () {
	if [ ! "x${backport_tag}" = "x" ] ; then
		cd ~/linux-rpi/
		${git_bin} checkout master -f
		cd -
	fi

	${git_bin} add .
	${git_bin} commit -a -m "backports: ${subsystem}: from: linux.git" -m "Reference: ${backport_tag}" -s
	if [ ! -d ../patches/backports/${subsystem}/ ] ; then
		mkdir -p ../patches/backports/${subsystem}/
	fi
	${git_bin} format-patch -1 -o ../patches/backports/${subsystem}/
	exit 2
}

backports () {
	backport_tag="v6.6.137"

	###FIXME: https://www.cve.org/CVERecord?id=CVE-2026-31431
	subsystem="crypto"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		pre_backports

		rsync -av --delete ~/linux-src/crypto/* ./crypto/
		rsync -av --delete ~/linux-src/drivers/crypto/* ./drivers/crypto/
		rsync -av --delete ~/linux-src/include/crypto/* ./include/crypto/
		patch -p1 < ../patches/hacks/lzo/0001-lzo-undo-lzorle1x_1_compress_safe.patch
		cp -v ~/linux-src/include/linux/math.h ./include/linux/

		post_backports
	else
		patch_backports
	fi

	subsystem="uio"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		unset backport_tag

		cp -v ../patches/drivers/ti/uio/uio_pruss.c ./drivers/uio/

		post_backports
	else
		patch_backports
		dir 'drivers/ti/uio'
	fi

	backport_tag="rpi-6.6.y"

	subsystem="edt-ft5x06"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		pre_rpibackports

		cp -v ~/linux-rpi/drivers/input/touchscreen/edt-ft5x06.c ./drivers/input/touchscreen/

		post_rpibackports
	else
		patch_backports
	fi
}

drivers () {
	dir 'branding/boris'

#	dir 'drivers/ar1021_i2c'
#	dir 'drivers/ti/serial'
#	dir 'drivers/ti/tsc'
#	dir 'drivers/fb_ssd1306'
#	dir 'drivers/hackaday'

	dir 'external/android'
	dir 'external/ti-amx3-cm3-pm-firmware'

	dir 'drivers/fixes/mmc'
	dir 'drivers/fixes/e5010'
}

###
backports
drivers

packaging () {
	echo "Update: package scripts"
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

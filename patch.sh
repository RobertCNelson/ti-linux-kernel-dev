#!/bin/sh
#
# Copyright (c) 2009-2015 Robert Nelson <robertcnelson@gmail.com>
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

git_add () {
	git add .
	git commit -a -m 'testing patchset'
}

start_cleanup () {
	git="git am --whitespace=fix"
}

cleanup () {
	if [ "${number}" ] ; then
		git format-patch -${number} -o ${DIR}/patches/
	fi
	exit 2
}

external_git () {
	git_tag="ti-linux-3.14.y"
	echo "pulling: ${git_tag}"
	git pull ${git_opts} ${git_patchset} ${git_tag}
}

local_patch () {
	echo "dir: dir"
	${git} "${DIR}/patches/dir/0001-patch.patch"
}

external_git
#local_patch

ipipe () {
	echo "dir: ipipe"
	#git checkout v3.14.39 -b ipipe-3.14
	#git pull --no-edit git://git.xenomai.org/ipipe.git ipipe-3.14
	#
	#commit 78bc745f9bfd2776e90c4f28e58cbbeddbe601fb

	#git diff v3.14.39...78bc745f9bfd2776e90c4f28e58cbbeddbe601fb > ../patches/ipipe-3.14/ipipe-3.14.diff

	#exit 2

	${git} "${DIR}/patches/ipipe-3.14/0001-ipipe-3.14.patch"
}

fixes () {
	echo "dir: fixes"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		start_cleanup
	fi

	${git} "${DIR}/patches/fixes/0001-musb_cppi41-fix-mismerge-https-github.com-beagleboar.patch"

	if [ "x${regenerate}" = "xenable" ] ; then
		number=1
		cleanup
	fi
}

backport () {
	echo "dir: backport"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		start_cleanup
	fi

#	${git} "${DIR}/patches/backport/0001-backport-gpio_backlight.c-from-v3.15.10.patch"

	if [ "x${regenerate}" = "xenable" ] ; then
		number=1
		cleanup
	fi
}

firmware () {
	echo "dir: firmware"
	#git clone git://git.ti.com/ti-cm3-pm-firmware/amx3-cm3.git
	#cd amx3-cm3/
	#git checkout origin/ti-v3.14.y -b tmp

	#commit d85e6a17da1025adac9ab7f97dd7aa2a58c517ce
	#Author: Dave Gerlach <d-gerlach@ti.com>
	#Date:   Mon Dec 15 12:07:18 2014 -0600
	#
	#    CM3: Bump firmware release version to 0x190
	#    
	#    This version, 0x190, includes the following changes:
	#         - Correction to interrupt clearing and disabling
	#         - Bug fix that caused AM335x CPUIdle to hang
	#         - Bug fix that caused AM335x SK EVM to hang on GPIO wake
	#    
	#    Signed-off-by: Dave Gerlach <d-gerlach@ti.com>

	#cp -v bin/am* /opt/github/ti-linux-kernel-dev/KERNEL/firmware/

	#git add -f ./firmware/am*

	${git} "${DIR}/patches/firmware/0001-firmware-am335x-pm-firmware.elf.patch"
}

dtb_makefile_append () {
	sed -i -e 's:am335x-boneblack.dtb \\:am335x-boneblack.dtb \\\n\t'$device' \\:g' arch/arm/boot/dts/Makefile
}

dtsi_append () {
	wfile="arch/arm/boot/dts/${base_dts}-${cape}.dts"
	cp arch/arm/boot/dts/${base_dts}-base.dts ${wfile}
	echo "" >> ${wfile}
	echo "#include \"am335x-bone-${cape}.dtsi\"" >> ${wfile}
	git add ${wfile}
}

dtsi_append_custom () {
	wfile="arch/arm/boot/dts/${dtb_name}.dts"
	cp arch/arm/boot/dts/${base_dts}-base.dts ${wfile}
	echo "" >> ${wfile}
	echo "#include \"am335x-bone-${cape}.dtsi\"" >> ${wfile}
	git add ${wfile}
}

dtsi_append_hdmi_no_audio () {
	dtsi_append
	echo "#include \"am335x-boneblack-nxp-hdmi-no-audio.dtsi\"" >> ${wfile}
	git add ${wfile}
}

dtsi_drop_nxp_hdmi_audio () {
	sed -i -e 's:#include "am335x-boneblack-nxp-hdmi-audio.dtsi":/* #include "am335x-boneblack-nxp-hdmi-audio.dtsi" */:g' ${wfile}
	git add ${wfile}
}

dtsi_drop_emmc () {
	sed -i -e 's:#include "am335x-boneblack-emmc.dtsi":/* #include "am335x-boneblack-emmc.dtsi" */:g' ${wfile}
	git add ${wfile}
}

dts_drop_clkout2_pin () {
	sed -i -e 's:pinctrl-0 = <\&clkout2_pin>;:/* pinctrl-0 = <\&clkout2_pin>; */:g' ${wfile}
	git add ${wfile}
}

beaglebone () {
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

	if [ "x${regenerate}" = "xenable" ] ; then
		number=13
		cleanup
	fi

	echo "dir: beaglebone/pinmux"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		start_cleanup
	fi
	# gedit arch/arm/boot/dts/am335x-bone-common.dtsi arch/arm/boot/dts/am335x-bone-common-pinmux.dtsi
	# gedit arch/arm/boot/dts/am335x-boneblack.dts arch/arm/boot/dts/am335x-bone.dts &
	# git commit -a -m 'am335x-bone-common: split out am33xx_pinmux' -s

	${git} "${DIR}/patches/beaglebone/pinmux/0001-am335x-bone-common-split-out-am33xx_pinmux.patch"

	# gedit arch/arm/boot/dts/am335x-bone-common-pinmux.dtsi arch/arm/boot/dts/am335x-boneblack.dts
	# git commit -a -m 'am335x-boneblack: split out am33xx_pinmux' -s

	${git} "${DIR}/patches/beaglebone/pinmux/0002-am335x-boneblack-split-out-am33xx_pinmux.patch"

	# cp arch/arm/boot/dts/am335x-boneblack.dts arch/arm/boot/dts/am335x-boneblack-emmc.dtsi
	# gedit arch/arm/boot/dts/am335x-boneblack.dts arch/arm/boot/dts/am335x-boneblack-emmc.dtsi &
	# git add arch/arm/boot/dts/am335x-boneblack-emmc.dtsi
	# git commit -a -m 'am335x-boneblack: split out emmc' -s

	${git} "${DIR}/patches/beaglebone/pinmux/0003-am335x-boneblack-split-out-emmc.patch"

	# cp arch/arm/boot/dts/am335x-boneblack.dts arch/arm/boot/dts/am335x-boneblack-nxp-hdmi-audio.dtsi
	# gedit arch/arm/boot/dts/am335x-boneblack.dts arch/arm/boot/dts/am335x-boneblack-nxp-hdmi-audio.dtsi &
	# git add arch/arm/boot/dts/am335x-boneblack-nxp-hdmi-audio.dtsi
	# git commit -a -m 'am335x-boneblack: split out nxp hdmi audio' -s

	${git} "${DIR}/patches/beaglebone/pinmux/0004-am335x-boneblack-split-out-nxp-hdmi-audio.patch"

	# cp arch/arm/boot/dts/am335x-boneblack-nxp-hdmi-audio.dtsi arch/arm/boot/dts/am335x-boneblack-nxp-hdmi-no-audio.dtsi
	# gedit arch/arm/boot/dts/am335x-boneblack.dts  arch/arm/boot/dts/am335x-boneblack-nxp-hdmi-no-audio.dtsi &
	# git add arch/arm/boot/dts/am335x-boneblack-nxp-hdmi-no-audio.dtsi
	# git commit -a -m 'am335x-bone: nxp hdmi no audio' -s

	${git} "${DIR}/patches/beaglebone/pinmux/0005-am335x-bone-nxp-hdmi-no-audio.patch"

	${git} "${DIR}/patches/beaglebone/pinmux/0006-pinmux-bone-black-disable-pins-for-hdmi-audio-clkout.patch"
	${git} "${DIR}/patches/beaglebone/pinmux/0007-pinmux-i2c.patch"
	${git} "${DIR}/patches/beaglebone/pinmux/0008-pinmux-uart.patch"
	${git} "${DIR}/patches/beaglebone/pinmux/0009-pinmux-spi.patch"
	${git} "${DIR}/patches/beaglebone/pinmux/0010-node-4-wire-touchscreen.patch"
	${git} "${DIR}/patches/beaglebone/pinmux/0011-node-led-gpio.patch"
	${git} "${DIR}/patches/beaglebone/pinmux/0012-node-backlight-gpio.patch"
	${git} "${DIR}/patches/beaglebone/pinmux/0013-node-keymap.patch"
	${git} "${DIR}/patches/beaglebone/pinmux/0014-node-panel.patch"
	${git} "${DIR}/patches/beaglebone/pinmux/0015-cape-audio-revb.patch"
	${git} "${DIR}/patches/beaglebone/pinmux/0016-cape-audio-reva.patch"
	${git} "${DIR}/patches/beaglebone/pinmux/0017-cape-crypto-00a0.patch"
	${git} "${DIR}/patches/beaglebone/pinmux/0018-cape-rtc-01-00a1.patch"
	${git} "${DIR}/patches/beaglebone/pinmux/0019-cape-lcd.patch"
	${git} "${DIR}/patches/beaglebone/pinmux/0020-cape-basic-proto.patch"
	${git} "${DIR}/patches/beaglebone/pinmux/0021-pinmux-use-hdmi-mode.patch"
	${git} "${DIR}/patches/beaglebone/pinmux/0022-temp-panels-disable-hdmi-pins-need-to-rewrite-agains.patch"
	${git} "${DIR}/patches/beaglebone/pinmux/0023-cape-can1.patch"
	${git} "${DIR}/patches/beaglebone/pinmux/0024-cape-factor-out-i2c2-eeprom.patch"
	${git} "${DIR}/patches/beaglebone/pinmux/0025-cape-can0.patch"
	${git} "${DIR}/patches/beaglebone/pinmux/0026-cape-bbb-exp-c-really-1024x600.patch"
	${git} "${DIR}/patches/beaglebone/pinmux/0027-audio-cape-Make-sure-i2c2-is-muxed-correctly.patch"
	${git} "${DIR}/patches/beaglebone/pinmux/0028-audio-cape-Adjust-clock-frequency.patch"
	${git} "${DIR}/patches/beaglebone/pinmux/0029-audio-cape-Add-comments.patch"
	${git} "${DIR}/patches/beaglebone/pinmux/0030-arm-dts-am335x-bone-common-add-collision-and-carrier.patch"

	if [ "x${regenerate}" = "xenable" ] ; then
		number=30
		cleanup
	fi

	echo "dir: beaglebone/dts"

	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		start_cleanup
	fi

	${git} "${DIR}/patches/beaglebone/dts/0001-hack-bbb-enable-1ghz-operation.patch"
	${git} "${DIR}/patches/beaglebone/dts/0002-dts-am335x-bone-common-fixup-leds-to-match-3.8.patch"
	${git} "${DIR}/patches/beaglebone/dts/0003-ARM-dts-am335x-bone-Fix-model-name-and-update-compat.patch"
	${git} "${DIR}/patches/beaglebone/dts/0004-tps65217-Enable-KEY_POWER-press-on-AC-loss-PWR_BUT.patch"
	${git} "${DIR}/patches/beaglebone/dts/0005-ARM-dts-am335x-bone-common-enable-aes-and-sham.patch"

	#echo "patch -p1 < \"${DIR}/patches/beaglebone/dts/0006-add-base-files.patch\""
#	exit 2
	${git} "${DIR}/patches/beaglebone/dts/0006-add-base-files.patch"

	if [ "x${regenerate}" = "xenable" ] ; then
		number=6
		cleanup
	fi

	#regenerate="enable"
	echo "dir: beaglebone/generated"
	if [ "x${regenerate}" = "xenable" ] ; then
		base_dts="am335x-bone"
		cape="ttyO1"
		dtsi_append

		cape="ttyO2"
		dtsi_append

		cape="ttyO4"
		dtsi_append

		cape="ttyO5"
		dtsi_append

		base_dts="am335x-boneblack"
		cape="ttyO1"
		dtsi_append

		cape="ttyO2"
		dtsi_append

		cape="ttyO4"
		dtsi_append

		cape="ttyO5"
		dtsi_append
		dtsi_drop_nxp_hdmi_audio

		git commit -a -m 'auto generated: cape: uarts' -s
		git format-patch -1 -o ../patches/beaglebone/generated/
	else
		${git} "${DIR}/patches/beaglebone/generated/0001-auto-generated-cape-uarts.patch"
	fi

	if [ "x${regenerate}" = "xenable" ] ; then
		base_dts="am335x-bone"
		cape="audio-reva"
		dtsi_append

		base_dts="am335x-boneblack"
		cape="audio-reva"
		dtsi_append_hdmi_no_audio
		dtsi_drop_nxp_hdmi_audio

		base_dts="am335x-bone"
		cape="audio-revb"
		dtsi_append

		base_dts="am335x-boneblack"
		cape="audio-revb"
		dtsi_append_hdmi_no_audio
		dtsi_drop_nxp_hdmi_audio

		git commit -a -m 'auto generated: cape: audio' -s
		git format-patch -2 -o ../patches/beaglebone/generated/
	else
		${git} "${DIR}/patches/beaglebone/generated/0002-auto-generated-cape-audio.patch"
	fi

	if [ "x${regenerate}" = "xenable" ] ; then
		base_dts="am335x-bone"
		cape="lcd3-01-00a2"
		dtsi_append

		cape="lcd4-01-00a1"
		dtsi_append

		cape="lcd7-01-00a2"
		dtsi_append

		cape="lcd7-01-00a3"
		dtsi_append

		base_dts="am335x-boneblack"
		#lcd3 a2+
		cape="lcd3-01-00a2"
		dtsi_append
		dtsi_drop_nxp_hdmi_audio

		#lcd4 a1+
		cape="lcd4-01-00a1"
		dtsi_append
		dtsi_drop_nxp_hdmi_audio

		#drop emmc:
		cape="lcd7-01-00a2"
		dtsi_append
		dtsi_drop_nxp_hdmi_audio
		dtsi_drop_emmc

		#lcd4 a3+
		cape="lcd7-01-00a3"
		dtsi_append
		dtsi_drop_nxp_hdmi_audio

		git commit -a -m 'auto generated: cape: lcd' -s
		git format-patch -3 -o ../patches/beaglebone/generated/
	else
		${git} "${DIR}/patches/beaglebone/generated/0003-auto-generated-cape-lcd.patch"
	fi

	if [ "x${regenerate}" = "xenable" ] ; then
		cape="argus"

		base_dts="am335x-bone"
		dtb_name="${base_dts}-cape-bone-${cape}"
		dtsi_append_custom
		dts_drop_clkout2_pin

		base_dts="am335x-boneblack"
		dtb_name="${base_dts}-cape-bone-${cape}"
		dtsi_append_custom
		dts_drop_clkout2_pin

		git commit -a -m 'auto generated: cape: argus' -s
		git format-patch -4 -o ../patches/beaglebone/generated/
	else
		${git} "${DIR}/patches/beaglebone/generated/0004-auto-generated-cape-argus.patch"
	fi

	if [ "x${regenerate}" = "xenable" ] ; then
		base_dts="am335x-bone"
		cape="rtc-01-00a1"
		dtsi_append

		base_dts="am335x-boneblack"
		cape="rtc-01-00a1"
		dtsi_append

		git commit -a -m 'auto generated: cape: rtc-01-00a1' -s
		git format-patch -5 -o ../patches/beaglebone/generated/
	else
		${git} "${DIR}/patches/beaglebone/generated/0005-auto-generated-cape-rtc-01-00a1.patch"
	fi

	if [ "x${regenerate}" = "xenable" ] ; then
		base_dts="am335x-bone"
		cape="crypto-00a0"
		dtsi_append

		base_dts="am335x-boneblack"
		cape="crypto-00a0"
		dtsi_append

		git commit -a -m 'auto generated: cape: crypto-00a0' -s
		git format-patch -6 -o ../patches/beaglebone/generated/
	else
		${git} "${DIR}/patches/beaglebone/generated/0006-auto-generated-cape-crypto-00a0.patch"
	fi

	if [ "x${regenerate}" = "xenable" ] ; then
		base_dts="am335x-bone"
		cape="4dcape-43"
		dtsi_append

		cape="4dcape-43t"
		dtsi_append

		cape="4dcape-70"
		dtsi_append

		cape="4dcape-70t"
		dtsi_append

		base_dts="am335x-boneblack"
		cape="4dcape-43"
		dtsi_append
		dtsi_drop_nxp_hdmi_audio

		base_dts="am335x-boneblack"
		cape="4dcape-43t"
		dtsi_append
		dtsi_drop_nxp_hdmi_audio

		base_dts="am335x-boneblack"
		cape="4dcape-70"
		dtsi_append
		dtsi_drop_nxp_hdmi_audio

		base_dts="am335x-boneblack"
		cape="4dcape-70t"
		dtsi_append
		dtsi_drop_nxp_hdmi_audio

		git commit -a -m 'auto generated: cape: 4dcape' -s
		git format-patch -7 -o ../patches/beaglebone/generated/
	else
		${git} "${DIR}/patches/beaglebone/generated/0007-auto-generated-cape-4dcape.patch"
	fi

	if [ "x${regenerate}" = "xenable" ] ; then
		base_dts="am335x-bone"
		cape="bbb-exp-c"
		dtsi_append

		base_dts="am335x-boneblack"
		cape="bbb-exp-c"
		dtsi_append
		dtsi_drop_nxp_hdmi_audio

		git commit -a -m 'auto generated: cape: bbb-exp-c' -s
		git format-patch -8 -o ../patches/beaglebone/generated/
	else
		${git} "${DIR}/patches/beaglebone/generated/0008-auto-generated-cape-bbb-exp-c.patch"
	fi

	if [ "x${regenerate}" = "xenable" ] ; then
		base_dts="am335x-bone"
		cape="bb-view-43"
		dtsi_append

		base_dts="am335x-boneblack"
		cape="bb-view-43"
		dtsi_append
		dtsi_drop_nxp_hdmi_audio

		git commit -a -m 'auto generated: cape: bb-view-43' -s
		git format-patch -9 -o ../patches/beaglebone/generated/
	else
		${git} "${DIR}/patches/beaglebone/generated/0009-auto-generated-cape-bb-view-43.patch"
	fi

	if [ "x${regenerate}" = "xenable" ] ; then
		base_dts="am335x-bone"
		cape="can1"
		dtsi_append

		base_dts="am335x-boneblack"
		cape="can1"
		dtsi_append

		git commit -a -m 'auto generated: cape: can1' -s
		git format-patch -10 -o ../patches/beaglebone/generated/
	else
		${git} "${DIR}/patches/beaglebone/generated/0010-auto-generated-cape-can1.patch"
	fi

	echo "dir: beaglebone/capes"
#	regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		start_cleanup
	fi
		${git} "${DIR}/patches/beaglebone/capes/0001-cape-Argus-UPS-cape-support.patch"
		${git} "${DIR}/patches/beaglebone/capes/0002-ARM-dts-am335x-boneblack-enable-wl1835mod-cape-suppo.patch"

	if [ "x${regenerate}" = "xenable" ] ; then
		number=2
		cleanup
	fi

	#Slowly merging to the way we did this in v4.0.x...

	#This has to be last...
	#echo "dir: beaglebone/dtbs"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		patch -p1 < "${DIR}/patches/beaglebone/dtbs/0001-sync-am335x-peripheral-pinmux.patch"
		exit 2
	fi
	${git} "${DIR}/patches/beaglebone/dtbs/0001-sync-am335x-peripheral-pinmux.patch"

	####
	#dtb makefile
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		device="am335x-arduino-tre.dtb" ; dtb_makefile_append
		device="am335x-bone-audio-reva.dtb" ; dtb_makefile_append
		device="am335x-bone-audio-revb.dtb" ; dtb_makefile_append
		device="am335x-bone-bb-view-43.dtb" ; dtb_makefile_append
		device="am335x-bone-can1.dtb" ; dtb_makefile_append
		device="am335x-bone-cape-bone-argus.dtb" ; dtb_makefile_append
		device="am335x-bone-crypto-00a0.dtb" ; dtb_makefile_append
		device="am335x-bone-4dcape-43.dtb" ; dtb_makefile_append
		device="am335x-bone-4dcape-43t.dtb" ; dtb_makefile_append
		device="am335x-bone-4dcape-70.dtb" ; dtb_makefile_append
		device="am335x-bone-4dcape-70t.dtb" ; dtb_makefile_append
		device="am335x-bone-bbb-exp-c.dtb" ; dtb_makefile_append
		device="am335x-bone-lcd3-01-00a2.dtb" ; dtb_makefile_append
		device="am335x-bone-lcd4-01-00a1.dtb" ; dtb_makefile_append
		device="am335x-bone-lcd7-01-00a2.dtb" ; dtb_makefile_append
		device="am335x-bone-lcd7-01-00a3.dtb" ; dtb_makefile_append
		device="am335x-bone-rtc-01-00a1.dtb" ; dtb_makefile_append
		device="am335x-bone-ttyO1.dtb" ; dtb_makefile_append
		device="am335x-bone-ttyO2.dtb" ; dtb_makefile_append
		device="am335x-bone-ttyO4.dtb" ; dtb_makefile_append
		device="am335x-bone-ttyO5.dtb" ; dtb_makefile_append
		device="am335x-boneblack-audio-reva.dtb" ; dtb_makefile_append
		device="am335x-boneblack-audio-revb.dtb" ; dtb_makefile_append
		device="am335x-boneblack-bb-view-43.dtb" ; dtb_makefile_append
		device="am335x-boneblack-can1.dtb" ; dtb_makefile_append
		device="am335x-boneblack-cape-bone-argus.dtb" ; dtb_makefile_append
		device="am335x-boneblack-crypto-00a0.dtb" ; dtb_makefile_append
		device="am335x-boneblack-4dcape-43.dtb" ; dtb_makefile_append
		device="am335x-boneblack-4dcape-43t.dtb" ; dtb_makefile_append
		device="am335x-boneblack-4dcape-70.dtb" ; dtb_makefile_append
		device="am335x-boneblack-4dcape-70t.dtb" ; dtb_makefile_append
		device="am335x-boneblack-bbb-exp-c.dtb" ; dtb_makefile_append
		device="am335x-boneblack-lcd3-01-00a2.dtb" ; dtb_makefile_append
		device="am335x-boneblack-lcd4-01-00a1.dtb" ; dtb_makefile_append
		device="am335x-boneblack-lcd7-01-00a2.dtb" ; dtb_makefile_append
		device="am335x-boneblack-lcd7-01-00a3.dtb" ; dtb_makefile_append
		device="am335x-boneblack-rtc-01-00a1.dtb" ; dtb_makefile_append
		device="am335x-boneblack-ttyO1.dtb" ; dtb_makefile_append
		device="am335x-boneblack-ttyO2.dtb" ; dtb_makefile_append
		device="am335x-boneblack-ttyO4.dtb" ; dtb_makefile_append
		device="am335x-boneblack-ttyO5.dtb" ; dtb_makefile_append
		device="am335x-boneblack-wl1835mod.dtb" ; dtb_makefile_append
		device="am335x-bonegreen.dtb" ; dtb_makefile_append

		git commit -a -m 'auto generated: capes: add dtbs to makefile' -s
		git format-patch -1 -o ../patches/beaglebone/generated/last/
		exit 2
	else
		${git} "${DIR}/patches/beaglebone/generated/last/0001-auto-generated-capes-add-dtbs-to-makefile.patch"
	fi

	echo "dir: beaglebone/mac"
	#[PATCH v6 0/7] net: cpsw: Support for am335x chip MACIDs
	${git} "${DIR}/patches/beaglebone/mac/0001-DT-doc-net-cpsw-mac-address-is-optional.patch"
	${git} "${DIR}/patches/beaglebone/mac/0002-net-cpsw-Add-missing-return-value.patch"
	${git} "${DIR}/patches/beaglebone/mac/0003-net-cpsw-header-Add-missing-include.patch"
	${git} "${DIR}/patches/beaglebone/mac/0004-net-cpsw-Replace-pr_err-by-dev_err.patch"
	${git} "${DIR}/patches/beaglebone/mac/0005-net-cpsw-Add-am33xx-MACID-readout.patch"
#	${git} "${DIR}/patches/beaglebone/mac/0006-am33xx-define-syscon-control-module-device-node.patch"
#	${git} "${DIR}/patches/beaglebone/mac/0007-arm-dts-am33xx-Add-syscon-phandle-to-cpsw-node.patch"

	echo "dir: beaglebone/phy"
	${git} "${DIR}/patches/beaglebone/phy/0001-cpsw-search-for-phy.patch"
}

sgx () {
	echo "dir: sgx"
}

###
ipipe
fixes
backport
firmware
beaglebone
#sgx

packaging_setup () {
	cp -v "${DIR}/3rdparty/packaging/builddeb" "${DIR}/KERNEL/scripts/package"
	git commit -a -m 'packaging: sync with mainline' -s

	git format-patch -1 -o "${DIR}/patches/packaging"
	exit 2
}

packaging () {
	echo "dir: packaging"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		start_cleanup
	fi

	${git} "${DIR}/patches/packaging/0001-packaging-sync-with-mainline.patch"
	${git} "${DIR}/patches/packaging/0002-deb-pkg-install-dtbs-in-linux-image-package.patch"
	${git} "${DIR}/patches/packaging/0003-deb-pkg-no-dtbs_install.patch"

	if [ "x${regenerate}" = "xenable" ] ; then
		number=3
		cleanup
	fi
}

#packaging_setup
packaging
echo "patch.sh ran successfully"

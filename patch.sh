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

pick () {
	if [ ! -d ../patches/${pick_dir} ] ; then
		mkdir -p ../patches/${pick_dir}
	fi
	git format-patch -1 ${SHA} --start-number ${num} -o ../patches/${pick_dir}
	num=$(($num+1))
}

external_git () {
	git_tag="ti-linux-4.1.y"
	echo "pulling: ${git_tag}"
	git pull ${git_opts} ${git_patchset} ${git_tag}
	. ${DIR}/.CC
	sed -i -e 's:linux-kernel:`pwd`/:g' ./ti_config_fragments/defconfig_merge.sh
	./ti_config_fragments/defconfig_merge.sh -o /dev/null -f ti_config_fragments/defconfig_fragment -c ${CC}
	git checkout -- ./ti_config_fragments/defconfig_merge.sh

	make ARCH=arm CROSS_COMPILE="${CC}" appended_omap2plus_defconfig
	mv -v .config ../patches/ti_omap2plus_defconfig

	rm -f arch/arm/configs/appended_omap2plus_defconfig
	rm -f ti_config_fragments/working_config/base_config
	rm -f ti_config_fragments/working_config/final_config
	rm -f ti_config_fragments/working_config/merged_omap2plus_defconfig

	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		pick_dir="ti/cpu_freq"
		echo "dir: ${pick_dir}"
		num="1"

		SHA="8f5f2b72d19c1e62f85acfd84a286f08ca76e3ac" ; pick
		SHA="b3e1038f558783b054ba24d018c887e679158fa7" ; pick
		SHA="cbc7d0137388b8d1a8052816a1502d96c681522e" ; pick
		SHA="13b96edc90e6fbe9becce8a6edbbed12c729d49a" ; pick
		SHA="2a68c9fed90d632c1c15d1209ba9da73a2c9c849" ; pick
		SHA="ad7ec1619ff14dfaf526d2b6502911736e23ad75" ; pick
		SHA="fbc6d87ccdfcc3a347b719c5b6a4925f3dca6fd4" ; pick
		SHA="8ab51f90b0e961ba2266a9af5a21af9195a749b6" ; pick
		SHA="40a4d7af3dae2838654befa165f882053d32d470" ; pick
		SHA="95a8ed125030375c173756f0fec150ff42d8d18e" ; pick
		SHA="7cc36064bd172b6008e4f77c48128b9c7a714eed" ; pick
		SHA="eb92a8ee969ac1b2128d8091ae9e1c4829e7dbca" ; pick
		SHA="d307d86ee5e2acbd4fed76be9b02056426252ca4" ; pick
		SHA="ddbb76e023395051205d97b038ddc8ffcfb0dedf" ; pick
		SHA="94529783628418c311ffb30f0fc0435ad8df7491" ; pick
		SHA="d3e2dd94ed47bdfbd1cce104b8e2d0f5584a35e8" ; pick
		SHA="44ebfa6930c9914d139543909e5c33cd5a7ddacc" ; pick
		SHA="9324834c18421e889a2286d6f3b88bdf31c07b17" ; pick
		SHA="5cf0b55b7e92b291195c52b8ec0b0d3f9a51f61d" ; pick
		SHA="cf7213e2d35f57d43fff6e360daf50eb837206f3" ; pick
		SHA="752beab102668147fcfde9ee19d853e9fc603e81" ; pick
		SHA="cbe7bf16320964a47b3a202e28e9c5f965eef830" ; pick
		SHA="9b0e9d74d7aa29b637bf06bd9454b67eb6893284" ; pick
		SHA="b24e79bb4db8b336985400478813d60c5ba5aec7" ; pick

		unset num

		pick_dir="ti/iodelay"
		echo "dir: ${pick_dir}"
		num="1"

		SHA="03ccdced5235b91254382038708713795ce7d021" ; pick
		SHA="ecc68390cd49a087634bb33c6192d73196e2e1a3" ; pick
		SHA="832e1d482bb7234cb504b31601abeaace08a8309" ; pick

		unset num

		exit 2
	fi
}

rt_cleanup () {
	echo "Fixing: drivers/gpio/gpio-omap.c"
	sed -i -e 's/\<spin_lock_irqsave\>/raw_spin_lock_irqsave/g' drivers/gpio/gpio-omap.c
	sed -i -e 's/\<spin_unlock_irqrestore\>/raw_spin_unlock_irqrestore/g' drivers/gpio/gpio-omap.c
	rm -rf drivers/gpio/gpio-omap.c.rej
}

rt () {
	echo "dir: rt"
	rt_patch="${KERNEL_REL}${kernel_rt}"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		git revert --no-edit 57293d164ce7c9cc91dd27050f6622edabbe0c02 -s
		git revert --no-edit d906a24a7ab60868a191c25e437f92f48948b5ca -s
		git revert --no-edit 98197d3de58a62785be3e421864d6145955f197d -s
		git revert --no-edit 3905f7abd0410acdd497661e84c7f6ef672c1e04 -s

		mkdir -p ${DIR}/patches/rt/reverts/
		git format-patch -4 -o ../patches/rt/reverts/

		wget -c https://www.kernel.org/pub/linux/kernel/projects/rt/${KERNEL_REL}/patch-${rt_patch}.patch.xz
		xzcat patch-${rt_patch}.patch.xz | patch -p1 || rt_cleanup
		rm -f patch-${rt_patch}.patch.xz
		rm -f localversion-rt
		git add .
		git commit -a -m 'merge: CONFIG_PREEMPT_RT Patch Set' -s
		git format-patch -1 -o ../patches/rt/

		exit 2
	fi

	${git} "${DIR}/patches/rt/reverts/0001-Revert-sched-preempt-powerpc-kvm-Use-need_resched-in.patch"
	${git} "${DIR}/patches/rt/reverts/0002-Revert-sched-preempt-xen-Use-need_resched-instead-of.patch"
	${git} "${DIR}/patches/rt/reverts/0003-Revert-sched-preempt-Fix-cond_resched_lock-and-cond_.patch"
	${git} "${DIR}/patches/rt/reverts/0004-Revert-sched-preempt-Rename-PREEMPT_CHECK_OFFSET-to-.patch"

	${git} "${DIR}/patches/rt/0001-merge-CONFIG_PREEMPT_RT-Patch-Set.patch"
}

local_patch () {
	echo "dir: dir"
	${git} "${DIR}/patches/dir/0001-patch.patch"
}

external_git
#rt
#local_patch

reverts () {
	echo "dir: reverts"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		start_cleanup
	fi

	${git} "${DIR}/patches/reverts/0001-Revert-spi-spidev-Warn-loudly-if-instantiated-from-D.patch"

	if [ "x${regenerate}" = "xenable" ] ; then
		number=1
		cleanup
	fi
}

backports () {
	echo "dir: backports"
	echo "dir: backports/mediatek"

	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		start_cleanup
	fi

	#careful around: https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/drivers/net/wireless/mediatek?id=30686bf7f5b3c30831761e188a6e3cb33580fa48
	${git} "${DIR}/patches/backports/mediatek/0001-backport-mediatek-mt7601u-from-v4.2-rc3.patch"

	if [ "x${regenerate}" = "xenable" ] ; then
		number=1
		cleanup
	fi
}

fixes () {
	echo "dir: fixes"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		start_cleanup
	fi

	if [ "x${regenerate}" = "xenable" ] ; then
		number=1
		cleanup
	fi
}

pru_uio () {
	echo "dir: pru_uio"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		start_cleanup
	fi

	${git} "${DIR}/patches/pru_uio/0001-Making-the-uio-pruss-driver-work.patch"
	${git} "${DIR}/patches/pru_uio/0002-Cleaned-up-error-reporting.patch"

	if [ "x${regenerate}" = "xenable" ] ; then
		number=2
		cleanup
	fi
}

pru_rpmsg () {
	echo "dir: pru_rpmsg"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		start_cleanup
	fi

	${git} "${DIR}/patches/pru_rpmsg/0001-Fix-remoteproc-to-work-with-the-PRU-GNU-Binutils-por.patch"
	${git} "${DIR}/patches/pru_rpmsg/0002-Add-rpmsg_pru-support.patch"

	if [ "x${regenerate}" = "xenable" ] ; then
		number=2
		cleanup
	fi
}

x15 () {
	echo "dir: x15/dsp"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		start_cleanup
	fi
	${git} "${DIR}/patches/x15/dsp/0001-am57xx-beagle-x15-cmem.patch"
	${git} "${DIR}/patches/x15/dsp/0002-dra74x-dra7xx-debugss.patch"

	if [ "x${regenerate}" = "xenable" ] ; then
		number=2
		cleanup
	fi
}

mainline () {
	git format-patch -1 ${SHA} --start-number ${num} -o ../patches/bbb_overlays/mainline/
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
		git pull --no-edit https://github.com/pantoniou/dtc dt-overlays5

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

		${git} "${DIR}/patches/bbb_overlays/dtc/0001-scripts-dtc-Update-to-upstream-version-overlays.patch"

		if [ "x${regenerate}" = "xenable" ] ; then
			number=1
			cleanup
		fi
	fi

	echo "dir: bbb_overlays/mainline"

	${git} "${DIR}/patches/bbb_overlays/mainline/0001-regmap-Introduce-regmap_get_max_register.patch"
	${git} "${DIR}/patches/bbb_overlays/mainline/0002-regmap-Introduce-regmap_get_reg_stride.patch"
	${git} "${DIR}/patches/bbb_overlays/mainline/0003-ARM-dts-Beaglebone-i2c-definitions.patch"
	${git} "${DIR}/patches/bbb_overlays/mainline/0004-i2c-Mark-instantiated-device-nodes-with-OF_POPULATE.patch"

	echo "dir: bbb_overlays/nvmem"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		start_cleanup
	fi

	${git} "${DIR}/patches/bbb_overlays/nvmem/0001-nvmem-Add-a-simple-NVMEM-framework-for-nvmem-provide.patch"
	${git} "${DIR}/patches/bbb_overlays/nvmem/0002-nvmem-Add-a-simple-NVMEM-framework-for-consumers.patch"
	${git} "${DIR}/patches/bbb_overlays/nvmem/0003-nvmem-Add-nvmem_device-based-consumer-apis.patch"
	${git} "${DIR}/patches/bbb_overlays/nvmem/0004-nvmem-Add-bindings-for-simple-nvmem-framework.patch"
	${git} "${DIR}/patches/bbb_overlays/nvmem/0005-Documentation-nvmem-add-nvmem-api-level-and-how-to-d.patch"
	${git} "${DIR}/patches/bbb_overlays/nvmem/0006-nvmem-qfprom-Add-Qualcomm-QFPROM-support.patch"
	${git} "${DIR}/patches/bbb_overlays/nvmem/0007-nvmem-qfprom-Add-bindings-for-qfprom.patch"
	${git} "${DIR}/patches/bbb_overlays/nvmem/0008-nvmem-sunxi-Move-the-SID-driver-to-the-nvmem-framewo.patch"

#linux-next:

	${git} "${DIR}/patches/bbb_overlays/nvmem/0009-nvmem-Add-Vybrid-OCOTP-support.patch"
	${git} "${DIR}/patches/bbb_overlays/nvmem/0010-nvmem-imx-ocotp-Add-i.MX6-OCOTP-driver.patch"
	${git} "${DIR}/patches/bbb_overlays/nvmem/0011-nvmem-add-driver-for-ocotp-in-i.MX23-and-i.MX28.patch"
	${git} "${DIR}/patches/bbb_overlays/nvmem/0012-nvmem-Adding-bindings-for-rockchip-efuse.patch"
	${git} "${DIR}/patches/bbb_overlays/nvmem/0013-nvmem-rockchip_efuse_regmap_config-can-be-static.patch"
	${git} "${DIR}/patches/bbb_overlays/nvmem/0014-nvmem-core-fix-the-out-of-range-leak-in-read-write.patch"
	${git} "${DIR}/patches/bbb_overlays/nvmem/0015-nvmem-core-Handle-shift-bits-in-place-if-cell-nbits-.patch"
	${git} "${DIR}/patches/bbb_overlays/nvmem/0016-nvmem-core-Fix-memory-leak-in-nvmem_cell_write.patch"
	${git} "${DIR}/patches/bbb_overlays/nvmem/0017-nvmem-sunxi-Check-for-memory-allocation-failure.patch"

#email...

	${git} "${DIR}/patches/bbb_overlays/nvmem/0018-nvmem-make-default-user-binary-file-root-access-only.patch"
	${git} "${DIR}/patches/bbb_overlays/nvmem/0019-nvmem-set-the-size-for-the-nvmem-binary-file.patch"
	${git} "${DIR}/patches/bbb_overlays/nvmem/0020-nvmem-add-permission-flags-in-nvmem_config.patch"
	${git} "${DIR}/patches/bbb_overlays/nvmem/0021-nvmem-fix-permissions-of-readonly-nvmem-binattr.patch"

	if [ "x${regenerate}" = "xenable" ] ; then
		number=21
		cleanup
	fi

	echo "dir: bbb_overlays"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		start_cleanup
	fi

	${git} "${DIR}/patches/bbb_overlays/0001-configfs-Implement-binary-attributes-v4.patch"
	${git} "${DIR}/patches/bbb_overlays/0002-OF-DT-Overlay-configfs-interface-v5.patch"
	${git} "${DIR}/patches/bbb_overlays/0003-gitignore-Ignore-DTB-files.patch"

	if [ "x${regenerate}" = "xenable" ] ; then
	${git} "${DIR}/patches/bbb_overlays/0004-add-PM-firmware.patch"
	${git} "${DIR}/patches/bbb_overlays/0005-ARM-CUSTOM-Build-a-uImage-with-dtb-already-appended.patch"
	fi

	${git} "${DIR}/patches/bbb_overlays/0006-arm-omap-Proper-cleanups-for-omap_device.patch"
	${git} "${DIR}/patches/bbb_overlays/0007-serial-omap-Fix-port-line-number-without-aliases.patch"
	${git} "${DIR}/patches/bbb_overlays/0008-tty-omap-serial-Fix-up-platform-data-alloc.patch"
	${git} "${DIR}/patches/bbb_overlays/0009-ARM-DT-Enable-symbols-when-CONFIG_OF_OVERLAY-is-used.patch"
	${git} "${DIR}/patches/bbb_overlays/0010-of-Custom-printk-format-specifier-for-device-node.patch"
	${git} "${DIR}/patches/bbb_overlays/0011-of-overlay-kobjectify-overlay-objects.patch"
	${git} "${DIR}/patches/bbb_overlays/0012-of-overlay-global-sysfs-enable-attribute.patch"
	${git} "${DIR}/patches/bbb_overlays/0013-of-overlay-add-per-overlay-sysfs-attributes.patch"
	${git} "${DIR}/patches/bbb_overlays/0014-Documentation-ABI-sys-firmware-devicetree-overlays.patch"
	${git} "${DIR}/patches/bbb_overlays/0015-i2c-nvmem-at24-Provide-an-EEPROM-framework-interface.patch"
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
	${git} "${DIR}/patches/bbb_overlays/0029-of-changesets-Introduce-changeset-helper-methods.patch"
	${git} "${DIR}/patches/bbb_overlays/0030-RFC-Device-overlay-manager-PCI-USB-DT.patch"

	if [ "x${regenerate}" = "xenable" ] ; then
	${git} "${DIR}/patches/bbb_overlays/0031-boneblack-defconfig.patch"
	fi

	if [ "x${regenerate}" = "xenable" ] ; then
		number=31
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

	#${git} "${DIR}/patches/beaglebone/dts/0001-am335x-boneblack-add-cpu0-opp-points.patch"
	${git} "${DIR}/patches/beaglebone/dts/0001-hack-bbb-enable-1ghz-operation.patch"
	${git} "${DIR}/patches/beaglebone/dts/0002-dts-am335x-bone-common-fixup-leds-to-match-3.8.patch"
	${git} "${DIR}/patches/beaglebone/dts/0003-arm-dts-am335x-bone-common-add-collision-and-carrier.patch"
	${git} "${DIR}/patches/beaglebone/dts/0004-add-am335x-bonegreen.patch"
	${git} "${DIR}/patches/beaglebone/dts/0005-add-overlay-dtb.patch"
	${git} "${DIR}/patches/beaglebone/dts/0006-am335x-bone-common-cpsw-no-longer-need-to-define-bot.patch"
	${git} "${DIR}/patches/beaglebone/dts/0007-am335x-bone-common-drop-0x1a0-from-mmc.patch"
	${git} "${DIR}/patches/beaglebone/dts/0008-tps65217-Enable-KEY_POWER-press-on-AC-loss-PWR_BUT.patch"

	if [ "x${regenerate}" = "xenable" ] ; then
		number=8
		cleanup
	fi

	echo "dir: beaglebone/capes"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		start_cleanup
	fi

	${git} "${DIR}/patches/beaglebone/capes/0001-cape-Argus-UPS-cape-support.patch"
	${git} "${DIR}/patches/beaglebone/capes/0002-Added-support-for-Replicape.patch"
	${git} "${DIR}/patches/beaglebone/capes/0003-ARM-dts-am335x-boneblack-enable-wl1835mod-cape-suppo.patch"

	if [ "x${regenerate}" = "xenable" ] ; then
		number=3
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

	if [ "x${regenerate}" = "xenable" ] ; then
		number=2
		cleanup
	fi

	#This has to be last...
	echo "dir: beaglebone/dtbs"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		patch -p1 < "${DIR}/patches/beaglebone/dtbs/0001-sync-am335x-peripheral-pinmux.patch"
		exit 2
	fi
	${git} "${DIR}/patches/beaglebone/dtbs/0001-sync-am335x-peripheral-pinmux.patch"

	####
	#dtb makefile
	echo "dir: beaglebone/generated"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then

		device="am335x-arduino-tre.dtb" ; dtb_makefile_append

		device="am335x-boneblack-bbb-exp-c.dtb" ; dtb_makefile_append
		device="am335x-boneblack-bbb-exp-r.dtb" ; dtb_makefile_append

		device="am335x-boneblack-emmc-overlay.dtb" ; dtb_makefile_append
		device="am335x-boneblack-hdmi-overlay.dtb" ; dtb_makefile_append
		device="am335x-boneblack-nhdmi-overlay.dtb" ; dtb_makefile_append
		device="am335x-boneblack-overlay.dtb" ; dtb_makefile_append

		device="am335x-boneblack-replicape.dtb" ; dtb_makefile_append
		device="am335x-boneblack-wl1835mod.dtb" ; dtb_makefile_append

		device="am335x-bonegreen.dtb" ; dtb_makefile_append
		device="am335x-bonegreen-overlay.dtb" ; dtb_makefile_append

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

	#cp -v bin/am* /opt/github/bb-kernel/KERNEL/firmware/

	#git add -f ./firmware/am*

	${git} "${DIR}/patches/beaglebone/firmware/0001-add-am33x-firmware.patch"

	if [ "x${regenerate}" = "xenable" ] ; then
		number=1
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
	${git} "${DIR}/patches/quieter/0002-quiet-topology.c-use-pr_info-over-pr_err-missing-clo.patch"
	${git} "${DIR}/patches/quieter/0003-quiet-vgaarb-use-pr_info-over-pr_err.patch"
	${git} "${DIR}/patches/quieter/0004-quiet-omap_hsmmc.c-dont-complain-about-something-we-.patch"
	${git} "${DIR}/patches/quieter/0005-quiet-arch-arm-mach-omap2-voltage.c-legacy-harmless.patch"

	if [ "x${regenerate}" = "xenable" ] ; then
		number=5
		cleanup
	fi
}

rpmsg () {
	echo "dir: pru"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		start_cleanup
	fi

	${git} "${DIR}/patches/pru/0003-Add-rpmsg_pru-support.patch"
	${git} "${DIR}/patches/pru/0004-Update-from-git.ti.com-rpmsg-rpmsg.patch"

	if [ "x${regenerate}" = "xenable" ] ; then
		number=2
		cleanup
	fi
}

###
reverts
backports
#fixes
x15
pru_uio
pru_rpmsg
bbb_overlays
beaglebone
quieter


packaging () {
	echo "dir: packaging"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		cp -v "${DIR}/3rdparty/packaging/builddeb" "${DIR}/KERNEL/scripts/package"
		git commit -a -m 'packaging: sync builddeb changes' -s
		git format-patch -1 -o "${DIR}/patches/packaging"
		exit 2
	else
		${git} "${DIR}/patches/packaging/0001-packaging-sync-builddeb-changes.patch"
	fi
}

packaging
echo "patch.sh ran successfully"

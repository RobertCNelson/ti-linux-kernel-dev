#!/bin/bash -e
#
# Copyright (c) 2009-2018 Robert Nelson <robertcnelson@gmail.com>
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
			${git_bin} clone -b aufs${KERNEL_REL} https://github.com/sfjro/aufs4-standalone --depth=1
		else
			rm -rf ./aufs4-standalone || true
			${git_bin} clone -b aufs${KERNEL_REL} https://github.com/sfjro/aufs4-standalone --depth=1
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

		rm -rf ../aufs4-standalone/ || true

		${git_bin} reset --hard HEAD~5

		start_cleanup

		${git} "${DIR}/patches/aufs4/0001-merge-aufs4-kbuild.patch"
		${git} "${DIR}/patches/aufs4/0002-merge-aufs4-base.patch"
		${git} "${DIR}/patches/aufs4/0003-merge-aufs4-mmap.patch"
		${git} "${DIR}/patches/aufs4/0004-merge-aufs4-standalone.patch"
		${git} "${DIR}/patches/aufs4/0005-merge-aufs4.patch"

		wdir="aufs4"
		number=5
		cleanup
	fi

	${git} "${DIR}/patches/aufs4/0001-merge-aufs4-kbuild.patch"
	${git} "${DIR}/patches/aufs4/0002-merge-aufs4-base.patch"
	${git} "${DIR}/patches/aufs4/0003-merge-aufs4-mmap.patch"
	${git} "${DIR}/patches/aufs4/0004-merge-aufs4-standalone.patch"
	${git} "${DIR}/patches/aufs4/0005-merge-aufs4.patch"
}

rt_cleanup () {
	echo "rt: needs fixup"
	exit 2
}

rt () {
	echo "dir: rt"
	rt_patch="${KERNEL_REL}${kernel_rt}"

	#${git_bin} revert --no-edit xyz

	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		wget -c https://www.kernel.org/pub/linux/kernel/projects/rt/${KERNEL_REL}/patch-${rt_patch}.patch.xz
		xzcat patch-${rt_patch}.patch.xz | patch -p1 || rt_cleanup
		rm -f patch-${rt_patch}.patch.xz
		rm -f localversion-rt
		${git_bin} add .
		${git_bin} commit -a -m 'merge: CONFIG_PREEMPT_RT Patch Set' -s
		${git_bin} format-patch -1 -o ../patches/rt/

		exit 2
	fi

	${git} "${DIR}/patches/rt/0001-merge-CONFIG_PREEMPT_RT-Patch-Set.patch"
}

wireguard_fail () {
	echo "WireGuard failed"
	exit 2
}

wireguard () {
	echo "dir: WireGuard"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		cd ../
		if [ ! -d ./WireGuard ] ; then
			${git_bin} clone https://git.zx2c4.com/WireGuard --depth=1
		else
			rm -rf ./WireGuard || true
			${git_bin} clone https://git.zx2c4.com/WireGuard --depth=1
		fi
		cd ./KERNEL/

		../WireGuard/contrib/kernel-tree/create-patch.sh | patch -p1 || wireguard_fail

		${git_bin} add .
		${git_bin} commit -a -m 'merge: WireGuard' -s
		${git_bin} format-patch -1 -o ../patches/WireGuard/

		rm -rf ../WireGuard/ || true

		${git_bin} reset --hard HEAD^

		start_cleanup

		${git} "${DIR}/patches/WireGuard/0001-merge-WireGuard.patch"

		wdir="WireGuard"
		number=1
		cleanup
	fi

	${git} "${DIR}/patches/WireGuard/0001-merge-WireGuard.patch"
}

ti_pm_firmware () {
	#http://git.ti.com/gitweb/?p=processor-firmware/ti-amx3-cm3-pm-firmware.git;a=shortlog;h=refs/heads/ti-v4.1.y-next
	echo "dir: drivers/ti/firmware"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then

		cd ../
		if [ ! -d ./ti-amx3-cm3-pm-firmware ] ; then
			${git_bin} clone -b ti-v4.1.y-next git://git.ti.com/processor-firmware/ti-amx3-cm3-pm-firmware.git --depth=1
		else
			rm -rf ./ti-amx3-cm3-pm-firmware || true
			${git_bin} clone -b ti-v4.1.y-next git://git.ti.com/processor-firmware/ti-amx3-cm3-pm-firmware.git --depth=1
		fi
		cd ./KERNEL/

		cp -v ../ti-amx3-cm3-pm-firmware/bin/am* ./firmware/

		${git_bin} add -f ./firmware/am*
		${git_bin} commit -a -m 'add am33x firmware' -s
		${git_bin} format-patch -1 -o ../patches/drivers/ti/firmware/

		rm -rf ../ti-amx3-cm3-pm-firmware/ || true

		${git_bin} reset --hard HEAD^

		start_cleanup

		${git} "${DIR}/patches/drivers/ti/firmware/0001-add-am33x-firmware.patch"

		wdir="drivers/ti/firmware"
		number=1
		cleanup
	fi

	${git} "${DIR}/patches/drivers/ti/firmware/0001-add-am33x-firmware.patch"
}

local_patch () {
	echo "dir: dir"
	${git} "${DIR}/patches/dir/0001-patch.patch"
}

external_git
aufs4
#rt
wireguard
ti_pm_firmware
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

	${git_bin} add .
	${git_bin} commit -a -m "backports: ${subsystem}: from: linux.git" -s
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
	backport_tag="v4.20-rc1"

	subsystem="brcm80211"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		pre_backports

		cp -rv ~/linux-src/drivers/net/wireless/broadcom/brcm80211/* ./drivers/net/wireless/broadcom/brcm80211/

		post_backports
		exit 2
	else
		patch_backports
		dir 'backports/brcm80211_post'
	fi
}

reverts () {
	echo "dir: reverts"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		start_cleanup
	fi

	## notes
	##git revert --no-edit xyz -s

	#${git} "${DIR}/patches/reverts/0001-Revert-xyz.patch"

	if [ "x${regenerate}" = "xenable" ] ; then
		wdir="reverts"
		number=1
		cleanup
	fi
}

drivers_cypress () {
	#https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/log/drivers/net/wireless/broadcom/brcm80211?h=v4.20-rc1

#	${git} "${DIR}/patches/drivers/cypress/2018_0928/0001-brcmfmac-add-CLM-download-support.patch" # [v4.15-rc1]
	${git} "${DIR}/patches/drivers/cypress/2018_0928/0002-brcmfmac-Set-F2-blksz-and-Watermark-to-256-for-4373.patch" # [x]
	${git} "${DIR}/patches/drivers/cypress/2018_0928/0003-brcmfmac-Add-sg-parameters-dts-parsing.patch"
#	${git} "${DIR}/patches/drivers/cypress/2018_0928/0004-brcmfmac-return-EPERM-when-getting-error-in-vendor-c.patch" # [v4.16-rc1]
	${git} "${DIR}/patches/drivers/cypress/2018_0928/0005-brcmfmac-Add-support-for-CYW43012-SDIO-chipset.patch"
	${git} "${DIR}/patches/drivers/cypress/2018_0928/0006-brcmfmac-set-apsta-to-0-when-AP-starts-on-primary-in.patch"
	${git} "${DIR}/patches/drivers/cypress/2018_0928/0007-brcmfmac-Saverestore-support-changes-for-43012.patch"
#	${git} "${DIR}/patches/drivers/cypress/2018_0928/0008-brcmfmac-Support-43455-save-restore-SR-feature-if-FW.patch" # [v4.16-rc1]
	${git} "${DIR}/patches/drivers/cypress/2018_0928/0009-brcmfmac-fix-CLM-load-error-for-legacy-chips-when-us.patch" # [x]
#	${git} "${DIR}/patches/drivers/cypress/2018_0928/0010-brcmfmac-enlarge-buffer-size-of-caps-to-512-bytes.patch" # [v4.16-rc1]
	${git} "${DIR}/patches/drivers/cypress/2018_0928/0011-brcmfmac-calling-skb_orphan-before-sending-skb-to-SD.patch"
	${git} "${DIR}/patches/drivers/cypress/2018_0928/0012-brcmfmac-43012-Update-F2-Watermark-to-0x60-to-fix-DM.patch" # [x]
	${git} "${DIR}/patches/drivers/cypress/2018_0928/0013-brcmfmac-DS1-Exit-should-re-download-the-firmware.patch"
	${git} "${DIR}/patches/drivers/cypress/2018_0928/0014-brcmfmac-add-FT-based-AKMs-in-brcmf_set_key_mgmt-for.patch"
#	${git} "${DIR}/patches/drivers/cypress/2018_0928/0015-brcmfmac-Add-support-for-43428-SDIO-device-ID.patch" # [4.18-rc1]
	${git} "${DIR}/patches/drivers/cypress/2018_0928/0016-brcmfmac-support-AP-isolation.patch"
	${git} "${DIR}/patches/drivers/cypress/2018_0928/0017-brcmfmac-do-not-print-ulp_sdioctrl-get-error.patch"
	${git} "${DIR}/patches/drivers/cypress/2018_0928/0018-brcmfmac-fix-system-warning-message-during-wowl-susp.patch"
	${git} "${DIR}/patches/drivers/cypress/2018_0928/0019-brcmfmac-add-a-module-parameter-to-set-scheduling-pr.patch" # [x]
	${git} "${DIR}/patches/drivers/cypress/2018_0928/0020-brcmfmac-make-firmware-eap_restrict-a-module-paramet.patch"
	${git} "${DIR}/patches/drivers/cypress/2018_0928/0021-brcmfmac-Support-wake-on-ping-packet.patch"
	${git} "${DIR}/patches/drivers/cypress/2018_0928/0022-brcmfmac-Remove-WOWL-configuration-in-disconnect-sta.patch"
	${git} "${DIR}/patches/drivers/cypress/2018_0928/0023-brcmfmac-add-CYW89342-PCIE-device.patch"
	${git} "${DIR}/patches/drivers/cypress/2018_0928/0024-brcmfmac-handle-compressed-tx-status-signal.patch"
	${git} "${DIR}/patches/drivers/cypress/2018_0928/0025-revert-brcmfmac-add-a-module-parameter-to-set-schedu.patch" # [x]
	${git} "${DIR}/patches/drivers/cypress/2018_0928/0026-brcmfmac-make-setting-SDIO-workqueue-WQ_HIGHPRI-a-mo.patch" # [x]
	${git} "${DIR}/patches/drivers/cypress/2018_0928/0027-brcmfmac-add-credit-map-updating-support.patch"
	${git} "${DIR}/patches/drivers/cypress/2018_0928/0028-brcmfmac-add-4-way-handshake-offload-detection-for-F.patch"
	${git} "${DIR}/patches/drivers/cypress/2018_0928/0029-brcmfmac-remove-arp_hostip_clear-from-brcmf_netdev_s.patch"
	${git} "${DIR}/patches/drivers/cypress/2018_0928/0030-brcmfmac-fix-unused-variable-building-warning-messag.patch"
	${git} "${DIR}/patches/drivers/cypress/2018_0928/0031-brcmfmac-disable-command-decode-in-sdio_aos-for-4339.patch"
	${git} "${DIR}/patches/drivers/cypress/2018_0928/0032-Revert-brcmfmac-fix-CLM-load-error-for-legacy-chips-.patch" # [x]
#	${git} "${DIR}/patches/drivers/cypress/2018_0928/0033-brcmfmac-fix-CLM-load-error-for-legacy-chips-when-us.patch" # [v4.15-rc9]
#	${git} "${DIR}/patches/drivers/cypress/2018_0928/0034-brcmfmac-set-WIPHY_FLAG_HAVE_AP_SME-flag.patch" # [v4.18-rc1]
	${git} "${DIR}/patches/drivers/cypress/2018_0928/0035-brcmfmac-P2P-CERT-6.1.9-Support-GOUT-handling-P2P-Pr.patch"
	${git} "${DIR}/patches/drivers/cypress/2018_0928/0036-brcmfmac-only-generate-random-p2p-address-when-neede.patch"
	${git} "${DIR}/patches/drivers/cypress/2018_0928/0037-brcmfmac-disable-command-decode-in-sdio_aos-for-4354.patch"
	${git} "${DIR}/patches/drivers/cypress/2018_0928/0038-brcmfmac-increase-max-hanger-slots-from-1K-to-3K-in-.patch"
	${git} "${DIR}/patches/drivers/cypress/2018_0928/0039-brcmfmac-reduce-timeout-for-action-frame-scan.patch"
	${git} "${DIR}/patches/drivers/cypress/2018_0928/0040-brcmfmac-fix-full-timeout-waiting-for-action-frame-o.patch"
	${git} "${DIR}/patches/drivers/cypress/2018_0928/0041-brcmfmac-4373-save-restore-support.patch"
	${git} "${DIR}/patches/drivers/cypress/2018_0928/0042-brcmfmac-map-802.1d-priority-to-precedence-level-bas.patch"
	${git} "${DIR}/patches/drivers/cypress/2018_0928/0043-brcmfmac-allow-GCI-core-enumuration.patch"
	${git} "${DIR}/patches/drivers/cypress/2018_0928/0044-brcmfmac-make-firmware-frameburst-mode-a-module-para.patch"
	${git} "${DIR}/patches/drivers/cypress/2018_0928/0045-brcmfmac-set-state-of-hanger-slot-to-FREE-when-flush.patch"
	${git} "${DIR}/patches/drivers/cypress/2018_0928/0046-brcmfmac-add-creating-station-interface-support.patch"
	${git} "${DIR}/patches/drivers/cypress/2018_0928/0047-brcmfmac-add-RSDB-condition-when-setting-interface-c.patch"
	${git} "${DIR}/patches/drivers/cypress/2018_0928/0048-brcmfmac-not-set-mbss-in-vif-if-firmware-does-not-su.patch"
	${git} "${DIR}/patches/drivers/cypress/2018_0928/0049-brcmfmac-support-the-second-p2p-connection.patch"
	${git} "${DIR}/patches/drivers/cypress/2018_0928/0050-brcmfmac-Add-support-for-BCM4359-SDIO-chipset.patch"
#	${git} "${DIR}/patches/drivers/cypress/2018_0928/0051-cfg80211-nl80211-add-a-port-authorized-event.patch" # [4.15-rc1]
	${git} "${DIR}/patches/drivers/cypress/2018_0928/0052-nl80211-add-NL80211_ATTR_IFINDEX-to-port-authorized-.patch"
	${git} "${DIR}/patches/drivers/cypress/2018_0928/0053-brcmfmac-send-port-authorized-event-for-802.1X-4-way.patch"
	${git} "${DIR}/patches/drivers/cypress/2018_0928/0054-brcmfmac-send-port-authorized-event-for-FT-802.1X.patch"
	${git} "${DIR}/patches/drivers/cypress/2018_0928/0055-brcmfmac-Support-DS1-TX-Exit-in-FMAC.patch"
	${git} "${DIR}/patches/drivers/cypress/2018_0928/0056-brcmfmac-disable-command-decode-in-sdio_aos-for-4373.patch"
	${git} "${DIR}/patches/drivers/cypress/2018_0928/0057-brcmfmac-add-vendor-ie-for-association-responses.patch"
	${git} "${DIR}/patches/drivers/cypress/2018_0928/0058-brcmfmac-fix-43012-insmod-after-rmmod-in-DS1-failure.patch"
	${git} "${DIR}/patches/drivers/cypress/2018_0928/0059-brcmfmac-Set-SDIO-F1-MesBusyCtrl-for-CYW4373.patch"
	${git} "${DIR}/patches/drivers/cypress/2018_0928/0060-brcmfmac-add-4354-raw-pcie-device-id.patch"
	${git} "${DIR}/patches/drivers/cypress/2018_0928/0061-nl80211-Allow-SAE-Authentication-for-NL80211_CMD_CON.patch" # [4.17-rc1]
#	${git} "${DIR}/patches/drivers/cypress/2018_0928/0062-non-upstream-update-enum-nl80211_attrs-and-nl80211_e.patch" # [x]
	${git} "${DIR}/patches/drivers/cypress/2018_0928/0063-nl80211-add-WPA3-definition-for-SAE-authentication.patch"
	${git} "${DIR}/patches/drivers/cypress/2018_0928/0064-cfg80211-add-support-for-SAE-authentication-offload.patch"
	${git} "${DIR}/patches/drivers/cypress/2018_0928/0065-brcmfmac-add-support-for-SAE-authentication-offload.patch"
	${git} "${DIR}/patches/drivers/cypress/2018_0928/0066-brcmfmac-fix-4339-CRC-error-under-SDIO-3.0-SDR104-mo.patch"
	${git} "${DIR}/patches/drivers/cypress/2018_0928/0067-brcmfmac-fix-the-incorrect-return-value-in-brcmf_inf.patch"
	${git} "${DIR}/patches/drivers/cypress/2018_0928/0068-brcmfmac-Fix-double-freeing-in-the-fmac-usb-data-pat.patch"
	${git} "${DIR}/patches/drivers/cypress/2018_0928/0069-brcmfmac-Fix-driver-crash-on-USB-control-transfer-ti.patch"
	${git} "${DIR}/patches/drivers/cypress/2018_0928/0070-brcmfmac-avoid-network-disconnection-during-suspend-.patch"
	${git} "${DIR}/patches/drivers/cypress/2018_0928/0071-brcmfmac-Allow-credit-borrowing-for-all-access-categ.patch"
	${git} "${DIR}/patches/drivers/cypress/2018_0928/0072-non-upstream-Changes-to-improve-USB-Tx-throughput.patch" # [x]
	${git} "${DIR}/patches/drivers/cypress/2018_0928/0073-non-upstream-reset-two-D11-cores-if-chip-has-two-D11.patch" # [x]
	${git} "${DIR}/patches/drivers/cypress/2018_0928/0074-brcmfmac-reset-PMU-backplane-all-cores-in-CYW4373-du.patch"
	${git} "${DIR}/patches/drivers/cypress/2018_0928/0075-brcmfmac-introduce-module-parameter-to-configure-def.patch"
	${git} "${DIR}/patches/drivers/cypress/2018_0928/0076-brcmfmac-configure-wowl-parameters-in-suspend-functi.patch"
	${git} "${DIR}/patches/drivers/cypress/2018_0928/0077-brcmfmac-discard-user-space-RSNE-for-SAE-authenticat.patch"

#Note: [*] is the upstream tag containing the patch
#      [x] means no plan to upstream

}

drivers () {
	#wip in progress.
#	dir 'drivers/bcmdhd'
	dir 'drivers/ar1021_i2c'
	dir 'drivers/btrfs'
	dir 'drivers/pwm'
#	dir 'drivers/lora'
	dir 'drivers/snd_pwmsp'
	dir 'drivers/spi'
	dir 'drivers/ssd1306'
	dir 'drivers/tps65217'
	dir 'drivers/opp'
	dir 'drivers/wiznet'
	dir 'drivers/ti/overlays'
	dir 'drivers/ti/cpsw'
	dir 'drivers/ti/etnaviv'
	dir 'drivers/ti/eqep'
	dir 'drivers/ti/rpmsg'
#needs ti driver...
#	dir 'drivers/ti/pru_rproc'
	dir 'drivers/ti/serial'
#Goal, use mainline spi number...
#	dir 'drivers/ti/spi'
	dir 'drivers/ti/tsc'
#Needs to be ported...
#	dir 'drivers/ti/uio'
	dir 'drivers/ti/gpio'
}

soc () {
	dir 'soc/ti'
	dir 'soc/ti/bone_common'
	dir 'soc/ti/uboot'
	dir 'soc/ti/blue'
	dir 'soc/ti/beaglebone_capes'
	dir 'soc/ti/pocketbeagle'
	dir 'soc/ti/uboot_univ'
}

dtb_makefile_append () {
	sed -i -e 's:am335x-boneblack.dtb \\:am335x-boneblack.dtb \\\n\t'$device' \\:g' arch/arm/boot/dts/Makefile
}

beaglebone () {
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

		device="am335x-boneblack-uboot.dtb" ; dtb_makefile_append

		device="am335x-boneblack-wl1835mod.dtb" ; dtb_makefile_append

		device="am335x-boneblack-bbbmini.dtb" ; dtb_makefile_append

		device="am335x-boneblack-bbb-exp-c.dtb" ; dtb_makefile_append
		device="am335x-boneblack-bbb-exp-r.dtb" ; dtb_makefile_append

		device="am335x-boneblack-audio.dtb" ; dtb_makefile_append

		device="am335x-bone-uboot-univ.dtb" ; dtb_makefile_append
		device="am335x-boneblack-uboot-univ.dtb" ; dtb_makefile_append
		device="am335x-bonegreen-wireless-uboot-univ.dtb" ; dtb_makefile_append

		git commit -a -m 'auto generated: capes: add dtbs to makefile' -s
		git format-patch -1 -o ../patches/beaglebone/generated/
		exit 2
	else
		${git} "${DIR}/patches/beaglebone/generated/0001-auto-generated-capes-add-dtbs-to-makefile.patch"
	fi
}

###
backports
#reverts
#drivers_cypress
drivers
soc
beaglebone
#dir 'drivers/ti/sgx'

packaging () {
	echo "dir: packaging"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		cp -v "${DIR}/3rdparty/packaging/Makefile" "${DIR}/KERNEL/scripts/package"
		cp -v "${DIR}/3rdparty/packaging/builddeb" "${DIR}/KERNEL/scripts/package"
		#Needed for v4.11.x and less
		#patch -p1 < "${DIR}/patches/packaging/0002-Revert-deb-pkg-Remove-the-KBUILD_IMAGE-workaround.patch"
		${git_bin} commit -a -m 'packaging: sync builddeb changes' -s
		${git_bin} format-patch -1 -o "${DIR}/patches/packaging"
		exit 2
	else
		${git} "${DIR}/patches/packaging/0001-packaging-sync-builddeb-changes.patch"
	fi
}

readme () {
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		cp -v "${DIR}/3rdparty/readme/README.md" "${DIR}/KERNEL/README.md"
		cp -v "${DIR}/3rdparty/readme/jenkins_build.sh" "${DIR}/KERNEL/jenkins_build.sh"
		cp -v "${DIR}/3rdparty/readme/Jenkinsfile" "${DIR}/KERNEL/Jenkinsfile"
		git add -f README.md
		git add -f jenkins_build.sh
		git add -f Jenkinsfile
		git commit -a -m 'enable: Jenkins: http://rcn-ee.online:8080' -s
		git format-patch -1 -o "${DIR}/patches/readme"
		exit 2
	else
		dir 'readme'
	fi
}

packaging
readme
echo "patch.sh ran successfully"

#!/bin/sh -e

#yeah, i'm getting lazy..

wfile=$(mktemp /tmp/builder.XXXXXXXXX)
echo "Working on temp $wfile ..."

cat_files () {
	if [ -f ../patches/external/git/BBDTBS ] ; then
		cat ../patches/external/git/BBDTBS >> ${wfile}
	fi

	if [ -f ../patches/external/git/RT ] ; then
		cat ../patches/external/git/RT >> ${wfile}
	fi

	if [ -f ../patches/external/git/WIRELESS_REGDB ] ; then
		cat ../patches/external/git/WIRELESS_REGDB >> ${wfile}
	fi

	if [ -f ../patches/external/git/TI_AMX3_CM3 ] ; then
		cat ../patches/external/git/TI_AMX3_CM3 >> ${wfile}
	fi

	if [ -f ../patches/external/git/WPANUSB ] ; then
		cat ../patches/external/git/WPANUSB >> ${wfile}
	fi
}

DIR=$PWD
git_bin=$(which git)

repo_gitlab="git@openbeagle.org:beagleboard/linux.git"
example="bb.org"
compare="https://github.com/RobertCNelson/ti-linux-kernel/compare"

if [ -e ${DIR}/version.sh ]; then
	unset BRANCH
	. ${DIR}/version.sh

	cd ${DIR}/KERNEL/
	make ARCH=${KERNEL_ARCH} distclean

	cp ${DIR}/patches/defconfig ${DIR}/KERNEL/.config
	make ARCH=${KERNEL_ARCH} savedefconfig
	cp ${DIR}/KERNEL/defconfig ${DIR}/KERNEL/arch/${KERNEL_ARCH}/configs/${example}_defconfig
	${git_bin} add arch/${KERNEL_ARCH}/configs/${example}_defconfig
	if [ -f arch/${KERNEL_ARCH}/configs/ti_sdk_release_defconfig ] ; then
		${git_bin} add arch/${KERNEL_ARCH}/configs/ti_sdk_release_defconfig
	fi
	if [ -f arch/${KERNEL_ARCH}/configs/ti_sdk_rt_release_defconfig ] ; then
		${git_bin} add arch/${KERNEL_ARCH}/configs/ti_sdk_rt_release_defconfig
	fi
	if [ -f arch/${KERNEL_ARCH}/configs/ti_sdk_arm64_release_defconfig ] ; then
		${git_bin} add arch/${KERNEL_ARCH}/configs/ti_sdk_arm64_release_defconfig
	fi
	if [ -f arch/${KERNEL_ARCH}/configs/ti_sdk_arm64_rt_release_defconfig ] ; then
		${git_bin} add arch/${KERNEL_ARCH}/configs/ti_sdk_arm64_rt_release_defconfig
	fi

	if [ "x${ti_git_old_release}" = "x${ti_git_new_release}" ] ; then
		echo "${KERNEL_TAG}${BUILD}" > ${wfile}
		echo "${KERNEL_TAG}${BUILD} ${example}_defconfig" >> ${wfile}
		if [ "${TISDK}" ] ; then
			echo "TI SDK: ${TISDK}" >> ${wfile}
		fi
		cat_files
	else
		echo "${KERNEL_TAG}${BUILD}" > ${wfile}
		echo "${KERNEL_TAG}${BUILD} ${example}_defconfig" >> ${wfile}
		if [ "${TISDK}" ] ; then
			echo "TI SDK: ${TISDK}" >> ${wfile}
		fi
		echo "${KERNEL_REL} TI Delta: ${compare}/${ti_git_old_release}...${ti_git_new_release}" >> ${wfile}
		cat_files
	fi
	${git_bin} commit -a -F ${wfile} -s

	${git_bin} tag -a "${KERNEL_TAG}${BUILD}" -F ${wfile} -f

	#push tag
	echo "log: git: pushing tags..."

	echo "log: git push -f ${repo_gitlab} ${KERNEL_TAG}${BUILD}"
	${git_bin} push -f ${repo_gitlab} "${KERNEL_TAG}${BUILD}"

	echo "debug: creating branch v${KERNEL_TAG}${BUILD}"

	${git_bin} branch -D v${KERNEL_TAG}${BUILD} || true

	${git_bin} branch -m v${KERNEL_TAG}${BUILD} v${KERNEL_TAG}${BUILD}

	#push branch
	echo "log: git: pushing branch v${KERNEL_TAG}${BUILD}..."

	echo "log: git push -f ${repo_gitlab} v${KERNEL_TAG}${BUILD}"
	${git_bin} push -f ${repo_gitlab} v${KERNEL_TAG}${BUILD}

	cd ${DIR}/
fi

echo "Deleting $wfile ..."
rm -f "$wfile"

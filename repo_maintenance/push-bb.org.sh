#!/bin/sh -e

#yeah, i'm getting lazy..

wfile=$(mktemp /tmp/builder.XXXXXXXXX)
echo "Working on temp $wfile ..."

cat_files () {
	if [ -f ../patches/git/AUFS ] ; then
		cat ../patches/git/AUFS >> ${wfile}
	fi

	if [ -f ../patches/git/BBDTBS ] ; then
		cat ../patches/git/BBDTBS >> ${wfile}
	fi

	if [ -f ../patches/git/RT ] ; then
		cat ../patches/git/RT >> ${wfile}
	fi

	if [ -f ../patches/git/TI_AMX3_CM3 ] ; then
		cat ../patches/git/TI_AMX3_CM3 >> ${wfile}
	fi

	if [ -f ../patches/git/WPANUSB ] ; then
		cat ../patches/git/WPANUSB >> ${wfile}
	fi

	if [ -f ../patches/git/BCFSERIAL ] ; then
		cat ../patches/git/BCFSERIAL >> ${wfile}
	fi

	if [ -f ../patches/git/WIRELESS_REGDB ] ; then
		cat ../patches/git/WIRELESS_REGDB >> ${wfile}
	fi

	if [ -f ../patches/git/KSMBD ] ; then
		cat ../patches/git/KSMBD >> ${wfile}
	fi
}

DIR=$PWD
git_bin=$(which git)

repo_github="git@github.com:beagleboard/linux.git"
repo_gitlab="git@git.beagleboard.org:beagleboard/linux.git"
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
	#${git_bin} add arch/${KERNEL_ARCH}/configs/ti_sdk_am3x_release_defconfig
	#${git_bin} add arch/${KERNEL_ARCH}/configs/ti_sdk_dra7x_release_defconfig
	${git_bin} add arch/${KERNEL_ARCH}/configs/ti_sdk_arm64_release_defconfig

	if [ "x${ti_git_old_release}" = "x${ti_git_new_release}" ] ; then
		echo "${KERNEL_TAG}${BUILD}" > ${wfile}
		echo "${KERNEL_TAG}${BUILD} ${example}_defconfig" >> ${wfile}
		if [ "${TISDK}" ] ; then
			echo "TI: ${TISDK}" >> ${wfile}
		fi
		cat_files
	else
		echo "${KERNEL_TAG}${BUILD}" > ${wfile}
		echo "${KERNEL_TAG}${BUILD} ${example}_defconfig" >> ${wfile}
		echo "${KERNEL_REL} TI Delta: ${compare}/${ti_git_old_release}...${ti_git_new_release}" >> ${wfile}
		if [ "${TISDK}" ] ; then
			echo "TI: ${TISDK}" >> ${wfile}
		fi
		cat_files
	fi
	${git_bin} commit -a -F ${wfile} -s

	${git_bin} tag -a "${KERNEL_TAG}${BUILD}" -F ${wfile} -f

	#push tag
	echo "log: git: pushing tags..."

	echo "log: git push -f ${repo_github} ${KERNEL_TAG}${BUILD}"
	${git_bin} push -f ${repo_github} "${KERNEL_TAG}${BUILD}"

	echo "log: git push -f ${repo_gitlab} ${KERNEL_TAG}${BUILD}"
	${git_bin} push -f ${repo_gitlab} "${KERNEL_TAG}${BUILD}"

	echo "debug: pushing ${bborg_branch}"

	${git_bin} branch -D ${bborg_branch} || true

	${git_bin} branch -m v${KERNEL_TAG}${BUILD} ${bborg_branch}

	#push branch
	echo "log: git: pushing branch..."

	echo "log: git push -f ${repo_github} ${bborg_branch}"
	${git_bin} push -f ${repo_github} ${bborg_branch}

	echo "log: git push -f ${repo_gitlab} ${bborg_branch}"
	${git_bin} push -f ${repo_gitlab} ${bborg_branch}

	cd ${DIR}/
fi

echo "Deleting $wfile ..."
rm -f "$wfile"

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

cleanup_dts_builds () {
	rm -rf arch/arm64/boot/dts/ti/modules.order || true
	rm -rf arch/arm64/boot/dts/ti/.*cmd || true
	rm -rf arch/arm64/boot/dts/ti/.*tmp || true
	rm -rf arch/arm64/boot/dts/ti/*dtb || true
	rm -rf arch/arm64/boot/dts/ti/*dtbo || true
}

dtb_makefile_append () {
	echo "dtb-\$(CONFIG_ARCH_K3) += $device" >> arch/arm64/boot/dts/ti/Makefile
}

beagleboard_dtbs () {
	branch="v5.10.x-ti-arm64"
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

		cleanup_dts_builds

		cp -vr ../${work_dir}/src/arm64/* arch/arm64/boot/dts/ti/
		cp -vr ../${work_dir}/include/dt-bindings/* ./include/dt-bindings/

		device="k3-j721e-beagleboneai64.dtb" ; dtb_makefile_append

		${git_bin} add -f arch/arm64/boot/dts/ti/
		${git_bin} add -f include/dt-bindings/
		${git_bin} commit -a -m "Add BeagleBoard.org Device Tree Changes" -m "${https_repo}/tree/${branch}" -m "${https_repo}/commit/${git_hash}" -s
		${git_bin} format-patch -1 -o ../patches/soc/ti/beagleboard_dtbs/
		echo "BBDTBS: ${https_repo}/commit/${git_hash}" > ../patches/git/BBDTBS

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
#rt
wireless_regdb
beagleboard_dtbs
#local_patch
dir 'fixes'

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

drivers () {
	dir 'drivers/spi'
}

###
drivers

packaging () {
	do_backport="enable"
	if [ "x${do_backport}" = "xenable" ] ; then
		backport_tag="v5.14.10"

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
	${git} "${DIR}/patches/backports/bindeb-pkg/0003-builddeb-copy-arm64-boot-Image-to-boot.patch"
}

packaging
echo "patch.sh ran successfully"

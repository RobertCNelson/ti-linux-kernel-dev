#!/bin/sh
#
# Copyright (c) 2009-2014 Robert Nelson <robertcnelson@gmail.com>
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

git="git am"
git_patchset="git://git.ti.com/ti-linux-kernel/ti-linux-kernel.git"
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
	exit
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

pinmux () {
	echo "dir: pinmux"
#start_cleanup
	# cp arch/arm/boot/dts/am335x-bone-common.dtsi arch/arm/boot/dts/am335x-bone-common-pinmux.dtsi
	# gedit arch/arm/boot/dts/am335x-bone-common.dtsi arch/arm/boot/dts/am335x-bone-common-pinmux.dtsi &
	# gedit arch/arm/boot/dts/am335x-boneblack.dts arch/arm/boot/dts/am335x-bone.dts &
	# git add arch/arm/boot/dts/am335x-bone-common-pinmux.dtsi
	# git commit -a -m 'am335x-bone-common: split out am33xx_pinmux' -s

	${git} "${DIR}/patches/pinmux/0001-am335x-bone-common-split-out-am33xx_pinmux.patch"

	# meld arch/arm/boot/dts/am335x-bone-common-pinmux.dtsi arch/arm/boot/dts/am335x-boneblack.dts
	# git commit -a -m 'am335x-boneblack: split out am33xx_pinmux' -s

	${git} "${DIR}/patches/pinmux/0002-am335x-boneblack-split-out-am33xx_pinmux.patch"

	# cp arch/arm/boot/dts/am335x-boneblack.dts arch/arm/boot/dts/am335x-boneblack-emmc.dtsi
	# gedit arch/arm/boot/dts/am335x-boneblack.dts arch/arm/boot/dts/am335x-boneblack-emmc.dtsi &
	# git add arch/arm/boot/dts/am335x-boneblack-emmc.dtsi
	# git commit -a -m 'am335x-boneblack: split out emmc' -s

	${git} "${DIR}/patches/pinmux/0003-am335x-boneblack-split-out-emmc.patch"

	# cp arch/arm/boot/dts/am335x-boneblack.dts arch/arm/boot/dts/am335x-boneblack-nxp-hdmi.dtsi
	# gedit arch/arm/boot/dts/am335x-boneblack.dts arch/arm/boot/dts/am335x-boneblack-nxp-hdmi.dtsi &
	# git add arch/arm/boot/dts/am335x-boneblack-nxp-hdmi.dtsi
	# git commit -a -m 'am335x-boneblack: split out nxp hdmi' -s

	${git} "${DIR}/patches/pinmux/0004-am335x-boneblack-split-out-nxp-hdmi.patch"

	${git} "${DIR}/patches/pinmux/0005-am335x-bone-common-pinmux-i2c2.patch"
	${git} "${DIR}/patches/pinmux/0006-am335x-bone-common-pinmux-uart.patch"
	${git} "${DIR}/patches/pinmux/0007-am335x-bone-common-pinmux-spi.patch"
	${git} "${DIR}/patches/pinmux/0008-am335x-bone-common-pinmux-mcasp0.patch"
	${git} "${DIR}/patches/pinmux/0009-am335x-bone-common-pinmux-lcd4.patch"
#number=9
#cleanup
}

###
pinmux

packaging_setup () {
	cp -v "${DIR}/3rdparty/packaging/builddeb" "${DIR}/KERNEL/scripts/package"
	git commit -a -m 'packaging: sync with mainline' -s

	git format-patch -1 -o "${DIR}/patches/packaging"
}

packaging () {
	echo "dir: packaging"
	${git} "${DIR}/patches/packaging/0001-packaging-sync-with-mainline.patch"
	${git} "${DIR}/patches/packaging/0002-deb-pkg-install-dtbs-in-linux-image-package.patch"
	${git} "${DIR}/patches/packaging/0003-deb-pkg-no-dtbs_install.patch"
}

#packaging_setup
packaging
echo "patch.sh ran successful"

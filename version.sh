#!/bin/sh
#
ARCH=$(uname -m)

#Debian 7 (Wheezy): git version 1.7.10.4 and later needs "--no-edit"
unset git_opts
git_no_edit=$(LC_ALL=C git help pull | grep -m 1 -e "--no-edit" || true)
if [ ! "x${git_no_edit}" = "x" ] ; then
	git_opts="--no-edit"
fi

config="omap2plus_defconfig"

build_prefix="ti"
branch_prefix=""

#toolchain="gcc_linaro_eabi_4_8"
#toolchain="gcc_linaro_eabi_4_9"
#toolchain="gcc_linaro_gnueabi_4_6"
#toolchain="gcc_linaro_gnueabihf_4_7"
toolchain="gcc_linaro_gnueabihf_4_8"
#toolchain="gcc_linaro_gnueabihf_4_9"

#Kernel/Build
KERNEL_REL=3.14
KERNEL_TAG=${KERNEL_REL}.37
BUILD=${build_prefix}-r57.3

#v3.X-rcX + upto SHA
#prev_KERNEL_SHA=""
#KERNEL_SHA=""

#git branch
BRANCH="ti-linux-${branch_prefix}3.14.y"

DISTRO=cross
DEBARCH=armhf

ti_git_old_release="01a3476723a06c55c6491e31b23e308df3ba73e4"
ti_git_pre="dcb1efb334b2d125e6ddbebf1d7401dbbf3fd220"
ti_git_post="18befee57e0640c81b4909d7e3f4805200b2acef"
#

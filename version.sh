#!/bin/sh
#
ARCH=$(uname -m)

if [ $(which nproc) ] ; then
	CORES=$(nproc)
else
	CORES=1
fi

#Debian 7 (Wheezy): git version 1.7.10.4 and later needs "--no-edit"
unset git_opts
git_no_edit=$(LC_ALL=C git help pull | grep -m 1 -e "--no-edit" || true)
if [ ! "x${git_no_edit}" = "x" ] ; then
	git_opts="--no-edit"
fi

config="omap2plus_defconfig"

#toolchain="gcc_linaro_eabi_4_8"
#toolchain="gcc_linaro_eabi_4_9"
#toolchain="gcc_linaro_gnueabi_4_6"
#toolchain="gcc_linaro_gnueabihf_4_7"
toolchain="gcc_linaro_gnueabihf_4_8"
#toolchain="gcc_linaro_gnueabihf_4_9"

#Kernel/Build
KERNEL_REL=3.14
KERNEL_TAG=${KERNEL_REL}.26
BUILD=ti-r39

#v3.X-rcX + upto SHA
#KERNEL_SHA=""

#git branch
BRANCH="ti-linux-3.14.y"

DISTRO=cross
DEBARCH=armhf

ti_git_old_release="f9f1e2d6f950a2022591927bac39ae45b47d6a30"
ti_git_pre="f9f1e2d6f950a2022591927bac39ae45b47d6a30"
ti_git_post="9489c8bb9d4fbb15fba8b0d8b58dce012e8b4e14"
#

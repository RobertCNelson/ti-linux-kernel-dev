#!/bin/sh
#
ARCH=$(uname -m)

config="omap2plus_defconfig"

build_prefix="-ti-xenomai-r"
branch_prefix="ti-linux-xenomai-"
branch_postfix=".y"

#arm
KERNEL_ARCH=arm
#toolchain="gcc_linaro_eabi_4_8"
#toolchain="gcc_linaro_eabi_4_9"
#toolchain="gcc_linaro_eabi_5"
#toolchain="gcc_linaro_eabi_6"
#toolchain="gcc_linaro_gnueabi_4_6"
#toolchain="gcc_linaro_gnueabihf_4_7"
#toolchain="gcc_linaro_gnueabihf_4_8"
#toolchain="gcc_linaro_gnueabihf_4_9"
toolchain="gcc_linaro_gnueabihf_5"
#toolchain="gcc_linaro_gnueabihf_6"
#arm64
#KERNEL_ARCH=arm64
#toolchain="gcc_linaro_aarch64_gnu_5"
#toolchain="gcc_linaro_aarch64_gnu_6"

#Kernel/Build
KERNEL_REL=4.4
KERNEL_TAG=${KERNEL_REL}.35
BUILD=${build_prefix}70
#kernel_rt=""

#v4.X-rcX + upto SHA
#prev_KERNEL_SHA=""
#KERNEL_SHA=""

#git branch
BRANCH="${branch_prefix}${KERNEL_REL}${branch_postfix}"

DISTRO=cross
DEBARCH=armhf

xenomai_checkout="4993d845b9af8a51255aa2978e25715f0207162e"

ti_git_old_release="c8a68cfe1a3df011b18072d97f1093e447a2816c"
        ti_git_pre="c8a68cfe1a3df011b18072d97f1093e447a2816c"
       ti_git_post="c8a68cfe1a3df011b18072d97f1093e447a2816c"
#

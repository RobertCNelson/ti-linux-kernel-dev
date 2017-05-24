#!/bin/sh
#
ARCH=$(uname -m)

config="omap2plus_defconfig"

build_prefix="-ti-xenomai-r"
branch_prefix="ti-linux-xenomai-"
branch_postfix=".y"
bborg_branch="4.9-xenomai"

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
#toolchain="gcc_linaro_gnueabihf_5"
toolchain="gcc_linaro_gnueabihf_6"
#arm64
#KERNEL_ARCH=arm64
#toolchain="gcc_linaro_aarch64_gnu_5"
#toolchain="gcc_linaro_aarch64_gnu_6"

#Kernel/Build
KERNEL_REL=4.9
KERNEL_TAG=${KERNEL_REL}.29
BUILD=${build_prefix}36
kernel_rt=".27-rt18"

#v4.X-rcX + upto SHA
#prev_KERNEL_SHA=""
#KERNEL_SHA=""

#git branch
BRANCH="${branch_prefix}${KERNEL_REL}${branch_postfix}"

DISTRO=cross
DEBARCH=armhf

ti_git_old_release="d92dfde95fa74e33b5e2c295161ea3a2a8cb97fe"
        ti_git_pre="d92dfde95fa74e33b5e2c295161ea3a2a8cb97fe"
       ti_git_post="28b6970466ab0e4f8a12b6f1fbdae284c2d51e07"
#

#https://git.xenomai.org/xenomai-3.git/
#https://git.xenomai.org/xenomai-3.git/log/?h=stable-3.0.x
xenomai_checkout="8c0f8161373d483ca827d22056b8fe53e16cf847"
#

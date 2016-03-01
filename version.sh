#!/bin/sh
#
ARCH=$(uname -m)

config="omap2plus_defconfig"

build_prefix="ti-rt-r"
branch_prefix="ti-linux-rt-"
branch_postfix=".y"

#arm
KERNEL_ARCH=arm
#toolchain="gcc_linaro_eabi_4_8"
#toolchain="gcc_linaro_eabi_4_9"
#toolchain="gcc_linaro_eabi_5"
#toolchain="gcc_linaro_gnueabi_4_6"
#toolchain="gcc_linaro_gnueabihf_4_7"
#toolchain="gcc_linaro_gnueabihf_4_8"
#toolchain="gcc_linaro_gnueabihf_4_9"
toolchain="gcc_linaro_gnueabihf_5"
#arm64
#KERNEL_ARCH=arm64
#toolchain="gcc_linaro_aarch64_gnu_5"

#Kernel/Build
KERNEL_REL=4.4
KERNEL_TAG=${KERNEL_REL}.3
BUILD=${build_prefix}8.1
kernel_rt=".3-rt9"

#v4.X-rcX + upto SHA
#prev_KERNEL_SHA=""
#KERNEL_SHA=""

#git branch
BRANCH="${branch_prefix}${KERNEL_REL}${branch_postfix}"

DISTRO=cross
DEBARCH=armhf

ti_git_old_release="45aef3176f7116129eb2076dbcdfc84483400164"
        ti_git_pre="45aef3176f7116129eb2076dbcdfc84483400164"
       ti_git_post="c180c1dc31e7375b3bd6d0c08ff15f4097b06b0c"
#

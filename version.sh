#!/bin/sh
#
ARCH=$(uname -m)

config="omap2plus_defconfig"

build_prefix="-ti-rt-r"
branch_prefix="ti-linux-rt-"
branch_postfix=".y"
bborg_branch="4.9-rt"

#arm
KERNEL_ARCH=arm
#toolchain="gcc_linaro_eabi_4_8"
#toolchain="gcc_linaro_eabi_4_9"
#toolchain="gcc_linaro_eabi_5"
#toolchain="gcc_linaro_eabi_6"
#toolchain="gcc_linaro_eabi_7"
#toolchain="gcc_linaro_gnueabi_4_6"
#toolchain="gcc_linaro_gnueabihf_4_7"
#toolchain="gcc_linaro_gnueabihf_4_8"
#toolchain="gcc_linaro_gnueabihf_4_9"
#toolchain="gcc_linaro_gnueabihf_5"
toolchain="gcc_linaro_gnueabihf_6"
#toolchain="gcc_linaro_gnueabihf_7"
#toolchain="gcc_arm_gnueabihf_8"
#arm64
#KERNEL_ARCH=arm64
#toolchain="gcc_linaro_aarch64_gnu_5"
#toolchain="gcc_linaro_aarch64_gnu_6"
#toolchain="gcc_linaro_aarch64_gnu_7"
#toolchain="gcc_arm_aarch64_gnu_8"

#Kernel
KERNEL_REL=4.9
KERNEL_TAG=${KERNEL_REL}.147
kernel_rt=".146-rt125"
#Kernel Build
BUILD=${build_prefix}121

#v5.X-rcX + upto SHA
#prev_KERNEL_SHA=""
#KERNEL_SHA=""

#git branch
BRANCH="${branch_prefix}${KERNEL_REL}${branch_postfix}"

DISTRO=xross
DEBARCH=armhf

ti_git_old_release="6f0e7dc72f4400ebb7dec8e34d688ff79572a918"
        ti_git_pre="6f0e7dc72f4400ebb7dec8e34d688ff79572a918"
       ti_git_post="6f0e7dc72f4400ebb7dec8e34d688ff79572a918"
#

#https://gitlab.denx.de/Xenomai/xenomai.git
#https://gitlab.denx.de/Xenomai/xenomai/tree/stable/v3.0.x
#xenomai_checkout="0e79d326061190e08f53e7a41bcea50da4859615"
#

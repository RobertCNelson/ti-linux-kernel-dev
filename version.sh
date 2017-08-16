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
#arm64
#KERNEL_ARCH=arm64
#toolchain="gcc_linaro_aarch64_gnu_5"
#toolchain="gcc_linaro_aarch64_gnu_6"
#toolchain="gcc_linaro_aarch64_gnu_7"

#Kernel/Build
KERNEL_REL=4.9
KERNEL_TAG=${KERNEL_REL}.43
BUILD=${build_prefix}54
kernel_rt=".40-rt30"

#v4.X-rcX + upto SHA
#prev_KERNEL_SHA=""
#KERNEL_SHA=""

#git branch
BRANCH="${branch_prefix}${KERNEL_REL}${branch_postfix}"

DISTRO=cross
DEBARCH=armhf

ti_git_old_release="df8f2e92a1b399611570ac198d90db349d42a0c2"
        ti_git_pre="df8f2e92a1b399611570ac198d90db349d42a0c2"
       ti_git_post="4f21c74e5538b7221ab8d8a6ac0eacc2cc5cdef0"
#

#https://git.xenomai.org/xenomai-3.git/
#https://git.xenomai.org/xenomai-3.git/log/?h=stable-3.0.x
#xenomai_checkout="22c328f032eb32f085e956542ca7abf9a94e58be"
#

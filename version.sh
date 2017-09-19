#!/bin/sh
#
ARCH=$(uname -m)

config="omap2plus_defconfig"

build_prefix="-ti-rt-r"
branch_prefix="ti-linux-rt-"
branch_postfix=".y"
bborg_branch="4.4-rt"

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
toolchain="gcc_linaro_gnueabihf_5"
#toolchain="gcc_linaro_gnueabihf_6"
#toolchain="gcc_linaro_gnueabihf_7"
#arm64
#KERNEL_ARCH=arm64
#toolchain="gcc_linaro_aarch64_gnu_5"
#toolchain="gcc_linaro_aarch64_gnu_6"
#toolchain="gcc_linaro_aarch64_gnu_7"

#Kernel
KERNEL_REL=4.4
KERNEL_TAG=${KERNEL_REL}.88
kernel_rt=".86-rt99"
#Kernel Build
BUILD=${build_prefix}124

#v4.X-rcX + upto SHA
#prev_KERNEL_SHA=""
#KERNEL_SHA=""

#git branch
BRANCH="${branch_prefix}${KERNEL_REL}${branch_postfix}"

DISTRO=cross
DEBARCH=armhf

ti_git_old_release="1e84dccca7bbc01eda4f31a04972acd3dfee4cad"
        ti_git_pre="1e84dccca7bbc01eda4f31a04972acd3dfee4cad"
       ti_git_post="1e84dccca7bbc01eda4f31a04972acd3dfee4cad"
#

#https://git.xenomai.org/xenomai-3.git/
#https://git.xenomai.org/xenomai-3.git/log/?h=stable-3.0.x
#xenomai_checkout="93ce273c7e2e96e1ede00b5d9290dc90c4c6ac6a"
#

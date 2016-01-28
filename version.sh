#!/bin/sh
#
ARCH=$(uname -m)

config="omap2plus_defconfig"

build_prefix="ti-xenomai-r"
branch_prefix="ti-linux-xenomai-"
branch_postfix=".y"

#arm
KERNEL_ARCH=arm
#toolchain="gcc_linaro_eabi_4_8"
#toolchain="gcc_linaro_eabi_4_9"
#toolchain="gcc_linaro_eabi_5"
#toolchain="gcc_linaro_gnueabi_4_6"
#toolchain="gcc_linaro_gnueabihf_4_7"
toolchain="gcc_linaro_gnueabihf_4_8"
#toolchain="gcc_linaro_gnueabihf_4_9"
#toolchain="gcc_linaro_gnueabihf_5"
#arm64
#KERNEL_ARCH=arm64
#toolchain="gcc_linaro_aarch64_gnu_5"

#Kernel/Build
KERNEL_REL=3.14
KERNEL_TAG=${KERNEL_REL}.59
BUILD=${build_prefix}78.5
kernel_rt=".58-rt59"

#v4.X-rcX + upto SHA
#prev_KERNEL_SHA=""
#KERNEL_SHA=""

#git branch
BRANCH="${branch_prefix}${KERNEL_REL}${branch_postfix}"

DISTRO=cross
DEBARCH=armhf

xenomai_checkout="5f6b32f9b82428ea798e0f2d7718ea4752e96ab1"

ti_git_old_release="b75394168a3a310b0dc2a27de9fb5d0645c12b8d"
        ti_git_pre="9513ad21a5f1b0fb104300fd245ead186cb39582"
       ti_git_post="7bb9a07d521ab45946c7a797fb60927fb9569136"
#

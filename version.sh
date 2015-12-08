#!/bin/sh
#
ARCH=$(uname -m)

config="omap2plus_defconfig"

build_prefix="ti"
branch_prefix=""

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
KERNEL_TAG=${KERNEL_REL}-rc4
BUILD=${build_prefix}-r2.1
kernel_rt=".x-rty"

#v4.X-rcX + upto SHA
#prev_KERNEL_SHA=""
#KERNEL_SHA=""

#git branch
BRANCH="ti-linux-${branch_prefix}4.4.y"

DISTRO=cross
DEBARCH=armhf

ti_git_old_release="a2931547eee19201856a89406397ecc1f978deaf"
        ti_git_pre="a2931547eee19201856a89406397ecc1f978deaf"
       ti_git_post="aa7e0f132a1a73a77fd56691056fe7feae3fba9e"
#

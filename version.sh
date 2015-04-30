#!/bin/sh
#
ARCH=$(uname -m)

config="omap2plus_defconfig"

build_prefix="ti-xenomai"
branch_prefix="xenomai-"

#toolchain="gcc_linaro_eabi_4_8"
#toolchain="gcc_linaro_eabi_4_9"
#toolchain="gcc_linaro_gnueabi_4_6"
#toolchain="gcc_linaro_gnueabihf_4_7"
toolchain="gcc_linaro_gnueabihf_4_8"
#toolchain="gcc_linaro_gnueabihf_4_9"

#Kernel/Build
KERNEL_REL=3.14
KERNEL_TAG=${KERNEL_REL}.40
BUILD=${build_prefix}-r61.3

#v3.X-rcX + upto SHA
#prev_KERNEL_SHA=""
#KERNEL_SHA=""

#git branch
BRANCH="ti-linux-${branch_prefix}3.14.y"

DISTRO=cross
DEBARCH=armhf

ti_git_old_release="1bc045ab6622f65406e48be7e361846ca091b311"
ti_git_pre="443cd651e9fd926f50932abff395f6f843a11372"
ti_git_post="177c70876a40add3c949f75e8cc6620ad98728b3"
#

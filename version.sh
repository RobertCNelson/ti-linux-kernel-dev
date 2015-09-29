#!/bin/sh
#
ARCH=$(uname -m)

config="omap2plus_defconfig"

build_prefix="ti"
branch_prefix="omap2plus-"

#toolchain="gcc_linaro_eabi_4_8"
#toolchain="gcc_linaro_eabi_4_9"
#toolchain="gcc_linaro_gnueabi_4_6"
#toolchain="gcc_linaro_gnueabihf_4_7"
#toolchain="gcc_linaro_gnueabihf_4_8"
toolchain="gcc_linaro_gnueabihf_4_9"

#Kernel/Build
KERNEL_REL=4.1
KERNEL_TAG=${KERNEL_REL}.8
BUILD=${build_prefix}-git20150929-5bf93b96
kernel_rt=".7-rt8"

#v4.X-rcX + upto SHA
#prev_KERNEL_SHA=""
#KERNEL_SHA=""

#git branch
BRANCH="ti-linux-${branch_prefix}4.1.y"

DISTRO=cross
DEBARCH=armhf

ti_git_old_release="420b0df43eff698b00a92ed3c0ba64e0c19f79fb"
ti_git_pre="420b0df43eff698b00a92ed3c0ba64e0c19f79fb"
ti_git_post="5bf93b966b88ff5aa668c767102d13a1ea1b6757"
#

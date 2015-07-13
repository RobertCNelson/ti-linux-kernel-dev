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
KERNEL_TAG=${KERNEL_REL}.48
BUILD=${build_prefix}-r71.1

#v3.X-rcX + upto SHA
#prev_KERNEL_SHA=""
#KERNEL_SHA=""

#git branch
BRANCH="ti-linux-${branch_prefix}3.14.y"

DISTRO=cross
DEBARCH=armhf

xenomai_checkout="2a7dcee23f32c01bd20dd9ecf1a2553f18abe78c"

ti_git_old_release="ce65c710bd587f3f2a900a85ae89334eb729aa72"
ti_git_pre="ce65c710bd587f3f2a900a85ae89334eb729aa72"
ti_git_post="847342b35913473684d8618364ee3551e47ead46"
#

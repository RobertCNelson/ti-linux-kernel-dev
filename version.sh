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
KERNEL_TAG=${KERNEL_REL}.52
BUILD=${build_prefix}-r75
kernel_rt=".51-rt52"

#v4.X-rcX + upto SHA
#prev_KERNEL_SHA=""
#KERNEL_SHA=""

#git branch
BRANCH="ti-linux-${branch_prefix}3.14.y"

DISTRO=cross
DEBARCH=armhf

xenomai_checkout="1f34e06120ccde12cd28a447289f2b5d859979bc"

ti_git_old_release="288dfb53f4636edb38c4730e7bb817f36362976c"
ti_git_pre="288dfb53f4636edb38c4730e7bb817f36362976c"
ti_git_post="6bbbdf074c2f925f5ca8b468999482904dc9aeaf"
#

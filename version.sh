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
KERNEL_TAG=${KERNEL_REL}.45
BUILD=${build_prefix}-r69

#v3.X-rcX + upto SHA
#prev_KERNEL_SHA=""
#KERNEL_SHA=""

#git branch
BRANCH="ti-linux-${branch_prefix}3.14.y"

DISTRO=cross
DEBARCH=armhf

xenomai_checkout="2a7dcee23f32c01bd20dd9ecf1a2553f18abe78c"

ti_git_old_release="e19ba3d996f22ad8cc7187b30c18347aba0d594d"
ti_git_pre="e19ba3d996f22ad8cc7187b30c18347aba0d594d"
ti_git_post="f14ea3dc1c90863ce5ce908e0110d55a1555e9a8"
#

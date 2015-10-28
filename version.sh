#!/bin/sh
#
ARCH=$(uname -m)

config="omap2plus_defconfig"

build_prefix="ti-xenomai"
branch_prefix="xenomai-"

#toolchain="gcc_linaro_eabi_4_8"
#toolchain="gcc_linaro_eabi_4_9"
#toolchain="gcc_linaro_eabi_5"
#toolchain="gcc_linaro_gnueabi_4_6"
#toolchain="gcc_linaro_gnueabihf_4_7"
toolchain="gcc_linaro_gnueabihf_4_8"
#toolchain="gcc_linaro_gnueabihf_4_9"
#toolchain="gcc_linaro_gnueabihf_5"

#Kernel/Build
KERNEL_REL=3.14
KERNEL_TAG=${KERNEL_REL}.56
BUILD=${build_prefix}-r78.2
kernel_rt=".53-rt54"

#v4.X-rcX + upto SHA
#prev_KERNEL_SHA=""
#KERNEL_SHA=""

#git branch
BRANCH="ti-linux-${branch_prefix}3.14.y"

DISTRO=cross
DEBARCH=armhf

xenomai_checkout="d0d67d97d840381b3ba5284cf6b843a7523bfe53"

ti_git_old_release="b75394168a3a310b0dc2a27de9fb5d0645c12b8d"
ti_git_pre="3781189918e0713e8af67ac71aa92ed18358a56d"
ti_git_post="b59fab0e742fff7f404894156445d1d7b695692e"
#

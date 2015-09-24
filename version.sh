#!/bin/sh
#
ARCH=$(uname -m)

config="omap2plus_defconfig"

build_prefix="ti-rt"
branch_prefix="rt-"

#toolchain="gcc_linaro_eabi_4_8"
#toolchain="gcc_linaro_eabi_4_9"
#toolchain="gcc_linaro_gnueabi_4_6"
#toolchain="gcc_linaro_gnueabihf_4_7"
#toolchain="gcc_linaro_gnueabihf_4_8"
toolchain="gcc_linaro_gnueabihf_4_9"

#Kernel/Build
KERNEL_REL=4.1
KERNEL_TAG=${KERNEL_REL}.6
BUILD=${build_prefix}-r16.3
kernel_rt=".5-rt5"

#v4.X-rcX + upto SHA
#prev_KERNEL_SHA=""
#KERNEL_SHA=""

#git branch
BRANCH="ti-linux-${branch_prefix}4.1.y"

DISTRO=cross
DEBARCH=armhf

ti_git_old_release="9279365676f916087bb6548f8c7698678208f71a"
ti_git_pre="9279365676f916087bb6548f8c7698678208f71a"
ti_git_post="9279365676f916087bb6548f8c7698678208f71a"
#

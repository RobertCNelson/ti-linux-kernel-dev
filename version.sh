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
BUILD=${build_prefix}-r14.2
kernel_rt=".5-rt5"

#v3.X-rcX + upto SHA
#prev_KERNEL_SHA=""
#KERNEL_SHA=""

#git branch
BRANCH="ti-linux-${branch_prefix}4.1.y"

DISTRO=cross
DEBARCH=armhf

ti_git_old_release="7ea5d509a39d41dc7a2b10bc5404293e047241a7"
ti_git_pre="77fdbd06b0cbb428469fdfc6d4a1b10b01f45446"
ti_git_post="065c5f0eb8b7aacc9d1ef201a1dd6af7f10afd64"
#

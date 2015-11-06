#!/bin/sh
#
ARCH=$(uname -m)

config="omap2plus_defconfig"

build_prefix="ti"
branch_prefix="omap2plus-"

#toolchain="gcc_linaro_eabi_4_8"
#toolchain="gcc_linaro_eabi_4_9"
#toolchain="gcc_linaro_eabi_5"
#toolchain="gcc_linaro_gnueabi_4_6"
#toolchain="gcc_linaro_gnueabihf_4_7"
#toolchain="gcc_linaro_gnueabihf_4_8"
toolchain="gcc_linaro_gnueabihf_4_9"
#toolchain="gcc_linaro_gnueabihf_5"

#Kernel/Build
KERNEL_REL=4.1
KERNEL_TAG=${KERNEL_REL}.12
BUILD=${build_prefix}-git20151105-4b4eb93a
kernel_rt=".10-rt11"

#v4.X-rcX + upto SHA
#prev_KERNEL_SHA=""
#KERNEL_SHA=""

#git branch
BRANCH="ti-linux-${branch_prefix}4.1.y"

DISTRO=cross
DEBARCH=armhf

ti_git_old_release="1729ffbf63ac5f03854a62f44b3b2499cad25d93"
        ti_git_pre="1729ffbf63ac5f03854a62f44b3b2499cad25d93"
       ti_git_post="4b4eb93a58d79dd593aaa6f6bc2108f5c7d54b5f"
#

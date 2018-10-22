#!/bin/sh
#
ARCH=$(uname -m)

config="omap2plus_defconfig"

build_prefix="-ti-r"
branch_prefix="ti-linux-"
branch_postfix=".y"
bborg_branch="4.9"

#arm
KERNEL_ARCH=arm
#toolchain="gcc_linaro_eabi_4_8"
#toolchain="gcc_linaro_eabi_4_9"
#toolchain="gcc_linaro_eabi_5"
#toolchain="gcc_linaro_eabi_6"
#toolchain="gcc_linaro_eabi_7"
#toolchain="gcc_linaro_gnueabi_4_6"
#toolchain="gcc_linaro_gnueabihf_4_7"
#toolchain="gcc_linaro_gnueabihf_4_8"
#toolchain="gcc_linaro_gnueabihf_4_9"
#toolchain="gcc_linaro_gnueabihf_5"
toolchain="gcc_linaro_gnueabihf_6"
#toolchain="gcc_linaro_gnueabihf_7"
#toolchain="gcc_arm_gnueabihf_8"
#arm64
#KERNEL_ARCH=arm64
#toolchain="gcc_linaro_aarch64_gnu_5"
#toolchain="gcc_linaro_aarch64_gnu_6"
#toolchain="gcc_linaro_aarch64_gnu_7"

#Kernel
KERNEL_REL=4.9
KERNEL_TAG=${KERNEL_REL}.126
kernel_rt=".115-rt93"
#Kernel Build
BUILD=${build_prefix}115

#v4.X-rcX + upto SHA
#prev_KERNEL_SHA=""
#KERNEL_SHA=""

#git branch
BRANCH="${branch_prefix}${KERNEL_REL}${branch_postfix}"

DISTRO=cross
DEBARCH=armhf

ti_git_old_release="cf63b764bdea23417d60e1e8158c6f01e8846014"
        ti_git_pre="cf63b764bdea23417d60e1e8158c6f01e8846014"
       ti_git_post="1e8dbd6794e3c2c32c68d77fcf994c3d0aa1260a"
#

#https://git.xenomai.org/xenomai-3.git/
#https://git.xenomai.org/xenomai-3.git/log/?h=stable-3.0.x
#xenomai_checkout="4ba4986a76eb5a60b0aacc6154208143f8894c74"
#

#!/bin/sh
#
ARCH=$(uname -m)

config="omap2plus_defconfig"

build_prefix="-ti-rt-r"
branch_prefix="ti-linux-rt-"
branch_postfix=".y"
bborg_branch="4.14-rt"

#https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/tree/Documentation/process/changes.rst?h=v4.14-rc1
#arm
KERNEL_ARCH=arm
DEBARCH=armhf
#toolchain="gcc_linaro_eabi_4_8"
#toolchain="gcc_linaro_eabi_4_9"
#toolchain="gcc_linaro_eabi_5"
#toolchain="gcc_linaro_eabi_6"
#toolchain="gcc_linaro_eabi_7"
#toolchain="gcc_linaro_gnueabihf_4_7"
#toolchain="gcc_linaro_gnueabihf_4_8"
#toolchain="gcc_linaro_gnueabihf_4_9"
#toolchain="gcc_linaro_gnueabihf_5"
#toolchain="gcc_linaro_gnueabihf_6"
toolchain="gcc_linaro_gnueabihf_7"
#toolchain="gcc_8_arm"
#toolchain="gcc_9_arm"
#toolchain="gcc_10_arm"
#arm64
#KERNEL_ARCH=arm64
#DEBARCH=arm64
#toolchain="gcc_linaro_aarch64_gnu_5"
#toolchain="gcc_linaro_aarch64_gnu_6"
#toolchain="gcc_linaro_aarch64_gnu_7"
#toolchain="gcc_arm_aarch64_gnu_8"
#toolchain="gcc_arm_aarch64_gnu_9"
#toolchain="gcc_10_aarch64"
#riscv64
#KERNEL_ARCH=riscv
#DEBARCH=riscv64
#toolchain="gcc_8_riscv64"
#toolchain="gcc_9_riscv64"
#toolchain="gcc_10_riscv64"

#Kernel
KERNEL_REL=4.14
KERNEL_TAG=${KERNEL_REL}.108
kernel_rt=".106-rt56"
#Kernel Build
BUILD=${build_prefix}142

#v5.X-rcX + upto SHA
#prev_KERNEL_SHA=""
#KERNEL_SHA=""

#git branch
BRANCH="${branch_prefix}${KERNEL_REL}${branch_postfix}"

DISTRO=xross

ti_git_old_release="b02daa74d9bd58b07b7d43168d4dca9595c0bab3"
        ti_git_pre="b02daa74d9bd58b07b7d43168d4dca9595c0bab3"
       ti_git_post="b02daa74d9bd58b07b7d43168d4dca9595c0bab3"
#

#https://source.denx.de/Xenomai/xenomai.git
#https://source.denx.de/Xenomai/xenomai/-/commits/stable/v3.0.x/
#xenomai_checkout="4f491468e78b1016126bd378c7dbb41bcf5c2429"
#

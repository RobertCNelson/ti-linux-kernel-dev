#!/bin/sh
#
ARCH=$(uname -m)

config="defconfig"

build_prefix="-ti-arm64-r"
branch_prefix="ti-linux-arm64-"
branch_postfix=".y"
bborg_branch="6.1-arm64"

#https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/tree/Documentation/process/changes.rst?h=v6.1-rc1
#arm
#KERNEL_ARCH=arm
#DEBARCH=armhf
#toolchain="gcc_6_arm"
#toolchain="gcc_7_arm"
#toolchain="gcc_8_arm"
#toolchain="gcc_9_arm"
#toolchain="gcc_10_arm"
#toolchain="gcc_11_arm"
#toolchain="gcc_12_arm"
#toolchain="gcc_13_arm"
#arm64
KERNEL_ARCH=arm64
DEBARCH=arm64
#toolchain="gcc_6_aarch64"
#toolchain="gcc_7_aarch64"
#toolchain="gcc_8_aarch64"
#toolchain="gcc_9_aarch64"
#toolchain="gcc_10_aarch64"
#toolchain="gcc_11_aarch64"
toolchain="gcc_12_aarch64"
#toolchain="gcc_13_aarch64"
#riscv64
#KERNEL_ARCH=riscv
#DEBARCH=riscv64
#toolchain="gcc_7_riscv64"
#toolchain="gcc_8_riscv64"
#toolchain="gcc_9_riscv64"
#toolchain="gcc_10_riscv64"
#toolchain="gcc_11_riscv64"
#toolchain="gcc_12_riscv64"
#toolchain="gcc_13_riscv64"

#Kernel
KERNEL_REL=6.1
KERNEL_TAG=${KERNEL_REL}.80
kernel_rt=".80-rt26"
#Kernel Build
BUILD=${build_prefix}32.1

#v6.X-rcX + upto SHA
#prev_KERNEL_SHA=""
#KERNEL_SHA=""

#git branch
BRANCH="${branch_prefix}${KERNEL_REL}${branch_postfix}"

DISTRO=xross

ti_git_old_release="a6174d6c4ff531039c677079321888a9a3f9951c"
ti_git_new_release="4d3502a8b8db0395db8ce0c6501795de2ec240c9"
#TISDK="09.02.00.007"

#

#!/bin/sh
#
ARCH=$(uname -m)

config="multi_v7_defconfig"

build_prefix="-ti-r"
branch_prefix="ti-linux-"
branch_postfix=".y"
bborg_branch="6.1"

#https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/tree/Documentation/process/changes.rst?h=v6.1-rc1
#arm
KERNEL_ARCH=arm
DEBARCH=armhf
#toolchain="gcc_6_arm"
#toolchain="gcc_7_arm"
#toolchain="gcc_8_arm"
#toolchain="gcc_9_arm"
#toolchain="gcc_10_arm"
#toolchain="gcc_11_arm"
toolchain="gcc_12_arm"
#toolchain="gcc_13_arm"
#arm64
#KERNEL_ARCH=arm64
#DEBARCH=arm64
#toolchain="gcc_6_aarch64"
#toolchain="gcc_7_aarch64"
#toolchain="gcc_8_aarch64"
#toolchain="gcc_9_aarch64"
#toolchain="gcc_10_aarch64"
#toolchain="gcc_11_aarch64"
#toolchain="gcc_12_aarch64"
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
KERNEL_TAG=${KERNEL_REL}.69
kernel_rt=".67-rt20"
#Kernel Build
BUILD=${build_prefix}20

#v6.X-rcX + upto SHA
#prev_KERNEL_SHA=""
#KERNEL_SHA=""

#git branch
BRANCH="${branch_prefix}${KERNEL_REL}${branch_postfix}"

DISTRO=xross

ti_git_old_release="247b2535b24894d5ac7f3d8cfc3b48edb7214cc0"
ti_git_new_release="82d2b827840254248a0444a9c50ab3dc395876cc"
TISDK="09.02.00.001"

#

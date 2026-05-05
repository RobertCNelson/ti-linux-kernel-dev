#!/bin/sh

# SPDX-FileCopyrightText: Robert Nelson <robertcnelson@gmail.com>
#
# SPDX-License-Identifier: MIT

#
ARCH=$(uname -m)

config="defconfig"

build_prefix="-ti-arm64-r"
branch_prefix="ti-linux-arm64-"
branch_postfix=".y"
bborg_branch="6.12-arm64"

#Changes
#https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/tree/Documentation/process/changes.rst?h=v6.12-rc1
#
#Cross Compilers
#https://mirrors.edge.kernel.org/pub/tools/crosstool/files/bin/x86_64/
#arm
#KERNEL_ARCH=arm
#DEBARCH=armhf
#toolchain="gcc_8_arm"
#toolchain="gcc_9_arm"
#toolchain="gcc_10_arm"
#toolchain="gcc_11_arm"
#toolchain="gcc_12_arm"
#toolchain="gcc_13_arm"
#toolchain="gcc_14_arm"
#toolchain="gcc_15_arm"
#arm64
KERNEL_ARCH=arm64
DEBARCH=arm64
#toolchain="gcc_8_aarch64"
#toolchain="gcc_9_aarch64"
#toolchain="gcc_10_aarch64"
#toolchain="gcc_11_aarch64"
#toolchain="gcc_12_aarch64"
#toolchain="gcc_13_aarch64"
toolchain="gcc_14_aarch64"
#toolchain="gcc_15_aarch64"
#riscv64
#KERNEL_ARCH=riscv
#DEBARCH=riscv64
#toolchain="gcc_8_riscv64"
#toolchain="gcc_9_riscv64"
#toolchain="gcc_10_riscv64"
#toolchain="gcc_11_riscv64"
#toolchain="gcc_12_riscv64"
#toolchain="gcc_13_riscv64"
#toolchain="gcc_14_riscv64"
#toolchain="gcc_15_riscv64"

#Wireless:
#https://git.kernel.org/pub/scm/linux/kernel/git/wens/wireless-regdb.git
WIRELESS_REGDB="2026-03-18"

#Kernel
linux_repo="https://kernel.googlesource.com/pub/scm/linux/kernel/git/torvalds/linux.git"
linux_stable_repo="https://kernel.googlesource.com/pub/scm/linux/kernel/git/stable/linux.git"
#
KERNEL_REL=6.12
KERNEL_TAG=${KERNEL_REL}.57
#https://mirrors.edge.kernel.org/pub/linux/kernel/projects/rt/6.12/
kernel_rt=".57-rt14"
#Kernel Build
BUILD=${build_prefix}61.2

#v6.X-rcX + upto SHA
#prev_KERNEL_SHA=""
#KERNEL_SHA=""

#git branch
BRANCH="${branch_prefix}${KERNEL_REL}${branch_postfix}"

DISTRO=xross

sdk_git_old_release="da3c0f0a33ac00f7138c695a16d90301cf7ec02b"
sdk_git_new_release="c52c5589aab8c376f975b1feb7b8746b7b6624bd"
SDK="11.02.13"
#

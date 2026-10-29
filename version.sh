#!/bin/sh

# SPDX-FileCopyrightText: Robert Nelson <robertcnelson@gmail.com>
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

# Options: arm, arm64, riscv
KERNEL_ARCH=arm64

# Options: 8, 9, 10, 11, 12, 13, 14, 15, 16
toolchain_version="14"

#Wireless:
#https://git.kernel.org/pub/scm/linux/kernel/git/wens/wireless-regdb.git
WIRELESS_REGDB="2026-09-03"

#Kernel
linux_repo="https://kernel.googlesource.com/pub/scm/linux/kernel/git/torvalds/linux.git"
linux_stable_repo="https://kernel.googlesource.com/pub/scm/linux/kernel/git/stable/linux.git"
#
KERNEL_REL=6.12
KERNEL_TAG=${KERNEL_REL}.57
#https://mirrors.edge.kernel.org/pub/linux/kernel/projects/rt/6.12/
kernel_rt=".57-rt14"
#Kernel Build
BUILD=${build_prefix}64.8

#git branch
BRANCH="${branch_prefix}${KERNEL_REL}${branch_postfix}"

DISTRO=xross

sdk_git_old_release="98bbe0d37952d0ce1b6508f108c357ceb6d58bf3"
sdk_git_new_release="7bbb58844e0ba096c6fc4f078fe20b5f9419bc6c"
#https://forgejo.gfnd.rcn-ee.org:3000/TexasInstruments/ti-linux-kernel/commits/tag/11.02.16
#https://forgejo.gfnd.rcn-ee.org:3000/TexasInstruments/ti-linux-kernel/compare/11.02.15...11.02.16
SDK="11.02.16"
#

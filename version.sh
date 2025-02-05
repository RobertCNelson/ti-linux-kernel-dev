#!/bin/sh
#
ARCH=$(uname -m)

config="defconfig"

build_prefix="-ti-rt-arm64-r"
branch_prefix="ti-linux-rt-arm64-"
branch_postfix=".y"
bborg_branch="6.6-rt-arm64"

#https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/tree/Documentation/process/changes.rst?h=v6.6-rc1
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
#toolchain="gcc_14_arm"
#arm64
KERNEL_ARCH=arm64
DEBARCH=arm64
#toolchain="gcc_6_aarch64"
#toolchain="gcc_7_aarch64"
#toolchain="gcc_8_aarch64"
#toolchain="gcc_9_aarch64"
#toolchain="gcc_10_aarch64"
#toolchain="gcc_11_aarch64"
#toolchain="gcc_12_aarch64"
toolchain="gcc_13_aarch64"
#toolchain="gcc_14_aarch64"
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
#toolchain="gcc_14_riscv64"

#Kernel
linux_repo="https://kernel.googlesource.com/pub/scm/linux/kernel/git/torvalds/linux.git"
#linux_stable_repo="https://kernel.googlesource.com/pub/scm/linux/kernel/git/stable/linux.git"
linux_stable_repo="https://github.com/beagleboard/mirror-ti-linux-kernel.git"
#
KERNEL_REL=6.6
KERNEL_TAG=${KERNEL_REL}.58
#https://mirrors.edge.kernel.org/pub/linux/kernel/projects/rt/6.6/
kernel_rt=".58-rt45"
#Kernel Build
BUILD=${build_prefix}20

#v6.X-rcX + upto SHA
#prev_KERNEL_SHA=""
#KERNEL_SHA=""

#git branch
BRANCH="${branch_prefix}${KERNEL_REL}${branch_postfix}"

DISTRO=xross

sdk_git_old_release="d32074b73785eb57c675cef603517247f5f4f33b"
sdk_git_new_release="a7758da17c2807e5285d6546b6797aae1d34a7d6"
SDK="10.01.10"

#

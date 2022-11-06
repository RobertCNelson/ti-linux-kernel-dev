#!/bin/sh
#
ARCH=$(uname -m)

config="omap2plus_defconfig"

build_prefix="-ti-r"
branch_prefix="ti-linux-"
branch_postfix=".y"
bborg_branch="5.10"

#https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/tree/Documentation/process/changes.rst?h=v5.10-rc1
#arm
KERNEL_ARCH=arm
DEBARCH=armhf
#toolchain="gcc_6_arm"
#toolchain="gcc_7_arm"
#toolchain="gcc_8_arm"
#toolchain="gcc_9_arm"
toolchain="gcc_10_arm"
#toolchain="gcc_11_arm"
#toolchain="gcc_12_arm"
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
#riscv64
#KERNEL_ARCH=riscv
#DEBARCH=riscv64
#toolchain="gcc_7_riscv64"
#toolchain="gcc_8_riscv64"
#toolchain="gcc_9_riscv64"
#toolchain="gcc_10_riscv64"
#toolchain="gcc_11_riscv64"
#toolchain="gcc_12_riscv64"

#Kernel
KERNEL_REL=5.10
KERNEL_TAG=${KERNEL_REL}.145
kernel_rt=".145-rt74"
#Kernel Build
BUILD=${build_prefix}53

#v6.X-rcX + upto SHA
#prev_KERNEL_SHA=""
#KERNEL_SHA=""

#git branch
BRANCH="${branch_prefix}${KERNEL_REL}${branch_postfix}"

DISTRO=xross

ti_git_old_release="ceb5ccdfa5c6e70c25e9321025e9850ee2a81a93"
ti_git_new_release="8b51d20b6e6e1b9277b59b7aaed8a97eff43097f"

#https://git.ti.com/gitweb?p=ti-linux-kernel/ti-linux-kernel.git;a=tag;h=refs/tags/08.05.00.003
#https://git.ti.com/gitweb?p=ti-linux-kernel/ti-linux-kernel.git;a=shortlog;h=8b51d20b6e6e1b9277b59b7aaed8a97eff43097f
#

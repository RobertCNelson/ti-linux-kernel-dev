#!/bin/sh
#
ARCH=$(uname -m)

config="omap2plus_defconfig"

build_prefix="-ti-r"
branch_prefix="ti-linux-"
branch_postfix=".y"
bborg_branch="4.19"

#https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/tree/Documentation/process/changes.rst?h=v4.19-rc1
#arm
KERNEL_ARCH=arm
DEBARCH=armhf
#toolchain="gcc_6_arm"
#toolchain="gcc_7_arm"
toolchain="gcc_8_arm"
#toolchain="gcc_9_arm"
#toolchain="gcc_10_arm"
#arm64
#KERNEL_ARCH=arm64
#DEBARCH=arm64
#toolchain="gcc_6_aarch64"
#toolchain="gcc_7_aarch64"
#toolchain="gcc_8_aarch64"
#toolchain="gcc_9_aarch64"
#toolchain="gcc_10_aarch64"
#riscv64
#KERNEL_ARCH=riscv
#DEBARCH=riscv64
#toolchain="gcc_7_riscv64"
#toolchain="gcc_8_riscv64"
#toolchain="gcc_9_riscv64"
#toolchain="gcc_10_riscv64"

#Kernel
KERNEL_REL=4.19
KERNEL_TAG=${KERNEL_REL}.94
kernel_rt=".94-rt39"
#Kernel Build
BUILD=${build_prefix}64.1

#v5.X-rcX + upto SHA
#prev_KERNEL_SHA=""
#KERNEL_SHA=""

#git branch
BRANCH="${branch_prefix}${KERNEL_REL}${branch_postfix}"

DISTRO=xross

ti_git_old_release="5a23bc00e08d26bb83952953d909c95b42fab70c"
        ti_git_pre="5a23bc00e08d26bb83952953d909c95b42fab70c"
       ti_git_post="5a23bc00e08d26bb83952953d909c95b42fab70c"
#

#https://source.denx.de/Xenomai/xenomai.git
#https://source.denx.de/Xenomai/xenomai/-/commits/stable/v3.1.x/
#xenomai_checkout="cdc938bc199a86097d936caf600fa13af029a434"
#

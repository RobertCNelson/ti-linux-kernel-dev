#!/bin/sh
#
ARCH=$(uname -m)

config="omap2plus_defconfig"

build_prefix="-ti-xenomai-r"
branch_prefix="ti-linux-xenomai-"
branch_postfix=".y"
bborg_branch="5.4-xenomai"

#https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/tree/Documentation/process/changes.rst?h=v5.4-rc1
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
KERNEL_REL=5.4
KERNEL_TAG=${KERNEL_REL}.106
kernel_rt=".106-rt54"
#Kernel Build
BUILD=${build_prefix}32

#v5.X-rcX + upto SHA
#prev_KERNEL_SHA=""
#KERNEL_SHA=""

#git branch
BRANCH="${branch_prefix}${KERNEL_REL}${branch_postfix}"

DISTRO=xross

ti_git_old_release="023faefa70274929bff92dc41167b007f7523792"
        ti_git_pre="023faefa70274929bff92dc41167b007f7523792"
       ti_git_post="023faefa70274929bff92dc41167b007f7523792"
#

#https://source.denx.de/Xenomai/xenomai.git
#https://source.denx.de/Xenomai/xenomai/-/commits/stable/v3.1.x/
xenomai_checkout="8b2052eaeaa4d458d3eb354a3548903a044d5b0d"
#

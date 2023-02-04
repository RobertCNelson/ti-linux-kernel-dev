#!/bin/sh
#
ARCH=$(uname -m)

config="omap2plus_defconfig"

build_prefix="-ti-rt-r"
branch_prefix="ti-linux-rt-"
branch_postfix=".y"
bborg_branch="5.10-rt"

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
KERNEL_TAG=${KERNEL_REL}.162
kernel_rt=".162-rt79"
#Kernel Build
BUILD=${build_prefix}56

#v6.X-rcX + upto SHA
#prev_KERNEL_SHA=""
#KERNEL_SHA=""

#git branch
BRANCH="${branch_prefix}${KERNEL_REL}${branch_postfix}"

DISTRO=xross

ti_git_old_release="06bd1d157b9b43163c1a2184e4a0c92f98656dd0"
ti_git_new_release="2927372e2c7cc3782c07b1896757962bc346d4c5"

#https://git.ti.com/gitweb?p=ti-linux-kernel/ti-linux-kernel.git;a=tag;h=refs/tags/08.06.00.004
#https://git.ti.com/gitweb?p=ti-linux-kernel/ti-linux-kernel.git;a=commit;h=2927372e2c7cc3782c07b1896757962bc346d4c5
#
#https://git.ti.com/gitweb?p=ti-linux-kernel/ti-linux-kernel.git;a=tag;h=refs/tags/08.06.00.003
#https://git.ti.com/gitweb?p=ti-linux-kernel/ti-linux-kernel.git;a=commit;h=06bd1d157b9b43163c1a2184e4a0c92f98656dd0
#
#https://git.ti.com/gitweb?p=ti-linux-kernel/ti-linux-kernel.git;a=tag;h=refs/tags/08.06.00.002
#https://git.ti.com/gitweb?p=ti-linux-kernel/ti-linux-kernel.git;a=commit;h=d948fe1239aa0c754e2fb25e23bb112e29679ba3
#
#https://git.ti.com/gitweb?p=ti-linux-kernel/ti-linux-kernel.git;a=tag;h=refs/tags/08.06.00.001
#https://git.ti.com/gitweb?p=ti-linux-kernel/ti-linux-kernel.git;a=shortlog;h=58c3afb61814c1271156d6ace8d0550475268d3f
#
#https://git.ti.com/gitweb?p=ti-linux-kernel/ti-linux-kernel.git;a=tag;h=refs/tags/08.05.00.003
#https://git.ti.com/gitweb?p=ti-linux-kernel/ti-linux-kernel.git;a=shortlog;h=8b51d20b6e6e1b9277b59b7aaed8a97eff43097f
#

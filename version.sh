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
#toolchain="gcc_8_arm"
#toolchain="gcc_9_arm"
toolchain="gcc_10_arm"
#toolchain="gcc_11_arm"
#toolchain="gcc_12_arm"
#toolchain="gcc_13_arm"
#toolchain="gcc_14_arm"
#arm64
#KERNEL_ARCH=arm64
#DEBARCH=arm64
#toolchain="gcc_8_aarch64"
#toolchain="gcc_9_aarch64"
#toolchain="gcc_10_aarch64"
#toolchain="gcc_11_aarch64"
#toolchain="gcc_12_aarch64"
#toolchain="gcc_13_aarch64"
#toolchain="gcc_14_aarch64"
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

#Kernel
linux_repo="https://kernel.googlesource.com/pub/scm/linux/kernel/git/torvalds/linux.git"
#linux_stable_repo="https://kernel.googlesource.com/pub/scm/linux/kernel/git/stable/linux.git"
linux_stable_repo="https://github.com/beagleboard/mirror-ti-linux-kernel.git"
#
KERNEL_REL=5.10
KERNEL_TAG=${KERNEL_REL}.168
#https://mirrors.edge.kernel.org/pub/linux/kernel/projects/rt/5.10/
kernel_rt=".168-rt83"
#Kernel Build
BUILD=${build_prefix}82

#v6.X-rcX + upto SHA
#prev_KERNEL_SHA=""
#KERNEL_SHA=""

#git branch
BRANCH="${branch_prefix}${KERNEL_REL}${branch_postfix}"

DISTRO=xross

sdk_git_old_release="76b3e88d569210a51399e8d8c8babd995af29d11"
sdk_git_new_release="2c23e6c538c879e380401ae4b236f54020618eaa"
SDK="08.06.00.007"

#https://git.ti.com/gitweb?p=ti-linux-kernel/ti-linux-kernel.git;a=tag;h=refs/tags/08.06.00.007
#https://git.ti.com/gitweb?p=ti-linux-kernel/ti-linux-kernel.git;a=commit;h=2c23e6c538c879e380401ae4b236f54020618eaa
#
#https://git.ti.com/gitweb?p=ti-linux-kernel/ti-linux-kernel.git;a=tag;h=refs/tags/08.06.00.006
#https://git.ti.com/gitweb?p=ti-linux-kernel/ti-linux-kernel.git;a=commit;h=76b3e88d569210a51399e8d8c8babd995af29d11
#
#https://git.ti.com/gitweb?p=ti-linux-kernel/ti-linux-kernel.git;a=tag;h=refs/tags/08.06.00.005
#https://git.ti.com/gitweb?p=ti-linux-kernel/ti-linux-kernel.git;a=commit;h=73f2f2bba715b5cada420f2fb34bb43d185248f2
#
#https://git.ti.com/gitweb?p=ti-linux-kernel/ti-linux-kernel.git;a=tag;h=refs/tags/08.06.00.004
#https://git.ti.com/gitweb?p=ti-linux-kernel/ti-linux-kernel.git;a=commit;h=2927372e2c7cc3782c07b1896757962bc346d4c5
#

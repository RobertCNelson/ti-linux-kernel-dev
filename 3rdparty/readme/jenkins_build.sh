#!/bin/bash

#git clone -b 6.1 https://github.com/beagleboard/linux --depth=10
#cd ./linux

CORES=$(getconf _NPROCESSORS_ONLN)

export CC=/usr/bin/arm-linux-gnueabihf-

make ARCH=arm CROSS_COMPILE=${CC} clean
make ARCH=arm CROSS_COMPILE=${CC} bb.org_defconfig

echo "make -j${CORES} ARCH=arm KBUILD_DEBARCH=armhf CROSS_COMPILE=${CC} bindeb-pkg"
make -j${CORES} ARCH=arm KBUILD_DEBARCH=armhf KDEB_PKGVERSION=1xross CROSS_COMPILE=${CC} bindeb-pkg
mv ../*.deb ./

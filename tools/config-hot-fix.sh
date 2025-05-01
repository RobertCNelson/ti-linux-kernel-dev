#!/bin/sh -e

DIR=$PWD

cd ${DIR}/KERNEL/

#Nuke DSA SubSystem: 2020.02.20
./scripts/config --disable CONFIG_HAVE_NET_DSA
./scripts/config --disable CONFIG_NET_DSA

#SC16IS7XX breaks SERIAL_DEV_CTRL_TTYPORT, which breaks Bluetooth on wl18xx
./scripts/config --disable CONFIG_SERIAL_SC16IS7XX_CORE
./scripts/config --disable CONFIG_SERIAL_SC16IS7XX
./scripts/config --disable CONFIG_SERIAL_SC16IS7XX_I2C
./scripts/config --disable CONFIG_SERIAL_SC16IS7XX_SPI
./scripts/config --enable CONFIG_SERIAL_DEV_CTRL_TTYPORT

#WIMAX going to be removed soon...
./scripts/config --disable CONFIG_WIMAX
./scripts/config --disable CONFIG_WIMAX_I2400M
./scripts/config --disable CONFIG_WIMAX_I2400M_USB

#Docker.io:
./scripts/config --enable CONFIG_CGROUP_HUGETLB
./scripts/config --enable CONFIG_RT_GROUP_SCHED

#PHY: CONFIG_DP83867_PHY
./scripts/config --enable CONFIG_DP83867_PHY

#2022.03.01 fix W1, needs to be a module now...
./scripts/config --enable CONFIG_W1
./scripts/config --module CONFIG_W1_MASTER_GPIO
./scripts/config --module CONFIG_W1_SLAVE_DS2430
./scripts/config --enable CONFIG_W1_SLAVE_DS2433_CRC

./scripts/config --disable CONFIG_MODULE_COMPRESS_ZSTD
./scripts/config --enable CONFIG_MODULE_COMPRESS_XZ
./scripts/config --enable CONFIG_GPIO_AGGREGATOR

#configure CONFIG_EXTRA_FIRMWARE
./scripts/config --set-str CONFIG_EXTRA_FIRMWARE "regulatory.db regulatory.db.p7s am335x-pm-firmware.elf am335x-bone-scale-data.bin am335x-evm-scale-data.bin am43x-evm-scale-data.bin"

cd ${DIR}/

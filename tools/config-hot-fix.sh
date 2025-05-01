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

#SC16IS7XX breaks SERIAL_DEV_CTRL_TTYPORT, which breaks Bluetooth on wl18xx
./scripts/config --disable CONFIG_SERIAL_SC16IS7XX_CORE
./scripts/config --disable CONFIG_SERIAL_SC16IS7XX
./scripts/config --disable CONFIG_SERIAL_SC16IS7XX_I2C
./scripts/config --disable CONFIG_SERIAL_SC16IS7XX_SPI
./scripts/config --enable CONFIG_SERIAL_DEV_CTRL_TTYPORT

#PHY: CONFIG_DP83867_PHY
./scripts/config --enable CONFIG_DP83867_PHY

#PRU: CONFIG_PRU_REMOTEPROC
./scripts/config --enable CONFIG_REMOTEPROC
./scripts/config --enable CONFIG_REMOTEPROC_CDEV
./scripts/config --enable CONFIG_WKUP_M3_RPROC
./scripts/config --module CONFIG_PRU_REMOTEPROC

#Docker.io
./scripts/config --enable CONFIG_NETFILTER_XT_MATCH_IPVS
./scripts/config --enable CONFIG_CGROUP_BPF
./scripts/config --enable CONFIG_BLK_DEV_THROTTLING
./scripts/config --enable CONFIG_NET_CLS_CGROUP
./scripts/config --enable CONFIG_CGROUP_NET_PRIO
./scripts/config --enable CONFIG_IP_NF_TARGET_REDIRECT
./scripts/config --enable CONFIG_IP_VS
./scripts/config --enable CONFIG_IP_VS_NFCT
./scripts/config --enable CONFIG_IP_VS_PROTO_TCP
./scripts/config --enable CONFIG_IP_VS_PROTO_UDP
./scripts/config --enable CONFIG_IP_VS_RR
./scripts/config --enable CONFIG_SECURITY_SELINUX
./scripts/config --enable CONFIG_SECURITY_APPARMOR
./scripts/config --enable CONFIG_VXLAN
./scripts/config --enable CONFIG_IPVLAN
./scripts/config --enable CONFIG_DUMMY
./scripts/config --enable CONFIG_NF_NAT_FTP
./scripts/config --enable CONFIG_NF_CONNTRACK_FTP
./scripts/config --enable CONFIG_NF_NAT_TFTP
./scripts/config --enable CONFIG_NF_CONNTRACK_TFTP
./scripts/config --enable CONFIG_DM_THIN_PROVISIONING

#abi="5.13.0-trunk"
#kernel="5.13.9-1~exp2"
./scripts/config --enable CONFIG_BPF_UNPRIV_DEFAULT_OFF
./scripts/config --enable CONFIG_CGROUP_MISC
./scripts/config --enable CONFIG_RESET_ATTACK_MITIGATION

#LIBCOMPOSITE built-in finally works... ;)
./scripts/config --enable CONFIG_USB_LIBCOMPOSITE
./scripts/config --enable CONFIG_USB_F_ACM
./scripts/config --enable CONFIG_USB_F_SS_LB
./scripts/config --enable CONFIG_USB_U_SERIAL
./scripts/config --enable CONFIG_USB_U_ETHER
./scripts/config --enable CONFIG_USB_U_AUDIO
./scripts/config --enable CONFIG_USB_F_SERIAL
./scripts/config --enable CONFIG_USB_F_OBEX
./scripts/config --enable CONFIG_USB_F_NCM
./scripts/config --enable CONFIG_USB_F_ECM
./scripts/config --module CONFIG_USB_F_PHONET
./scripts/config --enable CONFIG_USB_F_EEM
./scripts/config --enable CONFIG_USB_F_SUBSET
./scripts/config --enable CONFIG_USB_F_RNDIS
./scripts/config --enable CONFIG_USB_F_MASS_STORAGE
./scripts/config --enable CONFIG_USB_F_FS
./scripts/config --enable CONFIG_USB_F_UAC1
./scripts/config --enable CONFIG_USB_F_UAC2
./scripts/config --module CONFIG_USB_F_UVC
./scripts/config --enable CONFIG_USB_F_MIDI
./scripts/config --enable CONFIG_USB_F_HID
./scripts/config --enable CONFIG_USB_F_PRINTER
./scripts/config --module CONFIG_USB_F_TCM
./scripts/config --enable CONFIG_USB_CONFIGFS
./scripts/config --enable CONFIG_USB_CONFIGFS_SERIAL
./scripts/config --enable CONFIG_USB_CONFIGFS_ACM
./scripts/config --enable CONFIG_USB_CONFIGFS_OBEX
./scripts/config --enable CONFIG_USB_CONFIGFS_NCM
./scripts/config --enable CONFIG_USB_CONFIGFS_ECM
./scripts/config --enable CONFIG_USB_CONFIGFS_ECM_SUBSET
./scripts/config --enable CONFIG_USB_CONFIGFS_RNDIS
./scripts/config --enable CONFIG_USB_CONFIGFS_EEM
./scripts/config --enable CONFIG_USB_CONFIGFS_PHONET
./scripts/config --enable CONFIG_USB_CONFIGFS_MASS_STORAGE
./scripts/config --enable CONFIG_USB_CONFIGFS_F_LB_SS
./scripts/config --enable CONFIG_USB_CONFIGFS_F_FS
./scripts/config --enable CONFIG_USB_CONFIGFS_F_UAC1
./scripts/config --enable CONFIG_USB_CONFIGFS_F_UAC2
./scripts/config --enable CONFIG_USB_CONFIGFS_F_MIDI
./scripts/config --enable CONFIG_USB_CONFIGFS_F_HID
./scripts/config --enable CONFIG_USB_CONFIGFS_F_UVC
./scripts/config --enable CONFIG_USB_CONFIGFS_F_PRINTER

#2022.03.01 fix W1, needs to be a module now...
./scripts/config --enable CONFIG_W1
./scripts/config --module CONFIG_W1_MASTER_GPIO
./scripts/config --module CONFIG_W1_SLAVE_DS2430
./scripts/config --enable CONFIG_W1_SLAVE_DS2433_CRC

./scripts/config --disable CONFIG_MODULE_COMPRESS_ZSTD
./scripts/config --enable CONFIG_MODULE_COMPRESS_XZ
./scripts/config --enable CONFIG_GPIO_AGGREGATOR

#debian 6.12~rc6-1~exp1
./scripts/config --enable CONFIG_ZONE_DEVICE
./scripts/config --module CONFIG_IP_VS_TWOS
./scripts/config --module CONFIG_VIDEO_OV5648
./scripts/config --enable CONFIG_DRM_DISPLAY_DP_AUX_CHARDEV
./scripts/config --module CONFIG_TI_PRUSS

#debian 6.12.6-1
./scripts/config --enable CONFIG_ZRAM_BACKEND_LZ4
./scripts/config --enable CONFIG_ZRAM_BACKEND_LZ4HC
./scripts/config --enable CONFIG_ZRAM_BACKEND_ZSTD
./scripts/config --enable CONFIG_ZRAM_BACKEND_DEFLATE
./scripts/config --enable CONFIG_ZRAM_DEF_COMP_LZ4
./scripts/config --set-str CONFIG_ZRAM_DEF_COMP "lz4"

#configure CONFIG_EXTRA_FIRMWARE
./scripts/config --set-str CONFIG_EXTRA_FIRMWARE "regulatory.db regulatory.db.p7s am335x-pm-firmware.elf am335x-bone-scale-data.bin am335x-evm-scale-data.bin am43x-evm-scale-data.bin"
./scripts/config --enable CONFIG_FW_LOADER_COMPRESS
./scripts/config --enable CONFIG_FW_LOADER_COMPRESS_XZ
./scripts/config --enable CONFIG_FW_LOADER_COMPRESS_ZSTD

cd ${DIR}/

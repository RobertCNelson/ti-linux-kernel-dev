#!/bin/sh -e

DIR=$PWD

config_enable () {
	ret=$(./scripts/config --state ${config})
	if [ ! "x${ret}" = "xy" ] ; then
		echo "Setting: ${config}=y"
		./scripts/config --enable ${config}
	fi
}

config_disable () {
	ret=$(./scripts/config --state ${config})
	if [ ! "x${ret}" = "xn" ] ; then
		echo "Setting: ${config}=n"
		./scripts/config --disable ${config}
	fi
}

config_enable_special () {
	test_module=$(cat .config | grep ${config} || true)
	if [ "x${test_module}" = "x# ${config} is not set" ] ; then
		echo "Setting: ${config}=y"
		sed -i -e 's:# '$config' is not set:'$config'=y:g' .config
	fi
	if [ "x${test_module}" = "x${config}=m" ] ; then
		echo "Setting: ${config}=y"
		sed -i -e 's:'$config'=m:'$config'=y:g' .config
	fi
}

config_module_special () {
	test_module=$(cat .config | grep ${config} || true)
	if [ "x${test_module}" = "x# ${config} is not set" ] ; then
		echo "Setting: ${config}=m"
		sed -i -e 's:# '$config' is not set:'$config'=m:g' .config
	else
		echo "$config=m" >> .config
	fi
}

config_module () {
	ret=$(./scripts/config --state ${config})
	if [ ! "x${ret}" = "xm" ] ; then
		echo "Setting: ${config}=m"
		./scripts/config --module ${config}
	fi
}

config_string () {
	ret=$(./scripts/config --state ${config})
	if [ ! "x${ret}" = "x${option}" ] ; then
		echo "Setting: ${config}=\"${option}\""
		./scripts/config --set-str ${config} "${option}"
	fi
}

config_value () {
	ret=$(./scripts/config --state ${config})
	if [ ! "x${ret}" = "x${option}" ] ; then
		echo "Setting: ${config}=${option}"
		./scripts/config --set-val ${config} ${option}
	fi
}

cd ${DIR}/KERNEL/

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
config="CONFIG_BPF_UNPRIV_DEFAULT_OFF" ; config_enable
config="CONFIG_CGROUP_MISC" ; config_enable
config="CONFIG_RESET_ATTACK_MITIGATION" ; config_enable

#LIBCOMPOSITE built-in finally works... ;)
config="CONFIG_USB_LIBCOMPOSITE" ; config_enable
config="CONFIG_USB_F_ACM" ; config_enable
config="CONFIG_USB_F_SS_LB" ; config_enable
config="CONFIG_USB_U_SERIAL" ; config_enable
config="CONFIG_USB_U_ETHER" ; config_enable
config="CONFIG_USB_U_AUDIO" ; config_enable
config="CONFIG_USB_F_SERIAL" ; config_enable
config="CONFIG_USB_F_OBEX" ; config_enable
config="CONFIG_USB_F_NCM" ; config_enable
config="CONFIG_USB_F_ECM" ; config_enable
config="CONFIG_USB_F_PHONET" ; config_module
config="CONFIG_USB_F_EEM" ; config_enable
config="CONFIG_USB_F_SUBSET" ; config_enable
config="CONFIG_USB_F_RNDIS" ; config_enable
config="CONFIG_USB_F_MASS_STORAGE" ; config_enable
config="CONFIG_USB_F_FS" ; config_enable
config="CONFIG_USB_F_UAC1" ; config_enable
config="CONFIG_USB_F_UAC2" ; config_enable
config="CONFIG_USB_F_UVC" ; config_module
config="CONFIG_USB_F_MIDI" ; config_enable
config="CONFIG_USB_F_HID" ; config_enable
config="CONFIG_USB_F_PRINTER" ; config_enable
config="CONFIG_USB_F_TCM" ; config_module
config="CONFIG_USB_CONFIGFS" ; config_enable
config="CONFIG_USB_CONFIGFS_SERIAL" ; config_enable
config="CONFIG_USB_CONFIGFS_ACM" ; config_enable
config="CONFIG_USB_CONFIGFS_OBEX" ; config_enable
config="CONFIG_USB_CONFIGFS_NCM" ; config_enable
config="CONFIG_USB_CONFIGFS_ECM" ; config_enable
config="CONFIG_USB_CONFIGFS_ECM_SUBSET" ; config_enable
config="CONFIG_USB_CONFIGFS_RNDIS" ; config_enable
config="CONFIG_USB_CONFIGFS_EEM" ; config_enable
config="CONFIG_USB_CONFIGFS_PHONET" ; config_enable
config="CONFIG_USB_CONFIGFS_MASS_STORAGE" ; config_enable
config="CONFIG_USB_CONFIGFS_F_LB_SS" ; config_enable
config="CONFIG_USB_CONFIGFS_F_FS" ; config_enable
config="CONFIG_USB_CONFIGFS_F_UAC1" ; config_enable
config="CONFIG_USB_CONFIGFS_F_UAC2" ; config_enable
config="CONFIG_USB_CONFIGFS_F_MIDI" ; config_enable
config="CONFIG_USB_CONFIGFS_F_HID" ; config_enable
config="CONFIG_USB_CONFIGFS_F_UVC" ; config_enable
config="CONFIG_USB_CONFIGFS_F_PRINTER" ; config_enable

# Extras
config="CONFIG_VIDEO_OV5647" ; config_module
config="CONFIG_LED_TRIGGER_PHY" ; config_enable
config="CONFIG_USB_LEDS_TRIGGER_USBPORT" ; config_module
config="CONFIG_LEDS_TRIGGER_TRANSIENT" ; config_module
config="CONFIG_LEDS_TRIGGER_CAMERA" ; config_module
config="CONFIG_LEDS_TRIGGER_NETDEV" ; config_module
config="CONFIG_LEDS_TRIGGER_PATTERN" ; config_module
config="CONFIG_LEDS_TRIGGER_AUDIO" ; config_module

#PRU
config="CONFIG_UIO_PDRV_GENIRQ" ; config_module

# We recommend to turn off Real-Time group scheduling in the
# kernel when using systemd. RT group scheduling effectively
# makes RT scheduling unavailable for most userspace, since it
# requires explicit assignment of RT budgets to each unit whose
# processes making use of RT. As there's no sensible way to
# assign these budgets automatically this cannot really be
# fixed, and it's best to disable group scheduling hence.
./scripts/config --disable CONFIG_RT_GROUP_SCHED

#iwd
./scripts/config --enable CONFIG_CRYPTO_USER_API_SKCIPHER
./scripts/config --enable CONFIG_CRYPTO_USER_API_HASH
./scripts/config --enable CONFIG_CRYPTO_HMAC
./scripts/config --enable CONFIG_CRYPTO_CMAC
./scripts/config --enable CONFIG_CRYPTO_MD4
./scripts/config --enable CONFIG_CRYPTO_MD5
./scripts/config --enable CONFIG_CRYPTO_SHA256
./scripts/config --enable CONFIG_CRYPTO_SHA512
./scripts/config --enable CONFIG_CRYPTO_AES
./scripts/config --enable CONFIG_CRYPTO_ECB
./scripts/config --enable CONFIG_CRYPTO_DES
./scripts/config --enable CONFIG_CRYPTO_CBC
./scripts/config --enable CONFIG_KEY_DH_OPERATIONS

#WiFi, removed in 6.7-rc1
./scripts/config --disable CONFIG_WLAN_VENDOR_CISCO
./scripts/config --disable CONFIG_HOSTAP
./scripts/config --disable CONFIG_HERMES
./scripts/config --disable CONFIG_USB_ZD1201
./scripts/config --disable CONFIG_RTL8192U

#removed in 6.7-rc1
./scripts/config --disable CONFIG_DEV_APPLETALK

#TI delta 09.01.00.004:
./scripts/config --enable CONFIG_APERTURE_HELPERS
./scripts/config --enable CONFIG_FB_CFB_FILLRECT
./scripts/config --enable CONFIG_FB_CFB_COPYAREA
./scripts/config --enable CONFIG_FB_CFB_IMAGEBLIT
./scripts/config --enable CONFIG_FB_SIMPLE
./scripts/config --module CONFIG_TI_EQEP

#TI delta 09.01.00.005:
./scripts/config --enable CONFIG_TI_SYSC
./scripts/config --module CONFIG_TI_CPSW_PROXY_CLIENT

#TI delta 09.01.00.006:
./scripts/config --disable CONFIG_PCIE_ALTERA
./scripts/config --disable CONFIG_PCIE_ALTERA_MSI
./scripts/config --disable CONFIG_PCI_HOST_THUNDER_PEM
./scripts/config --disable CONFIG_PCI_HOST_THUNDER_ECAM
./scripts/config --disable CONFIG_MTD_NAND_DENALI
./scripts/config --disable CONFIG_MTD_NAND_DENALI_DT
./scripts/config --disable CONFIG_SCSI_HISI_SAS
./scripts/config --disable CONFIG_AHCI_CEVA
./scripts/config --disable CONFIG_ROCKCHIP_PHY
./scripts/config --disable CONFIG_CAN_FLEXCAN
./scripts/config --disable CONFIG_HW_RANDOM_ARM_SMCCC_TRNG
./scripts/config --disable CONFIG_HW_RANDOM_CN10K
./scripts/config --disable CONFIG_SPI_PL022
./scripts/config --disable CONFIG_GPIO_DWAPB
./scripts/config --disable CONFIG_GPIO_PL061
./scripts/config --disable CONFIG_ARM_SP805_WATCHDOG
./scripts/config --disable CONFIG_ARM_SBSA_WATCHDOG
./scripts/config --disable CONFIG_DW_WATCHDOG
./scripts/config --disable CONFIG_MFD_SEC_CORE

./scripts/config --module CONFIG_REGULATOR_RASPBERRYPI_TOUCHSCREEN_ATTINY

./scripts/config --disable CONFIG_MMC_ARMMMCI
./scripts/config --disable CONFIG_MMC_SDHCI_CADENCE
./scripts/config --disable CONFIG_MMC_SDHCI_F_SDH30
./scripts/config --disable CONFIG_MMC_SDHCI_XENON
./scripts/config --disable CONFIG_RTC_DRV_PL031
./scripts/config --disable CONFIG_FSL_EDMA
./scripts/config --disable CONFIG_MV_XOR_V2
./scripts/config --disable CONFIG_PL330_DMA
./scripts/config --disable CONFIG_QCOM_HIDMA_MGMT
./scripts/config --disable CONFIG_QCOM_HIDMA

#TI delta 09.01.00.007:
./scripts/config --disable CONFIG_SCHED_AUTOGROUP
./scripts/config --disable CONFIG_CRASH_DUMP
./scripts/config --disable CONFIG_RODATA_FULL_DEFAULT_ENABLED
./scripts/config --disable CONFIG_RANDOMIZE_KSTACK_OFFSET
./scripts/config --disable CONFIG_ARM64_SVE
./scripts/config --disable CONFIG_PROC_VMCORE

#TI delta 09.01.00.008:
./scripts/config --disable CONFIG_AMPERE_ERRATUM_AC03_CPU_38
./scripts/config --disable CONFIG_ARM64_ERRATUM_832075
./scripts/config --disable CONFIG_ARM64_ERRATUM_1024718
./scripts/config --disable CONFIG_ARM64_ERRATUM_1418040
./scripts/config --disable CONFIG_ARM64_ERRATUM_1165522
./scripts/config --disable CONFIG_ARM64_ERRATUM_1530923
./scripts/config --disable CONFIG_ARM64_ERRATUM_2441007
./scripts/config --disable CONFIG_ARM64_ERRATUM_1286807
./scripts/config --disable CONFIG_ARM64_ERRATUM_1463225
./scripts/config --disable CONFIG_ARM64_ERRATUM_1542419
./scripts/config --disable CONFIG_ARM64_ERRATUM_1508412
./scripts/config --disable CONFIG_ARM64_ERRATUM_2051678
./scripts/config --disable CONFIG_ARM64_ERRATUM_2077057
./scripts/config --disable CONFIG_ARM64_ERRATUM_2658417
./scripts/config --disable CONFIG_ARM64_ERRATUM_2054223
./scripts/config --disable CONFIG_ARM64_ERRATUM_2067961
./scripts/config --disable CONFIG_ARM64_ERRATUM_2441009
./scripts/config --disable CONFIG_CAVIUM_TX2_ERRATUM_219
./scripts/config --disable CONFIG_FUJITSU_ERRATUM_010001

./scripts/config  --enable CONFIG_USB_CDNS_SUPPORT
./scripts/config  --enable CONFIG_USB_CDNS3
./scripts/config  --enable CONFIG_USB_CDNS3_TI
./scripts/config  --enable CONFIG_USB_ONBOARD_HUB

./scripts/config --module CONFIG_VIDEO_WAVE_VPU
./scripts/config --module CONFIG_VIDEO_CADENCE_CSI2RX
./scripts/config --module CONFIG_VIDEO_TI_J721E_CSI2RX
./scripts/config --module CONFIG_PHY_CADENCE_DPHY_RX
./scripts/config --module CONFIG_VIDEO_CADENCE_CSI2TX
./scripts/config --module CONFIG_VIDEO_OV2312
./scripts/config --module CONFIG_VIDEO_OV5640
./scripts/config --module CONFIG_VIDEO_OV5645
./scripts/config --module CONFIG_VIDEO_IMX219
./scripts/config --module CONFIG_VIDEO_IMX390
./scripts/config --module CONFIG_VIDEO_OX05B1S

#enable MIKROBUS
./scripts/config --enable CONFIG_SPI_OMAP24XX
./scripts/config --enable CONFIG_W1
./scripts/config --enable CONFIG_MIKROBUS

#20240305: regression on discord, some systemd can no longer load *.xz modules...
./scripts/config --disable CONFIG_MODULE_DECOMPRESS

#enable CONFIG_DYNAMIC_FTRACE
./scripts/config --enable CONFIG_FUNCTION_TRACER
./scripts/config --enable CONFIG_DYNAMIC_FTRACE

./scripts/config --disable CONFIG_MODULE_COMPRESS_GZIP
./scripts/config --enable CONFIG_MODULE_COMPRESS_XZ
./scripts/config --disable CONFIG_MODULE_COMPRESS_ZSTD
./scripts/config --enable CONFIG_GPIO_AGGREGATOR
./scripts/config --module CONFIG_PWM_GPIO

#cc33xx ble
./scripts/config --disable CONFIG_BT_BNEP
./scripts/config --disable CONFIG_BT_HCIBTSDIO
./scripts/config --disable CONFIG_BT_TI

#Gone on Mainline, supporting 32bit only...
./scripts/config --disable CONFIG_UIO
./scripts/config --disable CONFIG_UIO_PRUSS

./scripts/config --module CONFIG_CC33XX
./scripts/config --module CONFIG_CC33XX_SDIO

./scripts/config --module CONFIG_VIDEO_IMG_VXD_DEC
./scripts/config --module CONFIG_VIDEO_IMG_VXE_ENC
./scripts/config --module CONFIG_VIDEO_E5010_JPEG_ENC
./scripts/config --module CONFIG_TI_EQEP
./scripts/config --enable CONFIG_CRYPTO_DEV_TI_MCRC64

#PCI Express Precision Time Measurement support
./scripts/config --enable CONFIG_PCIE_PTM

./scripts/config --module CONFIG_RPMSG
./scripts/config --module CONFIG_RPMSG_NS
./scripts/config --module CONFIG_RPMSG_VIRTIO

#Google Coral Gasket
./scripts/config --module CONFIG_STAGING_GASKET_FRAMEWORK
./scripts/config --module CONFIG_STAGING_APEX_DRIVER

#TI: 10.00.04
./scripts/config --enable CONFIG_FB_SIMPLE
./scripts/config --module CONFIG_RPMSG_PRU

#TI: 10.00.06
./scripts/config --disable CONFIG_CPU_FREQ_DEFAULT_GOV_SCHEDUTIL
./scripts/config --enable CONFIG_CPU_FREQ_DEFAULT_GOV_PERFORMANCE
./scripts/config --disable CONFIG_MTD_SPI_NOR_USE_4K_SECTORS

#TI: 10.01.01
./scripts/config --module CONFIG_OMAP2PLUS_MBOX

#new in v6.12.x
./scripts/config --enable CONFIG_PREEMPT_RT
./scripts/config --enable CONFIG_RPMB
./scripts/config --enable CONFIG_DRM_PANIC
./scripts/config --module CONFIG_TI_K3_M4_REMOTEPROC
./scripts/config --module CONFIG_ADXL380_SPI
./scripts/config --module CONFIG_ADXL380_I2C
./scripts/config --module CONFIG_AD4000
./scripts/config --module CONFIG_AD4695
./scripts/config --module CONFIG_PAC1921
./scripts/config --module CONFIG_LTC2664
./scripts/config --module CONFIG_ENS210
./scripts/config --module CONFIG_BH1745
./scripts/config --module CONFIG_SDP500
./scripts/config --module CONFIG_HX9023S
./scripts/config --module CONFIG_AW96103

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
./scripts/config --set-str CONFIG_EXTRA_FIRMWARE "regulatory.db regulatory.db.p7s cadence/mhdp8546.bin"
./scripts/config --enable CONFIG_FW_LOADER_COMPRESS
./scripts/config --enable CONFIG_FW_LOADER_COMPRESS_XZ
./scripts/config --enable CONFIG_FW_LOADER_COMPRESS_ZSTD

#BeagleBoard.org
./scripts/config --enable CONFIG_MSPM0_I2C

cd ${DIR}/

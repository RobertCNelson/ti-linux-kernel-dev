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
config="CONFIG_NETFILTER_XT_MATCH_IPVS"; config_enable
config="CONFIG_CGROUP_BPF"; config_enable

config="CONFIG_BLK_DEV_THROTTLING"; config_enable
config="CONFIG_NET_CLS_CGROUP"; config_enable
config="CONFIG_CGROUP_NET_PRIO"; config_enable
config="CONFIG_IP_NF_TARGET_REDIRECT"; config_enable
config="CONFIG_IP_VS"; config_enable
config="CONFIG_IP_VS_NFCT"; config_enable
config="CONFIG_IP_VS_PROTO_TCP"; config_enable
config="CONFIG_IP_VS_PROTO_UDP"; config_enable
config="CONFIG_IP_VS_RR"; config_enable
config="CONFIG_SECURITY_SELINUX"; config_enable
config="CONFIG_SECURITY_APPARMOR"; config_enable
config="CONFIG_VXLAN"; config_enable
config="CONFIG_IPVLAN"; config_enable
config="CONFIG_DUMMY"; config_enable
config="CONFIG_NF_NAT_FTP"; config_enable
config="CONFIG_NF_CONNTRACK_FTP"; config_enable
config="CONFIG_NF_NAT_TFTP"; config_enable
config="CONFIG_NF_CONNTRACK_TFTP"; config_enable
config="CONFIG_DM_THIN_PROVISIONING"; config_enable

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
./scripts/config --disable CONFIG_CRASH_DUMP
./scripts/config --disable CONFIG_ARM64_SVE
./scripts/config --disable CONFIG_PROC_VMCORE

cd ${DIR}/

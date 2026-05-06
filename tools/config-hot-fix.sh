#!/bin/sh -e

# SPDX-FileCopyrightText: Robert Nelson <robertcnelson@gmail.com>
#
# SPDX-License-Identifier: MIT

DIR=$PWD

cd ${DIR}/KERNEL/

./scripts/config --module CONFIG_INPUT_TPS65219_PWRBUTTON

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

# Extras
./scripts/config --module CONFIG_VIDEO_OV5647
./scripts/config --enable CONFIG_LED_TRIGGER_PHY
./scripts/config --module CONFIG_USB_LEDS_TRIGGER_USBPORT
./scripts/config --module CONFIG_LEDS_TRIGGER_TRANSIENT
./scripts/config --module CONFIG_LEDS_TRIGGER_CAMERA
./scripts/config --module CONFIG_LEDS_TRIGGER_NETDEV
./scripts/config --module CONFIG_LEDS_TRIGGER_PATTERN
./scripts/config --module CONFIG_LEDS_TRIGGER_AUDIO

#PRU
./scripts/config --module CONFIG_UIO_PDRV_GENIRQ

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
./scripts/config --module CONFIG_VIDEO_IMX708
./scripts/config --module CONFIG_VIDEO_OX05B1S

#enable SPI/W1
./scripts/config --enable CONFIG_SPI_OMAP24XX
./scripts/config --enable CONFIG_W1
./scripts/config --enable CONFIG_MIKROBUS

#20240305: regression on discord, some systemd can no longer load *.xz modules...
./scripts/config --disable CONFIG_MODULE_DECOMPRESS

#enable CONFIG_DYNAMIC_FTRACE
./scripts/config --enable CONFIG_FUNCTION_TRACER
./scripts/config --enable CONFIG_DYNAMIC_FTRACE

./scripts/config --enable CONFIG_MODULE_COMPRESS
./scripts/config --disable CONFIG_MODULE_COMPRESS_GZIP
./scripts/config --enable CONFIG_MODULE_COMPRESS_XZ
./scripts/config --disable CONFIG_MODULE_COMPRESS_ZSTD
./scripts/config --enable CONFIG_MODULE_COMPRESS_ALL
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

#REMOTEPROC
./scripts/config --module CONFIG_RPMSG
./scripts/config --module CONFIG_RPMSG_NS
./scripts/config --module CONFIG_RPMSG_PRU
./scripts/config --enable CONFIG_RPMSG_VIRTIO
./scripts/config --module CONFIG_TI_K3_DSP_REMOTEPROC
./scripts/config --module CONFIG_TI_K3_M4_REMOTEPROC
./scripts/config --module CONFIG_TI_K3_R5_REMOTEPROC

#Google Coral Gasket
./scripts/config --module CONFIG_STAGING_GASKET_FRAMEWORK
./scripts/config --module CONFIG_STAGING_APEX_DRIVER

#DRM_PANIC
./scripts/config --enable CONFIG_DRM_PANIC
#Broken in building with debian 13 with v6.12.x-ti
./scripts/config --disable CONFIG_DRM_PANIC_SCREEN_QR_CODE

#TI: 10.00.06
./scripts/config --disable CONFIG_CPU_FREQ_DEFAULT_GOV_SCHEDUTIL
./scripts/config --enable CONFIG_CPU_FREQ_DEFAULT_GOV_PERFORMANCE
./scripts/config --disable CONFIG_MTD_SPI_NOR_USE_4K_SECTORS

#TI: 10.01.01
./scripts/config --module CONFIG_OMAP2PLUS_MBOX

#new in v6.12.x
./scripts/config --enable CONFIG_PREEMPT_RT
./scripts/config --enable CONFIG_RPMB
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

#debian 6.12.16-1
./scripts/config --enable CONFIG_RCU_LAZY
./scripts/config --module CONFIG_NSM
./scripts/config --module CONFIG_NITRO_ENCLAVES
./scripts/config --module CONFIG_USB_MASS_STORAGE

#debian 6.12.20-1
./scripts/config --module CONFIG_VIDEO_OV5675
./scripts/config --enable CONFIG_RPCSEC_GSS_KRB5_ENCTYPES_AES_SHA2

#debian 6.13.5-1
./scripts/config --enable CONFIG_UDMABUF

#debian 6.13.7-1
./scripts/config --module CONFIG_VIRTIO_IOMMU
./scripts/config --enable CONFIG_CRYPTO_ECDSA

#debian 6.13.8-1
./scripts/config --enable CONFIG_NVME_TARGET_PASSTHRU
./scripts/config --module CONFIG_NVME_TARGET_LOOP
./scripts/config --module CONFIG_NVME_TARGET_FCLOOP

#debian 6.13.11-1
./scripts/config --enable CONFIG_KALLSYMS_ALL

#new in v6.14
./scripts/config --module CONFIG_NTSYNC
./scripts/config --module CONFIG_PPS_GENERATOR
./scripts/config --module CONFIG_SENSORS_CRPS
./scripts/config --module CONFIG_SENSORS_TPS25990
./scripts/config --module CONFIG_BD79703
./scripts/config --module CONFIG_OPT4060
./scripts/config --enable CONFIG_FPROBE

#TI: 11.00.01
./scripts/config --enable CONFIG_SRAM_DMA_HEAP
./scripts/config --module CONFIG_CC33XX
./scripts/config --module CONFIG_CC33XX_SDIO
./scripts/config --module CONFIG_VIDEO_IMX390
./scripts/config --enable CONFIG_DMABUF_HEAPS
./scripts/config --enable CONFIG_DMABUF_HEAPS_SYSTEM
./scripts/config --enable CONFIG_DMABUF_HEAPS_CMA
./scripts/config --enable CONFIG_DMABUF_HEAPS_CARVEOUT

#TI: 11.00.02
./scripts/config --module CONFIG_REGULATOR_RASPBERRYPI_TOUCHSCREEN_ATTINY
./scripts/config --module CONFIG_DRM_TOSHIBA_TC358762
#./scripts/config --module CONFIG_DRM_CDNS_DSI
#./scripts/config --module CONFIG_DRM_CDNS_DSI_J721E
#./scripts/config --module CONFIG_HWSPINLOCK_OMAP
#./scripts/config --module CONFIG_PWM_OMAP_DMTIMER
#./scripts/config --module CONFIG_PHY_CADENCE_DPHY
./scripts/config --module CONFIG_TI_ECAP_CAPTURE

#TI: 11.00.04
./scripts/config --enable CONFIG_MTD_SPI_NAND
./scripts/config --enable CONFIG_MTD_UBI
./scripts/config --enable CONFIG_TI_K3_UDMA_AM62L
./scripts/config --enable CONFIG_UBIFS_FS
./scripts/config --enable CONFIG_CRYPTO_ZSTD
./scripts/config --enable CONFIG_ZSTD_COMPRESS

#TI: 11.00.06
./scripts/config --module CONFIG_CRYPTO_CRC64_ISO3309
./scripts/config --enable CONFIG_CRYPTO_USER_API_HASH
./scripts/config --enable CONFIG_CRYPTO_DEV_TI_MCRC64
./scripts/config --enable CONFIG_CRYPTO_DEV_TI_DTHEV2
./scripts/config --module CONFIG_TOUCHSCREEN_ILI210X

#TI: 11.00.07
./scripts/config --module CONFIG_SERIAL_8250_PRUSS
./scripts/config --module CONFIG_VIDEO_IMX728
./scripts/config --module CONFIG_VIDEO_OV2312

#TI: 11.00.08
./scripts/config --module CONFIG_VIDEO_OX05B1S

#new in v6.15
./scripts/config --module CONFIG_FWCTL
./scripts/config --module CONFIG_IWLMLD
./scripts/config --module CONFIG_RTW88_8814AU
./scripts/config --module CONFIG_RTW88_8814AE
./scripts/config --module CONFIG_SPI_OFFLOAD_TRIGGER_PWM
./scripts/config --module CONFIG_SENSORS_HTU31
./scripts/config --module CONFIG_SENSORS_INA233
./scripts/config --module CONFIG_HID_UNIVERSAL_PIDFF
./scripts/config --module CONFIG_AD4030
./scripts/config --module CONFIG_AD4851
./scripts/config --module CONFIG_AD7191
./scripts/config --module CONFIG_TI_ADS7138
./scripts/config --module CONFIG_ADIS16550
./scripts/config --module CONFIG_AL3000A
./scripts/config --module CONFIG_APDS9160
./scripts/config --module CONFIG_SI7210

#configure CONFIG_EXTRA_FIRMWARE
./scripts/config --set-str CONFIG_EXTRA_FIRMWARE "regulatory.db regulatory.db.p7s cadence/mhdp8546.bin"
./scripts/config --enable CONFIG_FW_LOADER_COMPRESS
./scripts/config --enable CONFIG_FW_LOADER_COMPRESS_XZ
./scripts/config --enable CONFIG_FW_LOADER_COMPRESS_ZSTD

#BeagleBoard.org
./scripts/config --enable CONFIG_MSPM0_I2C
./scripts/config --module CONFIG_SEG_LED_GPIO
./scripts/config --module CONFIG_INPUT_PWM_BEEPER
./scripts/config --module CONFIG_SND_SOC_TLV320AIC3X_I2C
./scripts/config --module CONFIG_WIZNET_W5100
./scripts/config --module CONFIG_WIZNET_W5100_SPI

#Regressions:
./scripts/config --enable CONFIG_MMC_BLOCK

#PCIE
./scripts/config --enable CONFIG_PCI_ENDPOINT
./scripts/config --enable CONFIG_PCI_ENDPOINT_CONFIGFS
./scripts/config --enable CONFIG_PCIE_CADENCE_EP
./scripts/config --enable CONFIG_PCI_J721E_EP
./scripts/config --module CONFIG_PCI_EPF_TEST
./scripts/config --module CONFIG_PCI_EPF_NTB
./scripts/config --module CONFIG_PCI_EPF_VNTB
./scripts/config --module CONFIG_PCI_ENDPOINT_TEST

#Rust
./scripts/config --disable CONFIG_MODVERSIONS
./scripts/config --disable CONFIG_RUST

#v7.1-rc1

./scripts/config --disable CONFIG_ATM_CLIP
./scripts/config --disable CONFIG_ATM_LANE

./scripts/config --disable CONFIG_HAMRADIO

./scripts/config --disable CONFIG_CAIF

./scripts/config --disable CONFIG_ATM_DUMMY
./scripts/config --disable CONFIG_ATM_NICSTAR
./scripts/config --disable CONFIG_ATM_IA
./scripts/config --disable CONFIG_ATM_FORE200E

./scripts/config --disable CONFIG_NET_VENDOR_ALTEON

./scripts/config --disable CONFIG_ISDN

cd ${DIR}/
